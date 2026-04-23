# eNROLL Capacitor Plugin

Capacitor plugin for the **eNROLL SDK** — full-featured eKYC identity verification for Ionic and Capacitor mobile apps on Android and iOS.

eNROLL is a compliance solution that prevents identity fraud and phishing. Powered by AI, it reduces errors and speeds up identification, ensuring secure verification. This is the **standard** eNROLL SDK variant with full theme and icon customization on Android and color theming on iOS.

> **⚠️ Native mobile only.** This plugin does **not** support browser/web usage. It requires Capacitor running on a physical or emulated Android/iOS device.

Current native SDK versions:
- **Android:** eNROLL-Android v1.5.22 (via JitPack) + Innovatrics biometrics
- **iOS:** EnrollFramework ~> 3.0.7 (via CocoaPods)

## Requirements

| Platform | Minimum |
|----------|---------|
| Capacitor | 6.0+ |
| Android minSdk | 24 |
| Android compileSdk | 34 |
| iOS deployment target | 13.0 |
| Kotlin | 2.1.0 |
| Swift | 5.0 |
| Node.js | 18+ |

## Installation

```bash
npm install enroll-capacitor
npx cap sync
```

### Android Setup

#### 1. Add Repositories

Add the JitPack and Innovatrics repositories to your **project-level** `android/build.gradle` (or `android/settings.gradle`):

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

#### 2. Add Innovatrics License File

Place the `iengine.lic` file (from your Innovatrics/LuminSoft account) at:

```
android/app/src/main/res/raw/iengine.lic
```

> Without this file, biometric features (face liveness, document scanning, ePassport NFC) will fail at runtime.

#### 3. Verify minSdkVersion

Ensure `minSdkVersion` is at least **24** in `android/variables.gradle`:

```gradle
ext {
    minSdkVersion = 24
}
```

### iOS Setup

#### 1. Configure Podfile

Add the required pod sources and set the deployment target in your `ios/App/Podfile`:

```ruby
source 'https://github.com/LuminSoft/eNROLL-iOS-specs.git'
source 'https://github.com/innovatrics/innovatrics-podspecs.git'
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '15.0'
```

#### 2. Add Innovatrics License File

Place the `iengine.lic` file at `ios/App/App/iengine.lic`, then add it to your Xcode project:

1. Open `ios/App/App.xcworkspace` in Xcode
2. Drag `iengine.lic` into the **App** group
3. Ensure **"Copy items if needed"** is checked and the **App** target is selected

> Without this file, biometric features will fail at runtime.

#### 3. Add Info.plist Permissions

Add to `ios/App/App/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to capture your ID and face for verification</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location for security compliance</string>
```

#### 4. Install Pods

```bash
cd ios/App && pod install && cd ../..
```

> **Note:** iOS builds require a **physical device**. The EnrollFramework does not include a simulator architecture.

### ePassport / NFC (Optional — iOS only)

If you need electronic passport NFC reading, add to `Info.plist`:

```xml
<key>com.apple.developer.nfc.readersession.felica.systemcodes</key>
<array><string>A0000002471001</string></array>
<key>com.apple.developer.nfc.readersession.iso7816.select-identifiers</key>
<array><string>A0000002471001</string></array>
<key>NFCReaderUsageDescription</key>
<string>We need NFC access to read your electronic passport</string>
```

Then enable **Near Field Communication Tag Reading** in Xcode → Target → Signing & Capabilities.

---

## Usage

### Basic Example (Ionic/Angular)

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
  console.log('Exit step completed:', result.exitStepCompleted);
} catch (error) {
  console.error('Enrollment failed:', error);
} finally {
  await listener.remove();
}
```

### Authentication Mode

```typescript
const result = await Enroll.startEnroll({
  tenantId: 'YOUR_TENANT_ID',
  tenantSecret: 'YOUR_TENANT_SECRET',
  enrollMode: 'auth',
  applicationId: 'APPLICATION_ID',
  levelOfTrust: 'LEVEL_OF_TRUST_TOKEN',
});
```

### Sign Contract Mode

```typescript
const result = await Enroll.startEnroll({
  tenantId: 'YOUR_TENANT_ID',
  tenantSecret: 'YOUR_TENANT_SECRET',
  enrollMode: 'signContract',
  templateId: '12345',
  contractParameters: '{"key": "value"}',
});
```

---

## Enroll Modes

| Mode | Description | Required Params |
|------|-------------|-----------------|
| `onboarding` | Register a new user | `tenantId`, `tenantSecret` |
| `auth` | Authenticate existing user | + `applicationId`, `levelOfTrust` |
| `update` | Re-verify / update user | + `applicationId` |
| `signContract` | Sign contract templates | + `templateId` |

## Configuration Options

| Key | Type | Required | Default | Description |
|-----|------|----------|---------|-------------|
| `tenantId` | `string` | ✅ | — | Organization tenant ID |
| `tenantSecret` | `string` | ✅ | — | Organization tenant secret |
| `enrollMode` | `EnrollMode` | ✅ | — | SDK flow mode |
| `applicationId` | `string` | mode-dep | — | Application ID (required for `auth`, `update`) |
| `levelOfTrust` | `string` | mode-dep | — | Level-of-trust token (required for `auth`) |
| `templateId` | `string` | mode-dep | — | Contract template ID (required for `signContract`) |
| `enrollEnvironment` | `EnrollEnvironment` | | `'staging'` | Target environment |
| `localizationCode` | `EnrollLocalization` | | `'en'` | UI language |
| `googleApiKey` | `string` | | — | Google Maps API key for location step |
| `skipTutorial` | `boolean` | | `false` | Skip the tutorial screen |
| `correlationId` | `string` | | — | Link your user ID with eNROLL request ID |
| `requestId` | `string` | | — | Resume a previous enrollment request |
| `contractParameters` | `string` | | — | JSON string of contract parameters |
| `enrollTheme` | `EnrollTheme` | | — | Unified theme (colors + icons) |
| `appColors` | `EnrollColors` | | — | Color overrides (deprecated — use `enrollTheme.colors`) |
| `enrollForcedDocumentType` | `EnrollForcedDocumentType` | | — | Force specific document type |
| `enrollExitStep` | `EnrollStepType` | | — | Auto-close SDK after this step |

## Success Result

| Field | Type | Description |
|-------|------|-------------|
| `applicantId` | `string` | Assigned applicant ID |
| `enrollMessage` | `string?` | Human-readable success message |
| `documentId` | `string?` | Document ID (if applicable) |
| `requestId` | `string?` | Request ID for resuming later |
| `exitStepCompleted` | `boolean` | `true` if flow ended early via `enrollExitStep` |
| `completedStepName` | `string?` | Name of the completed exit step |

## Theme Customization

The eNROLL SDK supports full theme customization via `enrollTheme`. Colors work on **both** Android and iOS. Icons are **Android only**.

### Colors

```typescript
await Enroll.startEnroll({
  // ...required params...
  enrollTheme: {
    colors: {
      primary: { r: 29, g: 86, b: 184, opacity: 1.0 },
      secondary: { r: 87, g: 145, b: 219 },
      appBackgroundColor: { r: 255, g: 255, b: 255 },
      textColor: { r: 0, g: 65, b: 148 },
      errorColor: { r: 219, g: 48, b: 91 },
      successColor: { r: 97, g: 204, b: 61 },
      warningColor: { r: 249, g: 213, b: 72 },
    },
  },
});
```

### Icons (Android only)

Icon `assetName` values correspond to Android drawable resource names in your app's `res/drawable` folder.

```typescript
await Enroll.startEnroll({
  // ...required params...
  enrollTheme: {
    icons: {
      logo: { mode: 'custom', assetName: 'my_company_logo', renderingMode: 'original' },
      location: {
        tutorial: { assetName: 'ic_location_tutorial' },
        requestAccess: { assetName: 'ic_location_access' },
      },
      nationalId: {
        tutorial: { assetName: 'ic_nid_tutorial', renderingMode: 'template' },
      },
    },
  },
});
```

Available icon groups: `logo`, `location`, `nationalId`, `passport`, `phone`, `email`, `faceMatching`, `securityQuestions`, `password`, `signature`, `common`, `update`, `forget`.

See `EnrollIcons` in `src/definitions.ts` for the full type reference.

## Enrollment Step Types

Used with `enrollExitStep` to terminate the flow after a specific step:

`phoneOtp` · `personalConfirmation` · `smileLiveness` · `emailOtp` · `saveMobileDevice` · `deviceLocation` · `password` · `securityQuestions` · `amlCheck` · `termsAndConditions` · `electronicSignature` · `ntraCheck` · `csoCheck`

---

## Platform Limitations

| Feature | Android | iOS |
|---------|---------|-----|
| Color theming | ✅ | ✅ |
| Icon customization | ✅ | ❌ (planned) |
| Biometric SDK (Innovatrics) | ✅ | ✅ |
| Simulator support | ✅ (emulator) | ❌ (device only) |

## Security Notes

- **Never hardcode** `tenantSecret`, `levelOfTrust`, or API keys in client-side code.
- Use secure storage (Keychain on iOS, Keystore on Android).
- Rooted/jailbroken devices are blocked by default.
- All SDK network calls use HTTPS.
- Regularly update the plugin to the latest stable version.

## License

MIT
