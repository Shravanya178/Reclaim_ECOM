import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

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
@freezed
class Payment with _$Payment {
  const factory Payment({
    required String id,
    required String orderId,
    required double amount,
    required PaymentMethod paymentMethod,
    required PaymentStatusType status,
    String? transactionId,
    String? gatewayOrderId,
    String? gatewayPaymentId,
    String? gatewaySignature,
    Map<String, dynamic>? gatewayResponse,
    String? errorMessage,
    double? refundAmount,
    DateTime? refundedAt,
    required DateTime createdAt,
    DateTime? completedAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
}

const Payment._();

extension PaymentHelpers on Payment {
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
@freezed
class PaymentRequest with _$PaymentRequest {
  const factory PaymentRequest({
    required String orderId,
    required double amount,
    required PaymentMethod paymentMethod,
    String? email,
    String? phone,
    String? name,
  }) = _PaymentRequest;

  factory PaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$PaymentRequestFromJson(json);
}

/// Payment result after processing
@freezed
class PaymentResult with _$PaymentResult {
  const factory PaymentResult.success({
    required String transactionId,
    required String paymentId,
    String? signature,
  }) = PaymentSuccess;

  const factory PaymentResult.failure({
    required String errorMessage,
    String? errorCode,
  }) = PaymentFailure;

  const factory PaymentResult.cancelled() = PaymentCancelled;
}
