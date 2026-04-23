# Changelog — eNROLL Capacitor Plugin

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
