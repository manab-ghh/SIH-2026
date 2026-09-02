const MarketplaceListing = require('../../models/MarketplaceListing');
const Product = require('../../models/Product');

/**
 * MarketplaceService - Simulates publishing to ONDC & GeM
 */
const publishToMarketplaces = async (productId, marketplaces = ['ONDC', 'GeM']) => {
  const product = await Product.findById(productId);
  if (!product) {
    throw new Error('Product not found for marketplace publishing');
  }

  const listings = [];

  for (const mp of marketplaces) {
    const randomSuffix = Math.floor(100000 + Math.random() * 900000);
    const listingId = `${mp.toUpperCase()}-DEMO-${randomSuffix}`;

    // Upsert or create listing
    let listing = await MarketplaceListing.findOne({
      productId: product._id,
      marketplace: mp,
    });

    if (listing) {
      listing.status = 'Published';
      listing.listingId = listingId;
      listing.publishedAt = new Date();
      await listing.save();
    } else {
      listing = await MarketplaceListing.create({
        productId: product._id,
        marketplace: mp,
        listingId,
        status: 'Published',
        marketplaceCategory: `${product.category} & Handlooms`,
        isSimulation: true,
      });
    }

    listings.push(listing);
  }

  // Update product status
  product.status = 'published';
  product.marketplaceStatus = {
    ondc: 'published',
    gem: 'published',
  };
  await product.save();

  return {
    success: true,
    message: 'Product Published Successfully 🎉',
    simulationNotice: 'Demo marketplace listing. No real financial or governmental transaction has been performed.',
    listings,
    product,
  };
};

const getListings = async (query = {}) => {
  return await MarketplaceListing.find(query).populate('productId').sort({ createdAt: -1 });
};

module.exports = {
  publishToMarketplaces,
  getListings,
};
