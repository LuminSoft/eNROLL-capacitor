import { Enroll } from 'enroll-capacitor';

const defaultValues = {
  tenantId: 'YOUR_TENANT_ID',
  tenantSecret: 'YOUR_TENANT_SECRET',
  requestId: '',
  enrollMode: 'onboarding',
  enrollEnvironment: 'staging',
  localizationCode: 'en',
  applicationId: 'APPLICATION_ID',
  skipTutorial: false,
  levelOfTrust: 'LEVEL_OF_TRUST_TOKEN',
  googleApiKey: 'GOOGLE_API_KEY',
  correlationId: 'correlationIdTest',
  templateId: 'templateId',
  contractParameters: 'contractParameters',
  enrollExitStep: 'personalConfirmation',
};

const fieldIds = [
  'tenantId',
  'tenantSecret',
  'requestId',
  'enrollMode',
  'enrollEnvironment',
  'localizationCode',
  'applicationId',
  'levelOfTrust',
  'googleApiKey',
  'correlationId',
  'templateId',
  'contractParameters',
  'enrollExitStep',
  'skipTutorial',
];

const elements = {
  startButton: document.getElementById('startEnrollButton'),
  resetButton: document.getElementById('fillDefaultsButton'),
  clearButton: document.getElementById('clearResultsButton'),
  statusBox: document.getElementById('statusBox'),
  requestIdResult: document.getElementById('requestIdResult'),
  successResult: document.getElementById('successResult'),
  errorResult: document.getElementById('errorResult'),
};

function getInputValue(id) {
  return document.getElementById(id);
}

function setStatus(message, kind = 'info') {
  elements.statusBox.textContent = message;
  elements.statusBox.className = `status${kind === 'info' ? '' : ` ${kind}`}`;
}

function setPrettyJson(target, value) {
  target.textContent =
    typeof value === 'string' ? value : JSON.stringify(value, null, 2);
}

function normalizeOptionalString(value) {
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : undefined;
}

function applyDefaults() {
  document.getElementById('tenantId').value = defaultValues.tenantId;
  document.getElementById('tenantSecret').value = defaultValues.tenantSecret;
  document.getElementById('requestId').value = defaultValues.requestId;
  document.getElementById('enrollMode').value = defaultValues.enrollMode;
  document.getElementById('enrollEnvironment').value = defaultValues.enrollEnvironment;
  document.getElementById('localizationCode').value = defaultValues.localizationCode;
  document.getElementById('applicationId').value = defaultValues.applicationId;
  document.getElementById('levelOfTrust').value = defaultValues.levelOfTrust;
  document.getElementById('googleApiKey').value = defaultValues.googleApiKey;
  document.getElementById('correlationId').value = defaultValues.correlationId;
  document.getElementById('templateId').value = defaultValues.templateId;
  document.getElementById('contractParameters').value = defaultValues.contractParameters;
  document.getElementById('enrollExitStep').value = defaultValues.enrollExitStep;
  document.getElementById('skipTutorial').checked = defaultValues.skipTutorial;
}

function clearResults() {
  setStatus('Ready to launch eNROLL.');
  elements.requestIdResult.textContent = 'No request ID received yet.';
  elements.successResult.textContent = 'No success result yet.';
  elements.errorResult.textContent = 'No error result yet.';
}

function collectOptions() {
  const options = {
    tenantId: document.getElementById('tenantId').value.trim(),
    tenantSecret: document.getElementById('tenantSecret').value.trim(),
    enrollMode: document.getElementById('enrollMode').value,
    enrollEnvironment: document.getElementById('enrollEnvironment').value,
    localizationCode: document.getElementById('localizationCode').value,
    skipTutorial: document.getElementById('skipTutorial').checked,
  };

  const optionalFields = {
    applicationId: document.getElementById('applicationId').value,
    levelOfTrust: document.getElementById('levelOfTrust').value,
    requestId: document.getElementById('requestId').value,
    googleApiKey: document.getElementById('googleApiKey').value,
    correlationId: document.getElementById('correlationId').value,
    templateId: document.getElementById('templateId').value,
    contractParameters: document.getElementById('contractParameters').value,
    enrollExitStep: document.getElementById('enrollExitStep').value,
  };

  Object.entries(optionalFields).forEach(([key, value]) => {
    const normalized = normalizeOptionalString(value);
    if (normalized !== undefined) {
      options[key] = normalized;
    }
  });

  return options;
}

async function startEnroll() {
  clearResults();
  setStatus('Launching eNROLL...', 'info');
  elements.startButton.disabled = true;

  try {
    const options = collectOptions();
    setPrettyJson(elements.successResult, 'Waiting for result...');
    const result = await Enroll.startEnroll(options);
    setPrettyJson(elements.successResult, result);
    setStatus(
      `Enrollment completed successfully.${result.applicantId ? ` Applicant ID: ${result.applicantId}` : ''}`,
      'success',
    );
  } catch (error) {
    const errorPayload = error?.data ?? error;
    setPrettyJson(elements.errorResult, errorPayload);
    setStatus(
      `Enrollment failed: ${errorPayload?.message ?? error?.message ?? 'Unknown error'}`,
      'error',
    );
  } finally {
    elements.startButton.disabled = false;
  }
}

async function setupRequestIdListener() {
  try {
    await Enroll.addListener('onRequestId', (data) => {
      setPrettyJson(elements.requestIdResult, data);
      setStatus(`Request ID received: ${data.requestId}`, 'info');
    });
  } catch (error) {
    setStatus(
      'Listener setup failed. This is expected in browser preview; native Android/iOS is required for real SDK use.',
      'error',
    );
    setPrettyJson(elements.errorResult, error?.message ?? error);
  }
}

function validateMarkup() {
  const missingIds = fieldIds.filter((id) => !getInputValue(id));
  if (missingIds.length > 0) {
    throw new Error(`Missing form elements: ${missingIds.join(', ')}`);
  }
}

function bindActions() {
  elements.startButton.addEventListener('click', startEnroll);
  elements.resetButton.addEventListener('click', () => {
    applyDefaults();
    clearResults();
  });
  elements.clearButton.addEventListener('click', clearResults);
}

document.addEventListener('DOMContentLoaded', async () => {
  validateMarkup();
  applyDefaults();
  clearResults();
  bindActions();
  await setupRequestIdListener();
});
