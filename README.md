# Budget Tracker

A Flutter-based personal finance management application that helps users track their expenses and manage budgets effectively.

## Features

- Google Sign-In Authentication
- Category-based expense tracking
- Interactive charts and visualizations
- Real-time data synchronization using Firebase
- Clean and intuitive Material Design UI

## Tech Stack

- Flutter
- Firebase (Authentication, Firestore)
- Google Sign-In
- Charts for data visualization

## Prerequisites

- Flutter SDK (latest stable version)
- Firebase CLI
- Android Studio / VS Code
- Git

## Setting up Firebase

### Method 1: Using Firebase CLI (Recommended)

1. Install Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```

2. Login to Firebase:
   ```bash
   firebase login
   ```

3. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

4. Configure Firebase in your project:
   ```bash
   flutterfire configure --project=your-project-id
   ```

### Method 2: Manual Setup via Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Add Android app:
   - Use package name: `com.example.budget_tracker`
   - Download `google-services.json`
   - Place it in `android/app/`
4. Enable Authentication:
   - Go to Authentication > Sign-in methods
   - Enable Google Sign-in
5. Set up Cloud Firestore:
   - Create database
   - Set up rules for security

### Getting SHA-1 Certificate
```bash
keytool -list -v -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore -storepass android -keypass android
```
Add the SHA-1 to your Firebase Android app configuration.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/budget_tracker.git
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Update Firebase configuration:
   - Replace placeholder values in `lib/firebase_options.dart`
   - Add your `google-services.json` to `android/app/`

4. Run the app:
   ```bash
   flutter run
   ```

## Security Notes

Sensitive configuration files are excluded from version control. Before running the app, make sure to:
1. Set up proper Firebase configuration
2. Replace placeholder values in configuration files
3. Never commit actual API keys or secrets

## Project Structure

```
lib/
├── models/
│   ├── chart_models.dart      # Chart data models
│   └── data_models.dart       # Core data models
├── screens/
│   ├── drawer.dart           # Navigation drawer
│   └── home_page.dart        # Main screen
├── services/
│   ├── firebase.dart         # Firebase operations
│   └── sign_in.dart         # Authentication service
├── widgets/
│   ├── charts.dart          # Chart components
│   └── custom_buttons.dart  # Reusable buttons
└── main.dart                # App entry point
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request


