const path = require('path');
const multer = require('multer');
const { generateId } = require('../utils/ids');

const ALLOWED_IMAGE_EXT = new Set([
  '.jpg',
  '.jpeg',
  '.png',
  '.gif',
  '.webp',
  '.heic',
  '.heif',
]);

function isAllowedImage(file) {
  if (file.mimetype && file.mimetype.startsWith('image/')) {
    return true;
  }

  const ext = path.extname(file.originalname || '').toLowerCase();
  if (ALLOWED_IMAGE_EXT.has(ext)) {
    return true;
  }

  // Flutter Web / some clients send octet-stream without a proper extension
  const genericMime =
    !file.mimetype ||
    file.mimetype === 'application/octet-stream' ||
    file.mimetype === 'binary/octet-stream';

  return genericMime && (!ext || ext === '.jpg' || ext === '.jpeg');
}

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => {
    cb(null, path.join(__dirname, '..', 'uploads'));
  },
  filename: (_req, file, cb) => {
    let ext = path.extname(file.originalname || '').toLowerCase();
    if (!ALLOWED_IMAGE_EXT.has(ext)) {
      ext = '.jpg';
    }
    cb(null, `${generateId('img')}${ext}`);
  },
});

const fileFilter = (_req, file, cb) => {
  if (isAllowedImage(file)) {
    return cb(null, true);
  }
  return cb(new Error('Only image files are allowed'), false);
};

const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 },
});

const uploadPropertyImages = upload.array('images', 10);
const uploadAvatar = upload.single('avatar');

module.exports = { uploadPropertyImages, uploadAvatar };
