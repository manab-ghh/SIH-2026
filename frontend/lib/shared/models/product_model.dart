class ProductModel {
  final String id;
  final String artisanId;
  final String name;
  final String description;
  final String descriptionHindi;
  final String descriptionEnglish;
  final List<String> images;
  final String category;
  final String material;
  final String craftType;
  final String color;
  final String size;
  final int quantity;
  final double rawMaterialCost;
  final double productionCost;
  final double otherCost;
  final double totalCost;
  final double recommendedPrice;
  final double minimumPrice;
  final double competitivePrice;
  final double premiumPrice;
  final List<String> keywords;
  final String craftStory;
  final String status;
  final Map<String, dynamic>? marketplaceStatus;
  final DateTime? createdAt;

  const ProductModel({
    required this.id,
    this.artisanId = '',
    required this.name,
    this.description = '',
    this.descriptionHindi = '',
    this.descriptionEnglish = '',
    this.images = const [],
    this.category = 'Textile',
    this.material = '',
    this.craftType = '',
    this.color = '',
    this.size = 'Medium',
    this.quantity = 1,
    this.rawMaterialCost = 0,
    this.productionCost = 0,
    this.otherCost = 0,
    this.totalCost = 0,
    this.recommendedPrice = 0,
    this.minimumPrice = 0,
    this.competitivePrice = 0,
    this.premiumPrice = 0,
    this.keywords = const [],
    this.craftStory = 'Made by Hand. Made With Heritage.',
    this.status = 'draft',
    this.marketplaceStatus,
    this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? json['_id'] ?? '',
      artisanId: json['artisanId'] is Map
          ? json['artisanId']['_id']
          : (json['artisanId']?.toString() ?? ''),
      name: json['name'] ?? 'Handmade Craft',
      description: json['description'] ?? '',
      descriptionHindi: json['descriptionHindi'] ?? '',
      descriptionEnglish: json['descriptionEnglish'] ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      category: json['category'] ?? 'Textile',
      material: json['material'] ?? '',
      craftType: json['craftType'] ?? '',
      color: json['color'] ?? '',
      size: json['size'] ?? 'Medium',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      rawMaterialCost: (json['rawMaterialCost'] as num?)?.toDouble() ?? 0,
      productionCost: (json['productionCost'] as num?)?.toDouble() ?? 0,
      otherCost: (json['otherCost'] as num?)?.toDouble() ?? 0,
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0,
      recommendedPrice: (json['recommendedPrice'] as num?)?.toDouble() ?? 0,
      minimumPrice: (json['minimumPrice'] as num?)?.toDouble() ?? 0,
      competitivePrice: (json['competitivePrice'] as num?)?.toDouble() ?? 0,
      premiumPrice: (json['premiumPrice'] as num?)?.toDouble() ?? 0,
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      craftStory: json['craftStory'] ?? 'Made by Hand. Made With Heritage.',
      status: json['status'] ?? 'draft',
      marketplaceStatus: json['marketplaceStatus'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'descriptionHindi': descriptionHindi,
      'descriptionEnglish': descriptionEnglish,
      'images': images,
      'category': category,
      'material': material,
      'craftType': craftType,
      'color': color,
      'size': size,
      'quantity': quantity,
      'rawMaterialCost': rawMaterialCost,
      'productionCost': productionCost,
      'otherCost': otherCost,
      'totalCost': totalCost,
      'recommendedPrice': recommendedPrice,
      'minimumPrice': minimumPrice,
      'competitivePrice': competitivePrice,
      'premiumPrice': premiumPrice,
      'keywords': keywords,
      'craftStory': craftStory,
      'status': status,
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    String? descriptionHindi,
    String? descriptionEnglish,
    List<String>? images,
    String? category,
    String? material,
    String? craftType,
    String? color,
    String? size,
    int? quantity,
    double? rawMaterialCost,
    double? productionCost,
    double? otherCost,
    double? totalCost,
    double? recommendedPrice,
    double? minimumPrice,
    double? competitivePrice,
    double? premiumPrice,
    List<String>? keywords,
    String? craftStory,
    String? status,
  }) {
    return ProductModel(
      id: id ?? this.id,
      artisanId: artisanId,
      name: name ?? this.name,
      description: description ?? this.description,
      descriptionHindi: descriptionHindi ?? this.descriptionHindi,
      descriptionEnglish: descriptionEnglish ?? this.descriptionEnglish,
      images: images ?? this.images,
      category: category ?? this.category,
      material: material ?? this.material,
      craftType: craftType ?? this.craftType,
      color: color ?? this.color,
      size: size ?? this.size,
      quantity: quantity ?? this.quantity,
      rawMaterialCost: rawMaterialCost ?? this.rawMaterialCost,
      productionCost: productionCost ?? this.productionCost,
      otherCost: otherCost ?? this.otherCost,
      totalCost: totalCost ?? this.totalCost,
      recommendedPrice: recommendedPrice ?? this.recommendedPrice,
      minimumPrice: minimumPrice ?? this.minimumPrice,
      competitivePrice: competitivePrice ?? this.competitivePrice,
      premiumPrice: premiumPrice ?? this.premiumPrice,
      keywords: keywords ?? this.keywords,
      craftStory: craftStory ?? this.craftStory,
      status: status ?? this.status,
      marketplaceStatus: marketplaceStatus,
      createdAt: createdAt,
    );
  }
}
