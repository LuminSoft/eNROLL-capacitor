# Android Integration Guide

Detailed setup instructions for using the eNROLL Capacitor Plugin on Android.

## Prerequisites

- Android Studio with SDK 34
- Android device or emulator with minSdk 24 (Android 7.0+)
- JitPack access (public, no auth needed)

## Step 1: Install the Plugin

```bash
npm install enroll-capacitor
npx cap sync android
```

## Step 2: Add JitPack Repository

The eNROLL Android SDK is hosted on JitPack and uses Innovatrics biometrics. Add both repositories to your Ionic project's Android configuration.

**Option A — `android/build.gradle` (older Gradle structure):**

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://jitpack.io' }
        maven { url 'https://maven.innovatrics.com/releases' }
    }
}
```

**Option B — `android/settings.gradle` (newer Gradle structure):**

```gradle
dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://jitpack.io' }
        maven { url 'https://maven.innovatrics.com/releases' }
    }
}
```

## Step 3: Add Innovatrics License File

The eNROLL SDK uses Innovatrics biometrics (face detection, document scanning, NFC). You must place the Innovatrics license file in your Android project:

1. Obtain the `iengine.lic` file from your Innovatrics/LuminSoft account
2. Place it at: `android/app/src/main/res/raw/iengine.lic`

```
android/
  app/
    src/
      main/
        res/
          raw/
            iengine.lic   ← place here
```

> Without this file, biometric features (face liveness, document scanning, ePassport NFC) will fail at runtime.

## Step 4: Verify minSdkVersion

Ensure your project's `android/variables.gradle` has at least:

```gradle
ext {
    minSdkVersion = 24
    compileSdkVersion = 34
    targetSdkVersion = 34
}
```

## Step 5: Sync and Build

```bash
npx cap sync android
npx cap open android   # Opens in Android Studio
```

Build and run from Android Studio onto your device or emulator.

## ProGuard / R8

If you enable minification, you may need ProGuard rules. The plugin includes a `proguard-rules.pro` file. If you encounter issues, add to your app's `proguard-rules.pro`:

```proguard
-keep class com.luminsoft.enroll_sdk.** { *; }
-keep class com.luminsoft.enroll.capacitor.** { *; }
```

## Permissions

The eNROLL SDK requests these permissions at runtime:
- **Camera** — for document scanning and liveness detection
- **Location** — for the device location step (if configured)

No changes to `AndroidManifest.xml` are needed — the SDK handles permissions internally.

## Troubleshooting

### JitPack dependency not resolving
- Ensure `maven { url 'https://jitpack.io' }` is in the correct repositories block
- Run `./gradlew --refresh-dependencies` from the `android/` directory

### Build fails with "minSdk 24" error
- Update `minSdkVersion` to at least 24 in `android/variables.gradle`

### Rooted device blocked
- The eNROLL SDK blocks rooted devices by default for security. This is expected behavior.
