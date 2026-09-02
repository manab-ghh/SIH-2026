class PricingModel {
  final double rawMaterialCost;
  final double productionCost;
  final double otherCost;
  final double totalCost;
  final double minimumPrice;
  final double competitivePrice;
  final double recommendedPrice;
  final double premiumPrice;
  final double estimatedProfit;
  final double profitMargin;
  final String marketTrend;
  final String explanation;
  final String disclaimer;

  const PricingModel({
    required this.rawMaterialCost,
    required this.productionCost,
    required this.otherCost,
    required this.totalCost,
    required this.minimumPrice,
    required this.competitivePrice,
    required this.recommendedPrice,
    required this.premiumPrice,
    required this.estimatedProfit,
    required this.profitMargin,
    this.marketTrend = '',
    this.explanation = '',
    this.disclaimer = 'AI suggestions are estimates. Review before publishing.',
  });

  factory PricingModel.fromJson(Map<String, dynamic> json) {
    return PricingModel(
      rawMaterialCost: (json['rawMaterialCost'] as num?)?.toDouble() ?? 0,
      productionCost: (json['productionCost'] as num?)?.toDouble() ?? 0,
      otherCost: (json['otherCost'] as num?)?.toDouble() ?? 0,
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0,
      minimumPrice: (json['minimumPrice'] as num?)?.toDouble() ?? 0,
      competitivePrice: (json['competitivePrice'] as num?)?.toDouble() ?? 0,
      recommendedPrice: (json['recommendedPrice'] as num?)?.toDouble() ?? 0,
      premiumPrice: (json['premiumPrice'] as num?)?.toDouble() ?? 0,
      estimatedProfit: (json['estimatedProfit'] as num?)?.toDouble() ?? 0,
      profitMargin: (json['profitMargin'] as num?)?.toDouble() ?? 0,
      marketTrend: json['marketTrend'] ?? '',
      explanation: json['explanation'] ?? '',
      disclaimer: json['disclaimer'] ?? 'AI suggestions are estimates.',
    );
  }
}
