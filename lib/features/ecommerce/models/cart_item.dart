/// Individual item in shopping cart
class CartItem {
  final String id;
  final String cartId;
  final String materialId;
  final String materialName;
  final String materialType;
  final String? materialImageUrl;
  final int quantity;
  final double unitPrice;
  final String condition;
  final int stockAvailable;
  final DateTime addedAt;

  const CartItem({
    required this.id,
    required this.cartId,
    required this.materialId,
    required this.materialName,
    required this.materialType,
    this.materialImageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.condition,
    required this.stockAvailable,
    required this.addedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      cartId: json['cart_id'] as String,
      materialId: json['material_id'] as String,
      materialName: json['material_name'] as String,
      materialType: json['material_type'] as String,
      materialImageUrl: json['material_image_url'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      condition: json['condition'] as String,
      stockAvailable: json['stock_available'] as int,
      addedAt: DateTime.parse(json['added_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_id': cartId,
      'material_id': materialId,
      'material_name': materialName,
      'material_type': materialType,
      'material_image_url': materialImageUrl,
      'quantity': quantity,
      'unit_price': unitPrice,
      'condition': condition,
      'stock_available': stockAvailable,
      'added_at': addedAt.toIso8601String(),
    };
  }

  /// Subtotal for this item
  double get subtotal => unitPrice * quantity;

  /// Check if quantity is available in stock
  bool get isAvailable => quantity <= stockAvailable;

  /// Check if out of stock
  bool get isOutOfStock => stockAvailable <= 0;

  /// Maximum quantity that can be added
  int get maxQuantity => stockAvailable.clamp(0, 50);

  CartItem copyWith({
    String? id,
    String? cartId,
    String? materialId,
    String? materialName,
    String? materialType,
    String? materialImageUrl,
    int? quantity,
    double? unitPrice,
    String? condition,
    int? stockAvailable,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      cartId: cartId ?? this.cartId,
      materialId: materialId ?? this.materialId,
      materialName: materialName ?? this.materialName,
      materialType: materialType ?? this.materialType,
      materialImageUrl: materialImageUrl ?? this.materialImageUrl,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      condition: condition ?? this.condition,
      stockAvailable: stockAvailable ?? this.stockAvailable,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
