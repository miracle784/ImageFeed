import UIKit
//final class TabBarController: UITabBarController {
//       override func awakeFromNib() {
//           super.awakeFromNib()
//           let storyboard = UIStoryboard(name: "Main", bundle: .main)
//           let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
//           let profileViewController = ProfileViewController()
//           profileViewController.tabBarItem = UITabBarItem(
//               title: "", 
//               image: UIImage(named: "tab_profile_active"),
//               selectedImage: nil
//           )
//           self.viewControllers = [imagesListViewController, profileViewController]
//       }
//   }

//final class TabBarController: UITabBarController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        tabBar.isTranslucent = false
//        tabBar.backgroundColor = .ypBlack
//    }
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//
//        let storyboard = UIStoryboard(name: "Main", bundle: .main)
//
//        let imagesListVC = storyboard
//            .instantiateViewController(withIdentifier: "ImagesListViewController")
//
//        let profileVC = storyboard
//            .instantiateViewController(withIdentifier: "ProfileViewController")
//
//        imagesListVC.tabBarItem = UITabBarItem(
//            title: "",
//            image: UIImage(named: "tab_editorial_active"),
//            selectedImage: nil
//        )
//
//        profileVC.tabBarItem = UITabBarItem(
//            title: "",
//            image: UIImage(named: "tab_profile_active"),
//            selectedImage: nil
//        )
//
//        self.viewControllers = [imagesListVC, profileVC]
//    }
//}

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.isTranslucent = false
        tabBar.backgroundColor = .ypBlack
        
        setupTabs()
    }

    private func setupTabs() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)

        // 🔹 Лента из storyboard
        let imagesListVC = storyboard
            .instantiateViewController(withIdentifier: "ImagesListViewController")

        imagesListVC.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_editorial_active"),
            selectedImage: nil
        )

        // 🔹 Профиль полностью кодом
        let profileVC = ProfileViewController()
        profileVC.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )

        viewControllers = [imagesListVC, profileVC]
    }
}
