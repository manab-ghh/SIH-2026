const express = require('express');
const router = express.Router();
const {
  publishMarketplace,
  getMarketplaceListings,
} = require('../controllers/marketplaceController');
const { protect } = require('../middleware/authMiddleware');

router.post('/publish', protect, publishMarketplace);
router.get('/listings', protect, getMarketplaceListings);

module.exports = router;
