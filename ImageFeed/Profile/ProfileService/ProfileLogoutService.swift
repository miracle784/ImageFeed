import Foundation
import WebKit

final class ProfileLogoutService: ProfileLogoutServiceProtocol {
    
    static let shared = ProfileLogoutService()
    
    private init() {}
    
    func logout() {
        
        OAuth2TokenStorage.shared.token = nil
        
        
        ProfileService.shared.resetProfile()
        ProfileImageService.shared.resetAvatar()
        ImagesListService.shared.resetImages()
        
      
        cleanCookies()
        
        
        switchToSplashScreen()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()
        ) { records in
            
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(
                    ofTypes: record.dataTypes,
                    for: [record],
                    completionHandler: {}
                )
            }
        }
    }
    
    private func switchToSplashScreen() {
        guard let window = UIApplication.shared.windows.first else { return }
        let splashVC = SplashViewController()
        window.rootViewController = splashVC
    }
}
