import 'cart_item.dart';

/// Shopping cart model
class Cart {
  final String id;
  final String userId;
  final List<CartItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Cart({
    required this.id,
    required this.userId,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => CartItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'items': items.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Total number of items in cart
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Subtotal price before tax and shipping
  double get subtotal => items.fold(
        0.0,
        (sum, item) => sum + (item.unitPrice * item.quantity),
      );

  /// Estimated tax (18% GST for India)
  double get taxAmount => subtotal * 0.18;

  /// Estimated shipping cost
  double get shippingAmount {
    if (subtotal >= 1000) return 0.0; // Free shipping over 1000
    return 50.0; // Flat rate shipping
  }

  /// Total cart value
  double get total => subtotal + taxAmount + shippingAmount;

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Check if cart has items
  bool get isNotEmpty => items.isNotEmpty;
}
