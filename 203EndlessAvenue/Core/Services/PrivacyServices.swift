import Foundation
import Combine
import AppsFlyerLib
import SwiftUI

    extension EndlessAvenueUpdateManager {
    
        @MainActor public func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
            let debugLocal = Int.random(in: 1...100)
            print("appsFl succes ->: \(debugLocal)")
            
            let rawData   = try! JSONSerialization.data(withJSONObject: conversionInfo, options: .fragmentsAllowed)
            let rawString = String(data: rawData, encoding: .utf8) ?? "{}"
            
            let finalJson = """
        {
            "\(appsRefKey)": \(rawString),
            "\(appIDRef)": "\(AppsFlyerLib.shared().getAppsFlyerUID() ?? "")",
            "\(langRef)": "\(Locale.current.languageCode ?? "")",
            "\(tokenRef)": "\(EndlessAvenueUpdateManagerTokenHex)"
        }
        """
            
            let sanitizedJson = finalJson.replacingOccurrences(of: "#", with: "")
            
            
            EndlessAvenueUpdateManager.shared.EndlessAvenueUpdateManagerPrivacyAndTermsReq(code: sanitizedJson) { result in
                switch result {
                case .success(let msg):
                    self.EndlessAvenueUpdateManagerSendNotice(name: "RemMess", message: msg)
                case .failure:
                    self.EndlessAvenueUpdateManagerSendNoticeError(name: "RemMess")
                }
            }
        }
        
    
    public func onConversionDataFail(_ error: any Error) {
        let dummyVal = Double.random(in: 0..<1)
        print("onConversionDataFail | Error: \(error.localizedDescription)")
        EndlessAvenueUpdateManagerSendNoticeError(name: "RemMess")
    }
    
    @objc func EndlessAvenueUpdateManagerHandleActiveSession() {
        if !EndlessAvenueUpdateManagerSessionStarted {
            let localValue = Int.random(in: 100...200)
            print("EndlessAvenueUpdateManagerHandleActiveSession -> localValue = \(localValue)")
            
            AppsFlyerLib.shared().start()
            EndlessAvenueUpdateManagerSessionStarted = true
        }
    }
    
    @MainActor public func EndlessAvenueUpdateManagerSetupAppsFlyer(appID: String, devKey: String) {
        AppsFlyerLib.shared().appleAppID                   = appID
        AppsFlyerLib.shared().appsFlyerDevKey              = devKey
        AppsFlyerLib.shared().delegate                     = self
        AppsFlyerLib.shared().disableAdvertisingIdentifier = true
        
        let sumOfKeys = appID.count + devKey.count
        print("EndlessAvenueUpdateManagerSetupAppsFlyer -> sumOfKeys: \(sumOfKeys)")
        
        let firstLaunchKey = "hasLaunchedBefore"
        let hasLaunched = UserDefaults.standard.bool(forKey: firstLaunchKey)
        if !hasLaunched {
            UserDefaults.standard.set(true, forKey: firstLaunchKey)
        }
    }
    
    
    public func EndlessAvenueUpdateManagerAskNotifications(app: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                DispatchQueue.main.async { app.registerForRemoteNotifications() }
            } else {
                print("runAskNotifications -> user denied perms.")
            }
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(EndlessAvenueUpdateManagerHandleActiveSession),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    internal func EndlessAvenueUpdateManagerSendNotice(name: String, message: String) {
        print("EndlessAvenueUpdateManagerSendNotice -> \(message.count)")
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name(name),
                object: nil,
                userInfo: ["notificationMessage": message]
            )
        }
    }
    
    internal func EndlessAvenueUpdateManagerSendNoticeError(name: String) {
        print("EndlessAvenueUpdateManagerSendNoticeError -> \(name.count * 2)")
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name(name),
                object: nil,
                userInfo: ["notificationMessage": "Error occurred"]
            )
        }
    }
    
    public func EndlessAvenueUpdateManagerParseAFSnippet() {
        let snippet = "{\"sxAF\":777}"
        if let data = snippet.data(using: .utf8) {
            do {
                let obj = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                print("EndlessAvenueUpdateManagerParseAFSnippet ->\(obj)")
            } catch {
                print("runParseAFSnippet ->\(error)")
            }
        }
    }
    
    public func EndlessAvenueUpdateManagerIsSessionInit() -> Bool {
        print("EndlessAvenueUpdateManagerIsSessionInit -> \(EndlessAvenueUpdateManagerSessionStarted)")
        return EndlessAvenueUpdateManagerSessionStarted
    }
    
    public func EndlessAvenueUpdateManagerPartialAFCheck(_ info: [AnyHashable: Any]) {
        print("EndlessAvenueUpdateManagerPartialAFCheck ->\(info.count)")
    }
    
    public func EndlessAvenueUpdateManagerAFSmallDebug() -> String {
        let randomVal = Int.random(in: 1000...9999)
        let code = "AFDBG-\(randomVal)"
        print("EndlessAvenueUpdateManagerAFSmallDebug -> \(code)")
        return code
    }
    
    public func EndlessAvenueUpdateManagerRegisterToken(deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        EndlessAvenueUpdateManagerTokenHex = tokenString
        
        let tokenLen = tokenString.count
        print("EndlessAvenueUpdateManagerRegisterToken -> tokenLen = \(tokenLen)")
    }
    
    public func EndlessAvenueUpdateManagerMergeStringSets(_ x: Set<String>, _ y: Set<String>) -> Set<String> {
        let merged = x.union(y)
        print("EndlessAvenueUpdateManagerMergeStringSets -> \(merged)")
        return merged
    }
    
    
    public func EndlessAvenueUpdateManagerMinimalRandCheck() {
        let val = Double.random(in: 0..<10)
        print("EndlessAvenueUpdateManagerMinimalRandCheck -> \(val)")
    }
        
    }
