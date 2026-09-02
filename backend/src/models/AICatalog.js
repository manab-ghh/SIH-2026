const mongoose = require('mongoose');

const aiCatalogSchema = new mongoose.Schema(
  {
    productId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Product',
    },
    inputText: {
      type: String,
      required: true,
    },
    inputLanguage: {
      type: String,
      default: 'hi',
    },
    translatedText: {
      type: String,
      default: '',
    },
    generatedName: {
      type: String,
      default: '',
    },
    generatedDescription: {
      type: String,
      default: '',
    },
    generatedDescriptionHindi: {
      type: String,
      default: '',
    },
    keywords: {
      type: [String],
      default: [],
    },
    material: {
      type: String,
      default: '',
    },
    craftType: {
      type: String,
      default: '',
    },
    color: {
      type: String,
      default: '',
    },
    size: {
      type: String,
      default: 'Medium',
    },
    confidence: {
      type: Number,
      default: 90,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('AICatalog', aiCatalogSchema);
