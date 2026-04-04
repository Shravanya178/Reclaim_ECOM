import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service for sensitive data
/// Uses platform-native encryption (Keychain on iOS, Keystore on Android)
class SecureStorageService {
  static const String _sessionTokenKey = 'auth_session_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _userIdKey = 'auth_user_id';
  static const String _mfaSecretKey = 'mfa_secret';
  static const String _deviceFingerprintKey = 'device_fingerprint';

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(
            keystoreAlias: 'reclaim_key',
            // CRITICAL: Use EncryptedSharedPreferences to ensure encryption
            encryptedSharedPreferencesOnly: true,
            // Reset on app uninstall for security
            resetOnError: true,
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_available,
          ),
        );

  /// Store session token securely
  Future<void> saveSessionToken(String token) async {
    await _storage.write(
      key: _sessionTokenKey,
      value: token,
    );
  }

  /// Retrieve session token
  Future<String?> getSessionToken() async {
    return await _storage.read(key: _sessionTokenKey);
  }

  /// Store refresh token securely
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(
      key: _refreshTokenKey,
      value: token,
    );
  }

  /// Retrieve refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Store user ID (non-sensitive but kept secure for consistency)
  Future<void> saveUserId(String userId) async {
    await _storage.write(
      key: _userIdKey,
      value: userId,
    );
  }

  /// Retrieve user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// Store MFA secret (CRITICAL: never log or display)
  Future<void> saveMfaSecret(String secret) async {
    await _storage.write(
      key: _mfaSecretKey,
      value: secret,
    );
  }

  /// Retrieve MFA secret
  Future<String?> getMfaSecret() async {
    return await _storage.read(key: _mfaSecretKey);
  }

  /// Store device fingerprint for integrity checking
  Future<void> saveDeviceFingerprint(String fingerprint) async {
    await _storage.write(
      key: _deviceFingerprintKey,
      value: fingerprint,
    );
  }

  /// Retrieve device fingerprint
  Future<String?> getDeviceFingerprint() async {
    return await _storage.read(key: _deviceFingerprintKey);
  }

  /// Securely clear all sensitive data on logout
  Future<void> clearAllSecureData() async {
    await Future.wait([
      _storage.delete(key: _sessionTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _mfaSecretKey),
      _storage.delete(key: _deviceFingerprintKey),
    ]);
  }

  /// Delete specific sensitive data without clearing all
  Future<void> deleteSessionTokens() async {
    await Future.wait([
      _storage.delete(key: _sessionTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }
}
