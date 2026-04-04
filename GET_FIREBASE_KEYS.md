# Firebase API Keys - How to Get Them

Your `firebase_options.dart` file has been created with placeholder values. You need to replace them with your actual Firebase project credentials.

## Get Your Firebase Credentials

### Step 1: Go to Firebase Console

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your **ReClaim** project (reclaim-137d7)
3. Click **Project Settings** (gear icon in top-left)

### Step 2: Get Android API Key

1. In Project Settings, go to **Your apps** section
2. Find the Android app: **com.reclaim.reclaim**
3. Click it and copy `google-services.json` (if available, or copy the API key shown)

**Alternative - Get from SHA-1:**
- Your google-services.json (if already downloaded) contains the API key
- Place `google-services.json` in `android/app/`

### Step 3: Get iOS API Key

1. In **Your apps**, find the iOS app
2. Click it and look for API key and Bundle ID in the configuration

### Step 4: Get Android API Key (programmatically)

From `android/app/google-services.json`:
```json
{
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:443187564452:android:reclaim_app_id"
      },
      "api_key": [
        {
          "current_key": "YOUR_ACTUAL_API_KEY_HERE"
        }
      ]
    }
  ]
}
```

Copy the `current_key` value.

### Step 5: Update java/firebase_options.dart

Replace placeholder values in `lib/firebase_options.dart`:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY_HERE',  // Replace this
  appId: '1:443187564452:android:........',
  messagingSenderId: '443187564452',
  projectId: 'reclaim-137d7',
  databaseURL: 'https://reclaim-137d7.firebaseio.com',
  storageBucket: 'reclaim-137d7.appspot.com',
);

static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'YOUR_IOS_API_KEY_HERE',  // Replace this
  appId: '1:443187564452:ios:........',
  messagingSenderId: '443187564452',
  projectId: 'reclaim-137d7',
  databaseURL: 'https://reclaim-137d7.firebaseio.com',
  storageBucket: 'reclaim-137d7.appspot.com',
  iosBundleId: 'com.example.reclaim',
);

static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_WEB_API_KEY_HERE',  // Replace this
  appId: '1:443187564452:web:........',
  messagingSenderId: '443187564452',
  projectId: 'reclaim-137d7',
  authDomain: 'reclaim-137d7.firebaseapp.com',
  databaseURL: 'https://reclaim-137d7.firebaseio.com',
  storageBucket: 'reclaim-137d7.appspot.com',
);
```

## Quick Reference for Your Project

| Property | Value |
|----------|-------|
| Project ID | reclaim-137d7 |
| Project Number | 443187564452 |
| Auth Domain | reclaim-137d7.firebaseapp.com |
| Database URL | https://reclaim-137d7.firebaseio.com |
| Storage Bucket | reclaim-137d7.appspot.com |
| Android App ID | com.reclaim.reclaim |
| iOS Bundle ID | com.example. (or your actual bundle) |
| Web App ID | reclaim |

## Auto-Configuration Alternative

If you want to try the auto-configuration again:

```bash
# Try with different approach
flutterfire configure --project=reclaim-137d7 --out=lib/firebase_options.dart
```

Or see the google-services.json file that should now exist in `android/app/` (FlutterFire already registered the app).
