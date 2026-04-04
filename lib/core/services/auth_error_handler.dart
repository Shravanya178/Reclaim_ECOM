/// SECURITY FIX: Generic error messages to prevent user enumeration
/// Never reveal if email exists or doesn't exist in error messages
class AuthErrorHandler {
  /// Convert auth exceptions to generic user-friendly messages
  /// Prevents information disclosure and user enumeration attacks
  static String getFriendlyErrorMessage(String? error) {
    if (error == null || error.isEmpty) {
      return 'Authentication failed. Please try again.';
    }

    final lowerError = error.toLowerCase();

    // SECURITY: Map specific errors to generic messages
    // This prevents attackers from enumerating valid email addresses

    // Invalid credentials - be generic
    if (lowerError.contains('invalid login credentials') ||
        lowerError.contains('invalid email or password') ||
        lowerError.contains('user not found')) {
      return 'Invalid email or password. Please try again.';
    }

    // User already exists - don't reveal why
    if (lowerError.contains('user already registered') ||
        lowerError.contains('already exists')) {
      return 'This account could not be created. Please try signing in.';
    }

    // Email validation
    if (lowerError.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }

    // Password too short/weak
    if (lowerError.contains('password')) {
      return 'Password does not meet security requirements. Please try another.';
    }

    // Network errors
    if (lowerError.contains('timeout') || lowerError.contains('timed out')) {
      return 'Connection timed out. Please check your internet and try again.';
    }

    if (lowerError.contains('network') || lowerError.contains('connection')) {
      return 'Network error. Please check your connection and try again.';
    }

    // Account locked (rate limiting)
    if (lowerError.contains('too many requests') ||
        lowerError.contains('locked') ||
        lowerError.contains('rate limit')) {
      return 'Too many login attempts. Please try again in 15 minutes.';
    }

    // Email confirmation needed
    if (lowerError.contains('confirm') || lowerError.contains('verification')) {
      return 'Please verify your email before signing in.';
    }

    // Default: Generic error
    return 'Something went wrong. Please try again later.';
  }

  /// Check if error indicates account locked (rate limiting)
  static bool isAccountLocked(String? error) {
    if (error == null) return false;
    final lower = error.toLowerCase();
    return lower.contains('too many attempts') ||
        lower.contains('locked') ||
        lower.contains('rate limit');
  }

  /// Check if error is retriable
  static bool isRetriable(String? error) {
    if (error == null) return false;
    final lower = error.toLowerCase();
    return lower.contains('timeout') ||
        lower.contains('network') ||
        lower.contains('temporarily');
  }

  /// Log security event without exposing sensitive info
  /// In production, send to security logging service
  static void logSecurityEvent(String eventType, String email, String? error) {
    // SECURITY: Never log full error messages or email addresses
    // Only log event type and sanitized error category
    final eventData = {
      'event': eventType,
      'timestamp': DateTime.now().toIso8601String(),
      // Don't log email - use hashed identifier instead in production
      'email_hash': _hashEmail(email),
      'error_category': _categorizeError(error),
    };

    // In production: Send to security logging service
    // Example: FirebaseAnalytics, DataDog, custom backend
    print('[SECURITY_EVENT] ${eventData.toString()}');
  }

  /// Hash email for logging (not reversible)
  static String _hashEmail(String email) {
    // SECURITY: In production, use proper hashing with salt
    // This is simplified for demo
    return email.hashCode.toString();
  }

  /// Categorize error without exposing details
  static String _categorizeError(String? error) {
    if (error == null) return 'unknown';
    final lower = error.toLowerCase();

    if (lower.contains('invalid')) return 'invalid_credentials';
    if (lower.contains('not found')) return 'user_not_found';
    if (lower.contains('password')) return 'weak_password';
    if (lower.contains('network')) return 'network_error';
    if (lower.contains('timeout')) return 'timeout';
    if (lower.contains('rate limit') || lower.contains('too many')) {
      return 'rate_limited';
    }

    return 'other';
  }
}
