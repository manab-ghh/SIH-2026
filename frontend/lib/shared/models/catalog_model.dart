class CatalogModel {
  final String name;
  final String description;
  final String descriptionHindi;
  final String category;
  final String material;
  final String craftType;
  final String color;
  final String size;
  final List<String> keywords;
  final String craftStory;
  final double confidence;

  const CatalogModel({
    required this.name,
    required this.description,
    this.descriptionHindi = '',
    required this.category,
    required this.material,
    required this.craftType,
    required this.color,
    this.size = 'Medium',
    this.keywords = const [],
    this.craftStory = '',
    this.confidence = 92.0,
  });

  factory CatalogModel.fromJson(Map<String, dynamic> json) {
    return CatalogModel(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      descriptionHindi: json['descriptionHindi'] ?? '',
      category: json['category'] ?? 'Textile',
      material: json['material'] ?? '',
      craftType: json['craftType'] ?? '',
      color: json['color'] ?? '',
      size: json['size'] ?? 'Medium',
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      craftStory: json['craftStory'] ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 90.0,
    );
  }
}
