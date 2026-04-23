import { registerPlugin } from '@capacitor/core';

import type { EnrollPlugin } from './definitions';

const Enroll = registerPlugin<EnrollPlugin>('Enroll', {
  web: () => import('./web').then((m) => new m.EnrollWeb()),
});

export * from './definitions';
export { Enroll };
