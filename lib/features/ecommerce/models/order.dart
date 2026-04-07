import 'order_item.dart';

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
class Order {
  final String id;
  final String orderNumber;
  final String userId;
  final double totalAmount;
  final double subtotal;
  final double taxAmount;
  final double shippingAmount;
  final double discountAmount;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final ShippingAddress shippingAddress;
  final String? trackingNumber;
  final String? notes;
  final DateTime? cancelledAt;
  final String? cancelledReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem>? items;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.totalAmount,
    required this.subtotal,
    required this.taxAmount,
    required this.shippingAmount,
    required this.discountAmount,
    required this.status,
    required this.paymentStatus,
    required this.shippingAddress,
    this.trackingNumber,
    this.notes,
    this.cancelledAt,
    this.cancelledReason,
    required this.createdAt,
    required this.updatedAt,
    this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      userId: json['user_id'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      taxAmount: (json['tax_amount'] as num).toDouble(),
      shippingAmount: (json['shipping_amount'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num).toDouble(),
      status: OrderStatus.values.byName(json['status'] as String),
      paymentStatus:
          PaymentStatus.values.byName(json['payment_status'] as String),
      shippingAddress: ShippingAddress.fromJson(
          json['shipping_address'] as Map<String, dynamic>),
      trackingNumber: json['tracking_number'] as String?,
      notes: json['notes'] as String?,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      cancelledReason: json['cancelled_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'user_id': userId,
      'total_amount': totalAmount,
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'shipping_amount': shippingAmount,
      'discount_amount': discountAmount,
      'status': status.name,
      'payment_status': paymentStatus.name,
      'shipping_address': shippingAddress.toJson(),
      'tracking_number': trackingNumber,
      'notes': notes,
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancelled_reason': cancelledReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'items': items?.map((e) => e.toJson()).toList(),
    };
  }

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
class ShippingAddress {
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String? phone;

  const ShippingAddress({
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.phone,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      addressLine1: json['address_line1'] as String,
      addressLine2: json['address_line2'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postal_code'] as String,
      country: json['country'] as String,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'phone': phone,
    };
  }

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
