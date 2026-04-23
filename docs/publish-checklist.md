# Publish Checklist — eNROLL Capacitor Plugin

Step-by-step guide for publishing a new version to npm.

## Before You Start

- You need an npm account with publish access
- Node.js 18+ installed
- Run `npm login` if not already authenticated
- Preferred flow: use `./scripts/publish-release.sh`

## Pre-Publish Checklist

- [ ] Code changes are committed to `main`
- [ ] All manual tests pass on both Android and iOS
- [ ] No breaking changes (or migration plan documented in CHANGELOG)
- [ ] TypeScript builds cleanly: `npm run build`
- [ ] No hardcoded secrets, PII logging, or debug output
- [ ] README.md is up to date with any new features
- [ ] CHANGELOG.md has a new version entry with today's date

## Version Bump

Recommended:

```bash
./scripts/publish-release.sh --patch
```

or:

```bash
./scripts/publish-release.sh --minor
./scripts/publish-release.sh --major
./scripts/publish-release.sh --version X.Y.Z
```

This script performs the version bump plus review/build/package preview checks.

Manual alternative:

Update the version in `package.json`:

```bash
# For a patch release (bug fix):
npm version patch

# For a minor release (new feature, backward compatible):
npm version minor

# For a major release (breaking change):
npm version major
```

The podspec reads the version from `package.json` automatically — no separate update needed.

## Build

```bash
npm run build
```

This runs: `clean` → `tsc` → `rollup`

## Publish

```bash
npm publish
```

Preferred scripted publish:

```bash
./scripts/publish-release.sh --patch --publish
```

The `prepublishOnly` hook in `package.json` runs `npm run build` automatically before publishing.

### What Gets Published

Only the files listed in the `files` array in `package.json`:

- `dist/` — compiled TypeScript + bundled JS
- `android/src/main/` — Kotlin native bridge
- `android/build.gradle` — Android build config
- `ios/Sources/` — Swift native bridge
- `ios/Frameworks/` — EnrollFramework.xcframework
- `ios/Tests/` — Swift test stubs
- `Package.swift` — Swift Package Manager manifest
- `EnrollCapacitor.podspec` — CocoaPods spec

**Not published:** example-app, docs, scripts, .github, TASKS.md, PROJECT_RULES.md, ARCHITECTURE.md

### Verify What Will Be Published

Before publishing, you can preview the package contents:

```bash
npm pack --dry-run
```

## Post-Publish

1. **Git tag:**
   ```bash
   git tag vX.Y.Z
   git push origin vX.Y.Z
   ```

2. **GitHub Release:** Create a release on GitHub with:
   - Tag: `vX.Y.Z`
   - Title: `vX.Y.Z`
   - Body: Copy from CHANGELOG.md

3. **Verify installation:**
   ```bash
   npm install enroll-capacitor@X.Y.Z
   ```

## Rollback

If a bad version is published:

```bash
npm unpublish enroll-capacitor@X.Y.Z
```

> npm unpublish only works within 72 hours. After that, publish a patch fix instead.

## Quick Reference

| Action | Command |
|--------|---------|
| Login to npm | `npm login` |
| Check logged-in user | `npm whoami` |
| Build | `npm run build` |
| Preview package | `npm pack --dry-run` |
| Publish | `npm publish` |
| Bump patch | `npm version patch` |
| Bump minor | `npm version minor` |
| Bump major | `npm version major` |
