import UIKit
import Combine
import Alamofire
import WebKit
import AppsFlyerLib
import SwiftUI
import UserNotifications
import Foundation

public class EndlessAvenueUpdateManager: NSObject, @preconcurrency AppsFlyerLibDelegate {
    internal var lockRef: String = ""
    internal var appsRefKey: String = ""
    internal var tokenRef: String = ""
    internal var paramRef: String = ""
    
    @AppStorage("EndlessAvenueUpdateManagerInitial") var EndlessAvenueUpdateManagerInitial: String?
    @AppStorage("EndlessAvenueUpdateManagerStatus")  var EndlessAvenueUpdateManagerStatus: Bool = false
    @AppStorage("EndlessAvenueUpdateManagerFinal")   var EndlessAvenueUpdateManagerFinal: String?
    
    @MainActor public static let shared = EndlessAvenueUpdateManager()
    
    internal var appIDRef: String = ""
    internal var langRef: String = ""
    internal var EndlessAvenueUpdateManagerWindow: UIWindow?
    
    internal var EndlessAvenueUpdateManagerSessionStarted = false
    internal var EndlessAvenueUpdateManagerTokenHex = ""
    internal var EndlessAvenueUpdateManagerSession: Session
    internal var EndlessAvenueUpdateManagerCollector = Set<AnyCancellable>()
    
    private override init() {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 20
        cfg.timeoutIntervalForResource = 20
        let debugRand = Int.random(in: 1...999)
        print("EndlessAvenueUpdateManager init -> \(debugRand)")
        self.EndlessAvenueUpdateManagerSession = Alamofire.Session(configuration: cfg)
        super.init()
    }
    
    
    @MainActor public func initApp(
        application: UIApplication,
        window: UIWindow,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        EndlessAvenueUpdateManagerAskNotifications(app: application)
        
        let randomVal = Int.random(in: 10...99) + 3
        print("Run: \(randomVal)")
        
        appsRefKey = "appData"
        appIDRef   = "appId"
        langRef    = "appLng"
        tokenRef   = "appTk"
        
        lockRef  = "https://nnwirjke.lol/privacy"
        paramRef = "data"
        
        
        EndlessAvenueUpdateManagerWindow = window
        
        EndlessAvenueUpdateManagerSetupAppsFlyer(appID: "6775502030", devKey: "LcHBxTZtYqSPr7HQc6spmA")
        
        completion(.success("Initialization completed successfully"))
    }
    
    }
