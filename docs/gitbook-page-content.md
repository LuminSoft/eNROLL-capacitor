# eNROLL Capacitor Plugin

Our in-house developed eNROLL platform serves as a technological compliance solution. A solution that is now familiarized across the globe in countries with big populations, where falsification of identity, signatures, and phishing is very common.

The software utilizes a set of AI-powered technologies, like the OCR (Optical Character Recognition), to cut back on the risks of human-based errors and the time needed for identification.

> **⚠️ Native mobile only.** This plugin does **not** support browser/web usage. It requires Capacitor running on a physical or emulated Android/iOS device.

## REQUIREMENTS

* Capacitor 6.0+
* Android minSdkVersion 24
* Android compileSdkVersion 34
* Kotlin Version 2.1.0
* iOS Deployment Target 13.0
* Swift 5.0
* Physical iOS device (no simulator support — the EnrollFramework is arm64 only)

## 1. INSTALLATION

Install the plugin via npm:

```bash
npm install enroll-capacitor
npx cap sync
```

### 1.1. Android

* Upgrade minSdkVersion to 24 in `android/variables.gradle`:

```gradle
ext {
    minSdkVersion = 24
    compileSdkVersion = 34
    targetSdkVersion = 34
}
```

* Add JitPack and Innovatrics repositories to your **project-level** `android/build.gradle`:

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

* Or for newer Gradle structures, add to `android/settings.gradle`:

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

* Add the Innovatrics license file at `android/app/src/main/res/raw/iengine.lic`

> Without this file, biometric features (face liveness, document scanning, ePassport NFC) will fail at runtime.

### 1.2. iOS

* Add pod sources and set the deployment target in `ios/App/Podfile`:

```ruby
source 'https://github.com/LuminSoft/eNROLL-iOS-specs.git'
source 'https://github.com/innovatrics/innovatrics-podspecs.git'
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '15.0'
```

* Add the Innovatrics license file at `ios/App/App/iengine.lic`:
  * Open the `.xcworkspace` in Xcode
  * Drag `iengine.lic` into the **App** group
  * Ensure **"Copy items if needed"** is checked and the **App** target is selected

> Without this file, biometric features will fail at runtime.

* Add the following to your project `ios/App/App/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to capture your ID and face for verification</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location for security compliance</string>
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

* Install pods:

```bash
cd ios/App && pod install && cd ../..
```

### 1.3. ePassport / NFC (Optional)

If your eKYC flow includes electronic passport reading via NFC, add to `ios/App/App/Info.plist`:

```xml
<key>com.apple.developer.nfc.readersession.felica.systemcodes</key>
<array><string>A0000002471001</string></array>
<key>com.apple.developer.nfc.readersession.iso7816.select-identifiers</key>
<array><string>A0000002471001</string></array>
<key>NFCReaderUsageDescription</key>
<string>We need NFC access to read your electronic passport</string>
```

Then enable **Near Field Communication Tag Reading** in Xcode → Target → Signing & Capabilities.

## 2. IMPORT

```typescript
import { Enroll } from 'enroll-capacitor';
import type {
  StartEnrollOptions,
  EnrollSuccessResult,
  EnrollRequestIdResult,
} from 'enroll-capacitor';
```

## 3. USAGE

### Basic Example (Ionic / Angular)

```typescript
import { Enroll } from 'enroll-capacitor';
import type { EnrollSuccessResult } from 'enroll-capacitor';

// Listen for request ID events (fires mid-flow)
const listener = await Enroll.addListener('onRequestId', (data) => {
  console.log('Request ID:', data.requestId);
});

try {
  const result: EnrollSuccessResult = await Enroll.startEnroll({
    tenantId: 'YOUR_TENANT_ID',
    tenantSecret: 'YOUR_TENANT_SECRET',
    enrollMode: 'onboarding',
    enrollEnvironment: 'staging',
    localizationCode: 'en',
    skipTutorial: false,
  });

  console.log('Success! Applicant ID:', result.applicantId);
} catch (error: any) {
  console.error('Error:', error.message);
} finally {
  await listener.remove();
}
```

### Angular Service Example

```typescript
import { Injectable } from '@angular/core';
import { Enroll } from 'enroll-capacitor';
import type {
  StartEnrollOptions,
  EnrollSuccessResult,
  EnrollRequestIdResult,
} from 'enroll-capacitor';
import type { PluginListenerHandle } from '@capacitor/core';

@Injectable({ providedIn: 'root' })
export class EnrollService {
  private requestIdListener: PluginListenerHandle | null = null;

  async startEnroll(options: StartEnrollOptions): Promise<EnrollSuccessResult> {
    return Enroll.startEnroll(options);
  }

  async onRequestId(callback: (result: EnrollRequestIdResult) => void): Promise<void> {
    this.requestIdListener = await Enroll.addListener('onRequestId', callback);
  }

  async cleanup(): Promise<void> {
    if (this.requestIdListener) {
      await this.requestIdListener.remove();
      this.requestIdListener = null;
    }
  }
}
```

## 4. ENROLL MODES

The SDK supports **4 modes**:

| Mode | Description | Requirements |
| --- | --- | --- |
| `onboarding` | Registering a new user in the system. | `tenantId`, `tenantSecret` (required). |
| `auth` | Verifying the identity of an existing user. | `tenantId`, `tenantSecret`, **`applicationId`**, **`levelOfTrust`** (all required). |
| `update` | Updating or re-verifying the identity of an existing user. | `tenantId`, `tenantSecret`, `applicationId` (required). |
| `signContract` | Signing contract templates by a user. | `tenantId`, `tenantSecret`, **`templateId`**, `applicationId` (required). Optional: `contractParameters`. |

## 5. VALUES DESCRIPTION

| Key | Value |
| --- | --- |
| `tenantId` | **Required**. Your organization tenant ID. |
| `tenantSecret` | **Required**. Your organization tenant secret. |
| `enrollMode` | **Required**. Mode of the SDK. (See Enroll Modes above). |
| `enrollEnvironment` | **Optional**. `'staging'` or `'production'`. Defaults to `'staging'`. |
| `localizationCode` | **Optional**. `'en'` for English, `'ar'` for Arabic (with RTL). Defaults to `'en'`. |
| `applicationId` | **Conditional**. Required for `auth`, `update`, and `signContract` modes. |
| `levelOfTrust` | **Conditional**. Required for `auth` mode. |
| `templateId` | **Conditional**. Required for `signContract` mode. |
| `googleApiKey` | **Optional**. Google Maps API key for the device location step. |
| `skipTutorial` | **Optional**. Skip the tutorial screen. Defaults to `false`. |
| `correlationId` | **Optional**. Link your User ID with the SDK Request ID. |
| `requestId` | **Optional**. Resume a previously initiated request instead of starting fresh. |
| `contractParameters` | **Optional**. JSON string of extra contract parameters for `signContract`. |
| `enrollTheme` | **Optional**. Unified theme config with `colors` and `icons` (Android only for icons). Colors use `{ r, g, b, opacity? }` format with values 0–255 and opacity 0.0–1.0. |
| `appColors` | **Optional** (deprecated). Use `enrollTheme.colors` instead. |
| `enrollForcedDocumentType` | **Optional**. `'nationalIdOnly'`, `'passportOnly'`, or `'nationalIdOrPassport'`. |
| `enrollExitStep` | **Optional**. Exit after a specific step (e.g., `'smileLiveness'`, `'phoneOtp'`). |

## 6. SUCCESS RESULT

The `startEnroll` promise resolves with `EnrollSuccessResult`:

| Property | Type | Description |
| --- | --- | --- |
| `applicantId` | `string` | Assigned applicant ID. |
| `enrollMessage` | `string \| undefined` | Success message from the SDK. |
| `documentId` | `string \| undefined` | Document ID if applicable. |
| `requestId` | `string \| undefined` | Request ID for resuming flows. |
| `exitStepCompleted` | `boolean` | `true` if the flow exited early via `enrollExitStep`. |
| `completedStepName` | `string \| undefined` | Name of the completed exit step. |

## 7. ERROR CODES

| Code | Meaning |
| --- | --- |
| `INVALID_ARGUMENT` | Missing or invalid required parameter. |
| `FLOW_IN_PROGRESS` | Another enrollment flow is already running. |
| `ACTIVITY_ERROR` | Android Activity not available. |
| `VIEW_CONTROLLER_ERROR` | iOS ViewController not available. |
| `ENROLL_ERROR` | Native SDK returned an error. |
| `ENROLL_LAUNCH_ERROR` | Failed to initialize/launch the native SDK. |
| `UNAVAILABLE` | Plugin called on web (not supported). |

## 8. SECURITY NOTES

* Never hardcode `tenantSecret`, `levelOfTrust`, or API keys inside the mobile application. Use a secure storage mechanism (e.g., Keychain on iOS, Keystore on Android).
* Regularly update the SDK to the latest stable version for security patches.
* Rooted/jailbroken devices are blocked by default for security reasons.
* All SDK network calls use HTTPS.

## 9. ADDITIONAL RESOURCES

* **npm package:** [enroll-capacitor](https://www.npmjs.com/package/enroll-capacitor)
* **GitHub:** [https://github.com/LuminSoft/enroll-capacitor](https://github.com/LuminSoft/enroll-capacitor)
