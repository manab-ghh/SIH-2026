const express = require('express');
const router = express.Router();
const {
  enhanceImage,
  generateCatalog,
  generatePricing,
  processVoice,
} = require('../controllers/aiController');
const { protect } = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');

router.post('/image-enhance', protect, upload.single('image'), enhanceImage);
router.post('/catalog', protect, generateCatalog);
router.post('/pricing', protect, generatePricing);
router.post('/voice', protect, processVoice);

module.exports = router;
