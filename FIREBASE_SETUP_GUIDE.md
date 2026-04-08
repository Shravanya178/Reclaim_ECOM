# Firebase Setup Guide for ReClaim

## Overview

This guide walks you through setting up Firebase Authentication for the ReClaim app with email/password and Google Sign-In support.

---

## Step 1: Create Firebase Project

### 1.1 Go to Firebase Console
- Navigate to [Firebase Console](https://console.firebase.google.com/)
- Click "Create a new project"
- Project name: `ReClaim`
- Accept terms and click "Create project"

### 1.2 Add Firebase to Apps

After project creation, select your project and:

#### **For Android:**
1. Click "Add app" → Select "Android"
2. Fill in:
   - Package name: `com.reclaim.app` (or your actual package)
   - App nickname: `ReClaim Android`
   - Debug SHA-1: See step 1.3 below
3. Download `google-services.json`
4. Place in: `android/app/google-services.json`

#### **For iOS:**
1. Click "Add app" → Select "iOS"
2. Fill in:
   - Bundle ID: `com.reclaim.app` (or your actual bundle)
   - App nickname: `ReClaim iOS`
3. Download `GoogleService-Info.plist`
4. Place in: `ios/Runner/GoogleService-Info.plist`

### 1.3 Get Debug SHA-1 (Android)

```bash
cd android
# On macOS/Linux:
./gradlew signingReport

# On Windows:
gradlew.bat signingReport
```

Find the SHA-1 code and add to Firebase Android app configuration.

---

## Step 2: Enable Authentication Methods

1. In Firebase Console, go to **Authentication** → **Sign-in method**

### 2.1 Enable Email/Password
- Click on "Email/Password"
- Toggle "Enable" ON
- Click "Save"

### 2.2 Enable Google Sign-In
- Click on "Google"
- Toggle "Enable" ON
- Select your Support email
- Click "Save"

### 2.3 Get Google OAuth Credentials (for Web)
- Go to **Project Settings** → **Service Accounts**
- Click "Generate New Private Key"
- This is for backend verification (save securely)

---

## Step 3: Configure iOS (google-signin)

### 3.1 Add URL Scheme to Info.plist

Edit `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR_GOOGLE_APP_ID</string>
    </array>
  </dict>
</array>
```

Get `YOUR_GOOGLE_APP_ID` from `GoogleService-Info.plist` (REVERSED_CLIENT_ID field).

### 3.2 Update iOS Podfile

Edit `ios/Podfile` (find and update):

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'FIREBASE_ANALYTICS_COLLECTION_ENABLED=1',
      ]
    end
  end
end
```

---

## Step 4: Configure Android (google-signin)

### 4.1 Update android/app/build.gradle

```gradle
android {
  ...
  defaultConfig {
    ...
    // Firebase-specific
    resValue "string", "google_app_id", "YOUR_GOOGLE_APP_ID"
  }
}

dependencies {
  implementation 'com.google.firebase:firebase-auth-ktx'
  implementation 'com.google.android.gms:play-services-auth'
}

apply plugin: 'com.google.gms.google-services'
```

### 4.2 Update android/build.gradle

```gradle
buildscript {
  repositories {
    google()
    mavenCentral()
  }
  dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
  }
}
```

---

## Step 5: Update pubspec.yaml

The dependencies are already added:

```yaml
firebase_core: ^2.24.0
firebase_auth: ^4.14.0
google_sign_in: ^6.1.4
```

Run:
```bash
flutter pub get
```

---

## Step 6: Initialize Firebase in main.dart

Update `lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}
```

**Note:** You may need to generate `firebase_options.dart` using FlutterFire CLI:

```bash
flutter pub global activate flutterfire_cli
flutterfire configure
```

This generates the file automatically based on your Firebase project.

---

## Step 7: Test Authentication

### Test Email/Password SignUp
1. Run app: `flutter run`
2. Go to Sign Up tab
3. Enter:
   - Full Name: John Doe
   - Email: john@example.com
   - Password: MyPassword123!@
4. Click "Create Account"
5. Check Firebase Console → Authentication → Users
   - New user should appear

### Test Email/Password SignIn
1. Go to Sign In tab
2. Enter email and password from signup
3. Click "Sign In"
4. Should navigate to role-selection screen

### Test Google SignIn
1. Tap "Sign In with Google" button
2. Select Google account (or create test account)
3. Grant permissions
4. Should navigate to role-selection screen

---

## Step 8: Set Authentication Redirects

### 8.1 For Web (if deploying to web)

Firebase Console → Authentication → Settings → Authorized domains:
- Add: `localhost:5000` (for local testing)
- Add: `web-9ywxcpf4x-shravanyas-projects-6ff4fc4e.vercel.app` (Vercel deployment)
- Add: Your production domain (e.g., `reclaim.com`)

### 8.2 For Mobile App Link

Firebase Console → App Links:
- Configure Deep Links for authentication callbacks
- Example: `reclaim://auth-callback`

---

## Step 9: Security Rules

### 9.1 Update Firestore Security Rules

Go to Firestore Database → Rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own profile
    match /profiles/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Allow authenticated users to read materials
    match /materials/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

---

## Step 10: Environment Variables (Production)

### Create `.env.production`

```
FIREBASE_PROJECT_ID=reclaim-production
FIREBASE_API_KEY=YOUR_PRODUCTION_API_KEY
FIREBASE_AUTH_DOMAIN=reclaim-production.firebaseapp.com
FIREBASE_DATABASE_URL=https://reclaim-production.firebaseio.com
FIREBASE_STORAGE_BUCKET=reclaim-production.appspot.com
FIREBASE_MESSAGING_SENDER_ID=YOUR_SENDER_ID
FIREBASE_APP_ID=YOUR_APP_ID
GOOGLE_SIGN_IN_IOS_CLIENT_ID=YOUR_IOS_CLIENT_ID
GOOGLE_SIGN_IN_ANDROID_CLIENT_ID=YOUR_ANDROID_CLIENT_ID
```

Load in app:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  // ... rest of initialization
}
```

---

## Troubleshooting

### Issue: "google-services.json not found"
**Fix:** Ensure `google-services.json` is in `android/app/` directory
```bash
ls android/app/google-services.json
```

### Issue: Google SignIn always opens browser on Android
**Fix:** Ensure SHA-1 fingerprint is correctly registered in Firebase Console

### Issue: "Invalid client" error
**Fix:** 
1. Check package name matches in Firebase and Android manifest
2. Regenerate SHA-1 and update Firebase
3. Clear app cache: `flutter clean`

### Issue: "Network error" during signin
**Fix:**
1. Check internet connection
2. Verify Firebase project is active
3. Check firebaseio.com domain is accessible

### Issue: Profile not created after Google SignIn
**Fix:**
- Check Supabase RLS policies allow inserts
- Verify Supabase service is running
- Check error logs in Firebase Console

---

## Next Steps

1. ✅ Firebase project created
2. ✅ Authentication methods enabled
3. ✅ Platform-specific configuration
4. ✅ Tested email/password auth
5. ✅ Tested Google Sign-In
6. ✅ Deploy to production

---

## Useful Commands

```bash
# Check Firebase installation
flutter pub get

# Clean build (if issues)
flutter clean
flutter pub get

# Run app
flutter run -v

# Check Firebase logs
firebase logs read  # (requires Firebase CLI)

# Deploy to Firebase Hosting (if web)
firebase deploy
```

---

## Resources

- [Firebase Flutter Documentation](https://firebase.google.com/docs/flutter/setup)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Google SignIn Flutter](https://github.com/google/google-sign-in-flutter)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli)

---

**Last Updated**: April 4, 2026  
**Status**: Complete
