plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.fymemos"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "me.isming.fymemos"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        //ndk {
        //    abiFilters += "arm64-v8a"
        //    abiFilters += "x86_64"
        //}
    }

    signingConfigs {
        create("release") {
            if (System.getenv("GITHUB_ACTIONS") == "true") {
                storeFile = file("keystore.jks")
                storePassword = project.properties["STORE_PASSWORD"] as String?
                keyAlias = project.properties["KEY_ALIAS"] as String?
                keyPassword = project.properties["KEY_PASSWORD"] as String?
            }
        }
    }


    buildTypes {
        release {
            signingConfig = if (System.getenv("GITHUB_ACTIONS") == "true") {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
