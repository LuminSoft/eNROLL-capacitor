# Published Package Test

Simple way to test the published npm package using the existing Capacitor example app.

## Why this exists

The main `example-app` normally uses the local workspace package:

```json
"enroll-capacitor": "file:.."
```

That is good for development, but it does **not** prove that the published npm package works.

These helper scripts let you switch the example app between:
- the published npm package
- the local workspace package

## Use the published package

From the repo root:

```bash
cd /Users/luminsoft/StudioProjects/enroll-capacitor
bash ./scripts/use-published-example.sh 1.0.0
```

If you want the latest published version instead:

```bash
bash ./scripts/use-published-example.sh
```

Then run the example:

```bash
cd /Users/luminsoft/StudioProjects/enroll-capacitor/example-app
npm run build
npx cap sync
```

Android:

```bash
/usr/bin/env bash /Users/luminsoft/StudioProjects/enroll-capacitor/scripts/run-example-android.sh
```

iOS:

```bash
/usr/bin/env bash /Users/luminsoft/StudioProjects/enroll-capacitor/scripts/run-example-ios.sh
```

## Switch back to local development mode

```bash
cd /Users/luminsoft/StudioProjects/enroll-capacitor
bash ./scripts/use-local-example.sh
```

This restores:

```json
"enroll-capacitor": "file:.."
```

## Recommended smoke test checklist

- Install the published package in the example app
- Run Android build and launch
- Run iOS build and launch on a physical device
- Start `onboarding`
- Verify `onRequestId` event appears
- Verify success/error handling works
- Test one additional mode such as `auth` or `signContract`

## Notes

- iOS requires a physical device
- Android can run on emulator or device
- If npm install fails right after a publish, wait a minute and retry because npm propagation can take a little time
