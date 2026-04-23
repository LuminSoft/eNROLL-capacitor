# Contributing

This guide provides instructions for contributing to the eNROLL Capacitor plugin.

## Developing

### Local Setup

1. Fork and clone the repo.

```bash
# Clone the repo
git clone https://github.com/LuminSoft/enroll-capacitor.git
cd enroll-capacitor

# Install dependencies
npm install
```

## Scripts

| Command | Description |
|---------|-------------|
| `npm run build` | Clean, generate docs, compile TypeScript, bundle with Rollup |
| `npm run watch` | Watch TypeScript files for changes |
| `npm run lint` | Run ESLint, Prettier check, and SwiftLint |
| `npm run fmt` | Auto-fix ESLint, Prettier, and SwiftLint issues |
| `npm run verify` | Full build verification (iOS + Android + Web) |
| `npm run verify:web` | TypeScript build only |
| `npm run verify:android` | Gradle clean build + test |
| `npm run verify:ios` | Xcode build for iOS |

## Development Workflow

1. **Create a branch** from `main` with a descriptive name
2. **Make changes** to the relevant layer(s):
   - TypeScript API: `src/definitions.ts`, `src/index.ts`, `src/web.ts`
   - Android bridge: `android/src/main/kotlin/.../EnrollPlugin.kt`
   - iOS bridge: `ios/Sources/EnrollPlugin/EnrollPlugin.swift`
3. **Run `npm run build`** to verify TypeScript compiles
4. **Test on device** — both Android and iOS if your change touches native code
5. **Update documentation** — README, CHANGELOG, docs/ as needed
6. **Submit PR** with the review checklist from PROJECT_RULES.md

## Code Style

- **TypeScript:** Strict mode, no `any` in public API, JSDoc on all exports
- **Kotlin:** Follow Kotlin conventions, no `!!` force-unwrap
- **Swift:** Follow Swift conventions, use `guard` for optionals, no force-unwraps

## PR Requirements

Every PR must include:
- Description of what changed and why
- CHANGELOG.md entry
- Risk assessment (Low/Medium/High)
- Backward compatibility statement
- Test results on both platforms (if native code changed)

## Project Structure

```
src/                  → TypeScript definitions and plugin registration
android/              → Kotlin native bridge
ios/                  → Swift native bridge
docs/                 → Detailed documentation
example-app/          → Example Ionic app for testing
```

## Questions?

Open a GitHub issue or reach out to the LuminSoft team.

## Publishing

There is a `prepublishOnly` hook in `package.json` which prepares the plugin before publishing, so all you need to do is run:

```shell
npm publish
```

> **Note**: The [`files`](https://docs.npmjs.com/cli/v7/configuring-npm/package-json#files) array in `package.json` specifies which files get published. If you rename files/directories or add files elsewhere, you may need to update it.
