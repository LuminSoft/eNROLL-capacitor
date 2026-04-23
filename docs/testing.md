# Testing Guide

How to test the eNROLL Capacitor Plugin.

## Prerequisites

- Test credentials: `tenantId` and `tenantSecret` for the **staging** environment
- Android device or emulator (minSdk 24)
- Physical iOS device (no simulator support)
- The example app or your own Ionic app with the plugin installed

## TypeScript Build Verification

```bash
cd /path/to/enroll-capacitor
npm run build
```

This verifies that the TypeScript compiles and bundles without errors.

## Manual Test Checklist

### Per-Mode Testing

Run each mode and verify the expected outcome:

| # | Mode | Required Params | Expected |
|---|------|-----------------|----------|
| 1 | `onboarding` | tenantId, tenantSecret | Full onboarding flow completes, returns applicantId |
| 2 | `auth` | + applicationId, levelOfTrust | Authentication flow completes |
| 3 | `update` | + applicationId | Update flow completes |
| 4 | `signContract` | + templateId | Contract signing flow completes |

### Error Scenario Testing

| # | Test | Expected |
|---|------|----------|
| 6 | Empty `tenantId` | Reject with code `INVALID_ARGUMENT`, message "tenantId is required" |
| 7 | Empty `tenantSecret` | Reject with code `INVALID_ARGUMENT` |
| 8 | Invalid `enrollMode` | Reject with code `INVALID_ARGUMENT` |
| 9 | `auth` mode without `applicationId` | Reject with "applicationId is required for auth mode" |
| 10 | `auth` mode without `levelOfTrust` | Reject with "levelOfTrust is required for auth mode" |
| 11 | `signContract` without `templateId` | Reject with "templateId is required for signContract mode" |
| 12 | Call `startEnroll` while flow is running | Reject with code `FLOW_IN_PROGRESS` |
| 13 | Call on web browser | Reject with `UNAVAILABLE` error |

### Feature Testing

| # | Feature | How to Test |
|---|---------|-------------|
| 14 | Custom colors | Pass `enrollTheme.colors` with custom primary/secondary, verify UI |
| 15 | Arabic localization | Set `localizationCode: 'ar'`, verify RTL layout |
| 16 | English localization | Set `localizationCode: 'en'`, verify LTR layout |
| 17 | Skip tutorial | Set `skipTutorial: true`, verify tutorial is skipped |
| 18 | Exit step | Set `enrollExitStep: 'phoneOtp'`, verify flow exits after OTP |
| 19 | Forced document type | Set `enrollForcedDocumentType: 'passportOnly'`, verify |
| 20 | Request ID listener | Register listener, verify `onRequestId` fires during flow |
| 21 | Resume flow | Use saved `requestId` to resume a previous flow |

### Platform Matrix

Run tests 1–13 on both platforms:

| Test | Android | iOS |
|------|---------|-----|
| 1–4 (modes) | ☐ | ☐ |
| 6–13 (errors) | ☐ | ☐ |
| 14–21 (features) | ☐ | ☐ |

## Known Limitations

- **iOS Simulator:** Not supported. EnrollFramework is arm64 only.
- **Rooted/Jailbroken devices:** Blocked by the native SDK by default.
- **NFC (ePassport):** Requires physical device + NFC capability entitlement.

## Automated Tests

Currently, automated E2E tests are not feasible because the SDK requires:
- Camera access for document scanning
- Biometric detection (liveness)
- Physical device interaction

Unit tests for the TypeScript layer can be run with:

```bash
npm run verify:web
```
