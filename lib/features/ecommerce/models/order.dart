import 'package:freezed_annotation/freezed_annotation.dart';

part 'order.freezed.dart';
part 'order.g.dart';

/// Order status enum
enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
}

/// Payment status enum
enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded,
}

/// Order model
@freezed
class Order with _$Order {
  const factory Order({
    required String id,
    required String orderNumber,
    required String userId,
    required double totalAmount,
    required double subtotal,
    required double taxAmount,
    required double shippingAmount,
    required double discountAmount,
    required OrderStatus status,
    required PaymentStatus paymentStatus,
    required ShippingAddress shippingAddress,
    String? trackingNumber,
    String? notes,
    DateTime? cancelledAt,
    String? cancelledReason,
    required DateTime createdAt,
    required DateTime updatedAt,
    List<OrderItem>? items,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}

const Order._();

/// Order helper methods
extension OrderHelpers on Order {
  /// Check if order can be cancelled
  bool get canBeCancelled =>
      status == OrderStatus.pending || status == OrderStatus.confirmed;

  /// Check if order is in progress
  bool get isInProgress =>
      status == OrderStatus.processing || status == OrderStatus.shipped;

  /// Check if order is completed
  bool get isCompleted => status == OrderStatus.delivered;

  /// Check if order is cancelled or refunded
  bool get isCancelledOrRefunded =>
      status == OrderStatus.cancelled || status == OrderStatus.refunded;

  /// Get status display text
  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
    }
  }

  /// Get payment status display text
  String get paymentStatusText {
    switch (paymentStatus) {
      case PaymentStatus.pending:
        return 'Payment Pending';
      case PaymentStatus.completed:
        return 'Payment Completed';
      case PaymentStatus.failed:
        return 'Payment Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }
}

/// Shipping address model
@freezed
class ShippingAddress with _$ShippingAddress {
  const factory ShippingAddress({
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String postalCode,
    required String country,
    String? phone,
  }) = _ShippingAddress;

  factory ShippingAddress.fromJson(Map<String, dynamic> json) =>
      _$ShippingAddressFromJson(json);
}

const ShippingAddress._();

extension ShippingAddressHelpers on ShippingAddress {
  /// Get formatted address as single string
  String get formattedAddress {
    final parts = [
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2,
      city,
      state,
      postalCode,
      country,
    ];
    return parts.join(', ');
  }
}
