import type { PluginListenerHandle } from '@capacitor/core';

// ---------------------------------------------------------------------------
// Enums (string literal unions — idiomatic TypeScript, no runtime overhead)
// ---------------------------------------------------------------------------

/**
 * The environment in which the eNROLL SDK operates.
 * - `'staging'`    — test / QA environment
 * - `'production'` — live environment
 */
export type EnrollEnvironment = 'staging' | 'production';

/**
 * The mode of the enrollment flow.
 * - `'onboarding'`   — register a new user
 * - `'auth'`         — authenticate an existing user (requires `applicationId` + `levelOfTrust`)
 * - `'update'`       — re-verify / update an existing user
 * - `'signContract'` — sign a contract template (requires `templateId`)
 */
export type EnrollMode =
  | 'onboarding'
  | 'auth'
  | 'update'
  | 'signContract';

/**
 * UI language for the enrollment flow.
 * - `'en'` — English (default)
 * - `'ar'` — Arabic (enables RTL layout)
 */
export type EnrollLocalization = 'en' | 'ar';

/**
 * Forces the document scanning step to accept only a specific document type.
 * - `'nationalIdOnly'`        — only national ID
 * - `'passportOnly'`          — only passport
 * - `'nationalIdOrPassport'`  — user chooses (default)
 */
export type EnrollForcedDocumentType =
  | 'nationalIdOnly'
  | 'passportOnly'
  | 'nationalIdOrPassport';

/**
 * Individual enrollment step identifiers.
 * Used with `enrollExitStep` to terminate the flow after a specific step.
 */
export type EnrollStepType =
  | 'phoneOtp'
  | 'personalConfirmation'
  | 'smileLiveness'
  | 'emailOtp'
  | 'saveMobileDevice'
  | 'deviceLocation'
  | 'password'
  | 'securityQuestions'
  | 'amlCheck'
  | 'termsAndConditions'
  | 'electronicSignature'
  | 'ntraCheck'
  | 'csoCheck';

// ---------------------------------------------------------------------------
// Color types
// ---------------------------------------------------------------------------

/**
 * An RGBA color value.
 * `r`, `g`, `b` are integers 0–255. `opacity` is a float 0.0–1.0 (defaults to 1.0).
 */
export interface EnrollColor {
  r: number;
  g: number;
  b: number;
  opacity?: number;
}

/**
 * Custom color overrides for the enrollment UI.
 * Every property is optional — omitted colors fall back to the SDK defaults.
 */
export interface EnrollColors {
  primary?: EnrollColor;
  secondary?: EnrollColor;
  appBackgroundColor?: EnrollColor;
  textColor?: EnrollColor;
  errorColor?: EnrollColor;
  successColor?: EnrollColor;
  warningColor?: EnrollColor;
  appWhite?: EnrollColor;
  appBlack?: EnrollColor;
}

// ---------------------------------------------------------------------------
// Icon types (Android only — icons are not yet supported on iOS)
// ---------------------------------------------------------------------------

/**
 * Controls how a custom icon asset is colorized when displayed.
 * - `'original'` — renders the asset exactly as designed (default)
 * - `'template'` — replaces all colors with the SDK theme color
 */
export type EnrollIconRenderingMode = 'original' | 'template';

/**
 * Configuration for a single custom icon.
 * `assetName` is the Android drawable resource name (without `R.drawable.` prefix).
 */
export interface EnrollStepIcon {
  /** Android drawable resource name, e.g. `'my_location_icon'`. */
  assetName: string;
  /** How the icon should be rendered. Defaults to `'original'`. */
  renderingMode?: EnrollIconRenderingMode;
}

/**
 * Controls how the SDK logo is displayed.
 * - `'defaultLogo'` — show the built-in eNROLL logo
 * - `'hidden'`      — hide the logo entirely
 * - `'custom'`      — show a custom logo asset
 */
export type EnrollLogoMode = 'defaultLogo' | 'hidden' | 'custom';

/**
 * Configuration for the SDK logo on splash screens and the app bar.
 */
export interface EnrollLogoConfig {
  /** How the logo should be displayed. Defaults to `'defaultLogo'`. */
  mode?: EnrollLogoMode;
  /** Android drawable resource name for the custom logo. Required when `mode` is `'custom'`. */
  assetName?: string;
  /** How the logo should be rendered. Defaults to `'original'`. */
  renderingMode?: EnrollIconRenderingMode;
}

// -- Business-flow icon groups --

/** Icons for the Location step. */
export interface EnrollLocationIcons {
  tutorial?: EnrollStepIcon;
  requestAccess?: EnrollStepIcon;
  accessError?: EnrollStepIcon;
  grab?: EnrollStepIcon;
}

/** Icons for the National ID step. */
export interface EnrollNationalIdIcons {
  tutorial?: EnrollStepIcon;
  tutorialIdOrPassport?: EnrollStepIcon;
  preScan?: EnrollStepIcon;
  scanError?: EnrollStepIcon;
  choose?: EnrollStepIcon;
}

/** Icons for the Passport step. */
export interface EnrollPassportIcons {
  tutorial?: EnrollStepIcon;
  preScan?: EnrollStepIcon;
  ePassportPreScan?: EnrollStepIcon;
  choose?: EnrollStepIcon;
}

/** Icons for the Phone OTP step. */
export interface EnrollPhoneIcons {
  tutorial?: EnrollStepIcon;
  select?: EnrollStepIcon;
  validateOtp?: EnrollStepIcon;
}

/** Icons for the Email OTP step. */
export interface EnrollEmailIcons {
  tutorial?: EnrollStepIcon;
  select?: EnrollStepIcon;
  validateOtp?: EnrollStepIcon;
}

/** Icons for the Face Matching / Smile Liveness step. */
export interface EnrollFaceMatchingIcons {
  tutorial?: EnrollStepIcon;
  preScan?: EnrollStepIcon;
  error?: EnrollStepIcon;
}

/** Icons for the Security Questions step. */
export interface EnrollSecurityQuestionsIcons {
  tutorial?: EnrollStepIcon;
  authScreen?: EnrollStepIcon;
}

/** Icons for the Password step. */
export interface EnrollPasswordIcons {
  tutorial?: EnrollStepIcon;
  authScreen?: EnrollStepIcon;
}

/** Icons for the Electronic Signature step. */
export interface EnrollSignatureIcons {
  tutorial?: EnrollStepIcon;
}

// -- Shared / cross-cutting icon groups --

/** Background images used across screens. */
export interface EnrollBackgroundIcons {
  main?: EnrollStepIcon;
  layer1?: EnrollStepIcon;
  layer2?: EnrollStepIcon;
  layer3?: EnrollStepIcon;
  blur?: EnrollStepIcon;
  header?: EnrollStepIcon;
  footer?: EnrollStepIcon;
}

/** Popup and dialog icons. */
export interface EnrollPopupIcons {
  background?: EnrollStepIcon;
  warningIcon?: EnrollStepIcon;
  errorIcon?: EnrollStepIcon;
  successIcon?: EnrollStepIcon;
}

/** Profile / data display field icons. */
export interface EnrollFieldIcons {
  user?: EnrollStepIcon;
  calendar?: EnrollStepIcon;
  gender?: EnrollStepIcon;
  issuingAuthority?: EnrollStepIcon;
  nationality?: EnrollStepIcon;
  num?: EnrollStepIcon;
  passport?: EnrollStepIcon;
  address?: EnrollStepIcon;
  idCard?: EnrollStepIcon;
  profession?: EnrollStepIcon;
  religion?: EnrollStepIcon;
  maritalStatus?: EnrollStepIcon;
}

/** General UI icons used across screens. */
export interface EnrollUiIcons {
  visibility?: EnrollStepIcon;
  visibilityOff?: EnrollStepIcon;
  mobile?: EnrollStepIcon;
  mail?: EnrollStepIcon;
  answer?: EnrollStepIcon;
  error?: EnrollStepIcon;
  info?: EnrollStepIcon;
  edit?: EnrollStepIcon;
  activePhone?: EnrollStepIcon;
}

/** Common icons shared across all flows. */
export interface EnrollCommonIcons {
  backgrounds?: EnrollBackgroundIcons;
  popups?: EnrollPopupIcons;
  fieldIcons?: EnrollFieldIcons;
  ui?: EnrollUiIcons;
  termsAndConditions?: EnrollStepIcon;
}

/** Icons shown in the Update step-list screen. */
export interface EnrollUpdateIcons {
  modeIcon?: EnrollStepIcon;
  idCard?: EnrollStepIcon;
  passport?: EnrollStepIcon;
  mobile?: EnrollStepIcon;
  email?: EnrollStepIcon;
  device?: EnrollStepIcon;
  address?: EnrollStepIcon;
  securityQuestions?: EnrollStepIcon;
  password?: EnrollStepIcon;
}

/** Icons shown in the Forget Profile Data step-list screen. */
export interface EnrollForgetIcons {
  modeIcon?: EnrollStepIcon;
  nationalId?: EnrollStepIcon;
  passport?: EnrollStepIcon;
  phone?: EnrollStepIcon;
  email?: EnrollStepIcon;
  device?: EnrollStepIcon;
  location?: EnrollStepIcon;
  securityQuestions?: EnrollStepIcon;
  password?: EnrollStepIcon;
}

/**
 * Top-level icon configuration for the eNROLL SDK.
 * All fields are optional — when omitted, the SDK uses its built-in assets.
 *
 * **Android only.** Icons are not yet supported on iOS.
 */
export interface EnrollIcons {
  logo?: EnrollLogoConfig;
  location?: EnrollLocationIcons;
  nationalId?: EnrollNationalIdIcons;
  passport?: EnrollPassportIcons;
  phone?: EnrollPhoneIcons;
  email?: EnrollEmailIcons;
  faceMatching?: EnrollFaceMatchingIcons;
  securityQuestions?: EnrollSecurityQuestionsIcons;
  password?: EnrollPasswordIcons;
  signature?: EnrollSignatureIcons;
  common?: EnrollCommonIcons;
  update?: EnrollUpdateIcons;
  forget?: EnrollForgetIcons;
}

// ---------------------------------------------------------------------------
// Theme
// ---------------------------------------------------------------------------

/**
 * Unified theme configuration for the eNROLL SDK.
 *
 * Groups color and icon customization under a single concept,
 * aligned with the Android SDK's `AppTheme` structure.
 *
 * If both `enrollTheme` and `appColors` are provided on {@link StartEnrollOptions},
 * `enrollTheme` takes priority and `appColors` is ignored.
 *
 * > **Icons are Android only.** iOS support is planned for a future release.
 * > Colors work on both platforms.
 */
export interface EnrollTheme {
  /** Color customization for the SDK UI. Works on Android and iOS. */
  colors?: EnrollColors;
  /** Icon customization for logo and step illustrations. **Android only.** */
  icons?: EnrollIcons;
}

// ---------------------------------------------------------------------------
// Options
// ---------------------------------------------------------------------------

/**
 * Configuration object passed to {@link EnrollPlugin.startEnroll}.
 */
export interface StartEnrollOptions {
  // ---- Required ----

  /** Organization tenant ID. */
  tenantId: string;

  /** Organization tenant secret. */
  tenantSecret: string;

  /** SDK flow mode. */
  enrollMode: EnrollMode;

  // ---- Conditionally required ----

  /** Application / applicant ID. Required for `auth` and `update` modes. */
  applicationId?: string;

  /** Level-of-trust token. Required for `auth` mode. */
  levelOfTrust?: string;

  /** Contract template ID. Required for `signContract` mode. */
  templateId?: string;

  // ---- Optional ----

  /** Target environment. Defaults to `'staging'`. */
  enrollEnvironment?: EnrollEnvironment;

  /** UI language. Defaults to `'en'`. */
  localizationCode?: EnrollLocalization;

  /** Google Maps API key (used for location step). */
  googleApiKey?: string;

  /** Skip the tutorial screen. Defaults to `false`. */
  skipTutorial?: boolean;

  /** Correlation ID to link your user ID with the eNROLL request ID. */
  correlationId?: string;

  /** Resume a previous enrollment request by its ID. */
  requestId?: string;

  /** Extra contract parameters (JSON string) for `signContract` mode. */
  contractParameters?: string;

  /**
   * Unified theme configuration (colors + icons).
   * Icons are **Android only**; colors work on both platforms.
   * Takes priority over `appColors` when both are provided.
   */
  enrollTheme?: EnrollTheme;

  /**
   * Custom color overrides (cross-platform).
   * @deprecated Use `enrollTheme.colors` instead. Ignored when `enrollTheme` is provided.
   */
  appColors?: EnrollColors;

  /** Force a specific document type for scanning. */
  enrollForcedDocumentType?: EnrollForcedDocumentType;

  /** Auto-close the SDK after this step completes successfully. */
  enrollExitStep?: EnrollStepType;
}

// ---------------------------------------------------------------------------
// Result types
// ---------------------------------------------------------------------------

/**
 * Returned when the enrollment flow completes successfully.
 */
export interface EnrollSuccessResult {
  /** The applicant ID assigned by the eNROLL backend. */
  applicantId: string;

  /** Human-readable success message from the SDK. */
  enrollMessage?: string;

  /** Document ID (if applicable). */
  documentId?: string;

  /** Request ID that can be used to resume the flow later. */
  requestId?: string;

  /** `true` if the flow ended early because `enrollExitStep` was reached. */
  exitStepCompleted: boolean;

  /** Name of the step that was completed when the flow exited early. */
  completedStepName?: string;
}

/**
 * Shape of the error returned when the enrollment flow fails.
 * Accessible via the rejected promise's `data` property.
 */
export interface EnrollErrorResult {
  /** Human-readable error message. */
  message: string;

  /** Machine-readable error code (if available). */
  code?: string;

  /** Applicant ID (if one was assigned before the error occurred). */
  applicantId?: string;
}

/**
 * Payload delivered by the `'onRequestId'` event listener.
 */
export interface EnrollRequestIdResult {
  /** The request ID generated by the SDK during the flow. */
  requestId: string;
}

// ---------------------------------------------------------------------------
// Plugin interface
// ---------------------------------------------------------------------------

/**
 * Capacitor plugin for the eNROLL SDK.
 *
 * Provides eKYC identity verification for Ionic and Capacitor mobile apps on Android and iOS.
 * **Web / browser usage is not supported** — this plugin is for native mobile only.
 */
export interface EnrollPlugin {
  /**
   * Launch the eNROLL enrollment flow.
   *
   * Resolves with {@link EnrollSuccessResult} on success.
   * Rejects with an error whose `data` matches {@link EnrollErrorResult} on failure.
   *
   * @param options — configuration for the enrollment session
   */
  startEnroll(options: StartEnrollOptions): Promise<EnrollSuccessResult>;

  /**
   * Listen for the `'onRequestId'` event, which fires when the SDK
   * generates a request ID *during* the enrollment flow (before it completes).
   */
  addListener(
    eventName: 'onRequestId',
    listenerFunc: (result: EnrollRequestIdResult) => void,
  ): Promise<PluginListenerHandle>;

  /**
   * Remove all listeners registered by this plugin.
   */
  removeAllListeners(): Promise<void>;
}
