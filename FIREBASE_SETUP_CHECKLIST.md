# Firebase Setup Checklist

A quick reference checklist for Firebase configuration. Follow in order.

---

## Phase 1: Firebase Project Setup

- [ ] **Create Firebase Project**
  - [ ] Go to https://console.firebase.google.com/
  - [ ] Create project named "ReClaim"
  - [ ] Project ready for app registration

- [ ] **Register Android App**
  - [ ] Package name: `com.reclaim.app`
  - [ ] Debug SHA-1 obtained (run `./gradlew signingReport`)
  - [ ] SHA-1 added to Firebase
  - [ ] Download `google-services.json`
  - [ ] Place in: `android/app/google-services.json`

- [ ] **Register iOS App**
  - [ ] Bundle ID: `com.reclaim.app`
  - [ ] Download `GoogleService-Info.plist`
  - [ ] Place in: `ios/Runner/GoogleService-Info.plist`

---

## Phase 2: Authentication Methods

- [ ] **Enable Email/Password Auth**
  - [ ] Firebase Console → Authentication → Sign-in method
  - [ ] Email/Password toggle: ON
  - [ ] Save

- [ ] **Enable Google Sign-In**
  - [ ] Firebase Console → Authentication → Sign-in method
  - [ ] Google toggle: ON
  - [ ] Support email selected
  - [ ] Save

---

## Phase 3: Android Configuration

- [ ] **Update android/build.gradle**
  ```gradle
  buildscript {
    dependencies {
      classpath 'com.google.gms:google-services:4.3.15'
    }
  }
  ```

- [ ] **Update android/app/build.gradle**
  ```gradle
  dependencies {
    implementation 'com.google.firebase:firebase-auth-ktx'
    implementation 'com.google.android.gms:play-services-auth'
  }
  apply plugin: 'com.google.gms.google-services'
  ```

- [ ] **android/app/AndroidManifest.xml** - Verify permissions
  ```xml
  <uses-permission android:name="android.permission.INTERNET" />
  ```

---

## Phase 4: iOS Configuration

- [ ] **Update ios/Runner/Info.plist**
  - [ ] Add URL scheme from GoogleService-Info.plist (REVERSED_CLIENT_ID)
  ```xml
  <key>CFBundleURLTypes</key>
  <array>
    <dict>
      <key>CFBundleURLSchemes</key>
      <array>
        <string>com.googleusercontent.apps.YOUR_GOOGLE_APP_ID</string>
      </array>
    </dict>
  </array>
  ```

- [ ] **Update ios/Podfile** (if needed)
  - [ ] Ensure `post_install` hook exists
  - [ ] FIREBASE_ANALYTICS_COLLECTION_ENABLED flag set

- [ ] **Cocoapods update**
  ```bash
  cd ios && pod update && cd ..
  ```

---

## Phase 5: Dart/Flutter Configuration

- [ ] **pubspec.yaml Dependencies**
  - [ ] ✅ firebase_core: ^2.24.0
  - [ ] ✅ firebase_auth: ^4.14.0
  - [ ] ✅ google_sign_in: ^6.1.4
  - [ ] Run `flutter pub get`

- [ ] **Generate firebase_options.dart**
  ```bash
  flutter pub global activate flutterfire_cli
  flutterfire configure
  ```

- [ ] **lib/main.dart Updated**
  ```dart
  import 'package:firebase_core/firebase_core.dart';
  import 'firebase_options.dart';
  
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  }
  ```

---

## Phase 6: Code Files Verification

- [ ] **lib/core/services/validation_service.dart**
  - [ ] File exists
  - [ ] Contains: `validateEmail()`, `validatePassword()`, `validateFullName()`
  - [ ] Password validation: 12+ chars, uppercase, lowercase, digit, special char

- [ ] **lib/core/services/firebase_auth_service.dart**
  - [ ] File exists
  - [ ] Contains: `signUpWithEmail()`, `signInWithEmail()`, `signInWithGoogle()`
  - [ ] Error handling maps Firebase exceptions to friendly messages

- [ ] **lib/features/auth/presentation/screens/auth_screen.dart**
  - [ ] Imports Firebase instead of Supabase auth
  - [ ] No demo mode (no "Enter Demo" button)
  - [ ] Real-time validation on all fields
  - [ ] Password strength meter visible
  - [ ] Google Sign-In buttons in both tabs

---

## Phase 7: Testing

- [ ] **Clean & Build**
  ```bash
  flutter clean
  flutter pub get
  flutter run
  ```

- [ ] **Test Email/Password SignUp**
  - [ ] Name: John Doe
  - [ ] Email: john@example.com
  - [ ] Password: MyPassword123!@
  - [ ] Check user appears in Firebase Console

- [ ] **Test Email/Password SignIn**
  - [ ] Use credentials from signup
  - [ ] Successfully navigates to role-selection

- [ ] **Test Google SignIn**
  - [ ] Tap "Sign In with Google"
  - [ ] Google account selection works
  - [ ] Navigates to role-selection after auth

- [ ] **Test Error Handling**
  - [ ] Wrong password → error message
  - [ ] Email already exists → error message
  - [ ] Invalid email format → validation error
  - [ ] Password < 12 chars → validation error

---

## Phase 8: Security Configuration

- [ ] **Firestore Security Rules** (if using Firestore)
  - [ ] Authenticated users can access own profile
  - [ ] Materials readable by authenticated users
  - [ ] Test rules with sample data

- [ ] **Firebase Authentication Settings**
  - [ ] Email link signing disabled (use password only)
  - [ ] Anonymous signin disabled
  - [ ] Account linking disabled

- [ ] **Add Authorized Domains** (for web)
  - [ ] localhost:5000 (for testing)
  - [ ] Production domain (e.g., reclaim.com)

---

## Phase 9: Production Deployment

- [ ] **Create Production Firebase Project**
  - [ ] Project name: "ReClaim Production"
  - [ ] Separate from development project

- [ ] **Environment Configuration**
  - [ ] Create `.env.production` with production Firebase keys
  - [ ] Load environment based on build flavor

- [ ] **App Signing**
  - [ ] Production keystore created
  - [ ] SHA-1 from production keystore added to Firebase

- [ ] **Deployment**
  - [ ] Build release APK/IPA
  - [ ] Test full auth flow
  - [ ] Deploy to app store

---

## Phase 10: Monitoring & Maintenance

- [ ] **Firebase Analytics** (optional)
  - [ ] Enable in Firebase Console
  - [ ] Track signup/signin events
  - [ ] Monitor user engagement

- [ ] **Error Logging**
  - [ ] Firebase error logging configured
  - [ ] Review error patterns weekly
  - [ ] Alert on spike in auth failures

- [ ] **Quota Monitoring**
  - [ ] Firebase free tier: 50k sign-ups/month
  - [ ] Monitor usage in Firebase Console
  - [ ] Upgrade if needed

```
Free Tier Limits (as of 2026):
- Sign-ups: 50,000/month
- Authentication: Unlimited reads
- Firestore: 50k read ops, 20k write ops, 10GB storage
```

---

## Troubleshooting Checklist

### Problem: App won't build after Firebase changes

- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`
- [ ] Verify Android `google-services.json` in correct location
- [ ] Verify iOS `GoogleService-Info.plist` in Xcode
- [ ] Check iOS `Podfile` has flutter_root
- [ ] Run `cd ios && pod deintegrate && pod install && cd ..`

### Problem: SignIn fails with "Network error"

- [ ] Check internet connection
- [ ] Verify Firebase project is active
- [ ] Check app has INTERNET permission in AndroidManifest.xml
- [ ] Verify Firebase credentials are correct in config files

### Problem: Google SignIn browser opens instead of native dialog

- [ ] Ensure SHA-1 fingerprint registered in Firebase
- [ ] Run `flutter clean` and rebuild
- [ ] Check `android/app/build.gradle` has google-services plugin

### Problem: User not found after signup

- [ ] Check Supabase RLS policies allow inserts
- [ ] Verify `_createSupabaseProfile()` is called after Firebase signup
- [ ] Check error logs in FirebaseAuthService

### Problem: Password validation too strict

- If requirements too harsh:
  - Edit `lib/core/services/validation_service.dart`
  - Modify `validatePassword()` regex pattern
  - Update password strength calculation

---

## File Checklist Summary

| File | Status | Purpose |
|------|--------|---------|
| `firebase_options.dart` | Generated | Firebase config per platform |
| `android/app/google-services.json` | Downloaded | Android Firebase config |
| `ios/Runner/GoogleService-Info.plist` | Downloaded | iOS Firebase config |
| `lib/core/services/validation_service.dart` | Created | Email/password/name validation |
| `lib/core/services/firebase_auth_service.dart` | Created | Firebase auth logic |
| `lib/features/auth/presentation/screens/auth_screen.dart` | Updated | Auth UI with Firebase |
| `lib/main.dart` | Updated | Firebase initialization |
| `android/build.gradle` | Updated | Google services plugin |
| `android/app/build.gradle` | Updated | Firebase dependencies |
| `ios/Runner/Info.plist` | Updated | Google Sign-In URL scheme |
| `pubspec.yaml` | Updated | Firebase dependencies |

---

## Quick Reference Commands

```bash
# Get debug SHA-1 for Android
cd android && ./gradlew signingReport && cd ..

# Generate firebase_options.dart
flutterfire configure

# Install/update iOS pods
cd ios && pod install && cd ..

# Run app in debug
flutter run -v

# Build release APK
flutter build apk --release

# Build release IPA
flutter build ios --release
```

---

**Last Updated**: April 4, 2026  
**Estimated Setup Time**: 30-45 minutes  
**Difficulty**: Medium (mostly configuration, minimal coding)
