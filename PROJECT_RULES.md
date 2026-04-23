# Project Rules — eNROLL Capacitor Plugin

> **CRITICAL**: This plugin is used by government ministries and enterprise clients for user onboarding (eKYC).
> Every change must be treated as high-risk and reviewed thoroughly.

## Project Classification

| Attribute | Value |
|-----------|-------|
| **Project Type** | Capacitor Plugin (npm package) |
| **Sensitivity Level** | HIGH (Government + Enterprise) |
| **Consumers** | Ionic/Angular mobile apps |
| **Distribution** | Public npm registry |
| **Versioning** | Semantic Versioning (x.y.z) |

## Mandatory Rules

### 1. No Breaking Changes Without Migration Plan
- ❌ NEVER remove or rename public TypeScript types or methods
- ❌ NEVER change method signatures without deprecation cycle
- ❌ NEVER modify result interfaces that clients consume
- ✅ Add new methods / fields alongside old ones
- ✅ Use `@deprecated` JSDoc tag with migration instructions
- ✅ Maintain at least 2 versions of backward compatibility

### 2. Every PR/Change Must Include
- [ ] Description: What changed and why
- [ ] Changelog entry: User-facing description
- [ ] Risk assessment: Low/Medium/High with justification
- [ ] Backward compatibility check: Impact on existing clients
- [ ] Test verification: Manual test results on both platforms
- [ ] TypeScript build verification: `npm run build` passes

### 3. Version Bump Requirements

| Change Type | Version Bump | Example |
|-------------|--------------|---------|
| Bug fix (no API change) | PATCH | 0.1.0 → 0.1.1 |
| New feature (backward compatible) | MINOR | 0.1.0 → 0.2.0 |
| Breaking change | MAJOR | 0.1.0 → 1.0.0 |

### 4. Security Requirements
- [ ] No hardcoded credentials or API keys
- [ ] No logging of sensitive data (PII, tokens, biometrics)
- [ ] All network calls over HTTPS only
- [ ] Biometric data never leaves device
- [ ] No `tenantSecret` or `levelOfTrust` values in log output

### 5. Code Quality Standards

**TypeScript:**
- [ ] Strict mode enabled (`"strict": true` in tsconfig)
- [ ] No `any` types in public API surface
- [ ] All public exports have JSDoc documentation
- [ ] ESLint passes with zero warnings

**Kotlin (Android):**
- [ ] Follow Kotlin coding conventions
- [ ] No compiler warnings in production code
- [ ] Proper null safety (no `!!` in production code)
- [ ] All PluginMethod functions validate inputs before calling native SDK

**Swift (iOS):**
- [ ] Follow Swift coding conventions
- [ ] No force-unwraps (`!`) in production code
- [ ] Guard clauses for all optional parameters
- [ ] Main thread dispatch for UI operations

## Forbidden Actions

1. ❌ Removing public TypeScript types or methods
2. ❌ Changing `startEnroll` method signature
3. ❌ Modifying result interfaces
4. ❌ Exposing internal classes as public exports
5. ❌ Adding required parameters to `StartEnrollOptions`
6. ❌ Changing enum string values
7. ❌ Hardcoding credentials or secrets
8. ❌ Logging sensitive user data
9. ❌ Releasing without version bump
10. ❌ Publishing to npm without build verification

## Review Checklist Template

```markdown
## Change Summary
[Brief description]

## Files Changed
- [file1]: [what changed]
- [file2]: [what changed]

## Risk Assessment
**Level**: Low/Medium/High
**Reason**: [explanation]

## Backward Compatibility
**Impact**: None/Minor/Breaking
**Migration Required**: Yes/No

## Platform Testing
- [ ] Android device/emulator tested
- [ ] iOS physical device tested
- [ ] TypeScript builds cleanly
```
