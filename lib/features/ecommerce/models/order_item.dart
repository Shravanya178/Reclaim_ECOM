import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_item.freezed.dart';
part 'order_item.g.dart';

/// Individual item in an order
@freezed
class OrderItem with _$OrderItem {
  const factory OrderItem({
    required String id,
    required String orderId,
    String? materialId,
    required String materialName,
    required String materialType,
    String? materialImageUrl,
    required int quantity,
    required double unitPrice,
    required double subtotal,
    required DateTime createdAt,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
}
