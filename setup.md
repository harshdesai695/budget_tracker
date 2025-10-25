# Setup Instructions for Budget Tracker

This document provides step-by-step instructions for setting up the Budget Tracker project with Firebase and other configurations.

## Prerequisites

1. Flutter SDK (latest stable version)
2. Firebase CLI
3. Git
4. A Firebase project created in the Firebase Console

## Initial Setup

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd budget_tracker
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

## Firebase Configuration

### Step 1: Firebase Project Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select an existing one
3. Enable Authentication (Google Sign-In)
4. Set up Cloud Firestore
5. Add your application to Firebase:
   - Android
   - iOS
   - Web (if applicable)

### Step 2: Environment Configuration

1. Copy the environment template:
   ```bash
   cp .env.template .env
   ```

2. Update the `.env` file with your Firebase configuration:
   - Get these values from your Firebase project settings
   - Fill in all required fields (API keys, project IDs, etc.)

### Step 3: Firebase Options

1. Copy the Firebase options template:
   ```bash
   cp lib/firebase_options.template.dart lib/firebase_options.dart
   ```

2. Update `firebase_options.dart` with your Firebase configuration:
   - Replace all placeholder values with actual values from Firebase Console
   - Ensure all platforms you're targeting are properly configured


## Google Sign-In Configuration

1. Get your SHA-1 fingerprint:
   ```bash
   keytool -list -v -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore -storepass android -keypass android
   ```

2. Add SHA-1 to Firebase Console:
   - Go to Project Settings > Your Apps > Android app
   - Add the SHA-1 fingerprint
   - Download updated `google-services.json`

## Security Notes

1. Never commit sensitive files:
   - `.env`
   - `firebase_options.dart`
   - `google-services.json`
   - `GoogleService-Info.plist`

2. Keep your API keys and secrets secure
3. Regularly review Firebase Security Rules
4. Monitor Firebase Console for any unauthorized usage

## Verification

1. Clean and rebuild the project:
   ```bash
   flutter clean
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

3. Verify:
   - Google Sign-In works
   - Firestore operations work
   - All features are functional

## Troubleshooting

If you encounter issues:

1. Verify all configuration files are properly set up
2. Check SHA-1 fingerprint is correctly added to Firebase
3. Ensure all required Firebase services are enabled
4. Verify package versions in `pubspec.yaml`
5. Check Android and iOS minimum SDK versions

## Support

For additional help:
1. Check the [Flutter Firebase documentation](https://firebase.flutter.dev/docs/overview/)
2. Review the [Google Sign-In documentation](https://pub.dev/packages/google_sign_in)
3. Consult the project maintainers