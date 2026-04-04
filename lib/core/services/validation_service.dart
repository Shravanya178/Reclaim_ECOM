/// Email and Password Validation Service
class ValidationService {
  /// Email regex pattern (RFC 5322 simplified)
  static final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Validate email format
  /// Returns: null if valid, error message if invalid
  static String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email is required';
    }

    if (email.length > 254) {
      return 'Email is too long (max 254 characters)';
    }

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    return null; // Valid
  }

  /// Validate password strength
  /// Requirements:
  /// - Minimum 12 characters
  /// - At least 1 uppercase letter
  /// - At least 1 lowercase letter
  /// - At least 1 digit
  /// - At least 1 special character
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 12) {
      return 'Password must be at least 12 characters long';
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter (A-Z)';
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter (a-z)';
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one digit (0-9)';
    }

    if (!password.contains(RegExp(r'[!@#$%^&*()_+\-=\[\]{};:"\\|,.<>\/?]'))) {
      return 'Password must contain at least one special character (!@#\$%^&* etc.)';
    }

    return null; // Valid
  }

  /// Validate full name
  static String? validateFullName(String name) {
    if (name.isEmpty) {
      return 'Full name is required';
    }

    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (name.length > 100) {
      return 'Name is too long (max 100 characters)';
    }

    // Basic check for valid characters (no excessive special chars)
    if (!RegExp(r"^[a-zA-Z\s'\-]+$").hasMatch(name)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null; // Valid
  }

  /// Calculate password strength score (0-100)
  static int calculatePasswordStrength(String password) {
    int score = 0;

    // Length (0-25 points)
    if (password.length >= 12) score += 10;
    if (password.length >= 16) score += 10;
    if (password.length >= 20) score += 5;

    // Character variety (0-75 points)
    if (password.contains(RegExp(r'[a-z]'))) score += 15;
    if (password.contains(RegExp(r'[A-Z]'))) score += 15;
    if (password.contains(RegExp(r'[0-9]'))) score += 15;
    if (password.contains(RegExp(r'[!@#$%^&*()_+\-=\[\]{};:"\\|,.<>\/?]'))) score += 15;

    // No common patterns penalty
    if (_hasCommonPattern(password)) score -= 15;

    return score > 100 ? 100 : score < 0 ? 0 : score;
  }

  /// Check for common weak patterns
  static bool _hasCommonPattern(String password) {
    final commonPatterns = [
      'password', 'letmein', 'admin', 'qwerty', '12345', 'welcome',
      'dragon', 'master', 'monkey', 'sunshine', 'summer',
    ];

    final lower = password.toLowerCase();
    return commonPatterns.any((pattern) => lower.contains(pattern));
  }

  /// Get password strength label
  static String getStrengthLabel(int score) {
    if (score < 25) return 'Weak';
    if (score < 50) return 'Fair';
    if (score < 75) return 'Good';
    return 'Strong';
  }

  /// Get password strength color
  static int getStrengthColor(int score) {
    if (score < 25) return 0xFFEF5350; // Red
    if (score < 50) return 0xFFFFA726; // Orange
    if (score < 75) return 0xFFAB47BC; // Purple
    return 0xFF66BB6A; // Green
  }
}
