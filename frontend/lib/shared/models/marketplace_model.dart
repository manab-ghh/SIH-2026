class MarketplaceListingModel {
  final String id;
  final String productId;
  final String marketplace;
  final String listingId;
  final String status;
  final String marketplaceCategory;
  final DateTime publishedAt;

  const MarketplaceListingModel({
    required this.id,
    required this.productId,
    required this.marketplace,
    required this.listingId,
    required this.status,
    required this.marketplaceCategory,
    required this.publishedAt,
  });

  factory MarketplaceListingModel.fromJson(Map<String, dynamic> json) {
    return MarketplaceListingModel(
      id: json['id'] ?? json['_id'] ?? '',
      productId: json['productId'] is Map
          ? json['productId']['_id']
          : (json['productId']?.toString() ?? ''),
      marketplace: json['marketplace'] ?? 'ONDC',
      listingId: json['listingId'] ?? '',
      status: json['status'] ?? 'Published',
      marketplaceCategory: json['marketplaceCategory'] ?? 'Handicrafts',
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
