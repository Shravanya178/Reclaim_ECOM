// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'dart:js_util' as js_util;

import 'package:flutter/foundation.dart';
import 'package:reclaim/core/config/app_config.dart';

/// Callback signatures
typedef RzpSuccessCallback = void Function(
    String paymentId, String orderId, String signature);
typedef RzpFailureCallback = void Function(int code, String message);
typedef RzpDismissCallback = void Function();

/// Razorpay JavaScript Checkout integration for Flutter Web / PWA.
///
/// Requires the Razorpay checkout script loaded in web/index.html:
///   <script src="https://checkout.razorpay.com/v1/checkout.js"></script>
class RazorpayWebService {
  /// Opens the Razorpay checkout modal.
  ///
  /// [amountRupees] is in ₹ (converted to paise internally).
  /// [keyId] defaults to the test key — replace with live key for production.
  static void openCheckout({
    required double amountRupees,
    required String orderId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required RzpSuccessCallback onSuccess,
    required RzpFailureCallback onFailure,
    RzpDismissCallback? onDismiss,
    String? keyId, // optional override; defaults to AppConfig.razorpayKeyId
  }) {
    if (!kIsWeb) {
      onFailure(-1, 'Razorpay web checkout is only available on the web.');
      return;
    }

    final resolvedKey = keyId ?? AppConfig.razorpayKeyId;

    try {
      // Build options map
      final options = js.JsObject.jsify({
        'key': resolvedKey,
        'amount': (amountRupees * 100).toInt(), // paise
        'currency': 'INR',
        'name': 'ReClaim',
        'description': 'Order #$orderId',
        'image': '/icons/Icon-192.png',

        // ── Success handler ─────────────────────────────────────────────────
        'handler': js.allowInterop((dynamic response) {
          final paymentId =
              js_util.getProperty<String>(response, 'razorpay_payment_id');
          final rOrderId =
              js_util.getProperty<String>(response, 'razorpay_order_id');
          final signature =
              js_util.getProperty<String>(response, 'razorpay_signature');
          onSuccess(paymentId, rOrderId, signature);
        }),

        // ── Pre-fill customer info ──────────────────────────────────────────
        'prefill': {
          'name': customerName,
          'email': customerEmail,
          'contact': customerPhone,
        },

        // ── Theme ─────────────────────────────────────────────────────────
        'theme': {
          'color': '#2E7D32',
          'backdrop_color': '#00000080',
        },

        // ── Modal behaviour ────────────────────────────────────────────────
        'modal': {
          'ondismiss': js.allowInterop(() {
            onDismiss?.call();
          }),
          'confirm_close': true,
          'escape': false,
          'animation': true,
        },

        // ── Notes (visible in Razorpay dashboard) ──────────────────────────
        'notes': {
          'platform': 'ReClaim PWA',
          'order_ref': orderId,
        },
      });

      // Create Razorpay instance
      final rzp = js.JsObject(
          js.context['Razorpay'] as js.JsFunction, [options]);

      // Listen for payment failures (card declines, network errors, etc.)
      rzp.callMethod('on', [
        'payment.failed',
        js.allowInterop((dynamic failureResponse) {
          try {
            final error =
                js_util.getProperty<dynamic>(failureResponse, 'error');
            final code = js_util.getProperty<int>(error, 'code');
            final desc =
                js_util.getProperty<String>(error, 'description');
            onFailure(code, desc);
          } catch (_) {
            onFailure(-1, 'Payment failed due to an unknown error.');
          }
        }),
      ]);

      rzp.callMethod('open');
    } catch (e) {
      onFailure(-1, 'Could not initialise Razorpay: $e');
    }
  }
}
