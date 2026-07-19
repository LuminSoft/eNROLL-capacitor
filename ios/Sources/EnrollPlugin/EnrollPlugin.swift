import Foundation
import Capacitor
import UIKit
import EnrollFramework

@objc(EnrollPlugin)
public class EnrollPlugin: CAPPlugin, CAPBridgedPlugin, EnrollCallBack {

    public let identifier = "EnrollPlugin"
    public let jsName = "Enroll"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "startEnroll", returnType: CAPPluginReturnPromise)
    ]

    /// Guard against launching a second flow while one is already running.
    private var isFlowInProgress = false

    /// Saved reference to the current PluginCall so callbacks can resolve/reject it.
    private var savedCall: CAPPluginCall?

    // ------------------------------------------------------------------
    // MARK: - Plugin method exposed to TypeScript
    // ------------------------------------------------------------------

    @objc func startEnroll(_ call: CAPPluginCall) {
        if isFlowInProgress {
            call.reject("An enrollment flow is already in progress", "FLOW_IN_PROGRESS")
            return
        }

        // ---- Required parameters ----
        guard let tenantId = call.getString("tenantId"), !tenantId.isEmpty else {
            call.reject("tenantId is required", "INVALID_ARGUMENT")
            return
        }
        guard let tenantSecret = call.getString("tenantSecret"), !tenantSecret.isEmpty else {
            call.reject("tenantSecret is required", "INVALID_ARGUMENT")
            return
        }
        guard let enrollModeStr = call.getString("enrollMode"), !enrollModeStr.isEmpty else {
            call.reject("enrollMode is required", "INVALID_ARGUMENT")
            return
        }
        guard let enrollMode = parseEnrollMode(enrollModeStr) else {
            call.reject("Invalid enrollMode: \(enrollModeStr)", "INVALID_ARGUMENT")
            return
        }

        // ---- Conditionally required parameters ----
        let applicationId = call.getString("applicationId") ?? ""
        let levelOfTrust = call.getString("levelOfTrust") ?? ""
        let templateId = call.getString("templateId") ?? ""

        if enrollMode == .authentication {
            if applicationId.isEmpty {
                call.reject("applicationId is required for auth mode", "INVALID_ARGUMENT")
                return
            }
            if levelOfTrust.isEmpty {
                call.reject("levelOfTrust is required for auth mode", "INVALID_ARGUMENT")
                return
            }
        }

        if enrollMode == .signContarct {
            if templateId.isEmpty {
                call.reject("templateId is required for signContract mode", "INVALID_ARGUMENT")
                return
            }
        }

        // ---- Optional parameters ----
        let enrollEnvironment = parseEnrollEnvironment(call.getString("enrollEnvironment"))
        let localizationCode = parseLocalizationCode(call.getString("localizationCode"))
        let googleApiKey = call.getString("googleApiKey") ?? ""
        let skipTutorial = call.getBool("skipTutorial") ?? false
        let correlationId = call.getString("correlationId") ?? ""
        let requestId = call.getString("requestId") ?? ""
        let contractParameters = call.getString("contractParameters") ?? ""
        let enrollForcedDocumentType = parseEnrollForcedDocumentType(call.getString("enrollForcedDocumentType"))
        let exitStep = parseExitStep(call.getString("enrollExitStep"))
        let contractTemplateId = Int(templateId)
        let contractFileName = call.getString("contractFileName")
        let signContractFile: Data? = {
            guard let base64Str = call.getString("signContractFile"), !base64Str.isEmpty else { return nil }
            return Data(base64Encoded: base64Str)
        }()

        // ---- Colors: enrollTheme.colors > appColors ----
        let enrollColors: EnrollColors? = {
            if let themeObj = call.getObject("enrollTheme"),
               let colorsObj = themeObj["colors"] as? [String: Any] {
                return generateDynamicColors(colors: colorsObj)
            }
            guard let colorsObj = call.getObject("appColors") else { return nil }
            return generateDynamicColors(colors: colorsObj)
        }()

        // ---- Theme (colors + icons + typography) ----
        var enrollTheme: EnrollTheme? = {
            guard let themeObj = call.getObject("enrollTheme") else { return nil }
            return self.generateDynamicTheme(theme: themeObj)
        }()

        // Parse typography from enrollTheme
        if let themeObj = call.getObject("enrollTheme"),
           let typographyDict = themeObj["typography"] as? [String: Any] {
            let parsedTypography = generateDynamicTypography(typographyDict)
            if enrollTheme == nil {
                enrollTheme = EnrollTheme()
            }
            enrollTheme?.typography = parsedTypography
        }

        // Apply typography to the shared EnrollThemeManager
        EnrollThemeManager.shared.configure(enrollTheme)

        // ---- RTL layout for Arabic ----
        configureLayoutDirection(localizationCode)

        // ---- Save call & mark in progress ----
        self.savedCall = call
        self.isFlowInProgress = true

        // ---- Launch SDK on main thread ----
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let presenterVC = self.bridge?.viewController else {
                self.isFlowInProgress = false
                self.savedCall = nil
                call.reject("Unable to get presenting view controller", "VIEW_CONTROLLER_ERROR")
                return
            }

            do {
                let initModel = try EnrollInitModel(
                    tenantId: tenantId,
                    tenantSecret: tenantSecret,
                    enrollEnviroment: enrollEnvironment,
                    localizationCode: localizationCode,
                    enrollCallBack: self,
                    enrollMode: enrollMode,
                    skipTutorial: skipTutorial,
                    enrollColors: enrollColors,
                    enrollTheme: enrollTheme,
                    levelOffTrustId: levelOfTrust.isEmpty ? nil : levelOfTrust,
                    applicantId: applicationId.isEmpty ? nil : applicationId,
                    correlationId: correlationId.isEmpty ? nil : correlationId,
                    forcedDocumentType: enrollForcedDocumentType,
                    requestId: requestId.isEmpty ? nil : requestId,
                    contractTemplateId: contractTemplateId,
                    signContarctParam: contractParameters.isEmpty ? nil : contractParameters,
                    signContarctFile: signContractFile,
                    signContarctFileName: contractFileName,
                    exitStep: exitStep
                )

                let enrollVC = try Enroll.initViewController(
                    enrollInitModel: initModel,
                    presenterVC: presenterVC
                )
                presenterVC.present(enrollVC, animated: true)
            } catch {
                self.isFlowInProgress = false
                self.savedCall = nil
                call.reject("Failed to start enrollment: \(error.localizedDescription)", "ENROLL_LAUNCH_ERROR")
            }
        }
    }

    // ------------------------------------------------------------------
    // MARK: - EnrollCallBack protocol
    // ------------------------------------------------------------------

    public func enrollDidSucceed(with model: EnrollFramework.EnrollSuccessModel) {
        isFlowInProgress = false
        guard let call = savedCall else { return }
        savedCall = nil

        var result: [String: Any] = [
            "applicantId": model.applicantId ?? "",
            "exitStepCompleted": false
        ]
        call.resolve(result)
    }

    public func enrollDidFail(with error: EnrollFramework.EnrollErrorModel) {
        isFlowInProgress = false
        guard let call = savedCall else { return }
        savedCall = nil

        call.reject(error.errorMessage ?? "Unknown error", "ENROLL_ERROR")
    }

    public func didInitializeRequest(with requestId: String) {
        notifyListeners("onRequestId", data: ["requestId": requestId])
    }

    // ------------------------------------------------------------------
    // MARK: - Enum parsers
    // ------------------------------------------------------------------

    private func parseEnrollMode(_ mode: String) -> EnrollMode? {
        switch mode.lowercased() {
        case "onboarding":
            return .onboarding
        case "auth":
            return .authentication
        case "update":
            return .update
        case "signcontract":
            return .signContarct
        default:
            return nil
        }
    }

    private func parseEnrollEnvironment(_ env: String?) -> EnrollFramework.EnrollEnviroment {
        switch env {
        case "production":
            return .production
        default:
            return .staging
        }
    }

    private func parseLocalizationCode(_ code: String?) -> EnrollFramework.LocalizationEnum {
        switch code {
        case "ar":
            return .ar
        default:
            return .en
        }
    }

    private func parseEnrollForcedDocumentType(_ type: String?) -> EnrollForcedDocumentType? {
        switch type {
        case "nationalIdOnly":
            return .nationalId
        case "passportOnly":
            return .passport
        case "nationalIdOrPassport":
            return .deafult
        default:
            return nil
        }
    }

    private func parseExitStep(_ step: String?) -> EnrollFramework.StepType? {
        guard let step = step else { return nil }
        switch step {
        case "phoneOtp":
            return .phoneOtp
        case "personalConfirmation":
            return .personalConfirmation
        case "smileLiveness":
            return .smileLiveness
        case "emailOtp":
            return .emailOtp
        case "saveMobileDevice":
            return .saveMobileDevice
        case "deviceLocation":
            return .deviceLocation
        case "password":
            return .password
        case "securityQuestions":
            return .securityQuestions
        case "amlCheck":
            return .amlCheck
        case "termsAndConditions":
            return .termsAndConditions
        case "electronicSignature":
            return .electronicSignature
        case "ntraCheck":
            return .ntraCheck
        case "csoCheck":
            return .csoCheck
        default:
            return nil
        }
    }

    // ------------------------------------------------------------------
    // MARK: - Color parsing
    // ------------------------------------------------------------------

    private func generateDynamicColors(colors: [String: Any]) -> EnrollColors? {
        var primaryColor: UIColor?
        var appBackgroundColor: UIColor?
        var appBlack: UIColor?
        var secondary: UIColor?
        var appWhite: UIColor?
        var errorColor: UIColor?
        var textColor: UIColor?
        var successColor: UIColor?
        var warningColor: UIColor?

        if let primary = colors["primary"] as? [String: Any] {
            primaryColor = uiColorFrom(dict: primary)
        }
        if let bg = colors["appBackgroundColor"] as? [String: Any] {
            appBackgroundColor = uiColorFrom(dict: bg)
        }
        if let black = colors["appBlack"] as? [String: Any] {
            appBlack = uiColorFrom(dict: black)
        }
        if let sec = colors["secondary"] as? [String: Any] {
            secondary = uiColorFrom(dict: sec)
        }
        if let white = colors["appWhite"] as? [String: Any] {
            appWhite = uiColorFrom(dict: white)
        }
        if let err = colors["errorColor"] as? [String: Any] {
            errorColor = uiColorFrom(dict: err)
        }
        if let txt = colors["textColor"] as? [String: Any] {
            textColor = uiColorFrom(dict: txt)
        }
        if let suc = colors["successColor"] as? [String: Any] {
            successColor = uiColorFrom(dict: suc)
        }
        if let warn = colors["warningColor"] as? [String: Any] {
            warningColor = uiColorFrom(dict: warn)
        }

        return EnrollColors(
            primary: primaryColor,
            secondary: secondary,
            appBackgroundColor: appBackgroundColor,
            textColor: textColor,
            errorColor: errorColor,
            successColor: successColor,
            warningColor: warningColor,
            appWhite: appWhite,
            appBlack: appBlack
        )
    }

    private func uiColorFrom(dict: [String: Any]) -> UIColor? {
        guard let r = dict["r"] as? Int,
              let g = dict["g"] as? Int,
              let b = dict["b"] as? Int else {
            return nil
        }
        let opacity = dict["opacity"] as? Double ?? 1.0
        return UIColor(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: CGFloat(opacity)
        )
    }

    // ------------------------------------------------------------------
    // MARK: - Theme parsing
    // ------------------------------------------------------------------

    private func generateDynamicTheme(theme: [String: Any]?) -> EnrollTheme {
        guard let theme = theme else {
            return EnrollTheme()
        }

        var enrollColors: EnrollColors?
        if let colorDict = theme["colors"] as? [String: Any] {
            enrollColors = generateDynamicColors(colors: colorDict)
        }

        var appIcons = AppIcons()
        if let iconsDict = theme["icons"] as? [String: Any] {
            appIcons = generateAppIcons(from: iconsDict)
        }

        return EnrollTheme(icons: appIcons, colors: enrollColors)
    }

    // ------------------------------------------------------------------
    // MARK: - Typography parsing
    // ------------------------------------------------------------------

    private func generateDynamicTypography(_ dict: [String: Any]) -> EnrollTypography {
        let fontFamily = dict["fontFamily"] as? String
        let dynamicTypeEnabled = dict["dynamicTypeEnabled"] as? Bool ?? true

        var sizes = EnrollFontSizes(size: .default)
        if let sizeName = dict["sizes"] as? String {
            switch sizeName.lowercased() {
            case "medium":
                sizes = EnrollFontSizes(size: .medium)
            case "large":
                sizes = EnrollFontSizes(size: .large)
            default:
                sizes = EnrollFontSizes(size: .default)
            }
        }

        var localizationOverrides: EnrollLocalizationOverrides?
        if let overridesDict = dict["localizationOverrides"] as? [String: Any] {
            let englishFileName = overridesDict["englishFileName"] as? String
            let arabicFileName = overridesDict["arabicFileName"] as? String
            if englishFileName != nil || arabicFileName != nil {
                localizationOverrides = EnrollLocalizationOverrides(
                    englishFileName: englishFileName,
                    arabicFileName: arabicFileName,
                    bundle: .main
                )
            }
        }

        return EnrollTypography(
            fontFamily: fontFamily,
            dynamicTypeEnabled: dynamicTypeEnabled,
            sizes: sizes,
            localizationOverrides: localizationOverrides
        )
    }

    private func generateAppIcons(from dictionary: [String: Any]) -> AppIcons {
        var logo = LogoConfig()
        var location = LocationIcons()
        var nationalId: NationalIdIcons?
        var passport = PassportIcons()
        var phone = PhoneIcons()
        var email = EmailIcons()
        var faceMatching = FaceMatchingIcons()
        var securityQuestions = SecurityQuestionsIcons()
        var password = PasswordIcons()
        var signature = SignatureIcons()
        var common = CommonIcons()
        var update = UpdateIcons()
        var forget = ForgetIcons()

        if let logoDict = dictionary["logo"] as? [String: Any] {
            logo = parseLogoConfig(from: logoDict)
        }
        if let locationDict = dictionary["location"] as? [String: Any] {
            location = parseLocationIcons(from: locationDict)
        }
        if let nationalIdDict = dictionary["nationalId"] as? [String: Any] {
            nationalId = parseNationalIdIcons(from: nationalIdDict)
        }
        if let passportDict = dictionary["passport"] as? [String: Any] {
            passport = parsePassportIcons(from: passportDict)
        }
        if let phoneDict = dictionary["phone"] as? [String: Any] {
            phone = parsePhoneIcons(from: phoneDict)
        }
        if let emailDict = dictionary["email"] as? [String: Any] {
            email = parseEmailIcons(from: emailDict)
        }
        if let faceMatchingDict = dictionary["faceMatching"] as? [String: Any] {
            faceMatching = parseFaceMatchingIcons(from: faceMatchingDict)
        }
        if let securityQuestionsDict = dictionary["securityQuestions"] as? [String: Any] {
            securityQuestions = parseSecurityQuestionsIcons(from: securityQuestionsDict)
        }
        if let passwordDict = dictionary["password"] as? [String: Any] {
            password = parsePasswordIcons(from: passwordDict)
        }
        if let signatureDict = dictionary["signature"] as? [String: Any] {
            signature = parseSignatureIcons(from: signatureDict)
        }
        if let commonDict = dictionary["common"] as? [String: Any] {
            common = parseCommonIcons(from: commonDict)
        }
        if let updateDict = dictionary["update"] as? [String: Any] {
            update = parseUpdateIcons(from: updateDict)
        }
        if let forgetDict = dictionary["forget"] as? [String: Any] {
            forget = parseForgetIcons(from: forgetDict)
        }

        return AppIcons(
            logo: logo,
            location: location,
            nationalId: nationalId,
            passport: passport,
            phone: phone,
            email: email,
            faceMatching: faceMatching,
            securityQuestions: securityQuestions,
            password: password,
            signature: signature,
            common: common,
            update: update,
            forget: forget
        )
    }

    private func parseLogoConfig(from dictionary: [String: Any]) -> LogoConfig {
        var mode: LogoMode = .default
        var icon: EnrollIcon?

        if let modeString = dictionary["mode"] as? String {
            switch modeString.lowercased() {
            case "hidden":
                mode = .hidden
            case "custom":
                mode = .custom
            default:
                mode = .default
            }
        }

        if let _ = dictionary["assetName"] as? String {
            icon = parseEnrollIcon(from: dictionary)
        }

        return LogoConfig(mode: mode, icon: icon)
    }

    private func parseEnrollIcon(from dictionary: [String: Any]) -> EnrollIcon {
        let assetName = dictionary["assetName"] as? String ?? ""

        var renderingMode: EnrollIconRenderingMode = .original
        if let renderingModeString = dictionary["renderingMode"] as? String {
            renderingMode = renderingModeString.lowercased() == "template" ? .template : .original
        }

        var validationMode: IconValidationMode = .relaxed
        if let validationModeString = dictionary["validationMode"] as? String {
            validationMode = validationModeString.lowercased() == "strict" ? .strict : .relaxed
        }

        let bundle = Bundle.main

        return EnrollIcon(
            assetName: assetName,
            renderingMode: renderingMode,
            bundle: bundle,
            validationMode: validationMode
        )
    }

    private func parseStepIcon(from dictionary: [String: Any]) -> StepIcon? {
        guard let _ = dictionary as? [String: Any] else {
            return nil
        }

        guard let enrollIcon = parseEnrollIcon(from: dictionary) as? EnrollIcon else {
            return nil
        }

        return StepIcon(icon: enrollIcon)
    }

    private func parseLocationIcons(from dictionary: [String: Any]) -> LocationIcons {
        return LocationIcons(
            tutorial: parseStepIcon(from: dictionary["tutorial"] as? [String: Any] ?? [:]),
            requestAccess: parseStepIcon(from: dictionary["requestAccess"] as? [String: Any] ?? [:]),
            accessError: parseStepIcon(from: dictionary["accessError"] as? [String: Any] ?? [:]),
            grab: parseStepIcon(from: dictionary["grab"] as? [String: Any] ?? [:])
        )
    }

    private func parseNationalIdIcons(from dictionary: [String: Any]) -> NationalIdIcons {
        return NationalIdIcons(
            tutorial: parseStepIcon(from: dictionary["tutorial"] as? [String: Any] ?? [:]),
            tutorialIdOrPassport: parseStepIcon(from: dictionary["tutorialIdOrPassport"] as? [String: Any] ?? [:]),
            preScan: parseStepIcon(from: dictionary["preScan"] as? [String: Any] ?? [:]),
            scanError: parseStepIcon(from: dictionary["scanError"] as? [String: Any] ?? [:]),
            choose: parseStepIcon(from: dictionary["choose"] as? [String: Any] ?? [:])
        )
    }

    private func parsePassportIcons(from dictionary: [String: Any]) -> PassportIcons {
        return PassportIcons(
            tutorial: parseStepIcon(from: dictionary["tutorial"] as? [String: Any] ?? [:]),
            preScan: parseStepIcon(from: dictionary["preScan"] as? [String: Any] ?? [:]),
            ePassportPreScan: parseStepIcon(from: dictionary["ePassportPreScan"] as? [String: Any] ?? [:]),
            choose: parseStepIcon(from: dictionary["choose"] as? [String: Any] ?? [:]),
            scanError: parseStepIcon(from: dictionary["scanError"] as? [String: Any] ?? [:])
        )
    }

    private func parsePhoneIcons(from dictionary: [String: Any]) -> PhoneIcons {
        return PhoneIcons(
            tutorial: parseStepIcon(from: dictionary["tutorial"] as? [String: Any] ?? [:]),
            select: parseStepIcon(from: dictionary["select"] as? [String: Any] ?? [:]),
            validateOtp: parseStepIcon(from: dictionary["validateOtp"] as? [String: Any] ?? [:])
        )
    }

    private func parseEmailIcons(from dictionary: [String: Any]) -> EmailIcons {
        return EmailIcons(
            tutorial: parseStepIcon(from: dictionary["tutorial"] as? [String: Any] ?? [:]),
            select: parseStepIcon(from: dictionary["select"] as? [String: Any] ?? [:]),
            validateOtp: parseStepIcon(from: dictionary["validateOtp"] as? [String: Any] ?? [:])
        )
    }

    private func parseFaceMatchingIcons(from dictionary: [String: Any]) -> FaceMatchingIcons {
        return FaceMatchingIcons(
            tutorial: parseStepIcon(from: dictionary["tutorial"] as? [String: Any] ?? [:]),
            preScan: parseStepIcon(from: dictionary["preScan"] as? [String: Any] ?? [:]),
            error: parseStepIcon(from: dictionary["error"] as? [String: Any] ?? [:])
        )
    }

    private func parseSecurityQuestionsIcons(from dictionary: [String: Any]) -> SecurityQuestionsIcons {
        return SecurityQuestionsIcons(
            tutorial: parseStepIcon(from: dictionary["tutorial"] as? [String: Any] ?? [:]),
            authScreen: parseStepIcon(from: dictionary["authScreen"] as? [String: Any] ?? [:])
        )
    }

    private func parsePasswordIcons(from dictionary: [String: Any]) -> PasswordIcons {
        return PasswordIcons(
            tutorial: parseStepIcon(from: dictionary["tutorial"] as? [String: Any] ?? [:]),
            authScreen: parseStepIcon(from: dictionary["authScreen"] as? [String: Any] ?? [:])
        )
    }

    private func parseSignatureIcons(from dictionary: [String: Any]) -> SignatureIcons {
        return SignatureIcons(tutorial: parseStepIcon(from: dictionary["tutorial"] as? [String: Any] ?? [:]))
    }

    private func parseBackgroundIcons(from dictionary: [String: Any]) -> BackgroundIcons {
        return BackgroundIcons(
            main: parseStepIcon(from: dictionary["main"] as? [String: Any] ?? [:]),
            layer1: parseStepIcon(from: dictionary["layer1"] as? [String: Any] ?? [:]),
            layer2: parseStepIcon(from: dictionary["layer2"] as? [String: Any] ?? [:]),
            layer3: parseStepIcon(from: dictionary["layer3"] as? [String: Any] ?? [:]),
            blur: parseStepIcon(from: dictionary["blur"] as? [String: Any] ?? [:]),
            header: parseStepIcon(from: dictionary["header"] as? [String: Any] ?? [:]),
            footer: parseStepIcon(from: dictionary["footer"] as? [String: Any] ?? [:])
        )
    }

    private func parsePopupIcons(from dictionary: [String: Any]) -> PopupIcons {
        return PopupIcons(
            background: parseStepIcon(from: dictionary["background"] as? [String: Any] ?? [:]),
            warningIcon: parseStepIcon(from: dictionary["warningIcon"] as? [String: Any] ?? [:]),
            errorIcon: parseStepIcon(from: dictionary["errorIcon"] as? [String: Any] ?? [:]),
            successIcon: parseStepIcon(from: dictionary["successIcon"] as? [String: Any] ?? [:]),
            errorSign: parseStepIcon(from: dictionary["errorSign"] as? [String: Any] ?? [:]),
            successSign: parseStepIcon(from: dictionary["successSign"] as? [String: Any] ?? [:]),
            warningSign: parseStepIcon(from: dictionary["warningSign"] as? [String: Any] ?? [:])
        )
    }

    private func parseFieldIcons(from dictionary: [String: Any]) -> FieldIcons {
        return FieldIcons(
            user: parseStepIcon(from: dictionary["user"] as? [String: Any] ?? [:]),
            calendar: parseStepIcon(from: dictionary["calendar"] as? [String: Any] ?? [:]),
            gender: parseStepIcon(from: dictionary["gender"] as? [String: Any] ?? [:]),
            issuingAuthority: parseStepIcon(from: dictionary["issuingAuthority"] as? [String: Any] ?? [:]),
            nationality: parseStepIcon(from: dictionary["nationality"] as? [String: Any] ?? [:]),
            num: parseStepIcon(from: dictionary["num"] as? [String: Any] ?? [:]),
            passport: parseStepIcon(from: dictionary["passport"] as? [String: Any] ?? [:]),
            address: parseStepIcon(from: dictionary["address"] as? [String: Any] ?? [:]),
            idCard: parseStepIcon(from: dictionary["idCard"] as? [String: Any] ?? [:]),
            profession: parseStepIcon(from: dictionary["profession"] as? [String: Any] ?? [:]),
            religion: parseStepIcon(from: dictionary["religion"] as? [String: Any] ?? [:]),
            maritalStatus: parseStepIcon(from: dictionary["maritalStatus"] as? [String: Any] ?? [:])
        )
    }

    private func parseUiIcons(from dictionary: [String: Any]) -> UiIcons {
        return UiIcons(
            visibility: parseStepIcon(from: dictionary["visibility"] as? [String: Any] ?? [:]),
            visibilityOff: parseStepIcon(from: dictionary["visibilityOff"] as? [String: Any] ?? [:]),
            mobile: parseStepIcon(from: dictionary["mobile"] as? [String: Any] ?? [:]),
            mail: parseStepIcon(from: dictionary["mail"] as? [String: Any] ?? [:]),
            answer: parseStepIcon(from: dictionary["answer"] as? [String: Any] ?? [:]),
            error: parseStepIcon(from: dictionary["error"] as? [String: Any] ?? [:]),
            info: parseStepIcon(from: dictionary["info"] as? [String: Any] ?? [:]),
            edit: parseStepIcon(from: dictionary["edit"] as? [String: Any] ?? [:]),
            activePhone: parseStepIcon(from: dictionary["activePhone"] as? [String: Any] ?? [:])
        )
    }

    private func parseCommonIcons(from dictionary: [String: Any]) -> CommonIcons {
        let backgroundsDict = dictionary["backgrounds"] as? [String: Any] ?? [:]
        let backgrounds = parseBackgroundIcons(from: backgroundsDict)
        let popupsDict = dictionary["popups"] as? [String: Any] ?? [:]
        let popups = parsePopupIcons(from: popupsDict)
        let fieldIconsDict = dictionary["fieldIcons"] as? [String: Any] ?? [:]
        let fieldIcons = parseFieldIcons(from: fieldIconsDict)
        let uiDict = dictionary["ui"] as? [String: Any] ?? [:]
        let ui = parseUiIcons(from: uiDict)
        let termsAndConditions = parseStepIcon(from: dictionary["termsAndConditions"] as? [String: Any] ?? [:])

        return CommonIcons(
            backgrounds: backgrounds,
            popups: popups,
            fieldIcons: fieldIcons,
            ui: ui,
            termsAndConditions: termsAndConditions
        )
    }

    private func parseUpdateIcons(from dictionary: [String: Any]) -> UpdateIcons {
        return UpdateIcons(
            modeIcon: parseStepIcon(from: dictionary["modeIcon"] as? [String: Any] ?? [:]),
            idCard: parseStepIcon(from: dictionary["idCard"] as? [String: Any] ?? [:]),
            passport: parseStepIcon(from: dictionary["passport"] as? [String: Any] ?? [:]),
            mobile: parseStepIcon(from: dictionary["mobile"] as? [String: Any] ?? [:]),
            email: parseStepIcon(from: dictionary["email"] as? [String: Any] ?? [:]),
            device: parseStepIcon(from: dictionary["device"] as? [String: Any] ?? [:]),
            address: parseStepIcon(from: dictionary["address"] as? [String: Any] ?? [:]),
            securityQuestions: parseStepIcon(from: dictionary["securityQuestions"] as? [String: Any] ?? [:]),
            password: parseStepIcon(from: dictionary["password"] as? [String: Any] ?? [:])
        )
    }

    private func parseForgetIcons(from dictionary: [String: Any]) -> ForgetIcons {
        return ForgetIcons(
            modeIcon: parseStepIcon(from: dictionary["modeIcon"] as? [String: Any] ?? [:]),
            nationalId: parseStepIcon(from: dictionary["nationalId"] as? [String: Any] ?? [:]),
            passport: parseStepIcon(from: dictionary["passport"] as? [String: Any] ?? [:]),
            phone: parseStepIcon(from: dictionary["phone"] as? [String: Any] ?? [:]),
            email: parseStepIcon(from: dictionary["email"] as? [String: Any] ?? [:]),
            device: parseStepIcon(from: dictionary["device"] as? [String: Any] ?? [:]),
            location: parseStepIcon(from: dictionary["location"] as? [String: Any] ?? [:]),
            securityQuestions: parseStepIcon(from: dictionary["securityQuestions"] as? [String: Any] ?? [:]),
            password: parseStepIcon(from: dictionary["password"] as? [String: Any] ?? [:])
        )
    }

    // ------------------------------------------------------------------
    // MARK: - RTL layout configuration
    // ------------------------------------------------------------------

    private func configureLayoutDirection(_ code: EnrollFramework.LocalizationEnum) {
        DispatchQueue.main.async {
            if code == .ar {
                UIView.appearance().semanticContentAttribute = .forceRightToLeft
                UICollectionView.appearance().semanticContentAttribute = .forceRightToLeft
                UINavigationBar.appearance().semanticContentAttribute = .forceRightToLeft
                UITextField.appearance().semanticContentAttribute = .forceRightToLeft
                UITextField.appearance().textAlignment = .right
                UITextView.appearance().semanticContentAttribute = .forceRightToLeft
                UITableView.appearance().semanticContentAttribute = .forceRightToLeft
            } else {
                UIView.appearance().semanticContentAttribute = .forceLeftToRight
                UICollectionView.appearance().semanticContentAttribute = .forceLeftToRight
                UINavigationBar.appearance().semanticContentAttribute = .forceLeftToRight
                UITextField.appearance().semanticContentAttribute = .forceLeftToRight
                UITextField.appearance().textAlignment = .left
                UITextView.appearance().semanticContentAttribute = .forceLeftToRight
                UITableView.appearance().semanticContentAttribute = .forceLeftToRight
            }
        }
    }
}
