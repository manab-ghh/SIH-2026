class OrderTimelineItem {
  final String status;
  final String message;
  final DateTime timestamp;

  const OrderTimelineItem({
    required this.status,
    required this.message,
    required this.timestamp,
  });

  factory OrderTimelineItem.fromJson(Map<String, dynamic> json) {
    return OrderTimelineItem(
      status: json['status'] ?? 'pending',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String productId;
  final String productName;
  final String productImage;
  final String buyerName;
  final String buyerPhone;
  final int quantity;
  final double price;
  final double totalAmount;
  final String status;
  final Map<String, dynamic>? shippingAddress;
  final List<OrderTimelineItem> timeline;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.productId,
    required this.productName,
    this.productImage = '',
    required this.buyerName,
    this.buyerPhone = '',
    this.quantity = 1,
    required this.price,
    required this.totalAmount,
    this.status = 'pending',
    this.shippingAddress,
    this.timeline = const [],
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final prodSnapshot = json['productSnapshot'] as Map<String, dynamic>?;
    final prodObj = json['productId'] is Map
        ? json['productId'] as Map<String, dynamic>
        : null;

    final name =
        prodSnapshot?['name'] ?? prodObj?['name'] ?? 'Handmade Product';
    final img = prodSnapshot?['image'] ??
        ((prodObj?['images'] as List<dynamic>?)?.isNotEmpty == true
            ? prodObj!['images'][0]
            : '');

    final timelineList = (json['timeline'] as List<dynamic>?)
            ?.map((e) => OrderTimelineItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return OrderModel(
      id: json['id'] ?? json['_id'] ?? '',
      orderNumber: json['orderNumber'] ?? 'SHL-10000',
      productId: prodObj?['_id'] ?? json['productId']?.toString() ?? '',
      productName: name,
      productImage: img,
      buyerName: json['buyerName'] ?? 'Pooja Sharma',
      buyerPhone: json['buyerPhone'] ?? '+91 98765 43210',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      status: json['status'] ?? 'pending',
      shippingAddress: json['shippingAddress'] as Map<String, dynamic>?,
      timeline: timelineList,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
