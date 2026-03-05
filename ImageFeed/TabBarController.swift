import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.isTranslucent = false
        tabBar.backgroundColor = .ypBlack
        
        setupTabs()
    }

    private func setupTabs() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)

        guard let imagesListVC = storyboard
            .instantiateViewController(
                withIdentifier: "ImagesListViewController"
            ) as? ImagesListViewController else {
            assertionFailure("Failed to instantiate ImagesListViewController")
            return
        }
        
        let service = ImagesListService.shared
        let presenter = ImagesListPresenter(service: service)

        imagesListVC.presenter = presenter
        presenter.view = imagesListVC
        
        imagesListVC.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_editorial_active"),
            selectedImage: nil
        )

        let profileVC = ProfileViewController()
        let profilePresenter = ProfilePresenter()
        profileVC.configure(profilePresenter)
        profileVC.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )

        viewControllers = [imagesListVC, profileVC]
    }
}
