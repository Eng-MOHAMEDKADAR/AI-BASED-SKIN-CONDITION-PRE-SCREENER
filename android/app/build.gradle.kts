plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") // ✅ correct Kotlin plugin
    id("dev.flutter.flutter-gradle-plugin")

    // Google services plugin (version comes from project-level build.gradle.kts)
    id("com.google.gms.google-services")
}

dependencies {
    // Firebase BoM (Bill of Materials) - keeps all Firebase libs in sync
    implementation(platform("com.google.firebase:firebase-bom:34.2.0"))

    // Firebase products
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")

    // Add more Firebase dependencies if needed
}

android {
    namespace = "com.example.smart_crop_detection"
    compileSdk = flutter.compileSdkVersion

    // ✅ Force NDK version required by Firebase
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.smart_crop_detection"

        // ✅ Set minSdk to 23 (Firebase requirement)
        minSdk = 23
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
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
