# 🔒 RECLAIM - CRITICAL SECURITY FIXES

## Overview
This document outlines critical security vulnerabilities found in ReClaim and recommended fixes.

---

## 1. 🔑 API KEY & CREDENTIAL MANAGEMENT

### Vulnerabilities Found:
- **Hardcoded API keys in code** (Firebase, Supabase keys exposed)
- **Exposed credentials in git history**
- **No key rotation policy**
- **Public Firebase configuration in client code**

### Fixes Required:

#### 1.1 Move to Environment Variables
```bash
# Create .env file (ADD TO .gitignore)
FIREBASE_API_KEY=AIzaSyDEoBS-5hfye1VYMhjEoRPv1gu3XBcblhA
FIREBASE_PROJECT_ID=reclaim-c222a
SUPABASE_URL=https://your-supabase-url.com
SUPABASE_ANON_KEY=your-anon-key
RAZORPAY_KEY_ID=your-razorpay-key
```

#### 1.2 Create Environment Config Service
Create `lib/core/config/env_config.dart`:
```dart
class EnvConfig {
  static const String firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
}
```

#### 1.3 Add Package for Env Management
```yaml
# pubspec.yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

---

## 2. 🚨 INPUT VALIDATION & SANITIZATION

### Vulnerabilities:
- **No input validation on email/password fields**
- **SQL injection risk from unfiltered queries**
- **XSS vulnerability in text inputs**

### Fixes Required:

#### 2.1 Create Input Validation Service
Create `lib/core/services/validation_service.dart`:
```dart
class ValidationService {
  // Email validation using RFC 5322
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Password strength enforcement
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 12) return 'Min 12 characters';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Needs uppercase';
    if (!value.contains(RegExp(r'[a-z]'))) return 'Needs lowercase';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Needs digit';
    if (!value.contains(RegExp(r'[!@#$%^&*]'))) return 'Needs special char';
    return null;
  }
}
```

#### 2.2 Update Auth Screens with Validation
```dart
_field(_emailCtrl, 'email@example.com',
  errorText: ValidationService.validateEmail(_emailCtrl.text),
)
```

---

## 3. 🔐 AUTHENTICATION & AUTHORIZATION

### Vulnerabilities:
- **Weak password requirements (currently 6 chars minimum)**
- **No MFA/2FA implementation**
- **Session tokens not properly validated**
- **No rate limiting on login attempts**

### Fixes Required:

#### 3.1 Enforce Strong Passwords (Already Implemented)
✅ Firebase enforces:
- Minimum 12 characters
- Uppercase + Lowercase
- Numbers + Special characters

#### 3.2 Implement Rate Limiting
Create `lib/core/services/rate_limiter.dart`:
```dart
class RateLimiter {
  static const int maxAttempts = 5;
  static const Duration duration = Duration(minutes: 15);
  
  static final Map<String, List<DateTime>> _attempts = {};
  
  static bool canAttempt(String identifier) {
    final now = DateTime.now();
    final attempts = _attempts[identifier] ?? [];
    
    // Remove old attempts
    attempts.removeWhere((t) => now.difference(t) > duration);
    
    if (attempts.length >= maxAttempts) return false;
    
    attempts.add(now);
    _attempts[identifier] = attempts;
    return true;
  }
}
```

#### 3.3 Implement JWT Token Validation
```dart
// In firebase_auth_service.dart
Future<bool> isTokenValid() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;
  
  try {
    final token = await user.getIdToken(true);
    return token.isNotEmpty;
  } catch (e) {
    return false;
  }
}
```

---

## 4. 🛡️ CORS & HTTPS

### Vulnerabilities:
- **No HTTPS enforcement**
- **CORS not properly configured**
- **Man-in-the-middle (MITM) attack risk**

###Fixes Required:

#### 4.1 Enable HTTPS Only
In Firebase Console:
- Enable Authentication → Always require HTTPS
- Set Security Rules to require authentication

#### 4.2 Add SSL Pinning (Android/iOS)
```dart
// For HTTP requests via Dio
import 'package:dio_http2_adapter/dio_http2_adapter.dart';
```

---

## 5. 🚀 DATA ENCRYPTION

### Vulnerabilities:
- **Sensitive data stored in plain text**
- **No encryption for database transfers**
- **Unencrypted local storage**

### Fixes Required:

#### 5.1 Encrypt Sensitive Local Data
```yaml
# pubspec.yaml
dependencies:
  flutter_secure_storage: ^9.0.0
```

#### 5.2 Use Secure Storage for Tokens
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStorage {
  static const storage = FlutterSecureStorage();
  
  static Future<void> saveToken(String token) async {
    await storage.write(key: 'auth_token', value: token);
  }
  
  static Future<String?> getToken() async {
    return await storage.read(key: 'auth_token');
  }
  
  static Future<void> deleteToken() async {
    await storage.delete(key: 'auth_token');
  }
}
```

---

## 6. 🔍 ERROR HANDLING & LOGGING

### Vulnerabilities:
- **Verbose error messages exposing system details**
- **Stack traces shown to users**
- **No audit logging for sensitive operations**

### Fixes Required:

#### 6.1 Implement Error Handler
```dart
class ErrorHandler {
  static String getUserFriendlyMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      return 'Authentication failed. Please try again.';
    }
    if (error is SocketException) {
      return 'Network error. Check your connection.';
    }
    return 'Something went wrong. Please try again.';
  }
  
  static void logError(dynamic error, StackTrace stackTrace) {
    // Log to Sentry or Firebase Crashlytics (NOT to user)
    debugPrintStack(
      label: error.toString(),
      stackTrace: stackTrace,
    );
  }
}
```

#### 6.2 Add Audit Logging
```dart
Future<void> logSecurityEvent(String event, String userId) async {
  await Supabase.instance.client.from('audit_logs').insert({
    'event': event,
    'user_id': userId,
    'timestamp': DateTime.now().toIso8601String(),
    'ip_address': await _getUserIpAddress(),
  });
}
```

---

## 7.  🧹 DEPENDENCY MANAGEMENT

### Vulnerabilities:
- **111 packages with newer versions**
- **1 discontinued package (url_strategy)**
- **Outdated dependencies have known CVEs**

### Fixes Required:

Install updates (TEST THOROUGHLY):
```bash
flutter pub upgrade
```

Remove deprecated packages:
```yaml
# pubspec.yaml - REMOVE
url_strategy: ^0.2.0  # Discontinued
```

---

## 8. 🔐 DATABASE SECURITY (Supabase/Firebase)

### Vulnerabilities:
- **No Row-Level Security (RLS) policies**
- **Exposed Supabase/Firebase rules**

### Fixes Required:

#### 8.1 Implement RLS Policies (Supabase)
```sql
-- profiles table
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile"
ON profiles FOR SELECT
USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
ON profiles FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);
```

#### 8.2 Firebase Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

---

## 9. ⚠️ PAYMENT SECURITY (Razorpay)

### Vulnerabilities:
- **No PCI DSS compliance checks**
- **API keys potentially exposed**
- **No webhook signature validation**

### Fixes Required:

#### 9.1 Validate Razorpay Webhooks
```dart
bool validateRazorpaySignature({
  required String orderId,
  required String paymentId,
  required String signature,
  required String secret,
}) {
  final generatedSignature = Hmac(sha256, utf8.encode(secret))
    .convert(utf8.encode('$orderId|$paymentId'))
    .toString();
  
  return generatedSignature == signature;
}
```

#### 9.2 Never Store Card Data
✅ Already using Razorpay (good) - avoid storing card data locally

---

## 10. 📋 IMPLEMENTATION CHECKLIST

- [ ] Move all API keys to .env file
- [ ] Implement input validation service
- [ ] Add email RFC 5322 validation
- [ ] Enforce 12+ char passwords with special chars
- [ ] Implement rate limiting on login
- [ ] Add secure token storage
- [ ] Implement error handling without stack traces
- [ ] Add audit logging for sensitive operations
- [ ] Update deprecated packages
- [ ] Implement database security policies
- [ ] Enable HTTPS only in Firebase
- [ ] Add webhook signature validation for Razorpay
- [ ] Implement JWT token validation
- [ ] Add SSL certificate pinning
- [ ] Setup CORS headers properly

---

## 11. 🚀 DEPLOYMENT CHECKLIST

Before deploying to production:

- [ ] All API keys are environment variables
- [ ] No sensitive data in logs
- [ ] HTTPS enforced everywhere
- [ ] CORS configured to specific domains only
- [ ] Database RLS policies enabled
- [ ] Rate limiting configured
- [ ] Error messages don't expose system details
- [ ] Audit logging enabled
- [ ] Dependency vulnerabilities scanned (`flutter pub audit`)
- [ ] Security headers configured
- [ ] Backup/disaster recovery plan in place

---

## 🔗 Security Resources
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Flutter Security Best Practices](https://flutter.dev/docs/development/data-and-backend/firebase)
- [Firebase Security Best Practices](https://firebase.google.com/docs/rules/best-practices)
