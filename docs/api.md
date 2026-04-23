# API Reference

Full TypeScript API reference for the eNROLL Capacitor Plugin.

## Plugin Import

```typescript
import { Enroll } from 'enroll-capacitor';
import type {
  StartEnrollOptions,
  EnrollSuccessResult,
  EnrollErrorResult,
  EnrollRequestIdResult,
  EnrollMode,
  EnrollEnvironment,
  EnrollLocalization,
  EnrollForcedDocumentType,
  EnrollStepType,
  EnrollColors,
  EnrollColor,
  EnrollTheme,
  EnrollIcons,
} from 'enroll-capacitor';
```

## Methods

### `startEnroll(options)`

Launch the eNROLL enrollment flow.

```typescript
startEnroll(options: StartEnrollOptions): Promise<EnrollSuccessResult>
```

- **Resolves** with `EnrollSuccessResult` when the flow completes successfully.
- **Rejects** with an error when the flow fails. The error's `data` property contains `EnrollErrorResult`.

### `addListener('onRequestId', listener)`

Listen for request ID events that fire *during* the enrollment flow (before it completes).

```typescript
addListener(
  eventName: 'onRequestId',
  listenerFunc: (result: EnrollRequestIdResult) => void
): Promise<PluginListenerHandle>
```

Returns a `PluginListenerHandle` — call `handle.remove()` to unsubscribe.

### `removeAllListeners()`

Remove all event listeners registered by this plugin.

```typescript
removeAllListeners(): Promise<void>
```

---

## Types

### `StartEnrollOptions`

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `tenantId` | `string` | ✅ | — | Organization tenant ID |
| `tenantSecret` | `string` | ✅ | — | Organization tenant secret |
| `enrollMode` | `EnrollMode` | ✅ | — | SDK flow mode |
| `applicationId` | `string` | mode | — | Required for `auth`, `update` |
| `levelOfTrust` | `string` | mode | — | Required for `auth` |
| `templateId` | `string` | mode | — | Required for `signContract` |
| `enrollEnvironment` | `EnrollEnvironment` | | `'staging'` | Target environment |
| `localizationCode` | `EnrollLocalization` | | `'en'` | UI language |
| `googleApiKey` | `string` | | — | Google Maps API key |
| `skipTutorial` | `boolean` | | `false` | Skip tutorial screen |
| `correlationId` | `string` | | — | Link your user ID with request ID |
| `requestId` | `string` | | — | Resume previous request |
| `contractParameters` | `string` | | — | JSON contract params |
| `enrollTheme` | `EnrollTheme` | | — | Unified theme (colors + icons) |
| `appColors` | `EnrollColors` | | — | Color overrides (deprecated) |
| `enrollForcedDocumentType` | `EnrollForcedDocumentType` | | — | Force document type |
| `enrollExitStep` | `EnrollStepType` | | — | Exit after step |

### `EnrollSuccessResult`

| Property | Type | Description |
|----------|------|-------------|
| `applicantId` | `string` | Assigned applicant ID |
| `enrollMessage` | `string \| undefined` | Success message |
| `documentId` | `string \| undefined` | Document ID |
| `requestId` | `string \| undefined` | Request ID for resuming |
| `exitStepCompleted` | `boolean` | `true` if exited early |
| `completedStepName` | `string \| undefined` | Completed exit step name |

### `EnrollErrorResult`

| Property | Type | Description |
|----------|------|-------------|
| `message` | `string` | Error message |
| `code` | `string \| undefined` | Error code |
| `applicantId` | `string \| undefined` | Applicant ID if assigned before error |

### `EnrollRequestIdResult`

| Property | Type | Description |
|----------|------|-------------|
| `requestId` | `string` | Generated request ID |

---

## Enums (String Literal Unions)

### `EnrollMode`

`'onboarding'` | `'auth'` | `'update'` | `'signContract'`

### `EnrollEnvironment`

`'staging'` | `'production'`

### `EnrollLocalization`

`'en'` | `'ar'`

### `EnrollForcedDocumentType`

`'nationalIdOnly'` | `'passportOnly'` | `'nationalIdOrPassport'`

### `EnrollStepType`

`'phoneOtp'` | `'personalConfirmation'` | `'smileLiveness'` | `'emailOtp'` | `'saveMobileDevice'` | `'deviceLocation'` | `'password'` | `'securityQuestions'` | `'amlCheck'` | `'termsAndConditions'` | `'electronicSignature'` | `'ntraCheck'` | `'csoCheck'`

### `EnrollColor`

| Property | Type | Description |
|----------|------|-------------|
| `r` | `number` | Red (0–255) |
| `g` | `number` | Green (0–255) |
| `b` | `number` | Blue (0–255) |
| `opacity` | `number \| undefined` | Alpha (0.0–1.0, defaults to 1.0) |

### `EnrollColors`

All properties are optional `EnrollColor`:

`primary` · `secondary` · `appBackgroundColor` · `textColor` · `errorColor` · `successColor` · `warningColor` · `appWhite` · `appBlack`

---

## Error Codes

| Code | Meaning |
|------|---------|
| `INVALID_ARGUMENT` | Missing or invalid required parameter |
| `FLOW_IN_PROGRESS` | Another enrollment flow is already running |
| `ACTIVITY_ERROR` | Android Activity not available |
| `VIEW_CONTROLLER_ERROR` | iOS ViewController not available |
| `ENROLL_ERROR` | Native SDK returned an error |
| `ENROLL_LAUNCH_ERROR` | Failed to initialize/launch the native SDK |
| `UNAVAILABLE` | Plugin called on web (not supported) |
