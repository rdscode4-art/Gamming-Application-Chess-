const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Ensure public/avatars directory exists
const uploadDir = path.join(__dirname, '..', '..', 'public', 'avatars');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Set up storage engine
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const ext = path.extname(file.originalname);
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, req.user.userId + '-' + uniqueSuffix + ext);
  }
});

// File filter (accept only images)
const fileFilter = (req, file, cb) => {
  // Dart's http.MultipartFile sometimes defaults to application/octet-stream
  // if it can't determine the mime type from the file path.
  if (file.mimetype.startsWith('image/') || file.mimetype === 'application/octet-stream') {
    cb(null, true);
  } else {
    cb(new Error(`Invalid mimetype: ${file.mimetype}. Only images are allowed.`), false);
  }
};

const uploadAvatarMiddleware = multer({
  storage: storage,
  limits: {
    fileSize: 20 * 1024 * 1024 // 20MB limit
  },
  fileFilter: fileFilter
});

module.exports = {
  uploadAvatarMiddleware
};
