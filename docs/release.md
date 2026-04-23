# Release Process

How to publish a new version of the eNROLL Capacitor Plugin.

## Pre-Release Checklist

- [ ] All manual tests passing on both platforms
- [ ] No breaking changes (or migration plan documented)
- [ ] Version numbers updated (see below)
- [ ] CHANGELOG.md updated with new version entry
- [ ] TypeScript builds cleanly (`npm run build`)
- [ ] README.md up to date
- [ ] Security review completed (no hardcoded secrets, no PII logging)

## Preferred Release Script

Use the release script to handle version bump, review scan, changelog validation, build, package preview, and optional publish:

```bash
./scripts/publish-release.sh --patch
./scripts/publish-release.sh --minor
./scripts/publish-release.sh --version X.Y.Z
```

To actually publish after the dry run:

```bash
./scripts/publish-release.sh --patch --publish
```

What the script does:
- updates `package.json` using `npm version --no-git-tag-version`
- scans for risky text like TODOs, AI references, local paths, and placeholder secrets
- checks that `CHANGELOG.md` contains the new version with today's date
- runs `npm run build`
- runs `npm pack --dry-run`
- optionally runs `npm whoami` and `npm publish`

## Manual Version Bump

If you do not use the script, update the version in `package.json` manually or with `npm version`.

Follow semantic versioning:

| Change Type | Bump | Example |
|-------------|------|---------|
| Bug fix (no API change) | PATCH | 0.1.0 → 0.1.1 |
| New feature (backward compatible) | MINOR | 0.1.0 → 0.2.0 |
| Breaking change | MAJOR | 0.1.0 → 1.0.0 |

The podspec reads version from `package.json` automatically.

## Build

```bash
npm run build
```

This runs: clean → tsc → rollup

## Publish to npm

```bash
# Login to npm (first time only)
npm login

# Publish (prepublishOnly hook runs build automatically)
npm publish
```

The repo now includes a scripted flow here:

```bash
./scripts/publish-release.sh --patch --publish
```

## Post-Publish

1. **Git tag:** Create a version tag and push:
   ```bash
   git tag v0.1.0
   git push origin v0.1.0
   ```

2. **GitHub Release:** Create a release on GitHub with:
   - Tag: `vX.Y.Z`
   - Title: `vX.Y.Z`
   - Body: Copy from CHANGELOG.md

3. **Verify:** Install the published version in a test project:
   ```bash
   npm install enroll-capacitor@X.Y.Z
   npx cap sync
   ```

## Consumer Update Instructions

When clients need to update:

```bash
npm update enroll-capacitor
npx cap sync
# iOS only:
cd ios/App && pod install && cd ../..
```

## Rollback

If a bad version is published:

```bash
npm unpublish enroll-capacitor@X.Y.Z
```

> Note: npm unpublish only works within 72 hours of publishing. After that, publish a patch fix instead.
