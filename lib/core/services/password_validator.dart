/// Strong password validation service implementing NIST guidelines
class PasswordValidator {
  /// Validates password against strong password policy
  /// Requirements:
  /// - Minimum 12 characters
  /// - At least 1 uppercase letter
  /// - At least 1 lowercase letter
  /// - At least 1 digit
  /// - At least 1 special character
  /// - No common passwords
  static ValidationResult validatePassword(String password) {
    if (password.isEmpty) {
      return ValidationResult(
        isValid: false,
        errors: ['Password cannot be empty'],
      );
    }

    final errors = <String>[];

    // Length check
    if (password.length < 12) {
      errors.add('Password must be at least 12 characters long');
    }

    // Uppercase check
    if (!password.contains(RegExp(r'[A-Z]'))) {
      errors.add('Password must contain at least one uppercase letter');
    }

    // Lowercase check
    if (!password.contains(RegExp(r'[a-z]'))) {
      errors.add('Password must contain at least one lowercase letter');
    }

    // Digit check
    if (!password.contains(RegExp(r'[0-9]'))) {
      errors.add('Password must contain at least one digit');
    }

    // Special character check
    if (!password.contains(RegExp(r'[!@#$%^&*()_+\-=\[\]{};:"\\|,.<>\/?]'))) {
      errors.add('Password must contain at least one special character');
    }

    // Common password check
    if (isCommonPassword(password)) {
      errors.add('This password is too common. Please choose a stronger password');
    }

    // No user info in password check
    if (password.length > 3 && password.toLowerCase().contains('password')) {
      errors.add('Password should not contain the word "password"');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Check if password is in common password list
  static bool isCommonPassword(String password) {
    final commonPasswords = {
      'Password1!',
      'Pass1word!',
      'Welcome1!',
      'Admin@123',
      'Letmein1!',
      'Qwerty@1',
      'Monkey@1',
      'Dragon@1',
      'Sunshine1!',
      'Summer2024!',
    };

    return commonPasswords.contains(password);
  }

  /// Generate password strength score (0-100)
  static int calculateStrength(String password) {
    int score = 0;

    // Length (0-20 points)
    if (password.length >= 12) score += 10;
    if (password.length >= 16) score += 10;

    // Character variety (0-80 points)
    if (password.contains(RegExp(r'[a-z]'))) score += 20;
    if (password.contains(RegExp(r'[A-Z]'))) score += 20;
    if (password.contains(RegExp(r'[0-9]'))) score += 20;
    if (password.contains(RegExp(r'[!@#$%^&*()_+\-=\[\]{};:"\\|,.<>\/?]'))) score += 20;

    // Entropy bonus
    if (password.length > 16) score += bonus;

    return score > 100 ? 100 : score;
  }

  static const int bonus = 5;
}

/// Result of password validation
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({
    required this.isValid,
    required this.errors,
  });

  String get errorMessage => errors.join(' ');
}
