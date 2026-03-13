plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val walletApiDir = rootProject.projectDir.resolve("../api/andriod")
val generatedJniLibsDir = layout.buildDirectory.dir("generated/jniLibs")

android {
    namespace = "com.example.macos_sample_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.macos_sample_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    sourceSets {
        getByName("main").jniLibs.srcDir(generatedJniLibsDir)
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

val prepareWalletJniLibs by tasks.registering(Sync::class) {
    into(generatedJniLibsDir)

    from(walletApiDir.resolve("arm64-v8a")) {
        into("arm64-v8a")
    }

    from(walletApiDir.resolve("armabi-v7a")) {
        into("armeabi-v7a")
    }

    from(walletApiDir.resolve("x86_64")) {
        into("x86_64")
    }

    doFirst {
        if (!walletApiDir.exists()) {
            throw GradleException(
                "Expected Android wallet libraries at: ${walletApiDir.absolutePath}",
            )
        }

        val missingDirs =
            listOf("arm64-v8a", "armabi-v7a", "x86_64").filterNot {
                walletApiDir.resolve(it).exists()
            }

        if (missingDirs.isNotEmpty()) {
            throw GradleException(
                "Missing Android wallet ABI directories: ${missingDirs.joinToString()}",
            )
        }
    }
}

tasks.named("preBuild") {
    dependsOn(prepareWalletJniLibs)
}

flutter {
    source = "../.."
}
