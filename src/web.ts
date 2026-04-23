import { WebPlugin } from '@capacitor/core';

import type { EnrollPlugin, EnrollSuccessResult, StartEnrollOptions } from './definitions';

export class EnrollWeb extends WebPlugin implements EnrollPlugin {
  async startEnroll(_options: StartEnrollOptions): Promise<EnrollSuccessResult> {
    throw this.unavailable(
      'The eNROLL plugin is not available on the web. ' +
        'Run this app on a native Android or iOS device using Capacitor.',
    );
  }
}
