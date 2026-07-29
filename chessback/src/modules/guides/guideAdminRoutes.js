const express = require('express');
const router = express.Router();
const { createGuide, updateGuide, deleteGuide } = require('./guideController');
const { authMiddleware, adminMiddleware } = require('../../middleware/authMiddleware');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Ensure upload directory exists
const uploadDir = path.join(__dirname, '..', '..', '..', 'public', 'guides');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Set up multer for file uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'guide-' + uniqueSuffix + path.extname(file.originalname));
  }
});
const upload = multer({ storage: storage });

// Admin protected routes
router.use(authMiddleware);

// Since adminMiddleware is typically applied at the top level in app.js for /api/admin/*, 
// we assume it's protected there. But we can also add it explicitly if needed.
// router.use(adminMiddleware); 

router.post('/', upload.single('media'), createGuide);
router.put('/:id', upload.single('media'), updateGuide);
router.delete('/:id', deleteGuide);

module.exports = router;
