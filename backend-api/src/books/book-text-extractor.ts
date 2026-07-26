import { readFileSync } from 'fs';
import { join, resolve, sep } from 'path';
import AdmZip from 'adm-zip';
import { PDFParse } from 'pdf-parse';

// Sane ceiling so one huge upload can't produce a multi-hundred-MB text
// column — the Nnanga context builder only ever needs short excerpts around
// a keyword match, not the whole book at once (see KnowledgeService).
const MAX_EXTRACTED_CHARS = 2_000_000;

// PDF/EPUB text layers occasionally carry stray control characters (NUL from
// malformed content streams, form-feed, etc.) — Postgres's UTF8 text columns
// reject 0x00 outright ("invalid byte sequence"), so every extractor path
// funnels through this before the text is allowed near the database.
function sanitizeForStorage(text: string): string {
  // eslint-disable-next-line no-control-regex
  return text.replace(/[\x00-\x08\x0B\x0C\x0E-\x1F]/g, '');
}

function stripHtml(html: string): string {
  return html
    .replace(/<(script|style)[^>]*>[\s\S]*?<\/\1>/gi, ' ')
    .replace(/<br\s*\/?>/gi, '\n')
    .replace(/<\/(p|div|h[1-6]|li|tr)>/gi, '\n')
    .replace(/<[^>]+>/g, ' ')
    .replace(/&nbsp;/gi, ' ')
    .replace(/&amp;/gi, '&')
    .replace(/&lt;/gi, '<')
    .replace(/&gt;/gi, '>')
    .replace(/&#(\d+);/g, (_match, code) => String.fromCharCode(Number(code)))
    .replace(/[ \t]+/g, ' ')
    .replace(/\n{3,}/g, '\n\n')
    .trim();
}

async function extractPdfText(absolutePath: string): Promise<string | null> {
  const buffer = readFileSync(absolutePath);
  const parser = new PDFParse({ data: buffer });
  try {
    const result = await parser.getText();
    const text = result.text.trim();
    return text.length > 0 ? text : null;
  } finally {
    await parser.destroy();
  }
}

// EPUBs are zip archives of XHTML files; reading every (x)html entry in
// filename order approximates reading order closely enough for a search
// index without needing to parse the OPF spine — this is a search corpus,
// not a rendering path (the app's actual EPUB viewer reads the file itself).
function extractEpubText(absolutePath: string): string | null {
  const zip = new AdmZip(absolutePath);
  const htmlEntries = zip
    .getEntries()
    .filter((entry) => !entry.isDirectory && /\.x?html?$/i.test(entry.entryName))
    .sort((a, b) => a.entryName.localeCompare(b.entryName));

  const text = htmlEntries
    .map((entry) => stripHtml(entry.getData().toString('utf8')))
    .filter(Boolean)
    .join('\n\n')
    .trim();

  return text.length > 0 ? text : null;
}

/// Reads the uploaded book off disk and returns its plain text, or null if
/// extraction isn't possible (unsupported type, scanned/image-only PDF,
/// corrupt archive, missing file). Never throws — a failed extraction just
/// means this book stays unsearchable by Nnanga, not a broken upload.
export async function extractBookText(
  fileUrl: string,
  fileType: string,
): Promise<string | null> {
  try {
    // fileUrl is the public path served by ServeStaticModule, e.g.
    // "/uploads/books/<uuid>.pdf" — the physical file lives one level up
    // under the backend's own uploads/ directory (see app.module.ts).
    // fileUrl is caller-supplied (CreateBookDto only requires it be a
    // string), so a "../../../etc/passwd"-style value must not be allowed
    // to resolve outside the uploads root — path.join alone doesn't stop
    // that, it only normalizes the segments.
    const relativePath = fileUrl.replace(/^\/?uploads\//, '');
    const uploadsRoot = resolve(process.cwd(), 'uploads');
    const absolutePath = resolve(join(uploadsRoot, relativePath));
    if (absolutePath !== uploadsRoot && !absolutePath.startsWith(uploadsRoot + sep)) {
      return null;
    }

    let text: string | null;
    if (fileType === 'pdf') {
      text = await extractPdfText(absolutePath);
    } else if (fileType === 'epub') {
      text = extractEpubText(absolutePath);
    } else {
      text = null;
    }

    return text ? sanitizeForStorage(text).slice(0, MAX_EXTRACTED_CHARS) : null;
  } catch {
    return null;
  }
}
