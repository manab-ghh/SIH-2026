const marketplaceService = require('../services/marketplace/marketplaceService');
const { successResponse, errorResponse } = require('../utils/response');

/**
 * @desc    Publish product to simulated Marketplaces (ONDC & GeM)
 * @route   POST /api/marketplace/publish
 * @access  Private
 */
const publishMarketplace = async (req, res) => {
  try {
    const { productId, marketplaces } = req.body;

    if (!productId) {
      return errorResponse(res, 'Please provide a valid productId', null, 400);
    }

    const result = await marketplaceService.publishToMarketplaces(
      productId,
      marketplaces || ['ONDC', 'GeM']
    );

    return successResponse(res, result.message, result);
  } catch (error) {
    return errorResponse(res, error.message, null, 500);
  }
};

/**
 * @desc    Get all active Marketplace listings
 * @route   GET /api/marketplace/listings
 * @access  Private
 */
const getMarketplaceListings = async (req, res) => {
  try {
    const listings = await marketplaceService.getListings();

    const stats = {
      totalListings: listings.length,
      activeListings: listings.filter((l) => l.status === 'Published').length,
      ondcCount: listings.filter((l) => l.marketplace === 'ONDC').length,
      gemCount: listings.filter((l) => l.marketplace === 'GeM').length,
    };

    return successResponse(res, 'Marketplace listings retrieved', {
      stats,
      listings,
      statusBadge: 'Demo Ready',
    });
  } catch (error) {
    return errorResponse(res, error.message, null, 500);
  }
};

module.exports = {
  publishMarketplace,
  getMarketplaceListings,
};
