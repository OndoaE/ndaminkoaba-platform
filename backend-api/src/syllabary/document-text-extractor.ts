import { PDFParse } from 'pdf-parse';
import * as mammoth from 'mammoth';
import ExcelJS from 'exceljs';
import * as cheerio from 'cheerio';

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

/// Renders a Word table as one or more tab-separated blocks, the same
/// "preserve row/column structure" treatment `extractSpreadsheetText` gives
/// a spreadsheet — plain `mammoth.extractRawText` flattens a table into a
/// single run of paragraph text with no column boundaries at all, which is
/// exactly the wrong shape for a chart whose first column is the consonant
/// letter: without this, every row loses which consonant it belongs to.
///
/// Returns MULTIPLE blocks, not one, because in the real reference
/// documents this was built against, a single `<table>` element can hold
/// SEVERAL letters' charts back to back, separated only by a blank spacer
/// row (e.g. a "D" chart's 8 rows, a blank row, then an "F" chart's 8 rows,
/// all inside one `<table>`) -- Word's own table-splitting behaviour, not
/// anything this code controls. Rows are first split into runs at those
/// blank-row boundaries; within each run independently:
///  1. A real `rowspan` (from a genuinely vertically-merged cell) is
///     expanded down through the rows it covers.
///  2. The big letter is typically NOT a merged cell at all -- it is one
///     ordinary, non-empty first-column cell placed in roughly the middle
///     row of its run, with every other row's first column left blank
///     (the "big letter" look comes from font size and vertical
///     centering, not a real Word table merge). So if a run ends up with
///     exactly one distinct non-blank first-column value after step 1,
///     that value is backfilled across every row in the run -- it is that
///     run's one letter by construction. A run with zero or more than one
///     distinct value is left as-is rather than guessed at, since this
///     code cannot tell which of several letters a blank row belongs to.
/// Paragraph content outside any table (e.g. a heading above a chart) is
/// kept as its own block via a separate walk over the same parsed HTML,
/// in `extractDocxText` below.
function tableToBlocks($: cheerio.CheerioAPI, table: any): string[] {
  // pending[col] tracks a still-active vertical merge: the cell's text and
  // how many more rows (including this one) it still covers.
  const pending: { text: string; remaining: number }[] = [];
  // A blank row (every cell empty) is kept as an empty array `[]`, marking
  // a run boundary, rather than being dropped immediately.
  const allRows: string[][] = [];

  $(table)
    .find('tr')
    .each((_, tr) => {
      const cells: string[] = [];
      let col = 0;
      const realCells = $(tr).find('td, th').toArray();
      let realIndex = 0;

      while (realIndex < realCells.length || (pending[col]?.remaining ?? 0) > 0) {
        if (pending[col] && pending[col].remaining > 0) {
          cells.push(pending[col].text);
          pending[col].remaining -= 1;
        } else {
          const cell = realCells[realIndex++];
          const text = $(cell).text().replace(/\s+/g, ' ').trim();
          const rowspan = parseInt($(cell).attr('rowspan') || '1', 10) || 1;
          cells.push(text);
          if (rowspan > 1) {
            pending[col] = { text, remaining: rowspan - 1 };
          }
        }
        col += 1;
      }

      allRows.push(cells.some((c) => c.length > 0) ? cells : []);
    });

  const runs: string[][][] = [[]];
  for (const row of allRows) {
    if (row.length === 0) {
      if (runs[runs.length - 1].length > 0) runs.push([]);
    } else {
      runs[runs.length - 1].push(row);
    }
  }

  return runs
    .filter((run) => run.length > 0)
    .map((run) => {
      const distinctFirstColumnValues = new Set(
        run.map((r) => r[0]).filter((v) => v && v.length > 0),
      );
      if (distinctFirstColumnValues.size === 1) {
        const [letter] = distinctFirstColumnValues;
        for (const r of run) r[0] = letter;
      }
      return run.map((r) => r.join('\t')).join('\n');
    });
}

async function extractDocxText(buffer: Buffer): Promise<string | null> {
  const htmlResult = await mammoth.convertToHtml({ buffer });
  const $ = cheerio.load(htmlResult.value);
  const blocks: string[] = [];

  // Walk top-level body children in document order so a heading above a
  // chart and the chart's table stay in their original relative order,
  // rather than extracting all tables first and all paragraphs after.
  $('body')
    .children()
    .each((_, el) => {
      if (el.tagName === 'table') {
        for (const block of tableToBlocks($, el)) {
          if (block.length > 0) blocks.push(block);
        }
      } else {
        const text = $(el).text().replace(/\s+/g, ' ').trim();
        if (text.length > 0) blocks.push(text);
      }
    });

  const text = blocks.join('\n\n').trim();
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
