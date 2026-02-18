import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_item.freezed.dart';
part 'cart_item.g.dart';

/// Individual item in shopping cart
@freezed
class CartItem with _$CartItem {
  const factory CartItem({
    required String id,
    required String cartId,
    required String materialId,
    required String materialName,
    required String materialType,
    String? materialImageUrl,
    required int quantity,
    required double unitPrice,
    required String condition,
    required int stockAvailable,
    required DateTime addedAt,
  }) = _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);
}

const CartItem._();

/// Cart item calculations
extension CartItemCalculations on CartItem {
  /// Subtotal for this item
  double get subtotal => unitPrice * quantity;

  /// Check if quantity is available in stock
  bool get isAvailable => quantity <= stockAvailable;

  /// Check if out of stock
  bool get isOutOfStock => stockAvailable <= 0;

  /// Maximum quantity that can be added
  int get maxQuantity => stockAvailable.clamp(0, 50);
}
