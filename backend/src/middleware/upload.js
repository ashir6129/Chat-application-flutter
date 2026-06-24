import fs from 'fs';
import path from 'path';
import multer from 'multer';
import crypto from 'crypto';
import env from '../config/env.js';

const uploadDir = path.resolve(env.upload.dir);

if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const ALLOWED_MIME = new Set([
  'image/jpeg',
  'image/jpg',
  'image/pjpeg',
  'image/png',
  'image/x-png',
  'image/webp',
  'image/gif',
  'video/mp4',
  'video/webm',
  'video/quicktime',
  'video/x-msvideo',
  'video/avi',
  'application/octet-stream',
  'binary/octet-stream',
]);

const ALLOWED_EXT = new Set([
  '.jpg',
  '.jpeg',
  '.png',
  '.webp',
  '.gif',
  '.mp4',
  '.webm',
  '.mov',
  '.avi',
]);

function extFromMime(mime) {
  switch ((mime || '').toLowerCase()) {
    case 'image/jpeg':
    case 'image/jpg':
    case 'image/pjpeg':
      return '.jpg';
    case 'image/png':
    case 'image/x-png':
      return '.png';
    case 'image/webp':
      return '.webp';
    case 'image/gif':
      return '.gif';
    case 'video/mp4':
      return '.mp4';
    case 'video/webm':
      return '.webm';
    case 'video/quicktime':
      return '.mov';
    case 'video/x-msvideo':
    case 'video/avi':
      return '.avi';
    default:
      return '';
  }
}

function isAllowedUpload(file) {
  const mime = (file.mimetype || '').toLowerCase();
  const ext = path.extname(file.originalname || '').toLowerCase();

  if (ALLOWED_EXT.has(ext)) return true;

  if (mime.startsWith('image/') && mime !== 'image/svg+xml') return true;
  if (mime.startsWith('video/')) return true;

  return false;
}

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, uploadDir),
  filename: (_req, file, cb) => {
    let ext = path.extname(file.originalname || '').toLowerCase();

    if (!ALLOWED_EXT.has(ext)) {
      ext = extFromMime(file.mimetype);
    }

    if (!ext) {
      ext = '.jpg';
    }

    cb(null, `${crypto.randomUUID()}${ext}`);
  },
});

function fileFilter(_req, file, cb) {
  if (isAllowedUpload(file)) {
    cb(null, true);
    return;
  }

  cb(
    new Error(
      `Unsupported file type: ${file.mimetype || 'unknown'} (${file.originalname || 'no name'})`,
    ),
  );
}

export const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: env.upload.maxFileSizeMb * 1024 * 1024 },
});

export function publicUploadUrl(filename) {
  return `${env.upload.baseUrl}/uploads/${filename}`;
}

export function mediaKind(mimetype, filename) {
  const mime = (mimetype || '').toLowerCase();
  const ext = path.extname(filename || '').toLowerCase();

  if (mime.startsWith('video/') || ['.mp4', '.webm', '.mov', '.avi'].includes(ext)) {
    return 'video';
  }

  return 'image';
}
