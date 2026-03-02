

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    
    // MARK: - Public Properties
    
    var imageURL: URL?
    
    // MARK: - IB Outlets
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    // MARK: - Private Properties
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTransparentNavigationBar()
        assert(imageURL != nil, "imageURL must be set before presenting SingleImageViewController")
        
        setupScrollView()
        setupActivityIndicator()
        loadImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
    }
    
    private func configureTransparentNavigationBar() {
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    // MARK: - Setup
    
    private func setupScrollView() {
        scrollView.delegate = self
        scrollView.maximumZoomScale = 3.0
    }
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Image Loading
    
    private func loadImage() {
        guard let url = imageURL else { return }
        
        activityIndicator.startAnimating()
        
        imageView.kf.setImage(with: url) { [weak self] result in
            guard let self = self else { return }
            
            self.activityIndicator.stopAnimating()
            
            switch result {
            case .success(let value):
                self.imageView.image = value.image
                self.imageView.sizeToFit()
                self.rescaleAndCenterImageInScrollView(image: value.image)
                
            case .failure:
                self.showError()
            }
        }
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        view.layoutIfNeeded()
        
        
        let visibleSize = scrollView.bounds.size
        let imageSize = image.size
        
        guard imageSize.width > 0, imageSize.height > 0 else { return }
        
        let hScale = visibleSize.width / imageSize.width
        let vScale = visibleSize.height / imageSize.height
        // let scale = min(hScale, vScale)
        let scale = max(hScale, vScale)
        scrollView.minimumZoomScale = scale
        scrollView.setZoomScale(scale, animated: false)
        
        scrollView.layoutIfNeeded()
        
        let offsetX = max((scrollView.contentSize.width - visibleSize.width) / 2, 0)
        let offsetY = max((scrollView.contentSize.height - visibleSize.height) / 2, 0)
        
        scrollView.setContentOffset(CGPoint(x: offsetX, y: offsetY), animated: false)
    }
    
    private func centerImage() {
        let visibleSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize
        
        let xInset = max((visibleSize.width - contentSize.width) / 2, 0)
        let yInset = max((visibleSize.height - contentSize.height) / 2, 0)
        
        scrollView.contentInset = UIEdgeInsets(
            top: yInset,
            left: xInset,
            bottom: yInset,
            right: xInset
        )
    }
    
    // MARK: - Error Handling
    
    private func showError() {
        let alert = UIAlertController(
            title: "Ошибка загрузки",
            message: "Не удалось загрузить изображение. Проверьте соединение с интернетом.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadImage()
        })
        
        alert.addAction(UIAlertAction(title: "Закрыть", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction private func didTapShareButton() {
        guard let image = imageView.image else { return }
        
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        present(share, animated: true)
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true)
    }
    
    // MARK: - Layout Updates
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let image = imageView.image else { return }
        rescaleAndCenterImageInScrollView(image: image)
    }
    
}


// MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
    
}
