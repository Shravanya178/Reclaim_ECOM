# 🔥 FIREBASE CONFIGURATION GUIDE

## Your Project Details
- **Project ID**: reclaim-c222a
- **Project Number**: 502383251544
- **Organization**: 2023.shravanya.andhale@ves.ac.in

---

## ✅ STEP-BY-STEP FIREBASE CONSOLE SETUP

### 1. Enable Authentication Methods

**Go to: Firebase Console → Authentication → Sign-in method**

1. **Enable Email/Password**
   - Click "Email/Password"
   - Enable both:
     - ✅ Email/Password
     - ✅ Email link (passwordless sign-in) - Optional but recommended
   - Click "Save"

2. **Enable Google Sign-In**
   - Click "Google"
   - Web SDK configuration: (auto-configured)
   - Click "Save"

### 2. Configure CORS (Cross-Origin Resource Sharing)

**Go to: Firebase Console → Authentication → Settings → Authorized domains**

Add your domain:
```
localhost:5000  (for local development)
localhost:8080  (alternative port)
web-9ywxcpf4x-shravanyas-projects-6ff4fc4e.vercel.app  (Vercel deployment)
```

For production, add your actual domain:
```
yourdomain.com
www.yourdomain.com
api.yourdomain.com
```

### 3. Set Authentication Security Rules

**Go to: Firebase Console → Firestore Database → Rules**

Replace default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection - only accessible by authenticated users
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      
      // Public user profile (anyone can read)
      allow read: if true;
      
      // Only user can write their own profile
      allow create: if request.auth.uid == userId;
      allow update: if request.auth.uid == userId && 
                       request.resource.data.role == resource.data.role;
      allow delete: if request.auth.uid == userId;
    }
    
    // Orders collection
    match /orders/{orderId} {
      allow read: if request.auth.uid == resource.data.userId;
      allow create: if request.auth.uid == request.resource.data.userId;
      allow update: if request.auth.uid == resource.data.userId;
      allow delete: if request.auth.uid == resource.data.userId;
    }
    
    // Admin collection
    match /admin/{adminId} {
      allow read, write: if request.auth != null && 
                            get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

### 4. Configure Realtime Database Security Rules

**Go to: Realtime Database → Rules**

```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null",
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    }
  }
}
```

### 5. Configure Cloud Storage Security Rules

**Go to: Storage → Rules**

```firebase
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Only authenticated users can read their own uploads
    match /users/{userId}/{allPaths=**} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId && 
                      request.resource.size < 5 * 1024 * 1024 &&
                      request.resource.contentType.matches('image/.*');
    }
  }
}
```

### 6. Configure API Key Restrictions

**Go to: Project Settings → API keys**

1. Click on your API key
2. **Restrict Key**
   - Application restrictions: Select "iOS" and "Android"
   - Android app: `com.reclaim.reclaim`
   - iOS app bundle ID: `com.reclaim.reclaim`
   
3. **API restrictions**
   - Restrict to selected APIs
   - Enable:
     - ✅ Firebase Authentication API
     - ✅ Cloud Firestore API
     - ✅ Realtime Database API
     - ✅ Cloud Storage API

4. Click "Save"

### 7. Enable Cloud Logging (Monitoring)

**Go to: Functions → Logs**

This will automatically track function executions and errors.

### 8. Set Email Templates (Optional but Recommended)

**Go to: Authentication → Templates**

Customize email templates for:
- Email verification
- Password reset
- Account deletion

### 9. Enable 2FA/MFA (Optional - for future implementation)

**Go to: Authentication → Identity Providers**

Configure Multi-Factor Authentication for additional security.

### 10. Set up Webhooks/Cloud Functions (For Razorpay Verification)

**Go to: Functions → Create Function**

Create a function to validate Razorpay payment webhooks:

```javascript
// DO NOT commit this without proper security review
exports.validateRazorpayWebhook = functions.https.onRequest((req, res) => {
  // Validate webhook signature
  const crypto = require('crypto');
  const secret = process.env.RAZORPAY_WEBHOOK_SECRET;
  
  const shasum = crypto
    .createHmac('sha256', secret)
    .update(JSON.stringify(req.body))
    .digest('hex');
  
  if (shasum === req.headers['x-razorpay-signature']) {
    // Process payment
    res.status(200).send('OK');
  } else {
    res.status(401).send('Unauthorized');
  }
});
```

---

## 🔐 Network Security Configuration

### Add Security Headers

**For Firebase Hosting, create `firebase.json`:**

```json
{
  "hosting": {
    "headers": [
      {
        "source": "**/*.js",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "public, max-age=3600"
          }
        ]
      },
      {
        "source": "**",
        "headers": [
          {
            "key": "X-Content-Type-Options",
            "value": "nosniff"
          },
          {
            "key": "X-Frame-Options",
            "value": "DENY"
          },
          {
            "key": "X-XSS-Protection",
            "value": "1; mode=block"
          },
          {
            "key": "Referrer-Policy",
            "value": "strict-origin-when-cross-origin"
          },
          {
            "key": "Strict-Transport-Security",
            "value": "max-age=31536000; includeSubDomains"
          }
        ]
      }
    ]
  }
}
```

---

## 🚀 Deployment Checklist

Before deploying to production:

**Security:**
- [ ] All API keys restricted (iOS/Android only)
- [ ] CORS domains configured for production
- [ ] Security rules reviewed and tested
- [ ] 2FA/MFA enabled for admin account
- [ ] Environment variables set (.env file)
- [ ] Error logging configured
- [ ] Rate limiting configured

**Firebase Console:**
- [ ] Email/Password authentication enabled
- [ ] Google Sign-In enabled
- [ ] Firestore security rules deployed
- [ ] Cloud Storage rules secured
- [ ] API key restrictions applied
- [ ] Webhook signature validation working
- [ ] Cloud Functions deployed (if using)
- [ ] Monitoring/Logging enabled

**Flutter App:**
- [ ] firebase_options.dart has production credentials
- [ ] Rate limiter implemented
- [ ] Error handler doesn't expose details
- [ ] Tokens stored securely
- [ ] No hardcoded secrets
- [ ] All validation in place
- [ ] Audit logging configured

**Post-Deployment:**
- [ ] Monitor Firebase Console for errors
- [ ] Set up alerts for suspicious activity
- [ ] Regular security audits
- [ ] Dependency updates tracked
- [ ] Backup strategy in place

---

## 🧪 Testing Security

### Test Email/Password Auth
```bash
Email: test@example.com
Password: Test@Pass123456  # 12+ chars, mixed case, digit, special char
```

### Test Google Sign-In
1. Click "Sign In with Google" button
2. Select test Google account
3. Verify redirect to `/role-selection`

### Test Rate Limiting
1. Try signing in with wrong password 5 times
2. Should be locked out for 15 minutes
3. Check remaining attempts calculation

### Test Error Messages
1. Try with invalid email - should show user-friendly error
2. Try weak password - should show requirements
3. Try non-existent account - should not reveal if email exists

### Test Secure Token Storage
1. Sign in successfully
2. Kill app
3. Relaunch - should be logged in (token persisted)

---

## 🆘 Troubleshooting

### "Firebase app configuration not found"
- Ensure `firebase_options.dart` is imported in `main.dart`
- Run `flutter pub get` again

### Google Sign-In not working
- Verify Firebase Console has Google OAuth credentials
- Check that Google API enabled for your project
- Android/iOS app fingerprints registered

### Firestore rules denying access
- Check `request.auth.uid` matches document owner
- Ensure user is authenticated
- Review security rules in console

### Too many requests error
- Rate limiter is working (expected)
- Wait 15 minutes or clear SharedPreferences for testing

---

## 📞 Support & Resources

- [Firebase Console](https://console.firebase.google.com/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Firebase Plugin](https://pub.dev/packages/firebase_core)
- [Google Sign-In Plugin](https://pub.dev/packages/google_sign_in)
