import { PDFParse } from 'pdf-parse';
import * as mammoth from 'mammoth';
import ExcelJS from 'exceljs';

// A pasted/uploaded syllabary reference doc is a handful of rows, not a
// novel — this ceiling just guards against an oversized file blowing up
// the downstream AI prompt, mirroring MAX_EXTRACTED_CHARS in
// book-text-extractor.ts.
const MAX_EXTRACTED_CHARS = 200_000;

async function extractPdfText(buffer: Buffer): Promise<string | null> {
  const parser = new PDFParse({ data: buffer });
  try {
    const result = await parser.getText();
    const text = result.text.trim();
    return text.length > 0 ? text : null;
  } finally {
    await parser.destroy();
  }
}

async function extractDocxText(buffer: Buffer): Promise<string | null> {
  const result = await mammoth.extractRawText({ buffer });
  const text = result.value.trim();
  return text.length > 0 ? text : null;
}

/// Renders every sheet as a simple tab-separated block so the downstream
/// text-extraction prompt sees the row/column structure a copy-pasted
/// spreadsheet table would have — good enough for an LLM to read back the
/// original grid without needing real CSV escaping.
async function extractSpreadsheetText(buffer: Buffer): Promise<string | null> {
  const workbook = new ExcelJS.Workbook();
  await workbook.xlsx.load(buffer as any);

  const sheetBlocks: string[] = [];
  workbook.eachSheet((sheet) => {
    const rows: string[] = [];
    sheet.eachRow((row) => {
      const cells = (row.values as ExcelJS.CellValue[]).slice(1).map((v) => {
        if (v === null || v === undefined) return '';
        if (typeof v === 'object' && 'text' in (v as any)) return String((v as any).text);
        if (typeof v === 'object' && 'result' in (v as any)) return String((v as any).result);
        return String(v);
      });
      rows.push(cells.join('\t'));
    });
    if (rows.length > 0) sheetBlocks.push(rows.join('\n'));
  });

  const text = sheetBlocks.join('\n\n').trim();
  return text.length > 0 ? text : null;
}

/// Extracts plain text from an in-memory uploaded document so it can be fed
/// through the same text-based AI extraction path as a pasted table —
/// never touches disk, unlike `extractBookText` (uploaded books are stored
/// files; this is a one-shot review-before-import flow, see
/// `SyllabaryService.extract`). Returns null on any failure or unsupported
/// type rather than throwing, so the caller can turn that into a friendly
/// "couldn't read this file" warning instead of a 500.
export async function extractDocumentText(
  buffer: Buffer,
  mimeType: string,
): Promise<string | null> {
  try {
    let text: string | null;
    if (mimeType === 'application/pdf') {
      text = await extractPdfText(buffer);
    } else if (
      mimeType ===
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document' ||
      mimeType === 'application/msword'
    ) {
      text = await extractDocxText(buffer);
    } else if (
      mimeType ===
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ||
      mimeType === 'application/vnd.ms-excel'
    ) {
      text = await extractSpreadsheetText(buffer);
    } else if (mimeType === 'text/plain') {
      text = buffer.toString('utf8').trim() || null;
    } else {
      text = null;
    }
    return text ? text.slice(0, MAX_EXTRACTED_CHARS) : null;
  } catch {
    return null;
  }
}
