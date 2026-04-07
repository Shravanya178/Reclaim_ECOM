/// Secure Token Storage Service
/// Stores authentication tokens securely
/// Uses encrypted platform storage via flutter_secure_storage.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _lastLoginKey = 'last_login';

  /// Save authentication token
  static Future<void> saveToken({
    required String token,
    String? refreshToken,
    String? userId,
  }) async {
    try {
      await _storage.write(key: _tokenKey, value: token);

      if (refreshToken != null) {
        await _storage.write(key: _refreshTokenKey, value: refreshToken);
      }

      if (userId != null) {
        await _storage.write(key: _userIdKey, value: userId);
      }

      await _storage.write(
        key: _lastLoginKey,
        value: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw Exception('Failed to save token: $e');
    }
  }

  /// Get stored token
  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Get stored refresh token
  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Get stored user ID
  static Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e) {
      return null;
    }
  }

  /// Delete all stored tokens (logout)
  static Future<void> clearTokens() async {
    try {
      await Future.wait([
        _storage.delete(key: _tokenKey),
        _storage.delete(key: _refreshTokenKey),
        _storage.delete(key: _userIdKey),
      ]);
    } catch (e) {
      throw Exception('Failed to clear tokens: $e');
    }
  }

  /// Check if token is expired (basic check based on last login)
  static Future<bool> isTokenExpired({Duration validity = const Duration(hours: 24)}) async {
    try {
      final lastLoginStr = await _storage.read(key: _lastLoginKey);
      
      if (lastLoginStr == null) return true;
      
      final lastLogin = DateTime.parse(lastLoginStr);
      final now = DateTime.now();
      
      return now.difference(lastLogin) > validity;
    } catch (e) {
      return true;
    }
  }

  /// Get time until token expiration
  static Future<Duration?> getTimeUntilExpiration({Duration validity = const Duration(hours: 24)}) async {
    try {
      final lastLoginStr = await _storage.read(key: _lastLoginKey);
      
      if (lastLoginStr == null) return null;
      
      final lastLogin = DateTime.parse(lastLoginStr);
      final expiryTime = lastLogin.add(validity);
      final now = DateTime.now();
      
      if (now.isAfter(expiryTime)) return null;
      
      return expiryTime.difference(now);
    } catch (e) {
      return null;
    }
  }
}
