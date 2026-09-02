const express = require('express');
const router = express.Router();
const { visualSearch } = require('../controllers/searchController');
const { protect } = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');

router.post('/visual', protect, upload.single('image'), visualSearch);

module.exports = router;
