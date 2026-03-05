import UIKit
import Kingfisher

final class ProfileViewController: UIViewController, ProfileViewProtocol {
    private var presenter: ProfilePresenterProtocol! 
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    // MARK: - UI Elements
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .avatar)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = .systemFont(ofSize: 23, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var loginLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "Exit"), for: .normal)
        button.tintColor = .ypRed
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return button
    }()
    
 
  
    private var skeletonLayers: [CAGradientLayer] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        showSkeleton()
        setupAccessibilityIdentifiers()
        presenter?.viewDidLoad()
 
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        skeletonLayers.forEach { layer in
            layer.frame = layer.superlayer?.bounds ?? .zero
        }
    }
    private func setupAccessibilityIdentifiers() {
        nameLabel.accessibilityIdentifier = "Name Lastname"
        loginLabel.accessibilityIdentifier = "username"
        backButton.accessibilityIdentifier = "logout button"
    }
    
    private func showSkeleton() {
        view.layoutIfNeeded()

        let avatarSkeleton = makeSkeletonLayer(for: imageView, cornerRadius: 35)
        imageView.layer.addSublayer(avatarSkeleton)
        skeletonLayers.append(avatarSkeleton)

        let nameSkeleton = makeSkeletonLayer(for: nameLabel, cornerRadius: 8)
        nameLabel.layer.addSublayer(nameSkeleton)
        skeletonLayers.append(nameSkeleton)

        let loginSkeleton = makeSkeletonLayer(for: loginLabel, cornerRadius: 8)
        loginLabel.layer.addSublayer(loginSkeleton)
        skeletonLayers.append(loginSkeleton)

        let bioSkeleton = makeSkeletonLayer(for: descriptionLabel, cornerRadius: 8)
        descriptionLabel.layer.addSublayer(bioSkeleton)
        skeletonLayers.append(bioSkeleton)
    }
   
    private func hideSkeleton() {
        skeletonLayers.forEach { $0.removeFromSuperlayer() }
        skeletonLayers.removeAll()
    }
    
    
    // MARK: - Setup
    
    private func setupView() {
        view.backgroundColor = .ypBlack
    }
    
    private func makeSkeletonLayer(for view: UIView, cornerRadius: CGFloat) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.cornerRadius = cornerRadius
        
        gradient.colors = [
            UIColor(white: 0.85, alpha: 1).cgColor,
            UIColor(white: 0.75, alpha: 1).cgColor,
            UIColor(white: 0.85, alpha: 1).cgColor
        ]
        
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.locations = [0, 0.5, 1]
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1, -0.5, 0]
        animation.toValue = [1, 1.5, 2]
        animation.duration = 1.2
        animation.repeatCount = .infinity
        
        gradient.add(animation, forKey: "skeletonAnimation")
        
        return gradient
    }
   
    private func setupLayout() {
        view.addSubview(imageView)
        view.addSubview(nameLabel)
        view.addSubview(loginLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            
            // Avatar
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            // Name
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            // Login
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            // Description
            descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            // Back button
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            backButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            backButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }

    func displayAvatar(url: URL?) {
        guard let url else {
            hideSkeleton()
            return
        }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        
        imageView.kf.setImage(
            with: url,
            options: [.processor(processor)]
        ) { [weak self] _ in
            self?.hideSkeleton()
        }
    }

    func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name.isEmpty
            ? "Имя не указано"
            : profile.name
        
        loginLabel.text = profile.loginName.isEmpty
            ? "@неизвестный_пользователь"
            : profile.loginName
        
        descriptionLabel.text = (profile.bio?.isEmpty ?? true)
            ? "Профиль не заполнен"
            : profile.bio
        
        hideSkeleton()
    }
    
    
    // MARK: - Actions
    
    @objc
    private func didTapBackButton() {
        print("Logout tapped")
        presenter.didTapLogout()
    }
    
     func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )


         let logoutAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
                 self?.presenter.confirmLogout()
             }
        
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel)
      
        alert.addAction(logoutAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
}
