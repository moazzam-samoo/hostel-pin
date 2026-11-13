import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // NOTE: deliberately NOT applying org.jetbrains.kotlin.android (KGP).
    // AGP 9 uses Built-in Kotlin, and Flutter warns that applying KGP here
    // "will cause build failures in future versions of Flutter". Kotlin
    // source compilation is instead wired up via the sourceSets block below.
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Read MAPS_API_KEY out of local.properties (gitignored) so the real key
// never gets committed — see that file for where to paste it.
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(FileInputStream(localPropertiesFile))
}
val mapsApiKey: String = localProperties.getProperty("MAPS_API_KEY") ?: "YOUR_GOOGLE_MAPS_API_KEY_HERE"

// Release signing. Reads android/key.properties (git-ignored) — see
// RELEASE_CHECKLIST.md section A for how to create the keystore. Expected keys:
//   storeFile=<path to upload-keystore.jks>   storePassword=...
//   keyAlias=upload                           keyPassword=...
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.hostelfinder.hostel_finder_app"
    compileSdk = 36
    // Must be the highest NDK any plugin requires (they're backward
    // compatible). firebase_*, google_maps_flutter, geolocator, image_picker
    // and ~13 others all require 28.2.13676358; the previous 25.1.8937393
    // made every `flutter run` fail the NDK-mismatch check.
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }


    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.hostelfinder.hostel_finder_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["MAPS_API_KEY"] = mapsApiKey
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            if (hasReleaseKeystore) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                // No android/key.properties on this machine: fall back to the
                // debug key so `flutter run --release` still works locally.
                // NEVER upload a bundle built this way — Play rejects it.
                logger.warn("WARNING: android/key.properties not found; signing release with the DEBUG key.")
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
