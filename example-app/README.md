## eNROLL Capacitor Example App

Demonstrates all `enroll-capacitor` plugin features including sign contract (template + PDF), typography customization, and localization overrides.

### Running this example

```bash
# Quick start with script (builds plugin + example + runs on device):
bash ../scripts/run-example-android.sh

# Or manually:
npm start
npx cap sync
npx cap run android   # or: npx cap run ios
```

---

### Sign Contract

The example demonstrates both sign contract sub-modes (matching the native SDK demo):

| Mode | What it does | Fields shown |
|------|--------------|--------------|
| **Contract Template** | SDK generates contract from server-side template | Template ID, Contract Parameters |
| **PDF File** | Upload a PDF directly (converted to Base64) | File picker, auto-filled filename |

When you select `signContract` as the Enroll Mode, the "Sign Contract Options" panel appears. Switch between modes using the dropdown.

---

### Questionnaire Mode

Select `questionnaire` as the Enroll Mode to start a standalone questionnaire configured in the Dashboard.

Required fields:
- **Application ID**
- **Questionnaire ID**

The plugin rejects the launch if either value is missing.

---

### Font Type & Font Size

The example includes 4 bundled fonts (same as the native Android demo app):

| Dropdown label | Resource name | Style |
|----------------|---------------|-------|
| Itim - Handwritten (English) | `itim_regular` | Handwriting |
| Merriweather - Serif (English) | `merriweather_variable` | Serif |
| Amiri - Naskh (Arabic) | `amiri_regular` | Arabic Naskh |
| Reem Kufi - Kufi (Arabic) | `reem_kufi_variable` | Arabic Kufi |

Font files are at `android/app/src/main/res/font/`.

Font size presets:

| Dropdown label | Value passed to SDK |
|----------------|---------------------|
| Small (default) | `default` |
| Medium | `medium` |
| Large | `large` |

---

### Localization Overrides

The example includes pre-bundled localization override JSON files that demonstrate how to customize SDK strings for English and Arabic.

#### Android

```
android/app/src/main/assets/enroll_localizations_en.json
android/app/src/main/assets/enroll_localizations_ar.json
```

Android loads these files from the app's `assets/` directory by file name (without `.json` extension).

#### iOS

```
ios/App/App/enroll_localizations_en.json
ios/App/App/enroll_localizations_ar.json
```

**Important:** Open the Xcode project and ensure these files are included in the **App** target's "Copy Bundle Resources" build phase.

#### Adding Custom Fonts

- **Android:** Place `.ttf`/`.otf` in `android/app/src/main/res/font/`. Reference the filename (without extension) as `fontFamily`.
- **iOS:** Add `.ttf`/`.otf` to Xcode project, register under `UIAppFonts` in `Info.plist`, use PostScript/family name as `fontFamily`.

#### JSON File Format

Each localization file uses this structure:

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

Edit the **values** to override default SDK text. Do not change the keys — the SDK uses them internally. See the bundled JSON files for the complete list of customizable keys.
