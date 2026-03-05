import Foundation

protocol ProfileViewProtocol: AnyObject {
    func updateProfileDetails(profile: Profile)
    func displayAvatar(url: URL?)
    func showLogoutConfirmation()

}
