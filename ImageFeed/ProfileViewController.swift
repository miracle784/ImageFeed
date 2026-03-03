import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
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
    
    private var profileImageServiceObserver: NSObjectProtocol?
  
    private var skeletonLayers: [CAGradientLayer] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupLayout()
        
        showSkeleton()
        
        guard let token = OAuth2TokenStorage.shared.token else {
            return
        }

        ProfileService.shared.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    
                    
                    self.updateProfileDetails(profile: profile)
                    
                   
                    ProfileImageService.shared.fetchProfileImageURL(
                        username: profile.username
                    ) { _ in }
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
        

     
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updateAvatar()
            }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        skeletonLayers.forEach { layer in
            layer.frame = layer.superlayer?.bounds ?? .zero
        }
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
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let imageUrl = URL(string: profileImageURL)
        else {
            hideSkeleton()
            return
        }
        
        print("imageUrl: \(imageUrl)")
        
        let placeholderImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35) // Радиус для круга
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: imageUrl,
            placeholder: placeholderImage,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale), // Учитываем масштаб экрана
                .cacheOriginalImage, // Кэшируем оригинал
                .forceRefresh // Игнорируем кэш, чтобы обновить
            ]) { [weak self] result in
                self?.hideSkeleton()
                switch result {
                    // Успешная загрузка
                case .success(let value):
                    // Картинка
                    print(value.image)
                    
                    // Откуда картинка загружена:
                    // - .none — из сети.
                    // - .memory — из кэша оперативной памяти.
                    // - .disk — из дискового кэша.
                    print(value.cacheType)
                    
                    // Информация об источнике.
                    print(value.source)
                    
                    // В случае ошибки
                case .failure(let error):
                    print(error)
                }
            }
        
    }
    
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name.isEmpty
        ? "Имя не указано"
        : profile.name
        loginLabel.text = profile.loginName.isEmpty
        ? "@неизвестный_пользователь"
        : profile.loginName
        descriptionLabel.text = (profile.bio?.isEmpty ?? true)
        ? "Профиль не заполнен"
        : profile.bio
    }
    
    
    // MARK: - Actions
    
    @objc
    private func didTapBackButton() {
        print("Logout tapped")
        showLogoutAlert()
    }
    
    private func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )


        let logoutAction = UIAlertAction(title: "Да", style: .default) { _ in
            ProfileLogoutService.shared.logout()
        }
        
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel)

        alert.addAction(logoutAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
}
