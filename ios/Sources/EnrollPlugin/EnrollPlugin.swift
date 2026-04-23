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

        // ---- Colors: enrollTheme.colors > appColors ----
        let enrollColors: EnrollColors? = {
            if let themeObj = call.getObject("enrollTheme"),
               let colorsObj = themeObj["colors"] as? [String: Any] {
                return generateDynamicColors(colors: colorsObj)
            }
            guard let colorsObj = call.getObject("appColors") else { return nil }
            return generateDynamicColors(colors: colorsObj)
        }()

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
                    levelOffTrustId: levelOfTrust.isEmpty ? nil : levelOfTrust,
                    applicantId: applicationId.isEmpty ? nil : applicationId,
                    correlationId: correlationId.isEmpty ? nil : correlationId,
                    forcedDocumentType: enrollForcedDocumentType,
                    requestId: requestId.isEmpty ? nil : requestId,
                    contractTemplateId: contractTemplateId,
                    signContarctParam: contractParameters.isEmpty ? nil : contractParameters,
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
