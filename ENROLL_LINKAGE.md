# enroll-capacitor — Linkage & Sync Guide

## What This Repo Is

**Capacitor plugin** for the **enroll** (production) product line. Wraps the native eNROLL Android SDK (with Innovatrics) for Ionic/Capacitor apps.

## Product Line

**enroll** (production) — uses Innovatrics for OCR, face matching, and identity features.

## Native SDK Dependency

| Field | Value |
|---|---|
| Branch | `release/production` |
| Artifact | `com.github.LuminSoft:eNROLL-Android` |
| Current Version | `v1.5.22` |
| Declared in | `android/build.gradle` |
| iOS Distribution | CocoaPods (`EnrollFramework ~> 3.0.7`) |

> **WARNING**: SDK version is OUTDATED. Siblings are at v1.5.24.

## Sibling Projects (same product line)

| Plugin | Path | Type |
|---|---|---|
| enroll_flutter_plugin | `/Users/luminsoft/StudioProjects/enroll_flutter_plugin` | Flutter |
| enroll-react-native | `/Users/luminsoft/StudioProjects/enroll-react-native` | React Native |

## What This Plugin Exposes

- `startEnroll(options)` — launches the enrollment flow
- `addListener('onRequestId', callback)` — mid-flow event
- `removeAllListeners()` — cleanup
- Modes: onboarding, auth, update, signContract
- Theming: `EnrollTheme` (colors + icons)
- Localization: en, ar
- Options: forcedDocumentType, exitStep, skipTutorial, correlationId, googleApiKey, requestId, contractSigning

## How to Update When Native SDK Changes

1. Update `android/build.gradle` → change `eNROLL-Android:vX.Y.Z`
2. Update `package.json` → bump plugin version
3. Mirror new parameters/types to TypeScript API (`src/definitions.ts`)
4. Update `.enroll-linkage.json` with new version
5. Run sync check: `bash /Users/luminsoft/StudioProjects/ekyc-android/scripts/check-enroll-sync.sh`

## Where to Update Docs

- `README.md` — installation and usage
- `CHANGELOG.md` — version history
- `docs/api.md` — API reference
- `docs/integration-android.md` — Android setup
- `docs/integration-ios.md` — iOS setup
- `docs/integration-ionic-angular.md` — Ionic/Angular setup
- `.enroll-linkage.json` — machine-readable metadata

## TODO — Pending Issues

- [ ] **Android SDK version outdated** — Currently v1.5.22, should be v1.5.24
  - Update: `android/build.gradle` → `eNROLL-Android:v1.5.24`
- [ ] **forgetProfileData mode** — Native SDK supports it but not exposed (also missing from Flutter)
  - Implementation: `src/definitions.ts` (add to `EnrollMode` union)
  - **Wait for Flutter implementation first**
