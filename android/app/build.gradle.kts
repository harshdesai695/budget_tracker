plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.budget_tracker"
    compileSdk = 36 // <-- UPDATED to match your plugins
    ndkVersion = "27.0.12077973" // <-- UPDATED to match your plugins

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.budget_tracker"
        minSdk = flutter.minSdkVersion // This is fine
        targetSdk = 36 // <-- THIS IS THE FIX (was 25)
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // You can add other Android dependencies here if needed
}
