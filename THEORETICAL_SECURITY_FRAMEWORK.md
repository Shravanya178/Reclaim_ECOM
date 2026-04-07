# Risk Assessment and Security Implementation for E-Commerce Systems: A Comprehensive Framework

## Executive Summary

This document provides a comprehensive framework for conducting risk assessments and implementing security controls for e-commerce platforms. It combines theoretical foundations with practical implementation patterns, drawing from NIST guidelines, OWASP standards, and PCI-DSS requirements. This document serves as both a reference manual and a strategic roadmap for security professionals and development teams.

---

## Table of Contents

1. [Theoretical Foundations](#theoretical-foundations)
2. [Risk Assessment Framework](#risk-assessment-framework)
3. [Authentication & Authorization Security](#authentication--authorization-security)
4. [Payment Gateway Security](#payment-gateway-security)
5. [Data Protection & Encryption](#data-protection--encryption)
6. [API Security Architecture](#api-security-architecture)
7. [Infrastructure & Network Security](#infrastructure--network-security)
8. [Incident Response & Compliance](#incident-response--compliance)

---

## 1. Theoretical Foundations

### 1.1 Defense in Depth: The Multi-Layer Security Model

The principle of Defense in Depth states that security cannot rely on a single defensive measure. Instead, multiple overlapping security controls should be implemented to provide redundancy and resilience. This model creates a security perimeter with successive layers:

```
┌─────────────────────────────────────────────────────────────┐
│  Application & Business Logic Layer (Input Validation)      │
├─────────────────────────────────────────────────────────────┤
│  API & Communication Layer (Encryption, Rate Limiting)      │
├─────────────────────────────────────────────────────────────┤
│  Database & Data Layer (Encryption, Access Control)         │
├─────────────────────────────────────────────────────────────┤
│  Infrastructure Layer (Firewalls, DDoS Protection)          │
├─────────────────────────────────────────────────────────────┤
│  Monitoring & Detection Layer (Logging, Alerting)           │
└─────────────────────────────────────────────────────────────┘
```

**Benefits:**
- **Damage Containment**: If one layer is compromised, others prevent lateral movement
- **Resilience**: System continues functioning despite individual control failures
- **Attack Cost**: Increases attacker effort exponentially
- **Detection**: Multiple touchpoints enable threat identification

### 1.2 The CIA Triad: Core Security Objectives

All security controls map to three fundamental objectives:

#### **Confidentiality**: Information is accessible only to authorized parties
- *Theoretical basis*: Information asymmetry prevents unauthorized access
- *Implementation*: Encryption, access controls, authentication
- *Metrics*: Data breach incidents, unauthorized access attempts

#### **Integrity**: Information cannot be altered by unauthorized parties
- *Theoretical basis*: Tamper detection prevents unauthorized modifications
- *Implementation*: Digital signatures, checksums, audit logs
- *Metrics*: Data corruption incidents, failed integrity checks

#### **Availability**: Information is accessible when needed by authorized parties
- *Theoretical basis*: System resilience prevents service disruption
- *Implementation*: Redundancy, load balancing, DDoS protection
- *Metrics*: Uptime percentage, mean time to recovery (MTTR)

### 1.3 Threat Modeling: Systematic Risk Identification

Threat modeling identifies potential attacks before they occur. The STRIDE model categorizes threats:

```
STRIDE Analysis Framework
├── Spoofing (Identity)
│   └── Fake accounts, credential stuffing, JWT forgery
├── Tampering (Integrity)
│   └── Man-in-the-middle, database injection, file modification
├── Repudiation (Non-repudiation)
│   └── Denying actions, transaction disputes, audit trail gaps
├── Information Disclosure
│   └── Data leaks, user enumeration, error message exposure
├── Denial of Service
│   └── DDoS, resource exhaustion, brute force attacks
└── Elevation of Privilege
    └── Unauthorized access, broken access control, IDOR vulnerabilities
```

For e-commerce systems specifically:
- **Spoofing**: Fraudulent user accounts for stolen goods
- **Tampering**: Order modification, price manipulation
- **Repudiation**: Customer claims they didn't make purchase
- **Information Disclosure**: Payment data exposure, customer PII
- **Denial of Service**: Platform unavailability during peak sales
- **Elevation of Privilege**: Admin access to modify orders/prices

---

## 2. Risk Assessment Framework

### 2.1 Quantitative Risk Analysis (QRA)

Risk is calculated as:

```
Risk = Threat Probability × Impact Severity × Vulnerability Exploitability

Where:
- Threat Probability: Likelihood of attack occurring (0-1)
- Impact Severity: Business damage if compromise occurs (0-100)
- Vulnerability Exploitability: How easily vulnerability can be exploited (0-1)
```

**Example: Unencrypted Token Storage**

```
Threat Probability: 0.8 (attackers frequently target mobile apps)
Impact Severity: 95 (account takeover, fraud)
Exploitability: 0.9 (SharedPreferences easily readable on rooted devices)

Risk Score = 0.8 × 95 × 0.9 = 68.4/100 = CRITICAL
```

### 2.2 NIST Risk Assessment Methodology

The NIST Cybersecurity Framework defines 5 functions:

```
1. IDENTIFY
   ├── Asset Inventory: Catalog all systems, data, applications
   ├── Business Context: Understand mission criticality
   └── Governance: Define security policies and objectives

2. PROTECT
   ├── Access Control: Authentication, authorization, MFA
   ├── Data Security: Encryption, cryptography, key management
   ├── Infrastructure: Secure configuration, network segmentation
   └── Resilience: Backup, disaster recovery, redundancy

3. DETECT
   ├── Monitoring: Log aggregation, SIEM systems
   ├── Detection: Anomaly detection, intrusion detection
   └── Situational Awareness: Real-time threat visibility

4. RESPOND
   ├── Planning: Incident response procedures
   ├── Communication: Alert and escalation chains
   └── Analysis: Root cause identification

5. RECOVER
   ├── Recovery Planning: Restoration procedures
   ├── Improvements: Lessons learned, control updates
   └── Communication: Stakeholder notification
```

### 2.3 Asset Classification and Criticality Assessment

Classify assets by criticality:

```
TIER 1 (CRITICAL)
├── Payment Processing System
├── Customer Database (PII)
│   └── Risk: Financial fraud, identity theft
├── Authentication System
│   └── Risk: Account takeover, unauthorized access
└── Financial Records
    └── Risk: Compliance violations, audit failures

TIER 2 (HIGH)
├── E-commerce Platform
├── Customer Support System
└── Analytics & Reporting

TIER 3 (MEDIUM)
├── Marketing Systems
├── Content Management
└── Internal Tools

TIER 4 (LOW)
├── Public Website
└── Non-sensitive Documentation
```

---

## 3. Authentication & Authorization Security

### 3.1 Password Security: Evolution from Weak to Strong

#### **Weak Password Policies (DO NOT USE)**
```
❌ Minimum 6 characters "password123"
❌ No complexity requirements "aaaaaaaaaa"
❌ No expiration policy
❌ Reuse allowed
```

**Why they fail:**
- Easily brute-forced: 6-character passwords have only 2.1 trillion combinations
- Modern GPUs can test billions per second: 2.1T ÷ 1B/s = ~35 minutes
- Dictionary attacks succeed within seconds

#### **Strong Password Policies (IMPLEMENT)**
```
✓ Minimum 12 characters (complexity: 94^12 = 475 quintillion)
✓ Uppercase + Lowercase + Digits + Special characters
✓ No common patterns or dictionary words
✓ No user information (name, email, username)
✓ Breach database checking (HaveIBeenPwned.com API)
```

**Why they work:**
- 12-character strong password: ~475 quintillion combinations
- GPU attack time: 475Q ÷ 10B/s = 15 million years
- Entropy: 78.1 bits (strong cryptographic entropy)

**Implementation Strategy:**

```dart
// Strong password validation
class PasswordValidator {
  static const int MIN_LENGTH = 12;
  static const bool REQUIRE_UPPERCASE = true;
  static const bool REQUIRE_LOWERCASE = true;
  static const bool REQUIRE_DIGITS = true;
  static const bool REQUIRE_SPECIAL_CHARS = true;

  static bool validate(String password) {
    if (password.length < MIN_LENGTH) return false;
    if (REQUIRE_UPPERCASE && !password.contains(RegExp(r'[A-Z]'))) return false;
    if (REQUIRE_LOWERCASE && !password.contains(RegExp(r'[a-z]'))) return false;
    if (REQUIRE_DIGITS && !password.contains(RegExp(r'[0-9]'))) return false;
    if (REQUIRE_SPECIAL_CHARS && 
        !password.contains(RegExp(r'[!@#$%^&*()_+\-=\[\]{};:"\\|,.<>\/?]'))) {
      return false;
    }
    
    // Check against common/breached passwords
    return !isCommonPassword(password) && !isBreachedPassword(password);
  }
}
```

### 3.2 Multi-Factor Authentication (MFA/2FA)

MFA combines multiple authentication factors to verify identity:

```
FACTOR CATEGORIES:

1. SOMETHING YOU KNOW (Knowledge Factor)
   └── Password, PIN, security questions
   └── Vulnerability: User enumeration, weak passwords

2. SOMETHING YOU HAVE (Possession Factor)
   └── Authenticator app, hardware token, SMS
   └── Vulnerability: SIM swapping, device theft

3. SOMETHING YOU ARE (Biometric Factor)
   └── Fingerprint, face recognition, iris scan
   └── Vulnerability: Spoofing, replay attacks

4. SOMETHING YOU DO (Behavioral Factor)
   └── Keystroke dynamics, mouse movements
   └── Vulnerability: Machine learning attacks

5. SOMEWHERE YOU ARE (Geolocation Factor)
   └── GPS, network location, VPN detection
   └── Vulnerability: Location spoofing
```

**MFA Implementation: Time-based One-Time Password (TOTP)**

```dart
// Generate MFA secret during account setup
Future<String> generateMfaSecret() async {
  // Use a cryptographically secure random generator
  final random = Random.secure();
  final values = List<int>.generate(32, (i) => random.nextInt(256));
  
  // Encode as base32 for TOTP compatibility
  final secret = base32encode(values);
  
  // Store securely in flutter_secure_storage
  await secureStorage.saveMfaSecret(secret);
  
  // Generate QR code for authenticator app
  final qrCode = _generateQrCode(secret, userEmail);
  
  return secret; // Display once, user scans QR in authenticator
}

// Verify TOTP during login
Future<bool> verifyTotp(String userProvidedCode) async {
  final storedSecret = await secureStorage.getMfaSecret();
  
  // TOTP generates 6-digit code every 30 seconds
  // Check current and previous time window for clock drift
  final now = DateTime.now();
  final counter = (now.millisecondsSinceEpoch / 30000).floor();
  
  for (int offset = -1; offset <= 1; offset++) {
    final code = _generateTotp(storedSecret, counter + offset);
    if (code == userProvidedCode) {
      return true; // Valid MFA code
    }
  }
  
  return false; // Invalid or expired code
}

// Generate HMAC-SHA1 based TOTP
String _generateTotp(String secret, int counter) {
  final key = base32decode(secret);
  final msg = _int64ToBytes(counter);
  
  final hmac = Hmac(sha1, key);
  final hash = hmac.convert(msg);
  
  final offset = hash.bytes[hash.bytes.length - 1] & 0xf;
  final code = bytesToInt32(hash.bytes.sublist(offset, offset + 4)) & 0x7fffffff;
  
  return (code % 1000000).toString().padLeft(6, '0');
}
```

**Backup Codes for Account Recovery:**

```dart
// Generate recovery codes during MFA setup
Future<List<String>> generateRecoveryCodes() async {
  final codes = <String>[];
  final random = Random.secure();
  
  for (int i = 0; i < 10; i++) {
    // 8-character hex codes
    final code = '${random.nextInt(0x100000000):08x}';
    codes.add(code);
  }
  
  // Store hashed codes in database (never store plaintext)
  final hashedCodes = codes.map((c) => sha256.convert(utf8.encode(c))).toList();
  await database.saveMfaBackupCodes(userId, hashedCodes);
  
  // Display to user (ONLY ONCE) - user saves offline
  return codes; // User screenshots and stores safely
}

// Use recovery code
Future<bool> useRecoveryCode(String code) async {
  final hashedCode = sha256.convert(utf8.encode(code)).toString();
  
  final matches = await database.verifyMfaBackupCode(userId, hashedCode);
  if (matches) {
    // Code valid - delete it so it can't be reused
    await database.deleteMfaBackupCode(userId, hashedCode);
    return true;
  }
  
  return false;
}
```

### 3.3 Authorization: Role-Based Access Control (RBAC)

RBAC maps user roles to permissions:

```
RBAC MODEL

Users → Roles → Permissions → Resources

Example E-Commerce Roles:

STUDENT_ROLE:
├── Permissions: ['view_materials', 'create_request', 'contact_seller']
├── Restrictions: Cannot modify others' materials, cannot approve orders
└── Access Level: read, read-write

LAB_ROLE:
├── Permissions: ['upload_materials', 'manage_inventory', 'respond_requests']
├── Restrictions: Cannot modify payment settings, limited analytics
└── Access Level: read-write

ADMIN_ROLE:
├── Permissions: ALL
├── Restrictions: None (emergency access only, logged)
└── Access Level: read-write-delete

IMPLEMENTATION: Database Model

CREATE TABLE roles (
  id UUID PRIMARY KEY,
  name TEXT UNIQUE NOT NULL,
  description TEXT,
  created_at TIMESTAMP
);

CREATE TABLE permissions (
  id UUID PRIMARY KEY,
  name TEXT UNIQUE NOT NULL,
  resource TEXT NOT NULL,
  action TEXT NOT NULL, -- read, write, delete, admin
  description TEXT
);

CREATE TABLE role_permissions (
  role_id UUID REFERENCES roles(id),
  permission_id UUID REFERENCES permissions(id),
  PRIMARY KEY (role_id, permission_id)
);

-- RLS Policy for RBAC
CREATE POLICY "User can only access their role's resources" ON resources
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM role_permissions rp
      WHERE rp.role_id = (
        SELECT role_id FROM user_roles WHERE user_id = auth.uid()
      )
      AND rp.permission_id IN (
        SELECT id FROM permissions 
        WHERE resource = resources.type AND action = 'read'
      )
    )
  );
```

---

## 4. Payment Gateway Security

### 4.1 PCI-DSS Compliance: Secure Card Handling

The Payment Card Industry Data Security Standard (PCI-DSS) provides framework for secure payment processing:

```
PCI-DSS 12 Core Principles:

1. Install and maintain a firewall configuration
2. Do not use default passwords
3. Protect stored cardholder data
4. Encrypt transmission of cardholder data across networks
5. Protect systems against malware
6. Maintain secure development and change management
7. Restrict access by business need to know
8. Identify and authenticate access to cardholder data
9. Restrict physical access to cardholder data
10. Track and monitor access to network resources
11. Test security systems regularly
12. Maintain information security policy
```

### 4.2 Payment Security: Client vs. Server-Side Processing

#### **CRITICAL RULE: Never Process Payments on Client**

```
INSECURE (DO NOT IMPLEMENT):
┌─────────────┐
│   Client    │ ← Card Data
│  (Browser)  │
└──────┬──────┘
       │ SENDS CARD DATA OVER NETWORK
       ↓
┌─────────────────────┐
│  Payment Gateway    │
│   (Razorpay, etc)   │
└─────────────────────┘

Problems:
- Card data exposed in transit
- Network interception risk
- Client-side secrets exposure
- Violates PCI-DSS
```

#### **SECURE: Tokenization Flow**

```
SECURE ARCHITECTURE (IMPLEMENT THIS):

Client Browser
    ↓
┌──────────────────────────────────┐
│  Razorpay Hosted Checkout        │
│  (PCI-Compliant Payment Widget)  │
│  - Never sends card data         │
│  - Returns secure token only     │
└──────────────────────────────────┘
    ↓ Token Only
Application Server
    ↓
┌──────────────────────────────────┐
│  Backend Verification Service    │
│  - Has Razorpay Secret Key       │
│  - Verifies HMAC Signature       │
│  - Issues authorization          │
└──────────────────────────────────┘
    ↓
┌──────────────────────────────────┐
│  Razorpay Secure API             │
│  - Secret Key Processing         │
│  - Card Auth/Capture             │
│  - Settlement                    │
└──────────────────────────────────┘
```

### 4.3 Signature Verification: HMAC Security

HMAC (Hash-Based Message Authentication Code) ensures webhook authenticity:

```
SIGNATURE VERIFICATION PROCESS:

1. Receive Webhook from Razorpay:
   {
     "event": "payment.authorized",
     "payload": {
       "payment": {
         "id": "pay_xxxxxxxxx",
         "order_id": "order_xxxxxxxx",
         "amount": 50000
       }
     },
     "signature": "9ef4dffbfd84f1318f6739a3ce19f9d85851857ae648f114332d8401e0949a3d"
   }

2. Backend Verification Steps:
   - Extract: orderId, paymentId, signature from webhook
   - Create data string: "{orderId}|{paymentId}"
   - Compute HMAC: HMAC-SHA256(data, razorpaySecret)
   - Compare: computed_hmac == provided_signature
   - Result: If match → payment verified, update database

Implementation:

```dart
import 'package:crypto/crypto.dart';

Future<bool> verifyRazorpaySignature({
  required String orderId,
  required String paymentId,
  required String signature,
  required String razorpaySecret, // Backend secret only!
}) async {
  // Step 1: Create the signed data string
  final signedData = '$orderId|$paymentId';
  
  // Step 2: Compute HMAC-SHA256
  final key = utf8.encode(razorpaySecret);
  final bytes = utf8.encode(signedData);
  final hmac = Hmac(sha256, key);
  final computedSignature = hmac.convert(bytes).toString();
  
  // Step 3: Compare signatures
  // IMPORTANT: Use constant-time comparison to prevent timing attacks
  final isValid = constantTimeEquals(computedSignature, signature);
  
  if (!isValid) {
    // Log security event for fraud monitoring
    logSecurityEvent('payment_verification_failed', {
      'order_id': orderId,
      'payment_id': paymentId,
      'timestamp': DateTime.now(),
    });
    
    return false;
  }
  
  // Step 4: Update order payment status in database
  await database.updatePaymentStatus(
    orderId: orderId,
    paymentId: paymentId,
    status: 'verified',
    verifiedAt: DateTime.now(),
  );
  
  return true;
}

// Constant-time string comparison (prevent timing attacks)
bool constantTimeEquals(String a, String b) {
  if (a.length != b.length) return false;
  
  int result = 0;
  for (int i = 0; i < a.length; i++) {
    result |= (a.codeUnitAt(i) ^ b.codeUnitAt(i));
  }
  
  return result == 0;
}
```

### 4.4 Fraud Detection Using Risk Scoring

Implement multi-signal fraud detection:

```
FRAUD DETECTION SCORING MODEL:

Risk Score = (Velocity Score × 0.3) +
             (Distance Score × 0.25) +
             (Device Score × 0.15) +
             (Amount Score × 0.15) +
             (Behavioral Score × 0.15)

Each component ranges 0-100, result is 0-100

1. VELOCITY SCORE (Transaction Frequency)
   ├── 0-25: Normal (1 transaction per day)
   ├── 25-50: Unusual (3+ transactions per day)
   ├── 50-75: Suspicious (5+ transactions in 1 hour)
   └── 75-100: Fraudulent (10+ in 10 minutes)

2. DISTANCE SCORE (Geographic Anomaly)
   ├── Calculate: Distance from last transaction location
   ├── Check: Physically impossible travel speed
   ├── Formula: Max possible speed = 900 km/hour (commercial aircraft)
   └── Flag: If required speed > 900 km/h, likely fraud

3. DEVICE SCORE (Device Consistency)
   ├── Track: Device fingerprint, IMEI, MAC address
   ├── Score: Variation from user's typical devices
   ├── Red flag: Multiple devices in short timeframe
   └── Rule: Same device = 0 score, new device = 50 score

4. AMOUNT SCORE (Transaction Size)
   ├── Compare: Amount vs user's typical transaction size
   ├── Rule: Amount > 3× average = 50 score
   ├── Rule: First transaction for user = 30 score
   └── Rule: Large amount + new device + velocity = 100

5. BEHAVIORAL SCORE (User Pattern Deviation)
   ├── Track: Time of day, day of week, product type
   ├── Flag: Late night purchases for day trader
   ├── Flag: Purchase of high-risk items
   └── Flag: Multiple failed attempts before success

DECISION RULES:

Score 0-30: APPROVE (Low risk)
Score 30-50: REVIEW (Human review or additional verification)
Score 50-75: CHALLENGE (Request MFA/CVV)
Score 75-100: BLOCK (Immediate fraud alert)

Implementation:

CREATE TABLE fraud_scoring (
  id UUID PRIMARY KEY,
  order_id UUID REFERENCES orders(id),
  user_id UUID REFERENCES profiles(id),
  
  -- Individual scores
  velocity_score DECIMAL(5,2),
  distance_score DECIMAL(5,2),
  device_score DECIMAL(5,2),
  amount_score DECIMAL(5,2),
  behavioral_score DECIMAL(5,2),
  
  -- Final score
  final_risk_score DECIMAL(5,2),
  decision TEXT, -- approve, review, challenge, block
  
  -- Supporting data
  transaction_velocity INT, -- number of transactions in window
  geographic_distance_km DECIMAL(8,2),
  device_fingerprint TEXT,
  transaction_amount DECIMAL(10,2),
  user_avg_amount DECIMAL(10,2),
  
  created_at TIMESTAMP WITH TIME ZONE
);
```

---

## 5. Data Protection & Encryption

### 5.1 Encryption Models

#### **Encryption in Transit (TLS/SSL)**

```
Data in Transit: Client ↔ Server

1. Transport Layer Security (TLS 1.2+)
   ├── Asymmetric encryption: RSA-2048 or ECDSA
   ├── Symmetric encryption: AES-256-GCM
   ├── Key exchange: Diffie-Hellman (DHE) or Elliptic Curve (ECDHE)
   └── Authentication: X.509 certificate chain

2. Certificate Pinning (Prevent MITM attacks)
   ├── Client: Store server certificate public key
   ├── Verify: Compare received cert against pinned key
   ├── Benefit: Prevents rogue CA or compromised certificate
   └── Implementation: flutter_http_certificate_pinning
```

#### **Encryption at Rest**

```
Data at Rest: Database, Files, Backups

1. Database Encryption
   └── Supabase: Encryption at column-level or full TDE

   CREATE TABLE sensitive_data (
     id UUID PRIMARY KEY,
     user_id UUID REFERENCES profiles(id),
     ssn TEXT NOT NULL, -- Encrypted at column level
     bank_account TEXT NOT NULL, -- Encrypted
     created_at TIMESTAMP WITH TIME ZONE
   );

   -- Column-level encryption setup:
   ALTER TABLE sensitive_data 
   ADD COLUMN ssn_encrypted bytea 
   GENERATED ALWAYS AS (pgp_sym_encrypt(ssn, encryption_key)) STORED;

2. File Encryption (Local Storage)
   └── Use flutter_secure_storage (platform native encryption)

   ```dart
   final secureStorage = FlutterSecureStorage(
     aOptions: AndroidOptions(
       keystoreAlias: 'reclaim_key',
       encryptedSharedPreferencesOnly: true,
     ),
     iOptions: IOSOptions(
       accessibility: KeychainAccessibility.first_available,
     ),
   );
   
   // Files automatically encrypted with device's encryption keys
   await secureStorage.write(
     key: 'sensitive_data',
     value: sensitiveText,
   );
   ```

3. Backup Encryption
   ```dart
   // Disable automatic cloud backups for sensitive data
   android {
     defaultConfig {
       // Prevent inclusion in Android backup
       allowBackup = false
     }
   }
   
   // Manual backup with encryption
   Future<void> exportUserDataEncrypted() async {
     final userData = await database.exportAllData(userId);
     final encrypted = AES(key: masterKey).encrypt(jsonEncode(userData));
     
     // Save to user's encrypted cloud storage (OneDrive, Google Drive)
     await cloudStorage.upload(
       'backup_${DateTime.now().toIso8601String()}.enc',
       encrypted,
       encrypted: true,
     );
   }
   ```

### 5.2 Cryptographic Key Management

```
KEY MANAGEMENT HIERARCHY:

Master Key
    ↓
├── Database Encryption Key (KEK)
│   └── Encrypts all column keys
├── Application Secrets Key (KEK)
│   └── Encrypts API keys, tokens
├── Backup Encryption Key (KEK)
│   └── Encrypts exported data
└── Communication Key (KEK)
    └── Encrypts in-transit data

Rules:
1. Master key never transmitted over network
2. Master key stored in hardware security module (HSM) or environment-protected
3. All KEKs rotated annually
4. Data encryption keys rotated per record (GDPR requirement)
5. Separate keys per environment (dev/staging/prod)
```

**Key Rotation Strategy:**

```dart
// Implement key rotation for compliance
class KeyRotationService {
  // Rotate encryption keys every 90 days
  static const Duration KEY_ROTATION_INTERVAL = Duration(days: 90);
  
  Future<void> rotateAllKeys() async {
    // Step 1: Generate new master key
    final newMasterKey = _generateSecureKey();
    
    // Step 2: Re-encrypt all data with new key
    await database.transaction((txn) async {
      final allEncryptedRecords = await txn.query('encryption_metadata');
      
      for (final record in allEncryptedRecords) {
        // Decrypt with old key
        final decrypted = await decrypt(
          record['encrypted_data'],
          oldMasterKey,
        );
        
        // Re-encrypt with new key
        final reencrypted = await encrypt(decrypted, newMasterKey);
        
        // Update record
        await txn.update(
          'encryption_metadata',
          {
            'encrypted_data': reencrypted,
            'key_version': record['key_version'] + 1,
            'rotated_at': DateTime.now(),
          },
          where: 'id = ?',
          whereArgs: [record['id']],
        );
      }
    });
    
    // Step 3: Store new key in secure location
    await secureKeyStore.saveRotatedKey(newMasterKey, keyVersion: 2);
    
    // Step 4: Log key rotation event for audit
    await auditLog.logKeyRotation(
      oldKeyVersion: 1,
      newKeyVersion: 2,
      timestamp: DateTime.now(),
    );
  }
}
```

---

## 6. API Security Architecture

### 6.1 Rate Limiting: Preventing Brute Force & DDoS

Rate limiting restricts request frequency to prevent abuse:

```
RATE LIMITING TIERS:

1. GLOBAL RATE LIMIT (Per IP)
   ├── Limit: 10,000 requests/hour per IP
   ├── Purpose: Prevent DDoS attacks
   ├── Action: Return 429 Too Many Requests
   └── Duration: 1 hour blocking

2. USER RATE LIMIT (Per authenticated user)
   ├── Limit: 1,000 requests/hour per user
   ├── Purpose: Prevent resource exhaustion
   ├── Action: Return 429 after limit
   └── Duration: 1 hour blocking

3. ENDPOINT-SPECIFIC LIMITS

   Authentication Endpoints:
   ├── /auth/login: 5 attempts per 15 minutes (brute force prevention)
   ├── /auth/register: 3 per hour per IP
   └── /auth/password-reset: 3 per hour per email

   Payment Endpoints:
   ├── /payment/create: 10 per hour per user
   ├── /payment/verify: 20 per day per user
   └── /payment/refund: 5 per day per user

   Search/List Endpoints:
   ├── /materials/search: 100 per hour per user
   ├── /materials/list: 50 per hour per user
   └── /orders/list: 100 per hour per user

IMPLEMENTATION:

Backend Rate Limiting (Redis-based):

```dart
import 'package:redis/redis.dart';

class RateLimitService {
  final RedisConnection redis;
  
  // Check if request should be rate limited
  Future<bool> isRateLimited({
    required String userId,
    required String endpoint,
    required int limit,
    required int windowSeconds,
  }) async {
    final key = 'ratelimit:$endpoint:$userId';
    
    // Increment counter
    final count = await redis.call('INCR', [key]) as int;
    
    // Set expiration on first request in window
    if (count == 1) {
      await redis.call('EXPIRE', [key, windowSeconds]);
    }
    
    return count > limit;
  }
  
  // Example: Check login attempt rate limiting
  Future<bool> checkLoginAttempt(String email) async {
    return isRateLimited(
      userId: _hashEmail(email), // Don't store plaintext email in redis
      endpoint: 'auth:login',
      limit: 5,
      windowSeconds: 900, // 15 minutes
    );
  }
  
  // Lock account after too many attempts
  Future<void> lockAccountTemporarily(String userId) async {
    await redis.call('SET', [
      'account_lock:$userId',
      'locked',
      'EX',
      '900', // 15 minutes
    ]);
  }
}
```

### 6.2 Request Signing: Preventing Tampering

Implement request signing to detect tampering:

```
REQUEST SIGNING PROCESS:

CLIENT SIDE:

1. Create request payload
   {
     "order_id": "order_123",
     "amount": 5000,
     "timestamp": 1704067200
   }

2. Serialize to canonical form
   canonical = "{order_id}order_123|{amount}5000|{timestamp}1704067200"

3. Create HMAC signature
   signature = HMAC-SHA256(canonical, clientSecret)

4. Send request with signature
   {
     "order_id": "order_123",
     "amount": 5000,
     "timestamp": 1704067200,
     "signature": "abc123def456..."
   }

SERVER SIDE:

1. Receive request
2. Reconstruct canonical form (same serialization)
3. Verify HMAC with stored clientSecret
4. Check timestamp (prevent replay attacks - max 1 minute old)
5. Process only if valid

Implementation:

```dart
// Client-side signing
class RequestSigner {
  final String clientSecret;
  
  Future<Map<String, dynamic>> signRequest(
    Map<String, dynamic> payload,
  ) async {
    // Add timestamp
    payload['timestamp'] = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    // Create canonical form
    final canonical = _createCanonicalForm(payload);
    
    // Sign with client secret
    final key = utf8.encode(clientSecret);
    final bytes = utf8.encode(canonical);
    final hmac = Hmac(sha256, key);
    final signature = hmac.convert(bytes).toString();
    
    payload['signature'] = signature;
    return payload;
  }
  
  String _createCanonicalForm(Map<String, dynamic> payload) {
    final sorted = SplayTreeMap.from(payload);
    return sorted.entries
        .map((e) => '${e.key}${e.value}')
        .join('|');
  }
}

// Server-side verification
class RequestVerifier {
  final String clientSecret;
  
  bool verifyRequest(Map<String, dynamic> payload) {
    final providedSignature = payload.remove('signature');
    final timestamp = payload['timestamp'] as int;
    
    // Check timestamp freshness (prevent replay attacks)
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if ((now - timestamp).abs() > 60) {
      return false; // Request too old
    }
    
    // Verify signature
    final canonical = _createCanonicalForm(payload);
    final key = utf8.encode(clientSecret);
    final bytes = utf8.encode(canonical);
    final hmac = Hmac(sha256, key);
    final expectedSignature = hmac.convert(bytes).toString();
    
    return constantTimeEquals(expectedSignature, providedSignature);
  }
}
```

---

## 7. Infrastructure & Network Security

### 7.1 DDoS Protection Layers

```
DDoS PROTECTION STACK:

Layer 1: Network Level (Cloudflare, AWS Shield)
├── Volumetric Attacks: Filter at edge, rate limit
├── Protocol Attacks: TCP SYN, UDP floods filtered
├── Application Attacks: HTTP flood, slowloris detected
└── Mitigation: Anycast routing, geographically distributed

Layer 2: WAF (Web Application Firewall)
├── Rules: Detect SQL injection, XSS, etc.
├── Rate Limiting: Per IP, per session
├── Bot Detection: CAPTCHA for suspicious traffic
└── Actions: Block, challenge, or alert

Layer 3: Application Level
├── Connection Pooling: Limit connections per user
├── Request Queuing: Queue excess requests
├── Circuit Breaker: Fail gracefully under load
└── Resource Limits: Memory, CPU thresholds

IMPLEMENTATION:

// Backend rate limiting configuration
rateLimit: {
  // Global limits
  global: {
    requestsPerSecond: 10000,
    burstLimit: 15000,
    windowSeconds: 60,
  },
  
  // Per-endpoint limits
  endpoints: {
    '/api/login': { limit: 5, window: 900 }, // 5 per 15 min
    '/api/payment': { limit: 10, window: 3600 }, // 10 per hour
    '/api/search': { limit: 100, window: 3600 }, // 100 per hour
  },
  
  // Cloud provider
  cloudflare: {
    enabled: true,
    plan: 'pro',
    features: ['ddos-protection', 'cf-challenge', 'rate-limiting'],
  },
  
  // Generate CAPTCHA for suspicious IPs
  captchaThreshold: 85, // Risk score requiring CAPTCHA
}
```

### 7.2 Certificate Pinning: MITM Prevention

```
CERTIFICATE PINNING PROCESS:

1. EXTRACT PUBLIC KEY from server certificate
   ├── Fetch certificate from production server
   ├── Extract Subject Public Key Info (SPKI)
   ├── Base64-encode for storage
   └── Include in app assets

2. DURING REQUEST
   ├── Receive server certificate
   ├── Extract SPKI from certificate
   ├── Compare against pinned keys
   ├── If match: Continue, if mismatch: Reject

3. BENEFITS
   ├── Prevents MITM with rogue CA certificate
   ├── Protects against compromised certificate authority
   ├── Detects certificate substitution attacks
   └── Forces server to use specific certificate

IMPLEMENTATION:

```dart
import 'package:flutter_http_certificate_pinning/flutter_http_certificate_pinning.dart';

class SecureHttpClient {
  static Future<SecurityContext> setupCertificatePinning() async {
    // Pin the production server certificate
    final allowedSHA256Hashes = [
      'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=', // Production cert
      'sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=', // Backup cert
    ];
    
    try {
      await FlutterHttpCertificatePinning.check(
        serverURL: 'https://api.reclaim.com',
        headerClient: HttpClient(),
        allowedSHAFingerprintList: allowedSHA256Hashes,
        timeout: 60,
      );
    } catch (e) {
      // Certificate pinning failed - reject connection
      throw Exception('Certificate pinning verification failed');
    }
  }
  
  static Future<http.Client> createSecureClient() async {
    final context = SecurityContext.defaultContext;
    
    // Load certificate from app assets
    final certData = await rootBundle.load('assets/certificates/api.reclaim.com.pem');
    context.setTrustedCertificatesBytes(certData.buffer.asUint8List());
    
    // Enable certificate pinning
    await setupCertificatePinning();
    
    return http.Client();
  }
}
```

---

## 8. Incident Response & Compliance

### 8.1 Security Incident Response Plan

```
INCIDENT RESPONSE PHASES:

1. PREPARATION
   ├── Team: Identify incident commander, investigator, communicator
   ├── Tools: Set up SIEM, log aggregation, backup systems
   ├── Procedures: Document escalation paths, contact info
   └── Training: Regular drills, tabletop exercises

2. DETECTION & ANALYSIS
   ├── Alert: Unusual activity detected (SIEM alert)
   ├── Triage: Determine if actual security incident
   ├── Scope: Identify affected systems and data
   ├── Classification: Determine severity (Critical/High/Medium/Low)
   └── Timeline: Document all key events

3. CONTAINMENT
   ├── SHORT-TERM: Stop attack
   │   ├── Isolate affected systems
   │   ├── Kill malicious processes
   │   ├── Block attacking IPs
   │   └── Revoke compromised credentials
   │
   ├── LONG-TERM: Prepare forensic investigation
   │   ├── Preserve evidence (logs, memory, disk)
   │   ├── Monitor for attacker activity
   │   ├── Prepare backup systems
   │   └── Plan recovery procedure

4. ERADICATION
   ├── Remove malware/rootkits
   ├── Patch vulnerabilities
   ├── Reset compromised credentials
   ├── Close attack vectors
   └── Verify no backdoors remain

5. RECOVERY
   ├── Restore systems from clean backups
   ├── Rebuild affected servers
   ├── Restore data from backups
   ├── Verify integrity of restored systems
   └── Gradual rollout to production

6. POST-INCIDENT
   ├── Investigation: Root cause analysis
   ├── Timeline: Document exact sequence of events
   ├── Lessons: Identify process improvements
   ├── Updates: Patch systems and processes
   └── Communication: Notify affected users

INCIDENT SEVERITY CLASSIFICATION:

CRITICAL:
├── Payment data compromised
├── Large-scale data breach (100k+ records)
├── System unavailability (>1 hour)
└── Active fraud/financial theft

Action: Immediate response, executive escalation, external notification

HIGH:
├── Unauthorized access to customer data
├── PII exposure
├── System degradation (30min-1hour downtime)
└── Credential compromise

Action: Response within 1 hour, internal escalation

MEDIUM:
├── Suspicious activity in access logs
├── Failed intrusion attempts
├── Isolated system compromise
└── Minor data inconsistency

Action: Investigation within 4 hours, team notification

LOW:
├── Policy violations without impact
├── Suspicious but benign activity
├── Failed security scans
└── Information security events

Action: Log and monitor, team awareness
```

### 8.2 Compliance Frameworks

#### **OWASP Top 10 Web Application Risks**

```
1. Injection (SQL, NoSQL, OS)
   └── Mitigation: Parameterized queries, input validation, ORM

2. Broken Authentication
   └── Mitigation: MFA, strong passwords, session management

3. Sensitive Data Exposure
   └── Mitigation: Encryption at rest/transit, data classification

4. XML External Entities (XXE)
   └── Mitigation: Disable XML parsing, use JSON

5. Broken Access Control
   └── Mitigation: RBAC, principle of least privilege

6. Security Misconfiguration
   └── Mitigation: Security hardening, automated config scanning

7. Cross-Site Scripting (XSS)
   └── Mitigation: Input sanitization, output encoding, CSP

8. Insecure Deserialization
   └── Mitigation: Avoid untrusted serialization, use JSON

9. Using Components with Known Vulnerabilities
   └── Mitigation: Dependency scanning, regular updates

10. Insufficient Logging & Monitoring
    └── Mitigation: Comprehensive audit logging, alerting
```

#### **GDPR Compliance for Customer Privacy**

```
GDPR KEY REQUIREMENTS:

1. Lawful Basis
   ├── Consent: Explicit permission from user
   ├── Contract: Necessary for service delivery
   ├── Legal Obligation: Required by law
   ├── Vital Interests: Life-threatening situations
   ├── Public Task: Government function
   └── Legitimate Interests: Balanced risk assessment

2. Data Minimization
   ├── Only collect necessary data
   ├── Delete unused data within retention period
   ├── Implement data lifecycle policies
   └── Audit: Annual review of collected data

3. Right to Access
   ├── User can request all personal data
   ├── Response time: 30 days
   ├── Format: Structured, commonly used format
   └── Implementation: Self-service portal + API

4. Right to Erasure ("Right to be Forgotten")
   ├── User can request deletion
   ├── System cascading delete: user → orders → transactions
   ├── Exceptions: legal obligations, fraud prevention
   └── Anonymization: Instead of deletion for analytics

5. Data Portability
   ├── User can export data in machine-readable format
   ├── Format: JSON, CSV, XML
   ├── Timeline: 30 days from request
   └── Implementation: Scheduled export job

6. Data Breach Notification
   ├── Notify users within 72 hours
   ├── Notify authorities if high risk
   ├── Include: nature of breach, recommendations
   └── Evidence: Document notification date/method

IMPLEMENTATION:

CREATE TABLE data_requests (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES profiles(id),
  request_type TEXT, -- 'access', 'deletion', 'export', 'portability'
  status TEXT, -- 'pending', 'processing', 'completed'
  requested_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE,
  notes TEXT
);

-- User data export function
CREATE FUNCTION export_user_data(p_user_id UUID)
RETURNS JSONB AS $$
BEGIN
  RETURN json_build_object(
    'profile', (SELECT row_to_json(t) FROM profiles t WHERE id = p_user_id),
    'materials', (SELECT json_agg(row_to_json(t)) FROM materials t WHERE owner_id = p_user_id),
    'orders', (SELECT json_agg(row_to_json(t)) FROM orders t WHERE buyer_id = p_user_id),
    'payments', (SELECT json_agg(row_to_json(t)) FROM payment_transactions t 
                 WHERE order_id IN (SELECT id FROM orders WHERE buyer_id = p_user_id))
  );
END;
$$ LANGUAGE plpgsql;
```

#### **PCI-DSS Compliance for Payment Processing**

```
PCI-DSS REQUIREMENTS:

1. Network Security
   ├── Firewall: Required, properly configured
   ├── No defaults: Remove default passwords/accounts
   └── Segmentation: Isolate payment systems

2. Data Protection
   ├── Encryption: Asymmetric for card data
   ├── Hashing: For passwords, with salt
   └── Key Management: Secure storage and rotation

3. Access Control
   ├── Authentication: Strong, unique IDs
   ├── Authorization: Role-based, need-to-know
   └── Monitoring: Track all access

4. Monitoring & Testing
   ├── Logging: All access to cardholder data
   ├── Testing: Annual penetration testing
   ├── Scanning: Quarterly vulnerability scans
   └── Patching: Monthly updates

IMPLEMENTATION:

-- PCI-DSS compliant audit logging
CREATE TABLE pci_audit_log (
  id BIGSERIAL PRIMARY KEY,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  user_id UUID,
  user_name TEXT,
  action TEXT,
  resource TEXT,
  resource_id TEXT,
  status TEXT, -- success, failure
  ip_address INET,
  user_agent TEXT,
  
  -- For filtering
  INDEX idx_user (user_id),
  INDEX idx_timestamp (timestamp),
  INDEX idx_action (action)
);

-- Immutable audit log (cannot be modified/deleted)
CREATE POLICY "Audit log is append-only" ON pci_audit_log
  FOR UPDATE USING (false)
  FOR DELETE USING (false);
```

---

## Conclusion

Security is not a destination but a continuous process. This framework provides:

1. **Theoretical Foundation**: Understanding why security controls exist
2. **Practical Implementation**: Code examples and configurations
3. **Compliance Framework**: Meeting regulatory requirements
4. **Incident Readiness**: Responding to security events

### Recommended Implementation Roadmap:

**Phase 1 (Week 1-2): Critical Security**
- [ ] Remove all hardcoded secrets
- [ ] Implement strong password policy
- [ ] Add HTTPS/TLS everywhere
- [ ] Enable MFA for admins
- [ ] Set up basic audit logging

**Phase 2 (Week 3-4): Payment Security**
- [ ] Implement backend payment verification
- [ ] Add fraud detection scoring
- [ ] Configure rate limiting
- [ ] Certificate pinning for production APIs
- [ ] Establish PCI-DSS compliance

**Phase 3 (Week 5-6): Data Protection**
- [ ] Encrypt sensitive data at rest
- [ ] Implement secure key management
- [ ] Set up data retention policies
- [ ] Enable GDPR data export
- [ ] Establish backup encryption

**Phase 4 (Ongoing): Monitoring & Compliance**
- [ ] Implement comprehensive logging
- [ ] Set up security alerts
- [ ] Schedule quarterly penetration tests
- [ ] Conduct annual security audit
- [ ] Update incident response plan

---

**Document Version**: 1.0  
**Last Updated**: 2026-04-04  
**Status**: For Implementation  
**Classification**: Internal Use
