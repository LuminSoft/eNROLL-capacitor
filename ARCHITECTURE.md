# Architecture

This document describes the internal architecture of the eNROLL Capacitor Plugin.

## System Overview

```
┌─────────────────────────────────────────────────────────┐
│                  Ionic / Angular App                     │
│                                                         │
│   import { Enroll } from 'enroll-capacitor';     │
│   Enroll.startEnroll({ ... })                           │
└──────────────────────┬──────────────────────────────────┘
                       │  TypeScript → Capacitor Bridge
                       ▼
┌─────────────────────────────────────────────────────────┐
│              Capacitor Plugin Layer                      │
│                                                         │
│  src/definitions.ts  — TypeScript types & interface      │
│  src/index.ts        — Plugin registration               │
│  src/web.ts          — Web stub (throws unsupported)     │
└──────────┬──────────────────────────────┬───────────────┘
           │                              │
     Android Native                 iOS Native
           │                              │
           ▼                              ▼
┌─────────────────────┐   ┌──────────────────────────────┐
│  EnrollPlugin.kt    │   │  EnrollPlugin.swift           │
│                     │   │                              │
│  @PluginMethod      │   │  @objc func startEnroll()    │
│  fun startEnroll()  │   │                              │
│                     │   │  Conforms to:                │
│  Implements:        │   │  - CAPPlugin                 │
│  - Plugin           │   │  - CAPBridgedPlugin          │
│  - EnrollCallback   │   │  - EnrollCallBack            │
└────────┬────────────┘   └──────────┬───────────────────┘
         │                           │
         ▼                           ▼
┌─────────────────────┐   ┌──────────────────────────────┐
│  eNROLL Android SDK │   │  EnrollFramework (iOS)       │
│  (AAR via JitPack)  │   │  (xcframework + CocoaPods)   │
│                     │   │                              │
│  eNROLL.init(...)   │   │  Enroll.initViewController() │
│  eNROLL.launch()    │   │  present(vc, animated:)      │
└─────────────────────┘   └──────────────────────────────┘
```

## Data Flow

### 1. Configuration (TypeScript → Native)

```
StartEnrollOptions (TS object)
  → Capacitor serializes to JSON automatically
  → Native plugin receives as PluginCall (Android) / CAPPluginCall (iOS)
  → Plugin parses individual fields
  → Maps string values to native SDK enums
  → Maps color objects to native UIColor/Color
  → Calls native SDK init + launch
```

### 2. Results (Native → TypeScript)

**Success path:**
```
Native SDK callback (success)
  → Plugin builds JSObject / Dictionary with all success fields
  → call.resolve(result)
  → TypeScript Promise resolves with EnrollSuccessResult
```

**Error path:**
```
Native SDK callback (error)
  → Plugin calls call.reject(message, code, data)
  → TypeScript Promise rejects
```

**Mid-flow events (requestId):**
```
Native SDK callback (getRequestId)
  → Plugin calls notifyListeners("onRequestId", data)
  → TypeScript event listener fires with EnrollRequestIdResult
```

## Layer Responsibilities

| Layer | Responsibility |
|-------|---------------|
| **TypeScript (src/)** | Type definitions, plugin registration, web stub |
| **Android (android/)** | Kotlin bridge: parse options → call eNROLL SDK → forward callbacks |
| **iOS (ios/)** | Swift bridge: parse options → call EnrollFramework → forward callbacks |

## Threading Model

- **Android:** `eNROLL.launch()` starts a new Activity on the main thread. Callbacks may arrive on background threads — the plugin uses Capacitor's built-in thread-safe `call.resolve()` and `notifyListeners()`.
- **iOS:** SDK ViewController is presented on the main thread via `DispatchQueue.main.async`. Callbacks are forwarded using the same mechanism.

## Guard Logic

Both platforms include:
- **Double-launch prevention:** An `isFlowInProgress` flag prevents calling `startEnroll` while a flow is active.
- **Input validation:** Required fields are validated before calling the native SDK, with clear error codes.

## Dependencies

### Android
- `com.github.LuminSoft:eNROLL-Android:v1.5.22` (JitPack)
- `com.google.code.gson:gson:2.8.8`
- `@capacitor/android` (peer)

### iOS
- `EnrollFramework` ~> 3.0.7 (CocoaPods)
- `Capacitor` (CocoaPods, peer)

## Decision Log

| Decision | Rationale |
|----------|-----------|
| Promise for success/error, listener for requestId | requestId fires mid-flow (not terminal); Promise is idiomatic for one-shot results |
| String literal unions instead of TS enums | No runtime overhead, better tree-shaking, idiomatic TypeScript |
| Full native success model exposed | Richer result type; enables exit-step workflows |
| 4 modes supported (no forgetProfileData) | Feature parity with the standard native SDK |
| Kotlin for Android | Matches the native SDK language; better null safety |
| `amlCheck` mapped correctly | Ensures correct step-type mapping for AML checks |
