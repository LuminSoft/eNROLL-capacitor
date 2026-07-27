# eNROLL Capacitor Plugin

Capacitor plugin for the **eNROLL SDK** — full-featured eKYC identity verification for Ionic and Capacitor mobile apps on Android and iOS.

eNROLL is a compliance solution that prevents identity fraud and phishing. Powered by AI, it reduces errors and speeds up identification, ensuring secure verification. This is the **standard** eNROLL SDK variant with full theme and icon customization on Android and iOS.

> **⚠️ Native mobile only.** This plugin does **not** support browser/web usage. It requires Capacitor running on a physical or emulated Android/iOS device.

Current native SDK versions:
- **Android:** eNROLL-Android v1.5.29 (via JitPack) + Innovatrics biometrics
- **iOS:** EnrollFramework ~> 3.0.16 (via CocoaPods)

## Requirements

| Platform | Minimum |
|----------|---------|
| Capacitor | 8.0+ |
| Android minSdk | 24 |
| Android compileSdk | 36 |
| Android targetSdk | 36 |
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

For projects that manage repositories from `android/settings.gradle`, add the same repositories inside `dependencyResolutionManagement.repositories`.

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
    compileSdkVersion = 36
    targetSdkVersion = 36
}
```

### iOS Setup

#### 1. Configure Podfile

Add the required pod sources and set the deployment target in your `ios/App/Podfile`. The plugin supports iOS 13.0+, but the example app uses iOS 15.0:

```ruby
source 'https://github.com/LuminSoft/eNROLL-iOS-specs.git'
source 'https://github.com/innovatrics/innovatrics-podspecs.git'
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '15.0'
use_frameworks! :linkage => :static
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

### Basic Example

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
} catch (error: any) {
  console.error('Enrollment failed:', error?.data ?? error);
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

### Update Mode

```typescript
const result = await Enroll.startEnroll({
  tenantId: 'YOUR_TENANT_ID',
  tenantSecret: 'YOUR_TENANT_SECRET',
  enrollMode: 'update',
  applicationId: 'APPLICATION_ID',
});
```

### Sign Contract Mode

Sign contract supports two sub-modes:

#### Contract Template (server-side template)

Provide a `templateId` configured in your eNROLL dashboard. The SDK generates the contract from the template.

```typescript
const result = await Enroll.startEnroll({
  tenantId: 'YOUR_TENANT_ID',
  tenantSecret: 'YOUR_TENANT_SECRET',
  enrollMode: 'signContract',
  applicationId: 'APPLICATION_ID',
  templateId: '12345',
  contractParameters: '{"name": "John", "amount": "5000"}',
});
```

#### Multi-Signing (multiple contracts in one journey)

Pass **comma-separated template IDs** to sign multiple contracts in a single signing session. The SDK displays each contract PDF for the user to review and approve in sequence, then signs all of them with a **single OTP**.

```typescript
const result = await Enroll.startEnroll({
  tenantId: 'YOUR_TENANT_ID',
  tenantSecret: 'YOUR_TENANT_SECRET',
  enrollMode: 'signContract',
  applicationId: 'APPLICATION_ID',
  templateId: '56,63,71',  // comma-separated IDs — triggers multi-signing flow
});
```

> **Note:** Single-ID behavior is unchanged. Multi-signing requires Android SDK v1.5.29+ and iOS EnrollFramework ~> 3.0.16+.

#### PDF File (client-side PDF)

Provide a Base64-encoded PDF directly. No `templateId` is needed.

```typescript
// Read PDF file and convert to Base64 (e.g., via FileReader)
const base64Pdf = '...'; // Base64-encoded PDF content

const result = await Enroll.startEnroll({
  tenantId: 'YOUR_TENANT_ID',
  tenantSecret: 'YOUR_TENANT_SECRET',
  enrollMode: 'signContract',
  applicationId: 'APPLICATION_ID',
  signContractFile: base64Pdf,
  contractFileName: 'my_contract.pdf', // optional display name
});
```

> **Note:** Either `templateId` or `signContractFile` must be provided for sign contract mode. If both are provided, `signContractFile` takes precedence.

---

## Enroll Modes

| Mode | Description | Required Params |
|------|-------------|-----------------|
| `onboarding` | Register a new user | `tenantId`, `tenantSecret` |
| `auth` | Authenticate existing user | + `applicationId`, `levelOfTrust` |
| `update` | Re-verify / update user | + `applicationId` |
| `signContract` | Sign contract (template or PDF) | + `templateId` **or** `signContractFile` |

## Request ID and Resume

The SDK can emit a `requestId` while the flow is still running. Store it on your backend if you need to resume an interrupted enrollment later.

```typescript
const listener = await Enroll.addListener('onRequestId', ({ requestId }) => {
  // Send requestId to your backend and link it to your user/session.
});

await Enroll.startEnroll({
  tenantId: 'YOUR_TENANT_ID',
  tenantSecret: 'YOUR_TENANT_SECRET',
  enrollMode: 'onboarding',
  requestId: 'PREVIOUS_REQUEST_ID',
});

await listener.remove();
```

## Exit Step / Partial Flow

Use `enrollExitStep` when your app needs to stop the SDK after a specific onboarding step and return control to the Ionic/Capacitor app.

If `enrollExitStep` is not provided, the SDK runs the full flow configured for the tenant. This is the same as selecting **None (Full Flow)** in the Android sample app.

```typescript
const listener = await Enroll.addListener('onRequestId', ({ requestId }) => {
  // Persist this requestId if you want to resume the flow later.
});

const result = await Enroll.startEnroll({
  tenantId: 'YOUR_TENANT_ID',
  tenantSecret: 'YOUR_TENANT_SECRET',
  enrollMode: 'onboarding',
  enrollExitStep: 'personalConfirmation',
});

if (result.exitStepCompleted) {
  console.log('Stopped after:', result.completedStepName);
  console.log('Resume with requestId:', result.requestId);
}

await listener.remove();
```

When the configured exit step is completed successfully:

- the native SDK closes and resolves the `startEnroll` promise
- `exitStepCompleted` is `true`
- `completedStepName` contains the completed native step name
- `requestId` can be stored and passed again later to resume the same enrollment request

If the configured step is not part of the tenant's backend flow, the SDK continues according to the configured flow. Use only steps enabled for the selected tenant and enrollment mode.

### Exit Step Values

| TypeScript value | Native Android step | Description |
|------------------|---------------------|-------------|
| no value / `undefined` | `null` | Run the full flow |
| `personalConfirmation` | `EkycStepType.PersonalConfirmation` | Stop after ID/passport personal confirmation |
| `smileLiveness` | `EkycStepType.SmileLiveness` | Stop after face liveness |
| `phoneOtp` | `EkycStepType.PhoneOtp` | Stop after phone OTP verification |
| `emailOtp` | `EkycStepType.EmailOtp` | Stop after email OTP verification |
| `saveMobileDevice` | `EkycStepType.SaveMobileDevice` | Stop after saving the mobile device |
| `deviceLocation` | `EkycStepType.DeviceLocation` | Stop after device location |
| `securityQuestions` | `EkycStepType.SecurityQuestions` | Stop after security questions |
| `password` | `EkycStepType.SettingPassword` | Stop after password setup |
| `amlCheck` | `EkycStepType.AmlCheck` | Stop after AML check |
| `ntraCheck` | `EkycStepType.NtraCheck` | Stop after NTRA check |
| `csoCheck` | `EkycStepType.CsoCheck` | Stop after CSO check |
| `termsAndConditions` | `EkycStepType.TermsConditions` | Stop after terms and conditions |
| `electronicSignature` | `EkycStepType.ElectronicSignature` | Stop after electronic signature |

## Configuration Options

| Key | Type | Required | Default | Description |
|-----|------|----------|---------|-------------|
| `tenantId` | `string` | ✅ | — | Organization tenant ID |
| `tenantSecret` | `string` | ✅ | — | Organization tenant secret |
| `enrollMode` | `EnrollMode` | ✅ | — | SDK flow mode |
| `applicationId` | `string` | mode-dep | — | Application ID (required for `auth`, `update`) |
| `levelOfTrust` | `string` | mode-dep | — | Level-of-trust token (required for `auth`) |
| `templateId` | `string` | mode-dep | — | Contract template ID for `signContract` mode. Comma-separated for multi-signing (e.g. `"56,63,71"`) |
| `enrollEnvironment` | `EnrollEnvironment` | | `'staging'` | Target environment |
| `localizationCode` | `EnrollLocalization` | | `'en'` | UI language |
| `googleApiKey` | `string` | | — | Google Maps API key for location step |
| `skipTutorial` | `boolean` | | `false` | Skip the tutorial screen |
| `correlationId` | `string` | | — | Link your user ID with eNROLL request ID |
| `requestId` | `string` | | — | Resume a previous enrollment request |
| `contractParameters` | `string` | | — | JSON string of contract parameters |
| `signContractFile` | `string` | | — | Base64-encoded PDF for sign contract step |
| `contractFileName` | `string` | | — | Custom filename for the contract PDF |
| `enrollTheme` | `EnrollTheme` | | — | Unified theme (colors + icons + typography) |
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

The eNROLL SDK supports full theme customization via `enrollTheme`. Both colors and icons work on **Android and iOS**.

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

### Icons

Icon `assetName` values reference platform-specific image assets:
- **Android**: drawable resource names in your app's `res/drawable` folder
- **iOS**: image asset names in your app's `Assets.xcassets`

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

### Typography

Customize fonts, size presets, and localization overrides (works on **Android and iOS**):

```typescript
await Enroll.startEnroll({
  // ...required params...
  enrollTheme: {
    typography: {
      fontFamily: 'itim_regular',    // res/font name (Android) or PostScript name (iOS)
      dynamicTypeEnabled: true,
      sizes: 'large',                // 'default' | 'medium' | 'large'
      localizationOverrides: {
        englishFileName: 'enroll_localizations_en', // loaded from app assets/bundle
        arabicFileName: 'enroll_localizations_ar',
      },
    },
  },
});
```

#### Font Type Setup

| Platform | How to add a custom font |
|----------|-------------------------|
| **Android** | Place `.ttf`/`.otf` in `android/app/src/main/res/font/`. Reference the filename (without extension) as `fontFamily`. |
| **iOS** | Add `.ttf`/`.otf` to the Xcode project, register it under `UIAppFonts` in `Info.plist`. Use the PostScript/family name as `fontFamily`. |

The example app includes these bundled fonts: `itim_regular`, `merriweather_variable`, `amiri_regular`, `reem_kufi_variable`.

#### Font Size Presets

| Value | Description |
|-------|-------------|
| `'default'` | Small — SDK default sizing |
| `'medium'` | Medium — slightly larger |
| `'large'` | Large — accessibility-friendly |

#### Localization Overrides

Override any SDK UI string (button labels, error messages, instructions) by providing JSON files:

- **Android:** Place files in `android/app/src/main/assets/` (e.g., `enroll_localizations_en.json`)
- **iOS:** Add files to the Xcode project and ensure they're in "Copy Bundle Resources"

JSON format:

```json
{
  "localizationOverrides": {
    "en": {
      "welcome": "Welcome",
      "start": "Start",
      "exit": "Exit",
      "continue_to_next": "Continue",
      "termsAndConditions": "Terms & Conditions"
    }
  }
}
```

See the example app's `enroll_localizations_en.json` / `enroll_localizations_ar.json` for the complete list of customizable keys.

---

## Platform Limitations

| Feature | Android | iOS |
|---------|---------|-----|
| Color theming | ✅ | ✅ |
| Icon customization | ✅ | ✅ |
| Typography | ✅ | ✅ |
| Sign contract with PDF file | ✅ | ✅ |
| Biometric SDK (Innovatrics) | ✅ | ✅ |
| Simulator support | ✅ (emulator) | ❌ (device only) |

## Troubleshooting

### Web Preview Error

This plugin is native-only. Running in a browser, Ionic serve, or Vite preview will throw an unavailable error. Use:

```bash
npx cap run android
npx cap run ios
```

### Missing License File

If document scanning, face liveness, or NFC fails at runtime, verify that `iengine.lic` is present in the correct native app target:

- Android: `android/app/src/main/res/raw/iengine.lic`
- iOS: `ios/App/App/iengine.lic` and added to the Xcode App target

### FLOW_IN_PROGRESS

`FLOW_IN_PROGRESS` means `startEnroll` was called while another enrollment flow is already open. Disable the launch button until the returned promise resolves or rejects.

### INVALID_ARGUMENT

Check the required fields for the selected mode:

- `onboarding`: `tenantId`, `tenantSecret`
- `auth`: `tenantId`, `tenantSecret`, `applicationId`, `levelOfTrust`
- `update`: `tenantId`, `tenantSecret`, `applicationId`
- `signContract` (template): `tenantId`, `tenantSecret`, `templateId`
- `signContract` (PDF): `tenantId`, `tenantSecret`, `signContractFile`

### iOS Pod Install or Build Issues

Confirm that the Podfile includes the three required pod sources, `platform :ios, '15.0'`, and `use_frameworks! :linkage => :static`. Then run:

```bash
cd ios/App
pod install
```

Build and test on a physical iOS device.

## Security Notes

- **Never hardcode** `tenantSecret`, `levelOfTrust`, or API keys in client-side code.
- Use secure storage (Keychain on iOS, Keystore on Android).
- Rooted/jailbroken devices are blocked by default.
- All SDK network calls use HTTPS.
- Regularly update the plugin to the latest stable version.

## License

MIT
