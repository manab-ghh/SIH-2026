const mongoose = require('mongoose');

const pricingSchema = new mongoose.Schema(
  {
    productId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Product',
    },
    rawMaterialCost: {
      type: Number,
      required: true,
      default: 0,
    },
    productionCost: {
      type: Number,
      required: true,
      default: 0,
    },
    otherCost: {
      type: Number,
      default: 0,
    },
    totalCost: {
      type: Number,
      required: true,
      default: 0,
    },
    minimumPrice: {
      type: Number,
      required: true,
      default: 0,
    },
    competitivePrice: {
      type: Number,
      required: true,
      default: 0,
    },
    recommendedPrice: {
      type: Number,
      required: true,
      default: 0,
    },
    premiumPrice: {
      type: Number,
      required: true,
      default: 0,
    },
    profitMargin: {
      type: Number,
      default: 0,
    },
    estimatedProfit: {
      type: Number,
      default: 0,
    },
    marketTrend: {
      type: String,
      default: 'Moderate demand with positive growth in authentic handicrafts',
    },
    explanation: {
      type: String,
      default: 'Based on your costs, artisan labor tier, craft category benchmarks, and simulated marketplace trends.',
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Pricing', pricingSchema);
