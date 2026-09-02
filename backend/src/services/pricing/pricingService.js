/**
 * PricingService - Calculates intelligent price recommendations for handmade artisan products
 */

const CATEGORY_BENCHMARKS = {
  Textile: { minMargin: 0.35, recommendedMargin: 0.55, premiumMargin: 0.85, baseLaborRate: 150 },
  Pottery: { minMargin: 0.40, recommendedMargin: 0.65, premiumMargin: 1.00, baseLaborRate: 100 },
  Jewelry: { minMargin: 0.45, recommendedMargin: 0.70, premiumMargin: 1.20, baseLaborRate: 200 },
  Woodwork: { minMargin: 0.35, recommendedMargin: 0.60, premiumMargin: 0.90, baseLaborRate: 180 },
  Metalware: { minMargin: 0.40, recommendedMargin: 0.65, premiumMargin: 0.95, baseLaborRate: 220 },
  Painting: { minMargin: 0.50, recommendedMargin: 0.80, premiumMargin: 1.40, baseLaborRate: 160 },
  Leatherwork: { minMargin: 0.35, recommendedMargin: 0.55, premiumMargin: 0.85, baseLaborRate: 140 },
  BambooCane: { minMargin: 0.40, recommendedMargin: 0.60, premiumMargin: 0.90, baseLaborRate: 110 },
  Other: { minMargin: 0.35, recommendedMargin: 0.55, premiumMargin: 0.85, baseLaborRate: 120 },
};

const calculatePricing = async ({
  rawMaterialCost = 0,
  productionCost = 0,
  otherCost = 0,
  category = 'Textile',
  craftType = '',
  material = '',
  laborHours = 4,
}) => {
  const raw = Number(rawMaterialCost) || 0;
  const prod = Number(productionCost) || 0;
  const other = Number(otherCost) || 0;
  const totalCost = Math.max(raw + prod + other, 50);

  const benchmark = CATEGORY_BENCHMARKS[category] || CATEGORY_BENCHMARKS.Other;

  // Minimum safe price (covers costs + small artisan living wage margin)
  const minimumPrice = Math.round((totalCost * (1 + benchmark.minMargin)) / 10) * 10;

  // Competitive price (sweet spot for high volume e-commerce)
  const competitivePrice = Math.round((totalCost * (1 + benchmark.recommendedMargin * 0.85)) / 10) * 10;

  // Recommended price (ideal balance of artisan fair compensation + buyer demand)
  const recommendedPrice = Math.round((totalCost * (1 + benchmark.recommendedMargin)) / 10) * 10;

  // Premium price (for boutique/heritage collector value)
  const premiumPrice = Math.round((totalCost * (1 + benchmark.premiumMargin)) / 10) * 10;

  const estimatedProfit = recommendedPrice - totalCost;
  const profitMargin = Math.round((estimatedProfit / recommendedPrice) * 1000) / 10;

  let marketTrend = `High seasonal interest in authentic handcrafted ${category.toLowerCase()}`;
  let explanation = `Based on total production costs of ₹${totalCost.toLocaleString('en-IN')}, a fair artisan labor factor, and simulated handicraft market trends in ${category}.`;

  return {
    rawMaterialCost: raw,
    productionCost: prod,
    otherCost: other,
    totalCost,
    minimumPrice,
    competitivePrice,
    recommendedPrice,
    premiumPrice,
    estimatedProfit,
    profitMargin,
    marketTrend,
    explanation,
    disclaimer: 'Demo Market Insights: AI suggestions are estimates. Review before publishing.',
  };
};

module.exports = {
  calculatePricing,
};
