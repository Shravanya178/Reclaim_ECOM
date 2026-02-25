/// Payment method enum
enum PaymentMethod {
  creditCard,
  debitCard,
  upi,
  netBanking,
  wallet,
  cod, // Cash on Delivery
}

/// Payment status from database
enum PaymentStatusType {
  pending,
  processing,
  completed,
  failed,
  refunded,
}

/// Payment model
class Payment {
  final String id;
  final String orderId;
  final double amount;
  final PaymentMethod paymentMethod;
  final PaymentStatusType status;
  final String? transactionId;
  final String? gatewayOrderId;
  final String? gatewayPaymentId;
  final String? gatewaySignature;
  final Map<String, dynamic>? gatewayResponse;
  final String? errorMessage;
  final double? refundAmount;
  final DateTime? refundedAt;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Payment({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.transactionId,
    this.gatewayOrderId,
    this.gatewayPaymentId,
    this.gatewaySignature,
    this.gatewayResponse,
    this.errorMessage,
    this.refundAmount,
    this.refundedAt,
    required this.createdAt,
    this.completedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod:
          PaymentMethod.values.byName(json['payment_method'] as String),
      status: PaymentStatusType.values.byName(json['status'] as String),
      transactionId: json['transaction_id'] as String?,
      gatewayOrderId: json['gateway_order_id'] as String?,
      gatewayPaymentId: json['gateway_payment_id'] as String?,
      gatewaySignature: json['gateway_signature'] as String?,
      gatewayResponse: json['gateway_response'] as Map<String, dynamic>?,
      errorMessage: json['error_message'] as String?,
      refundAmount: (json['refund_amount'] as num?)?.toDouble(),
      refundedAt: json['refunded_at'] != null
          ? DateTime.parse(json['refunded_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'amount': amount,
      'payment_method': paymentMethod.name,
      'status': status.name,
      'transaction_id': transactionId,
      'gateway_order_id': gatewayOrderId,
      'gateway_payment_id': gatewayPaymentId,
      'gateway_signature': gatewaySignature,
      'gateway_response': gatewayResponse,
      'error_message': errorMessage,
      'refund_amount': refundAmount,
      'refunded_at': refundedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  /// Check if payment is successful
  bool get isSuccessful => status == PaymentStatusType.completed;

  /// Check if payment is pending
  bool get isPending =>
      status == PaymentStatusType.pending ||
      status == PaymentStatusType.processing;

  /// Check if payment failed
  bool get isFailed => status == PaymentStatusType.failed;

  /// Get payment method display name
  String get paymentMethodName {
    switch (paymentMethod) {
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.netBanking:
        return 'Net Banking';
      case PaymentMethod.wallet:
        return 'Wallet';
      case PaymentMethod.cod:
        return 'Cash on Delivery';
    }
  }
}

/// Payment request model for initiating payment
class PaymentRequest {
  final String orderId;
  final double amount;
  final PaymentMethod paymentMethod;
  final String? email;
  final String? phone;
  final String? name;

  const PaymentRequest({
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    this.email,
    this.phone,
    this.name,
  });

  factory PaymentRequest.fromJson(Map<String, dynamic> json) {
    return PaymentRequest(
      orderId: json['order_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod:
          PaymentMethod.values.byName(json['payment_method'] as String),
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'amount': amount,
      'payment_method': paymentMethod.name,
      'email': email,
      'phone': phone,
      'name': name,
    };
  }
}

/// Payment result after processing
sealed class PaymentResult {
  const PaymentResult();
}

class PaymentSuccess extends PaymentResult {
  final String transactionId;
  final String paymentId;
  final String? signature;

  const PaymentSuccess({
    required this.transactionId,
    required this.paymentId,
    this.signature,
  });
}

class PaymentFailure extends PaymentResult {
  final String errorMessage;
  final String? errorCode;

  const PaymentFailure({
    required this.errorMessage,
    this.errorCode,
  });
}

class PaymentCancelled extends PaymentResult {
  const PaymentCancelled();
}
