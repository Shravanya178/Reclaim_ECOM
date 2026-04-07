/// Individual item in an order
class OrderItem {
  final String id;
  final String orderId;
  final String? materialId;
  final String materialName;
  final String materialType;
  final String? materialImageUrl;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final DateTime createdAt;

  const OrderItem({
    required this.id,
    required this.orderId,
    this.materialId,
    required this.materialName,
    required this.materialType,
    this.materialImageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.createdAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      materialId: json['material_id'] as String?,
      materialName: json['material_name'] as String,
      materialType: json['material_type'] as String,
      materialImageUrl: json['material_image_url'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'material_id': materialId,
      'material_name': materialName,
      'material_type': materialType,
      'material_image_url': materialImageUrl,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
