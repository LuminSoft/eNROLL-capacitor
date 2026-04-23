# Ionic / Angular Integration Guide

Step-by-step guide for integrating the eNROLL Capacitor Plugin into an Ionic Angular mobile app.

## Prerequisites

- Ionic CLI installed (`npm install -g @ionic/cli`)
- An existing Ionic Angular project (or create one with `ionic start myApp blank --type=angular`)
- Capacitor 6+ configured in your project
- Completed [Android Setup](integration-android.md) and/or [iOS Setup](integration-ios.md)

## Step 1: Install the Plugin

```bash
npm install enroll-capacitor
npx cap sync
```

> **What this does:** `npm install` downloads the plugin. `npx cap sync` copies the native code into your `android/` and `ios/` directories so the native build systems can compile it.

## Step 2: Create an Angular Service

Create a service to wrap the plugin calls. This keeps your components clean.

```bash
ionic generate service services/enroll
```

Then implement the service:

```typescript
// src/app/services/enroll.service.ts
import { Injectable } from '@angular/core';
import { Enroll } from 'enroll-capacitor';
import type {
  StartEnrollOptions,
  EnrollSuccessResult,
  EnrollRequestIdResult,
} from 'enroll-capacitor';
import type { PluginListenerHandle } from '@capacitor/core';

@Injectable({ providedIn: 'root' })
export class EnrollService {
  private requestIdListener: PluginListenerHandle | null = null;

  /**
   * Start the eNROLL enrollment flow.
   */
  async startEnroll(options: StartEnrollOptions): Promise<EnrollSuccessResult> {
    return Enroll.startEnroll(options);
  }

  /**
   * Register a listener for request ID events.
   * Call this BEFORE startEnroll() if you need to capture the request ID.
   */
  async onRequestId(callback: (result: EnrollRequestIdResult) => void): Promise<void> {
    this.requestIdListener = await Enroll.addListener('onRequestId', callback);
  }

  /**
   * Clean up listeners. Call when your component is destroyed.
   */
  async cleanup(): Promise<void> {
    if (this.requestIdListener) {
      await this.requestIdListener.remove();
      this.requestIdListener = null;
    }
  }
}
```

## Step 3: Use in a Component

```typescript
// src/app/pages/kyc/kyc.page.ts
import { Component, OnDestroy } from '@angular/core';
import { EnrollService } from '../../services/enroll.service';

@Component({
  selector: 'app-kyc',
  template: `
    <ion-header>
      <ion-toolbar>
        <ion-title>Identity Verification</ion-title>
      </ion-toolbar>
    </ion-header>
    <ion-content class="ion-padding">
      <ion-button expand="block" (click)="startVerification()" [disabled]="isLoading">
        {{ isLoading ? 'Verifying...' : 'Start Verification' }}
      </ion-button>
      <p *ngIf="resultMessage">{{ resultMessage }}</p>
    </ion-content>
  `,
})
export class KycPage implements OnDestroy {
  isLoading = false;
  resultMessage = '';

  constructor(private enrollService: EnrollService) {}

  async startVerification(): Promise<void> {
    this.isLoading = true;
    this.resultMessage = '';

    // Listen for request ID (optional)
    await this.enrollService.onRequestId((data) => {
      console.log('Request ID received:', data.requestId);
    });

    try {
      const result = await this.enrollService.startEnroll({
        tenantId: 'YOUR_TENANT_ID',
        tenantSecret: 'YOUR_TENANT_SECRET',
        enrollMode: 'onboarding',
        enrollEnvironment: 'staging',
        localizationCode: 'en',
        skipTutorial: false,
      });

      this.resultMessage = `Success! Applicant ID: ${result.applicantId}`;
    } catch (error: any) {
      this.resultMessage = `Error: ${error?.message || 'Unknown error'}`;
    } finally {
      this.isLoading = false;
    }
  }

  ngOnDestroy(): void {
    this.enrollService.cleanup();
  }
}
```

## Step 4: Build and Run

### Android

```bash
npx cap sync android
npx cap run android
# Or open in Android Studio:
npx cap open android
```

### iOS

```bash
npx cap sync ios
npx cap open ios
# Build and run from Xcode onto a physical device
```

## Tips

### Environment Configuration

Store your tenant credentials securely — not in source code:

```typescript
// src/environments/environment.ts
export const environment = {
  production: false,
  enroll: {
    tenantId: 'YOUR_STAGING_TENANT_ID',
    tenantSecret: 'YOUR_STAGING_TENANT_SECRET',
    environment: 'staging' as const,
  },
};
```

Then use in the service:

```typescript
import { environment } from '../environments/environment';

const result = await Enroll.startEnroll({
  tenantId: environment.enroll.tenantId,
  tenantSecret: environment.enroll.tenantSecret,
  enrollEnvironment: environment.enroll.environment,
  enrollMode: 'onboarding',
});
```

### Error Handling

The rejected promise contains an error object. Access it like this:

```typescript
try {
  const result = await Enroll.startEnroll({ ... });
} catch (error: any) {
  // error.message — human-readable error string
  // error.code   — machine-readable error code (e.g., 'INVALID_ARGUMENT')
  // error.data   — additional error data (e.g., { applicantId: '...' })
  console.error('Code:', error.code, 'Message:', error.message);
}
```

### Resuming a Flow

If the user closes the app mid-flow, you can resume using the request ID:

```typescript
// Save the request ID when received
let savedRequestId = '';
await Enroll.addListener('onRequestId', (data) => {
  savedRequestId = data.requestId;
  // Persist to storage if needed
});

// Later, resume the flow:
const result = await Enroll.startEnroll({
  tenantId: 'YOUR_TENANT_ID',
  tenantSecret: 'YOUR_TENANT_SECRET',
  enrollMode: 'onboarding',
  requestId: savedRequestId,
});
```

### Exit Step Workflow

Auto-close the SDK after a specific step and check the result:

```typescript
const result = await Enroll.startEnroll({
  tenantId: 'YOUR_TENANT_ID',
  tenantSecret: 'YOUR_TENANT_SECRET',
  enrollMode: 'onboarding',
  enrollExitStep: 'smileLiveness',
});

if (result.exitStepCompleted) {
  console.log('Exited after:', result.completedStepName);
  console.log('Resume with requestId:', result.requestId);
}
```
