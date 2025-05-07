plugins {
    id "com.android.application"
    id "kotlin-android"
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id "dev.flutter.flutter-gradle-plugin"
}

def localProperties = new Properties()
def localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader("UTF-8") { reader ->
        localProperties.load(reader)
    }
}

def flutterVersionCode = localProperties.getProperty("flutter.versionCode")
if (flutterVersionCode == null) {
    flutterVersionCode = "1"
}

def flutterVersionName = localProperties.getProperty("flutter.versionName")
if (flutterVersionName == null) {
    flutterVersionName = "1.0"
}

// Read environment variables for potential API keys
// Example: def googleMapsApiKey = System.getenv("GOOGLE_MAPS_API_KEY")

android {
    // ----- BEGIN VARIABLE SECTION -----
    // Set compileSdkVersion to the latest stable version.
    compileSdkVersion 34 // Updated to a more recent version
    namespace "com.example.kitaby_flutter" // Replace with your actual package name
    ndkVersion flutter.ndkVersion
    // ----- END VARIABLE SECTION -----

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets {
        main.java.srcDirs += "src/main/kotlin"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId "com.example.kitaby_flutter" // Replace with your actual package name
        // You can update the following values to match your application needs.
        // For more information, see: https://docs.flutter.dev/deployment/android#reviewing-the-gradle-build-configuration.
        minSdkVersion 21 // Increased minSdkVersion as required by some packages
        targetSdkVersion 34 // Match compileSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
        // Example of adding build config field for API key:
        // if (googleMapsApiKey != null) {
        //     resValue "string", "google_maps_api_key", googleMapsApiKey
        // }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig signingConfigs.debug
        }
    }
}

flutter {
    source "../.."
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk8:$kotlin_version" // Ensure Kotlin stdlib is included
    // Add any other specific Android dependencies here if needed
}
