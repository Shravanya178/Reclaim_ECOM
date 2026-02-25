import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:reclaim/features/ecommerce/models/payment.dart';

/// Abstract payment service interface
abstract class PaymentService {
  Future<PaymentResult> processPayment(PaymentRequest request);
  Future<bool> verifyPayment(String transactionId, String signature);
  Future<RefundResult> processRefund(String transactionId, double amount);
  void dispose();
}

/// Razorpay payment service implementation
class RazorpayPaymentService implements PaymentService {
  late Razorpay _razorpay;
  PaymentResult? _paymentResult;

  RazorpayPaymentService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    try {
      final options = {
        'key': 'rzp_test_1DP5mmOlF5G5ag', // Replace with your key
        'amount': (request.amount * 100).toInt(), // Amount in paise
        'name': 'ReClaim',
        'description': 'Order #${request.orderId}',
        'order_id': request.orderId,
        'prefill': {
          'email': request.email ?? '',
          'contact': request.phone ?? '',
          'name': request.name ?? '',
        },
        'theme': {
          'color': '#2E7D32',
        },
        'modal': {
          'ondismiss': () {
            _paymentResult = const PaymentCancelled();
          }
        }
      };

      _razorpay.open(options);

      // Wait for payment result
      await Future.delayed(const Duration(seconds: 1));
      return _paymentResult ?? const PaymentCancelled();
    } catch (e) {
      return PaymentFailure(
        errorMessage: e.toString(),
      );
    }
  }

  @override
  Future<bool> verifyPayment(String transactionId, String signature) async {
    // Implement signature verification
    // This should be done on the backend for security
    try {
      // TODO: Call backend API to verify payment signature
      return true;
    } catch (e) {
      print('Error verifying payment: $e');
      return false;
    }
  }

  @override
  Future<RefundResult> processRefund(
    String transactionId,
    double amount,
  ) async {
    try {
      // TODO: Implement refund processing via backend
      return RefundResult(
        success: true,
        refundId: 'rfnd_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      return RefundResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _paymentResult = PaymentSuccess(
      transactionId: response.orderId ?? '',
      paymentId: response.paymentId ?? '',
      signature: response.signature,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _paymentResult = PaymentFailure(
      errorMessage: response.message ?? 'Payment failed',
      errorCode: response.code.toString(),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External wallet: ${response.walletName}');
  }

  @override
  void dispose() {
    _razorpay.clear();
  }
}

/// Refund result model
class RefundResult {
  final bool success;
  final String? refundId;
  final String? error;

  RefundResult({
    required this.success,
    this.refundId,
    this.error,
  });
}

/// Mock payment service for testing
class MockPaymentService implements PaymentService {
  @override
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    // Simulate payment delay
    await Future.delayed(const Duration(seconds: 2));

    // Return success for testing
    return PaymentSuccess(
      transactionId: 'test_${DateTime.now().millisecondsSinceEpoch}',
      paymentId: 'pay_${DateTime.now().millisecondsSinceEpoch}',
      signature: 'mock_signature',
    );
  }

  @override
  Future<bool> verifyPayment(String transactionId, String signature) async {
    return true;
  }

  @override
  Future<RefundResult> processRefund(
    String transactionId,
    double amount,
  ) async {
    return RefundResult(
      success: true,
      refundId: 'rfnd_mock',
    );
  }

  @override
  void dispose() {}
}
