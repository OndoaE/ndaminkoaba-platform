import { BadRequestException } from '@nestjs/common';
import { closeSync, openSync, readSync, unlinkSync } from 'fs';
import { extname } from 'path';

/// Uploaded files are served back as static files from the API origin, so the
/// stored extension decides how a browser treats them. These helpers make sure
/// the extension is always one WE chose from a validated type, never one the
/// client supplied (e.g. an `.html` file declared as `image/png`).

const IMAGE_EXTENSIONS: Record<string, string> = {
  'image/jpeg': '.jpg',
  'image/jpg': '.jpg',
  'image/png': '.png',
  'image/webp': '.webp',
};

const AUDIO_EXTENSIONS: Record<string, string> = {
  'audio/mpeg': '.mp3',
  'audio/mp3': '.mp3',
  'audio/mpeg3': '.mp3',
  'audio/x-mpeg-3': '.mp3',
  'audio/wav': '.wav',
  'audio/x-wav': '.wav',
  'audio/wave': '.wav',
  'audio/vnd.wave': '.wav',
  'audio/ogg': '.ogg',
  'audio/opus': '.opus',
  'audio/webm': '.webm',
  'audio/mp4': '.m4a',
  'audio/x-m4a': '.m4a',
  'audio/m4a': '.m4a',
  'audio/aac': '.aac',
  'audio/x-aac': '.aac',
  'audio/flac': '.flac',
  'audio/x-flac': '.flac',
  'audio/3gpp': '.3gp',
  'audio/3gpp2': '.3g2',
  'audio/amr': '.amr',
};

// Browsers/OSes report EPUB and PDF inconsistently, so the extension decides
// the type and the declared mimetype only has to be one that is plausible for
// it (never, say, text/html).
const DOCUMENT_TYPES: Record<
  string,
  { extension: string; mimetypes: string[] }
> = {
  '.pdf': {
    extension: '.pdf',
    mimetypes: [
      'application/pdf',
      'application/x-pdf',
      'application/octet-stream',
    ],
  },
  '.epub': {
    extension: '.epub',
    mimetypes: [
      'application/epub+zip',
      'application/zip',
      'application/octet-stream',
    ],
  },
};

function baseMimetype(mimetype: string | undefined): string {
  return (mimetype ?? '').split(';')[0].trim().toLowerCase();
}

export function imageExtension(
  mimetype: string | undefined,
): string | undefined {
  return IMAGE_EXTENSIONS[baseMimetype(mimetype)];
}

export function audioExtension(
  mimetype: string | undefined,
): string | undefined {
  return AUDIO_EXTENSIONS[baseMimetype(mimetype)];
}

export function documentExtension(
  originalName: string | undefined,
  mimetype: string | undefined,
): string | undefined {
  const type = DOCUMENT_TYPES[extname(originalName ?? '').toLowerCase()];
  if (!type) return undefined;
  return type.mimetypes.includes(baseMimetype(mimetype))
    ? type.extension
    : undefined;
}

export type FileKind = 'image' | 'pdf' | 'epub';

/// The declared mimetype and filename are both client-controlled, so after the
/// file is on disk its leading bytes are checked against the real format.
/// A mismatch deletes the file and rejects the upload.
export function assertFileSignature(path: string, kind: FileKind): void {
  const buf = Buffer.alloc(1024);
  let read = 0;
  const fd = openSync(path, 'r');
  try {
    read = readSync(fd, buf, 0, buf.length, 0);
  } finally {
    closeSync(fd);
  }
  const head = buf.subarray(0, read);

  const ok =
    kind === 'pdf'
      ? head.includes(Buffer.from('%PDF-')) // the spec allows up to 1024 bytes of leading junk
      : kind === 'epub'
        ? head.subarray(0, 4).equals(Buffer.from([0x50, 0x4b, 0x03, 0x04]))
        : isImageSignature(head);

  if (!ok) {
    try {
      unlinkSync(path);
    } catch {
      /* best effort */
    }
    throw new BadRequestException(
      'The file content does not match its declared type.',
    );
  }
}

function isImageSignature(head: Buffer): boolean {
  const jpeg = head.subarray(0, 3).equals(Buffer.from([0xff, 0xd8, 0xff]));
  const png = head
    .subarray(0, 8)
    .equals(Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]));
  const webp =
    head.subarray(0, 4).toString('latin1') === 'RIFF' &&
    head.subarray(8, 12).toString('latin1') === 'WEBP';
  return jpeg || png || webp;
}
