const mongoose = require('mongoose');

const marketplaceListingSchema = new mongoose.Schema(
  {
    productId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Product',
      required: true,
    },
    marketplace: {
      type: String,
      enum: ['ONDC', 'GeM'],
      required: true,
    },
    listingId: {
      type: String,
      required: true,
      unique: true,
    },
    status: {
      type: String,
      enum: ['Draft', 'Pending', 'Published', 'Suspended'],
      default: 'Published',
    },
    marketplaceCategory: {
      type: String,
      default: 'Handicrafts & Handlooms',
    },
    isSimulation: {
      type: Boolean,
      default: true,
    },
    publishedAt: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('MarketplaceListing', marketplaceListingSchema);
