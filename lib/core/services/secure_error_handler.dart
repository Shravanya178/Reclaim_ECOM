/// Secure Error Handler
/// Converts detailed errors to user-friendly messages
/// without exposing sensitive system information

import 'package:firebase_auth/firebase_auth.dart';

class SecureErrorHandler {
  /// Convert any error to a user-friendly message
  static String getUserFriendlyMessage(dynamic error) {
    // Firebase Auth errors
    if (error is FirebaseAuthException) {
      return _handleFirebaseAuthError(error);
    }

    // Network errors
    if (error.toString().toLowerCase().contains('socket')) {
      return 'Network error. Please check your internet connection.';
    }

    // Timeout errors
    if (error.toString().toLowerCase().contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    // Invalid email errors
    if (error.toString().toLowerCase().contains('email')) {
      return 'Please check your email address.';
    }

    // Rate limiting
    if (error.toString().toLowerCase().contains('too many')) {
      return 'Too many attempts. Please try again later.';
    }

    // Default fallback
    return 'Something went wrong. Please try again later.';
  }

  /// Handle Firebase Authentication specific errors
  static String _handleFirebaseAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Use 12+ characters with uppercase, lowercase, number, and special character.';
      case 'operation-not-allowed':
        return 'This sign-in method is not available.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check and try again.';
      case 'account-exists-with-different-credential':
        return 'An account exists with this email but different sign-in method.';
      case 'invalid-verification-code':
        return 'Invalid verification code.';
      case 'invalid-verification-id':
        return 'Verification failed. Please try again.';
      case 'missing-email':
        return 'Email is required.';
      case 'missing-password':
        return 'Password is required.';
      case 'session-expired':
        return 'Your session has expired. Please sign in again.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again in a few minutes.';
      default:
        // Don't expose raw error code to user
        return 'Authentication failed. Please try again.';
    }
  }

  /// Log error securely (without exposing sensitive data)
  /// In production, send to error tracking service (Sentry, Firebase Crashlytics, etc.)
  static void logError(
    dynamic error,
    StackTrace stackTrace, {
    String? context,
  }) {
    // Only log in debug mode or to secure logging service
    // NEVER log to console in production
    try {
      final errorInfo = {
        'message': error.toString(),
        'type': error.runtimeType.toString(),
        'context': context,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // In production, send to:
      // - Firebase Crashlytics
      // - Sentry
      // - Custom secure logging endpoint

      // Debug output (development only)
      assert(() {
        print('🔴 Error: ${errorInfo['message']}');
        print('📍 Context: ${errorInfo['context']}');
        print('⏰ Time: ${errorInfo['timestamp']}');
        print('Stack Trace:\n$stackTrace');
        return true;
      }());
    } catch (e) {
      // Fail silently to avoid cascading errors
      assert(() {
        print('Error logging failed: $e');
        return true;
      }());
    }
  }

  /// Validate error privacy
  static bool isErrorSafe(String message) {
    // Check if error message contains sensitive info
    final sensitivePatterns = [
      'password',
      'token',
      'secret',
      'key',
      'api',
      'database',
      'server',
      'stack trace',
      'line',
      'file path',
    ];

    return !sensitivePatterns.any(
      (pattern) => message.toLowerCase().contains(pattern),
    );
  }
}
