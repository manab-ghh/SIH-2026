const catalogService = require('../services/ai/catalogService');
const imageService = require('../services/ai/imageService');
const speechService = require('../services/ai/speechService');
const pricingService = require('../services/pricing/pricingService');
const AICatalog = require('../models/AICatalog');
const Pricing = require('../models/Pricing');
const { successResponse, errorResponse } = require('../utils/response');

/**
 * @desc    AI Image Studio Enhancement
 * @route   POST /api/ai/image-enhance
 * @access  Private
 */
const enhanceImage = async (req, res) => {
  try {
    let filePath = '';

    if (req.file) {
      filePath = req.file.path;
    } else if (req.body.imagePath) {
      filePath = req.body.imagePath;
    } else {
      return errorResponse(res, 'Please upload an image file or provide imagePath', null, 400);
    }

    const { removeBackground, enhanceLighting, enhanceColors, eCommerceCrop } = req.body;

    const result = await imageService.enhanceImage(filePath, {
      removeBackground: removeBackground !== 'false' && removeBackground !== false,
      enhanceLighting: enhanceLighting !== 'false' && enhanceLighting !== false,
      enhanceColors: enhanceColors !== 'false' && enhanceColors !== false,
      eCommerceCrop: eCommerceCrop !== 'false' && eCommerceCrop !== false,
    });

    return successResponse(res, 'Image enhanced successfully', result);
  } catch (error) {
    return errorResponse(res, error.message, null, 500);
  }
};

/**
 * @desc    Generate AI Auto Catalog from Voice/Text Description
 * @route   POST /api/ai/catalog
 * @access  Private
 */
const generateCatalog = async (req, res) => {
  try {
    const { inputText, voiceText, inputLanguage, productImage, productId } = req.body;

    const textToProcess = (inputText || voiceText || '').trim();
    if (!textToProcess) {
      return errorResponse(res, 'Please provide a product description or voice text', null, 400);
    }

    const catalogData = await catalogService.generateCatalog({
      inputText: textToProcess,
      inputLanguage: inputLanguage || 'hi',
      productImage: productImage || '',
    });

    // Save AI Catalog record
    const aiCatalog = await AICatalog.create({
      productId: productId || null,
      inputText: textToProcess,
      inputLanguage: inputLanguage || 'hi',
      translatedText: catalogData.name,
      generatedName: catalogData.name,
      generatedDescription: catalogData.description,
      generatedDescriptionHindi: catalogData.descriptionHindi,
      keywords: catalogData.keywords,
      material: catalogData.material,
      craftType: catalogData.craftType,
      color: catalogData.color,
      size: catalogData.size,
      confidence: catalogData.confidence,
    });

    return successResponse(res, 'AI Catalog generated ✨', {
      catalog: catalogData,
      recordId: aiCatalog._id,
    });
  } catch (error) {
    return errorResponse(res, error.message, null, 500);
  }
};

/**
 * @desc    Calculate Smart Pricing recommendations
 * @route   POST /api/ai/pricing
 * @access  Private
 */
const generatePricing = async (req, res) => {
  try {
    const {
      rawMaterialCost,
      productionCost,
      otherCost,
      category,
      craftType,
      material,
      laborHours,
      productId,
    } = req.body;

    const pricingData = await pricingService.calculatePricing({
      rawMaterialCost,
      productionCost,
      otherCost,
      category: category || 'Textile',
      craftType: craftType || '',
      material: material || '',
      laborHours: laborHours || 4,
    });

    // Save Pricing record
    const pricingRecord = await Pricing.create({
      productId: productId || null,
      rawMaterialCost: pricingData.rawMaterialCost,
      productionCost: pricingData.productionCost,
      otherCost: pricingData.otherCost,
      totalCost: pricingData.totalCost,
      minimumPrice: pricingData.minimumPrice,
      competitivePrice: pricingData.competitivePrice,
      recommendedPrice: pricingData.recommendedPrice,
      premiumPrice: pricingData.premiumPrice,
      profitMargin: pricingData.profitMargin,
      estimatedProfit: pricingData.estimatedProfit,
      marketTrend: pricingData.marketTrend,
      explanation: pricingData.explanation,
    });

    return successResponse(res, 'Smart Pricing calculated 💰', {
      pricing: pricingData,
      recordId: pricingRecord._id,
    });
  } catch (error) {
    return errorResponse(res, error.message, null, 500);
  }
};

/**
 * @desc    Process Voice input / Speech-to-text simulation
 * @route   POST /api/ai/voice
 * @access  Private
 */
const processVoice = async (req, res) => {
  try {
    const { voiceText, language } = req.body;

    const result = await speechService.processVoiceInput({
      voiceText,
      language: language || 'hi',
    });

    return successResponse(res, 'Voice processed successfully', result);
  } catch (error) {
    return errorResponse(res, error.message, null, 500);
  }
};

module.exports = {
  enhanceImage,
  generateCatalog,
  generatePricing,
  processVoice,
};
