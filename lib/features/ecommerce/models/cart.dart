import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart.freezed.dart';
part 'cart.g.dart';

/// Shopping cart model
@freezed
class Cart with _$Cart {
  const factory Cart({
    required String id,
    required String userId,
    required List<CartItem> items,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Cart;

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);
}

const Cart._();

/// Cart summary calculations
extension CartCalculations on Cart {
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
