const visualSearchService = require('../services/search/visualSearchService');
const { successResponse, errorResponse } = require('../utils/response');

/**
 * @desc    Visual Search for Similar Handicrafts
 * @route   POST /api/search/visual
 * @access  Private
 */
const visualSearch = async (req, res) => {
  try {
    let imagePath = '';
    if (req.file) {
      imagePath = req.file.path;
    } else if (req.body.imagePath) {
      imagePath = req.body.imagePath;
    }

    const { category, craftType } = req.body;

    const results = await visualSearchService.searchSimilarProducts({
      category: category || 'Textile',
      craftType: craftType || '',
      imagePath,
    });

    return successResponse(res, 'Visual search completed', {
      count: results.length,
      results,
    });
  } catch (error) {
    return errorResponse(res, error.message, null, 500);
  }
};

module.exports = {
  visualSearch,
};
