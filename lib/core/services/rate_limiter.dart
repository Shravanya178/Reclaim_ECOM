/// Rate Limiter Service
/// Prevents brute force attacks by limiting login attempts
class RateLimiter {
  static const int maxAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  
  static final Map<String, List<DateTime>> _attempts = {};
  static final Map<String, DateTime> _lockedOut = {};

  /// Check if an identifier can attempt an action
  static bool canAttempt(String identifier) {
    final now = DateTime.now();
    
    // Check if currently locked out
    if (_lockedOut.containsKey(identifier)) {
      final lockoutEnd = _lockedOut[identifier]!;
      if (now.isBefore(lockoutEnd)) {
        return false; // Still locked out
      } else {
        _lockedOut.remove(identifier); // Lockout expired
      }
    }
    
    // Clean up old attempts
    var attempts = _attempts[identifier] ?? [];
    attempts.removeWhere((t) => now.difference(t) > lockoutDuration);
    
    if (attempts.length >= maxAttempts) {
      // Lock out this identifier
      _lockedOut[identifier] = now.add(lockoutDuration);
      _attempts.remove(identifier);
      return false;
    }
    
    // Record this attempt
    attempts.add(now);
    _attempts[identifier] = attempts;
    return true;
  }

  /// Get remaining attempts
  static int getRemainingAttempts(String identifier) {
    final now = DateTime.now();
    var attempts = _attempts[identifier] ?? [];
    attempts.removeWhere((t) => now.difference(t) > lockoutDuration);
    return maxAttempts - attempts.length;
  }

  /// Get lockout time remaining (in seconds)
  static int? getLockedOutTimeRemaining(String identifier) {
    if (!_lockedOut.containsKey(identifier)) return null;
    
    final remaining = _lockedOut[identifier]!.difference(DateTime.now());
    if (remaining.isNegative) return null;
    
    return remaining.inSeconds;
  }

  /// Reset attempts for an identifier (call after successful login)
  static void resetAttempts(String identifier) {
    _attempts.remove(identifier);
    _lockedOut.remove(identifier);
  }

  /// Clear all data (useful for testing)
  static void clear() {
    _attempts.clear();
    _lockedOut.clear();
  }
}
