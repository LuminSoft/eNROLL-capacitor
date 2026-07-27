# Changelog — eNROLL Capacitor Plugin

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2026-07-27

### Added

- **Multi-signing support** in `signContract` mode (Android + iOS):
  - Pass comma-separated template IDs via `templateId` (e.g. `"56,63,71"`) to sign multiple contracts in a single session
  - The SDK displays each contract PDF for review and approval in sequence, ordered by `displayOrder`
  - All contracts are signed with a **single OTP** at the end — no API change required from the plugin side
  - Single-ID behavior is fully preserved (backward compatible)

### Changed

- Updated Android SDK from v1.5.28 to v1.5.29 (adds multi-signing flow, `GetSignContractFiles` API, `GetSignContractFileByRequestId` API)
- Updated iOS EnrollFramework pod from ~> 3.0.13 to ~> 3.0.16 (adds `contractTemplateId: String` support for multi-signing)
- Fixed iOS bridge: `contractTemplateId` was incorrectly converted to `Int`; now passed as `String?` to support comma-separated IDs
- Fixed iOS bridge: `signContract` mode now accepts either `templateId` OR `signContractFile` (matching Android validation)
- Updated `templateId` documentation to document comma-separated multi-signing usage

## [1.2.0] - 2026-07-14

### Added

- **Sign Contract dual-mode support** (Android + iOS):
  - **Contract Template mode** — use `templateId` + `contractParameters` for server-side template generation
  - **PDF File mode** — use `signContractFile` (Base64-encoded PDF) + optional `contractFileName`
  - `templateId` is now only required when `signContractFile` is not provided
- **Typography support** via `enrollTheme.typography` (Android + iOS):
  - `fontFamily` — custom font identifier (`res/font` name on Android, PostScript name on iOS)
  - `dynamicTypeEnabled` — platform font scaling toggle
  - `sizes` — preset font size (`'default'` | `'medium'` | `'large'`)
  - `localizationOverrides` — JSON-file based localization overrides per language
- New TypeScript types: `EnrollTypography`, `EnrollFontSizes`, `EnrollLocalizationOverrides`
- Example app: font type dropdown (4 bundled fonts), font size dropdown, localization override toggle
- Example app: conditional sign contract UI matching native demo (template vs PDF picker)
- Example app: bundled `enroll_localizations_en.json` and `enroll_localizations_ar.json` for Android and iOS

### Changed

- Updated Android SDK from v1.5.24 to v1.5.28 (adds `EnrollTypography`, `EnrollFontSize`, `EnrollLocalizationOverrides`, `signContractFile`, `contractFileName`)
- Updated iOS EnrollFramework pod from ~> 3.0.9 to ~> 3.0.13 (adds typography support)
- Sign contract validation is now conditional: requires `templateId` OR `signContractFile` (not both)

## [1.1.2] - 2026-05-21

### Changed

- Expanded README documentation for `enrollExitStep`, partial-flow behavior, resume handling, and native Android step mapping.

## [1.1.1] - 2026-05-21

### Changed

- Updated README integration requirements and client-facing setup guidance.
- Improved publish review scan exclusions for internal linkage documentation.

## [1.1.0] - 2026-05-19

### Added

- Full `enrollTheme` support on iOS — colors and icons now work on both platforms
- Logo customization with `LogoConfig` (mode, assetName, renderingMode, showSponsoredBy)
- iOS simulator support in run-example-ios script

### Changed

- Updated Android SDK from v1.5.22 to v1.5.24
- Updated iOS EnrollFramework pod dependency from ~> 3.0.7 to ~> 3.0.9
- Removed stale "Android only" documentation for theme features
- Simplified CI workflow to TypeScript build only

## [1.0.0] - 2026-04-22

### Added
- Initial public release of `enroll-capacitor` (standard eNROLL SDK variant)
- TypeScript type definitions for the full eNROLL API surface including `EnrollTheme`, `EnrollIcons`, and all 13 icon groups
- Android native bridge (Kotlin) using eNROLL-Android v1.5.22 via JitPack + Innovatrics biometrics
- iOS native bridge (Swift) using EnrollFramework ~> 3.0.7 via CocoaPods
- Full theme customization: colors (Android + iOS) and icons (Android only)
- Support for 4 enrollment modes: onboarding, auth, update, signContract
- Theme precedence: `enrollTheme.colors` > `appColors` > SDK defaults
- Full success model exposure (applicantId, enrollMessage, documentId, requestId, exitStepCompleted, completedStepName)
- Forced document type support
- Exit step support
- Localization support (English and Arabic with RTL)
- Double-launch prevention guard
- Input validation with clear error codes
- Web stub that throws clear "not supported" error
- Comprehensive documentation with theme and icon guides

### Changed (vs enroll-capacitor-neo)
- Renamed `applicantId` parameter to `applicationId`
- Removed `forgetProfileData` mode
- Replaced `enrollColors` option with `enrollTheme` (unified colors + icons)
- Android SDK: eNROLL-Lite-Android → eNROLL-Android v1.5.22 with full AppTheme/AppIcons support
- iOS SDK: EnrollNeoCore → EnrollFramework ~> 3.0.7
- iOS deployment target: 15.5 → 13.0
