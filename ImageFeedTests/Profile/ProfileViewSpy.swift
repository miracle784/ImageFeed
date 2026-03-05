@testable import ImageFeed
import Foundation

final class ProfileViewSpy: ProfileViewProtocol {
    var onUpdateProfileDetails: (() -> Void)?
    var updateProfileDetailsCalled = false
    var showLogoutConfirmationCalled = false
    var displayAvatarCalled = false
    
    func updateProfileDetails(profile: Profile) {
        updateProfileDetailsCalled = true
        onUpdateProfileDetails?()
    }
    
    func displayAvatar(url: URL?) {
        displayAvatarCalled = true
    }
    
    func showLogoutConfirmation() {
        showLogoutConfirmationCalled = true
    }
}
