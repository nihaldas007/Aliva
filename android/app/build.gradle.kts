import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"

// 1. Forces Kotlin to use JVM 17
kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

android {
    namespace = "com.example.eliva_control"
    compileSdk = 36 // Fixes the splash screen warning

    defaultConfig {
        applicationId = "com.example.eliva_control"
        minSdk = flutter.minSdkVersion
        targetSdk = 33 // Prevents Android 14+ from crashing your Bluetooth plugin
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
    }

    // 2. THIS FIXES YOUR CURRENT ERROR: Forces Java to match Kotlin at 17
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
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
