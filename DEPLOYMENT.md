# Deployment Guide — enroll-capacitor

## npm Publishing

### Prerequisites
- Logged into npm as `luminsoftcorp`: `npm whoami`
- All changes committed and pushed

### Manual Publish
```bash
# 1. Bump version
npm version patch   # or minor / major

# 2. Build
npm run build

# 3. Verify contents
npm pack --dry-run

# 4. Publish
npm publish --access public

# 5. Push tag
git push origin main --tags
```

### Automated Publish (CI/CD)
Publishing is automated via GitHub Actions. When you create a **GitHub Release**:

1. Go to https://github.com/LuminSoft/eNROLL-capacitor/releases
2. Click **"Draft a new release"**
3. Create a tag matching your version (e.g. `v1.0.1`)
4. Add release notes from CHANGELOG.md
5. Click **"Publish release"**

The `.github/workflows/publish.yml` workflow will automatically:
- Checkout code
- Install dependencies
- Build the plugin
- Publish to npm

**Required secret:** Add `NPM_TOKEN` to your repo secrets:
1. Go to https://github.com/LuminSoft/eNROLL-capacitor/settings/secrets/actions
2. Click **"New repository secret"**
3. Name: `NPM_TOKEN`
4. Value: Generate at https://www.npmjs.com/settings/luminsoftcorp/tokens (Automation token)

### CI Pipeline
On every push/PR to `main`, GitHub Actions runs:
- **TypeScript Build** — `npm run build` + `npm run lint`
- **Android Build** — Gradle verification

## Version Locations
Update version in **all** of these:

| File | Field |
|------|-------|
| `package.json` | `"version"` |
| `EnrollCapacitor.podspec` | reads from package.json automatically |

## GitBook Documentation
The file `docs/gitbook-page-content.md` contains the ready-to-upload GitBook page content.
Copy its contents to your GitBook space when updating documentation.
