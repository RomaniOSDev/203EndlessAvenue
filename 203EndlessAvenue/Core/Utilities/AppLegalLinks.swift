import Foundation
import UIKit

enum AppLegalURL: String {
    case privacyPolicy = "https://endless203avenue.site/privacy/237"
    case termsOfService = "https://endless203avenue.site/terms/237"

    var url: URL? {
        URL(string: rawValue)
    }

    static func open(_ link: AppLegalURL) {
        guard let url = link.url else { return }
        UIApplication.shared.open(url)
    }
}
