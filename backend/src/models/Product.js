const mongoose = require('mongoose');

const productSchema = new mongoose.Schema(
  {
    artisanId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    name: {
      type: String,
      required: [true, 'Product name is required'],
      trim: true,
    },
    description: {
      type: String,
      default: '',
    },
    descriptionHindi: {
      type: String,
      default: '',
    },
    descriptionEnglish: {
      type: String,
      default: '',
    },
    images: {
      type: [String],
      default: [],
    },
    category: {
      type: String,
      enum: [
        'Textile',
        'Pottery',
        'Jewelry',
        'Woodwork',
        'Metalware',
        'Painting',
        'Leatherwork',
        'BambooCane',
        'Other',
      ],
      default: 'Textile',
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
    quantity: {
      type: Number,
      default: 1,
      min: 0,
    },
    rawMaterialCost: {
      type: Number,
      default: 0,
      min: 0,
    },
    productionCost: {
      type: Number,
      default: 0,
      min: 0,
    },
    otherCost: {
      type: Number,
      default: 0,
      min: 0,
    },
    totalCost: {
      type: Number,
      default: 0,
      min: 0,
    },
    recommendedPrice: {
      type: Number,
      default: 0,
      min: 0,
    },
    minimumPrice: {
      type: Number,
      default: 0,
      min: 0,
    },
    competitivePrice: {
      type: Number,
      default: 0,
      min: 0,
    },
    premiumPrice: {
      type: Number,
      default: 0,
      min: 0,
    },
    keywords: {
      type: [String],
      default: [],
    },
    craftStory: {
      type: String,
      default: 'Made by Hand. Made With Heritage. Every piece carries the skill and tradition of India’s artisan communities.',
    },
    status: {
      type: String,
      enum: ['draft', 'ready', 'published', 'out_of_stock'],
      default: 'draft',
    },
    marketplaceStatus: {
      type: Map,
      of: String,
      default: {
        ondc: 'not_published',
        gem: 'not_published',
      },
    },
  },
  {
    timestamps: true,
  }
);

productSchema.index({ name: 'text', description: 'text', craftType: 'text', material: 'text' });

module.exports = mongoose.model('Product', productSchema);
