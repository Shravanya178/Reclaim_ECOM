import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/payment.dart';

/// Repository for payment operations
class PaymentRepository {
  final SupabaseClient _supabase;

  PaymentRepository(this._supabase);

  /// Create payment record
  Future<Payment?> createPayment({
    required String orderId,
    required double amount,
    required PaymentMethod paymentMethod,
    String? gatewayOrderId,
  }) async {
    try {
      final response = await _supabase.from('payments').insert({
        'order_id': orderId,
        'amount': amount,
        'payment_method': _paymentMethodToString(paymentMethod),
        'payment_status': 'pending',
        'gateway_order_id': gatewayOrderId,
      }).select().single();

      return _paymentFromJson(response);
    } catch (e) {
      print('Error creating payment: $e');
      return null;
    }
  }

  /// Update payment status
  Future<bool> updatePaymentStatus({
    required String paymentId,
    required PaymentStatusType status,
    String? transactionId,
    String? gatewayPaymentId,
    String? gatewaySignature,
    Map<String, dynamic>? gatewayResponse,
    String? errorMessage,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'payment_status': status.name,
      };

      if (transactionId != null) updateData['transaction_id'] = transactionId;
      if (gatewayPaymentId != null) {
        updateData['gateway_payment_id'] = gatewayPaymentId;
      }
      if (gatewaySignature != null) {
        updateData['gateway_signature'] = gatewaySignature;
      }
      if (gatewayResponse != null) {
        updateData['gateway_response'] = gatewayResponse;
      }
      if (errorMessage != null) updateData['error_message'] = errorMessage;

      if (status == PaymentStatusType.completed) {
        updateData['completed_at'] = DateTime.now().toIso8601String();
      }

      await _supabase
          .from('payments')
          .update(updateData)
          .eq('id', paymentId);

      return true;
    } catch (e) {
      print('Error updating payment status: $e');
      return false;
    }
  }

  /// Get payment by order ID
  Future<Payment?> getPaymentByOrderId(String orderId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select()
          .eq('order_id', orderId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return _paymentFromJson(response);
    } catch (e) {
      print('Error fetching payment: $e');
      return null;
    }
  }

  /// Get payment by ID
  Future<Payment?> getPayment(String paymentId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select()
          .eq('id', paymentId)
          .single();

      return _paymentFromJson(response);
    } catch (e) {
      print('Error fetching payment: $e');
      return null;
    }
  }

  /// Process refund
  Future<bool> processRefund({
    required String paymentId,
    required double refundAmount,
  }) async {
    try {
      await _supabase.from('payments').update({
        'payment_status': 'refunded',
        'refund_amount': refundAmount,
        'refunded_at': DateTime.now().toIso8601String(),
      }).eq('id', paymentId);

      return true;
    } catch (e) {
      print('Error processing refund: $e');
      return false;
    }
  }

  /// Get user's payment history
  Future<List<Payment>> getUserPayments(String userId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select('''
            *,
            order:orders!inner(user_id)
          ''')
          .eq('order.user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => _paymentFromJson(json)).toList();
    } catch (e) {
      print('Error fetching user payments: $e');
      return [];
    }
  }

  /// Helper to convert JSON to Payment
  Payment _paymentFromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      orderId: json['order_id'],
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: _stringToPaymentMethod(json['payment_method']),
      status: PaymentStatusType.values.firstWhere(
        (e) => e.name == json['payment_status'],
        orElse: () => PaymentStatusType.pending,
      ),
      transactionId: json['transaction_id'],
      gatewayOrderId: json['gateway_order_id'],
      gatewayPaymentId: json['gateway_payment_id'],
      gatewaySignature: json['gateway_signature'],
      gatewayResponse: json['gateway_response'],
      errorMessage: json['error_message'],
      refundAmount: json['refund_amount'] != null
          ? (json['refund_amount'] as num).toDouble()
          : null,
      refundedAt: json['refunded_at'] != null
          ? DateTime.parse(json['refunded_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }

  /// Convert PaymentMethod to string for database
  String _paymentMethodToString(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'credit_card';
      case PaymentMethod.debitCard:
        return 'debit_card';
      case PaymentMethod.upi:
        return 'upi';
      case PaymentMethod.netBanking:
        return 'net_banking';
      case PaymentMethod.wallet:
        return 'wallet';
      case PaymentMethod.cod:
        return 'cod';
    }
  }

  /// Convert string to PaymentMethod
  PaymentMethod _stringToPaymentMethod(String? method) {
    switch (method) {
      case 'credit_card':
        return PaymentMethod.creditCard;
      case 'debit_card':
        return PaymentMethod.debitCard;
      case 'upi':
        return PaymentMethod.upi;
      case 'net_banking':
        return PaymentMethod.netBanking;
      case 'wallet':
        return PaymentMethod.wallet;
      case 'cod':
        return PaymentMethod.cod;
      default:
        return PaymentMethod.upi;
    }
  }
}
