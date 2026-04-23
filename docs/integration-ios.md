# iOS Integration Guide

Detailed setup instructions for using the eNROLL Capacitor Plugin on iOS.

## Prerequisites

- Xcode 15+
- **Physical iOS device** (the EnrollFramework does NOT include a simulator slice)
- CocoaPods (`gem install cocoapods`)
- Apple Developer account (for device provisioning)
- iOS 13.0+ deployment target

## Step 1: Install the Plugin

```bash
npm install enroll-capacitor
npx cap sync ios
```

## Step 2: Configure Podfile

In `ios/App/Podfile`, add the required pod sources and set the deployment target:

```ruby
source 'https://github.com/LuminSoft/eNROLL-iOS-specs.git'
source 'https://github.com/innovatrics/innovatrics-podspecs.git'
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '15.0'
```

> **Note:** The minimum deployment target depends on your Capacitor version. Capacitor 6+ requires iOS 13.0, Capacitor 8+ requires iOS 15.0.

## Step 3: Add Innovatrics License File

The eNROLL SDK uses Innovatrics biometrics (face detection, document scanning, NFC). You must place the Innovatrics license file in your iOS project:

1. Obtain the `iengine.lic` file from your Innovatrics/LuminSoft account
2. Place it at: `ios/App/App/iengine.lic`
3. Open `ios/App/App.xcworkspace` in Xcode
4. Drag and drop `iengine.lic` into the **App** group in the project navigator
5. Ensure **"Copy items if needed"** is checked and the **App** target is selected

```
ios/
  App/
    App/
      iengine.lic   ← place here
```

> Without this file, biometric features (face liveness, document scanning, ePassport NFC) will fail at runtime.

## Step 4: Add Info.plist Permissions

Add to `ios/App/App/Info.plist`:

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

## Step 5: Install Pods and Build

```bash
cd ios/App && pod install && cd ../..
npx cap open ios   # Opens in Xcode
```

Select your physical device in Xcode and build.

## ePassport / NFC (Optional)

If your eKYC flow includes electronic passport reading via NFC:

### 1. Add to Info.plist

```xml
<key>com.apple.developer.nfc.readersession.felica.systemcodes</key>
<array><string>A0000002471001</string></array>
<key>com.apple.developer.nfc.readersession.iso7816.select-identifiers</key>
<array><string>A0000002471001</string></array>
<key>NFCReaderUsageDescription</key>
<string>We need NFC access to read your electronic passport</string>
```

### 2. Enable NFC Capability

1. Open `ios/App/App.xcworkspace` in Xcode
2. Select your Target → **Signing & Capabilities**
3. Click **+ Capability**
4. Add **Near Field Communication Tag Reading**

> NFC requires a physical device. It will not work on simulators.

## Troubleshooting

### "No simulator slice" / Build fails on simulator
- The `EnrollFramework.xcframework` is arm64 only. You **must** test on a physical device.
- For development without a device, you can stub the plugin calls in your TypeScript code.

### Build fails with deployment target error
- Set `platform :ios, '13.0'` in your Podfile
- In Xcode, set the deployment target to 13.0 for your app target
