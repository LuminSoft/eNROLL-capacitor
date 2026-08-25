import { Enroll } from 'enroll-capacitor';

const defaultValues = {
  tenantId: '9235e61e-3322-4940-a78e-4c182cf7ef63',
  tenantSecret: '736db9db-680a-4608-b545-1c7d636c7487',
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
  questionnaireId: 'QUESTIONNAIRE_ID',
  contractParameters: 'contractParameters',
  enrollExitStep: 'personalConfirmation',
  logoMode: 'custom',
  logoAssetName: 'enroll_test_logo',
  logoRenderingMode: 'original',
  fontFamily: '',
  fontSizes: 'default',
  dynamicTypeEnabled: true,
  useLocalizationOverrides: false,
};

const elements = {
  startButton: document.getElementById('startEnrollButton'),
  resetButton: document.getElementById('fillDefaultsButton'),
  clearButton: document.getElementById('clearResultsButton'),
  statusBox: document.getElementById('statusBox'),
  requestIdResult: document.getElementById('requestIdResult'),
  successResult: document.getElementById('successResult'),
  errorResult: document.getElementById('errorResult'),
};

function setStatus(message, kind = 'info') {
  elements.statusBox.textContent = message;
  elements.statusBox.className = `status${kind === 'info' ? '' : ` ${kind}`}`;
}

function setPrettyJson(target, value) {
  target.textContent =
    typeof value === 'string' ? value : JSON.stringify(value, null, 2);
}

function normalizeOptionalString(value) {
  if (!value) return undefined;
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : undefined;
}

function normalizeOptionalField(value) {
  if (typeof value === 'string') {
    return normalizeOptionalString(value);
  }
  return value;
}

// --- Sign Contract Mode UI toggling ---

function isQuestionnaireMode() {
  return document.getElementById('enrollMode').value === 'questionnaire';
}

function isSignContractMode() {
  return document.getElementById('enrollMode').value === 'signContract';
}

function getSignContractMode() {
  return document.getElementById('signContractMode').value;
}

function updateSignContractVisibility() {
  const signContractSection = document.getElementById('signContractSection');
  const normalContractFields = document.getElementById('normalContractFields');

  if (isSignContractMode()) {
    signContractSection.style.display = 'block';
    normalContractFields.style.display = 'none';
  } else {
    signContractSection.style.display = 'none';
    normalContractFields.style.display = 'block';
  }
}

function updateSignContractModeFields() {
  const templateFields = document.getElementById('templateModeFields');
  const pdfFields = document.getElementById('pdfModeFields');

  if (getSignContractMode() === 'template') {
    templateFields.style.display = 'block';
    pdfFields.style.display = 'none';
  } else {
    templateFields.style.display = 'none';
    pdfFields.style.display = 'block';
  }
}

// --- PDF File Picker ---

function readFileAsBase64(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => {
      const base64 = reader.result.split(',')[1];
      resolve(base64);
    };
    reader.onerror = reject;
    reader.readAsDataURL(file);
  });
}

async function handlePdfFileSelected(event) {
  const file = event.target.files[0];
  if (!file) {
    document.getElementById('signContractFile').value = '';
    document.getElementById('contractFileName').value = '';
    document.getElementById('pdfFileName').textContent = '';
    return;
  }

  document.getElementById('contractFileName').value = file.name;
  document.getElementById('pdfFileName').textContent = `Selected: ${file.name}`;

  try {
    const base64 = await readFileAsBase64(file);
    document.getElementById('signContractFile').value = base64;
  } catch (err) {
    document.getElementById('pdfFileName').textContent = 'Error reading file';
    document.getElementById('signContractFile').value = '';
  }
}

// --- Theme ---

function collectEnrollTheme() {
  const logoMode = document.getElementById('logoMode').value;
  const logoAssetName = normalizeOptionalString(document.getElementById('logoAssetName').value);

  const logo = {
    mode: logoMode,
    renderingMode: document.getElementById('logoRenderingMode').value,
    showSponsoredBy: document.getElementById('showSponsoredBy').checked,
  };

  if (logoMode === 'custom' && logoAssetName !== undefined) {
    logo.assetName = logoAssetName;
  }

  const theme = {
    icons: {
      logo,
    },
  };

  // Typography
  const fontFamilyValue = document.getElementById('fontFamily').value;
  const fontFamily = fontFamilyValue && fontFamilyValue.length > 0 ? fontFamilyValue : undefined;
  const dynamicTypeEnabled = document.getElementById('dynamicTypeEnabled').checked;
  const sizes = document.getElementById('fontSizes').value;
  const useOverrides = document.getElementById('useLocalizationOverrides').checked;

  if (fontFamily || sizes !== 'default' || !dynamicTypeEnabled || useOverrides) {
    const typography = {
      dynamicTypeEnabled,
      sizes,
    };
    if (fontFamily) {
      typography.fontFamily = fontFamily;
    }
    if (useOverrides) {
      typography.localizationOverrides = {
        englishFileName: 'enroll_localizations_en',
        arabicFileName: 'enroll_localizations_ar',
      };
    }
    theme.typography = typography;
  }

  return theme;
}

// --- Defaults ---

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
  document.getElementById('enrollExitStep').value = defaultValues.enrollExitStep;
  document.getElementById('logoMode').value = defaultValues.logoMode;
  document.getElementById('logoAssetName').value = defaultValues.logoAssetName;
  document.getElementById('logoRenderingMode').value = defaultValues.logoRenderingMode;
  document.getElementById('skipTutorial').checked = defaultValues.skipTutorial;
  document.getElementById('fontFamily').value = defaultValues.fontFamily;
  document.getElementById('fontSizes').value = defaultValues.fontSizes;
  document.getElementById('dynamicTypeEnabled').checked = defaultValues.dynamicTypeEnabled;
  document.getElementById('useLocalizationOverrides').checked = defaultValues.useLocalizationOverrides;

  // Sign contract fields
  document.getElementById('signContractMode').value = 'template';
  document.getElementById('templateId').value = defaultValues.templateId;
  document.getElementById('contractParameters').value = defaultValues.contractParameters;
  document.getElementById('signContractFile').value = '';
  document.getElementById('contractFileName').value = '';
  document.getElementById('pdfFileName').textContent = '';
  document.getElementById('pdfFileInput').value = '';
  document.getElementById('questionnaireId').value = defaultValues.questionnaireId;
  document.getElementById('showSponsoredBy').checked = true;

  // Normal mode fields
  document.getElementById('templateIdNormal').value = defaultValues.templateId;
  document.getElementById('contractParametersNormal').value = defaultValues.contractParameters;

  updateSignContractVisibility();
  updateSignContractModeFields();
}

function clearResults() {
  setStatus('Ready to launch eNROLL.');
  elements.requestIdResult.textContent = 'No request ID received yet.';
  elements.successResult.textContent = 'No success result yet.';
  elements.errorResult.textContent = 'No error result yet.';
}

// --- Collect Options ---

function collectOptions() {
  const enrollMode = document.getElementById('enrollMode').value;
  const options = {
    tenantId: document.getElementById('tenantId').value.trim(),
    tenantSecret: document.getElementById('tenantSecret').value.trim(),
    enrollMode,
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
    enrollExitStep: document.getElementById('enrollExitStep').value,
    questionnaireId: document.getElementById('questionnaireId').value,
    enrollTheme: collectEnrollTheme(),
  };

  // Collect templateId / contractParameters / signContractFile based on mode
  if (enrollMode === 'signContract') {
    const signContractMode = getSignContractMode();
    if (signContractMode === 'template') {
      optionalFields.templateId = document.getElementById('templateId').value;
      optionalFields.contractParameters = document.getElementById('contractParameters').value;
    } else {
      optionalFields.signContractFile = document.getElementById('signContractFile').value;
      optionalFields.contractFileName = document.getElementById('contractFileName').value;
    }
  } else {
    optionalFields.templateId = document.getElementById('templateIdNormal').value;
    optionalFields.contractParameters = document.getElementById('contractParametersNormal').value;
  }

  Object.entries(optionalFields).forEach(([key, value]) => {
    const normalized = normalizeOptionalField(value);
    if (normalized !== undefined) {
      options[key] = normalized;
    }
  });

  return options;
}

// --- Launch ---

async function startEnroll() {
  clearResults();

  if (isQuestionnaireMode()) {
    const appId = document.getElementById('applicationId').value.trim();
    const questionnaireId = document.getElementById('questionnaireId').value.trim();
    if (!appId || appId === 'APPLICATION_ID') {
      setStatus('Application ID is required for questionnaire mode', 'error');
      return;
    }
    if (!questionnaireId || questionnaireId === 'QUESTIONNAIRE_ID') {
      setStatus('Questionnaire ID is required for questionnaire mode', 'error');
      return;
    }
  }

  // Validation for sign contract mode
  if (isSignContractMode()) {
    const appId = document.getElementById('applicationId').value.trim();
    if (!appId || appId === 'APPLICATION_ID') {
      setStatus('Application ID is required for sign contract', 'error');
      return;
    }
    if (getSignContractMode() === 'template') {
      const templateId = document.getElementById('templateId').value.trim();
      if (!templateId) {
        setStatus('Template ID is required for contract template mode', 'error');
        return;
      }
    } else {
      const signContractFile = document.getElementById('signContractFile').value;
      if (!signContractFile) {
        setStatus('PDF file is required for PDF sign contract mode', 'error');
        return;
      }
    }
  }

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

function bindActions() {
  elements.startButton.addEventListener('click', startEnroll);
  elements.resetButton.addEventListener('click', () => {
    applyDefaults();
    clearResults();
  });
  elements.clearButton.addEventListener('click', clearResults);

  // Mode switching
  document.getElementById('enrollMode').addEventListener('change', updateSignContractVisibility);
  document.getElementById('signContractMode').addEventListener('change', () => {
    updateSignContractModeFields();
    // Clear PDF state when switching to template
    if (getSignContractMode() === 'template') {
      document.getElementById('signContractFile').value = '';
      document.getElementById('contractFileName').value = '';
      document.getElementById('pdfFileName').textContent = '';
      document.getElementById('pdfFileInput').value = '';
    }
  });

  // PDF file picker
  document.getElementById('pdfFileInput').addEventListener('change', handlePdfFileSelected);
}

document.addEventListener('DOMContentLoaded', async () => {
  applyDefaults();
  clearResults();
  bindActions();
  await setupRequestIdListener();
});
