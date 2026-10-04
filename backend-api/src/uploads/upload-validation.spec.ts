import { BadRequestException } from '@nestjs/common';
import { existsSync, mkdtempSync, rmSync, writeFileSync } from 'fs';
import { tmpdir } from 'os';
import { join } from 'path';

import {
  assertFileSignature,
  audioExtension,
  documentExtension,
  imageExtension,
} from './upload-validation';

describe('upload type validation', () => {
  it('maps only real image types to a server-chosen extension', () => {
    expect(imageExtension('image/png')).toBe('.png');
    expect(imageExtension('image/jpeg')).toBe('.jpg');
    expect(imageExtension('image/svg+xml')).toBeUndefined(); // SVG can carry script
    expect(imageExtension('text/html')).toBeUndefined();
  });

  it('ignores mimetype parameters on audio and rejects unknown types', () => {
    expect(audioExtension('audio/webm;codecs=opus')).toBe('.webm');
    expect(audioExtension('audio/x-wav')).toBe('.wav');
    expect(audioExtension('audio/html')).toBeUndefined();
    expect(audioExtension('text/html')).toBeUndefined();
  });

  it('requires BOTH a PDF/EPUB extension and a plausible mimetype', () => {
    expect(documentExtension('book.PDF', 'application/pdf')).toBe('.pdf');
    expect(documentExtension('book.epub', 'application/octet-stream')).toBe(
      '.epub',
    );
    // A script named .html but declared as a PDF used to slip through.
    expect(documentExtension('evil.html', 'application/pdf')).toBeUndefined();
    // A .pdf name with a contradicting mimetype is rejected too.
    expect(documentExtension('book.pdf', 'text/html')).toBeUndefined();
    expect(documentExtension(undefined, 'application/pdf')).toBeUndefined();
  });
});

describe('assertFileSignature', () => {
  let dir: string;
  beforeEach(() => {
    dir = mkdtempSync(join(tmpdir(), 'upl-'));
  });
  afterEach(() => rmSync(dir, { recursive: true, force: true }));

  const write = (name: string, bytes: Buffer) => {
    const p = join(dir, name);
    writeFileSync(p, bytes);
    return p;
  };

  it('accepts real PDF, EPUB (zip) and image signatures', () => {
    expect(() =>
      assertFileSignature(write('a.pdf', Buffer.from('%PDF-1.7\n...')), 'pdf'),
    ).not.toThrow();
    expect(() =>
      assertFileSignature(
        write('a.epub', Buffer.from([0x50, 0x4b, 0x03, 0x04, 0])),
        'epub',
      ),
    ).not.toThrow();
    expect(() =>
      assertFileSignature(
        write('a.jpg', Buffer.from([0xff, 0xd8, 0xff, 0xe0, 0])),
        'image',
      ),
    ).not.toThrow();
    expect(() =>
      assertFileSignature(
        write(
          'a.png',
          Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
        ),
        'image',
      ),
    ).not.toThrow();
  });

  it('rejects HTML pretending to be an image or PDF, and deletes it', () => {
    const html = write(
      'x.png',
      Buffer.from('<html><script>alert(1)</script></html>'),
    );
    expect(() => assertFileSignature(html, 'image')).toThrow(
      BadRequestException,
    );
    expect(existsSync(html)).toBe(false);

    const fakePdf = write('x.pdf', Buffer.from('<html>not a pdf</html>'));
    expect(() => assertFileSignature(fakePdf, 'pdf')).toThrow(
      BadRequestException,
    );
    expect(existsSync(fakePdf)).toBe(false);
  });
});
