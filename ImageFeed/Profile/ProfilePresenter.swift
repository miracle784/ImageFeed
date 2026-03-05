import Foundation

final class ProfilePresenter: ProfilePresenterProtocol {
    
    weak var view: ProfileViewProtocol?
    private var profileImageServiceObserver: NSObjectProtocol?
    private let profileService: ProfileServiceProtocol
    private let tokenStorage: OAuth2TokenStorageProtocol
    private let logoutService: ProfileLogoutServiceProtocol
    
    init(
        profileService: ProfileServiceProtocol = ProfileService.shared,
        tokenStorage: OAuth2TokenStorageProtocol = OAuth2TokenStorage.shared,
        logoutService: ProfileLogoutServiceProtocol = ProfileLogoutService.shared
    ) {
        self.profileService = profileService
        self.tokenStorage = tokenStorage
        self.logoutService = logoutService
    }
    func viewDidLoad() {
        observeAvatarChanges()
        loadProfile()
    }
    
    func didTapLogout() {
        view?.showLogoutConfirmation()
    }
    func confirmLogout() {
        logoutService.logout()
    }
    
    private func loadProfile() {
        guard let token = tokenStorage.token else { return }
        
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self.view?.updateProfileDetails(profile: profile)
                    ProfileImageService.shared.fetchProfileImageURL(
                                        username: profile.username
                                    ) { _ in }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    private func observeAvatarChanges() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard
                let self,
                let urlString = ProfileImageService.shared.avatarURL,
                let url = URL(string: urlString)
            else {
                self?.view?.displayAvatar(url: nil)
                return
            }
            
            self.view?.displayAvatar(url: url)
        }
    }
}
