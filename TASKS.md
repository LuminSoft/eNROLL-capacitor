# Tasks

Living task tracker for the eNROLL Capacitor Plugin project.

## Epic 1: Project Scaffolding
- [x] Initialize Capacitor plugin project
- [x] Configure package.json (name, version, keywords, homepage)
- [x] Configure TypeScript and Rollup build
- [x] Set up ESLint + Prettier (via scaffolding generator)
- [x] Create TypeScript definitions (`src/definitions.ts`)
- [x] Create plugin registration (`src/index.ts`) and web stub (`src/web.ts`)
- [x] Create documentation skeleton files

## Epic 2: Android Bridge
- [x] Configure `android/build.gradle` with Kotlin + JitPack + eNROLL-Android
- [x] Implement `EnrollPlugin.kt` with `@PluginMethod startEnroll`
- [x] Options parsing (all params from PluginCall)
- [x] Color mapping (JSON → AppColors)
- [x] Enum mapping (mode, environment, localization, forcedDoc, exitStep)
- [x] Callback handling (success → resolve, error → reject, requestId → listener)
- [x] Input validation with clear error codes
- [x] Double-launch prevention guard
- [ ] Manual smoke test on Android device/emulator

## Epic 3: iOS Bridge
- [x] Configure podspec with EnrollFramework ~> 3.0.7
- [x] Implement `EnrollPlugin.swift` with CAPPlugin + EnrollCallBack
- [x] Options parsing, color mapping, enum mapping
- [x] RTL layout configuration for Arabic
- [x] Correct `amlCheck` step-type mapping
- [ ] Manual smoke test on physical iOS device

## Epic 4: Documentation
- [x] README.md (installation, usage, API summary)
- [x] ARCHITECTURE.md (system diagram, data flow, decisions)
- [x] PROJECT_RULES.md (mandatory rules, security, quality)
- [x] CHANGELOG.md (initial entry)
- [x] TASKS.md (this file)
- [x] CONTRIBUTING.md
- [x] docs/api.md
- [x] docs/integration-android.md
- [x] docs/integration-ios.md
- [x] docs/integration-ionic-angular.md
- [x] docs/testing.md
- [x] docs/release.md

## Epic 5: Testing & QA
- [ ] Create minimal Ionic/Angular test project
- [ ] Test all 4 modes on Android
- [ ] Test all 4 modes on iOS (physical device)
- [ ] Test error scenarios (invalid tenant, missing fields)
- [ ] Test color customization on both platforms
- [ ] Test localization (en/ar) on both platforms

## Epic 6: Release Preparation
- [x] Configure npm publishing (.npmignore, package.json files field)
- [ ] Set up GitHub Actions CI (lint, build, type-check)
- [ ] Create release workflow documentation
- [ ] Publish v0.1.0 to npm
