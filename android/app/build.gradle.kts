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

    splits {

    // Configures multiple APKs based on ABI.
    abi {

      // Enables building multiple APKs per ABI.
      isEnable = true
      

      // By default all ABIs are included, so use reset() and include to specify that you only
      // want APKs for x86 and x86_64.

      // Resets the list of ABIs for Gradle to create APKs for to none.
      reset()

      // Specifies a list of ABIs for Gradle to create APKs for."x86", , "armeabi-v7a"
      include("x86_64", "arm64-v8a")

      // Specifies that you don't want to also generate a universal APK that includes all ABIs.
      isUniversalApk = false
    }
  }

    

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
