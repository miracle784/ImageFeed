//import UIKit
//import Kingfisher
//
//final class SingleImageViewController: UIViewController {
//
//    var imageURL: URL?
//    
//    @IBOutlet private var imageView: UIImageView!
//    
//    @IBOutlet weak var scrollView: UIScrollView!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        assert(imageURL != nil, "imageURL must be set before presenting SingleImageViewController")
//        scrollView.delegate = self
//        scrollView.minimumZoomScale = 0.1
//        scrollView.maximumZoomScale = 1.25
//        
//        setupActivityIndicator()
//        loadImage()
//    }
//    
//    private let activityIndicator: UIActivityIndicatorView = {
//                let indicator = UIActivityIndicatorView(style: .large)
//                indicator.color = .white
//                indicator.translatesAutoresizingMaskIntoConstraints = false
//                indicator.hidesWhenStopped = true
//                return indicator
//            }()
//    
//    private func setupActivityIndicator() {
//                view.addSubview(activityIndicator)
//                NSLayoutConstraint.activate([
//                    activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//                    activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//                ])
//            }
//    
//    private func loadImage() {
//                guard let url = imageURL else { return }
//                activityIndicator.startAnimating()
//                
//                imageView.kf.setImage(with: url) { [weak self] result in
//                    guard let self = self else { return }
//                    self.activityIndicator.stopAnimating()
//                    
//                    switch result {
////                    case .success(let value):
////                        self.imageView.frame.size = value.image.size
////                        self.rescaleAndCenterImageInScrollView(image: value.image)
//                    case .success(let value):
//                        self.imageView.image = value.image
//                        self.imageView.sizeToFit()
//                        self.rescaleAndCenterImageInScrollView(image: value.image)
//                    case .failure:
//                        self.showError()
//                    }
//                }
//            }
//    
//    private func showError() {
//        let alert = UIAlertController(
//            title: "Ошибка загрузки",
//            message: "Не удалось загрузить изображение",
//            preferredStyle: .alert
//        )
//        
//        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in self?.loadImage()})
//        alert.addAction(UIAlertAction(title: "Закрыть", style: .cancel))
//        
//        present(alert, animated: true)
//    }
//
//    
//    @IBAction func didTapShareButton() {
//        guard let image = imageView.image else { return }
//      //  guard let image else { return }
//        let share = UIActivityViewController(
//            activityItems: [image],
//            applicationActivities: nil
//        )
//        present(share, animated: true, completion: nil)
//        
//    }
//    @IBAction func didTapBackButton() {
//        dismiss(animated: true, completion: nil)
//    }
//}
//
//extension SingleImageViewController: UIScrollViewDelegate {
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        imageView
//    }
//    private func rescaleAndCenterImageInScrollView(image: UIImage) {
//        let minZoomScale = scrollView.minimumZoomScale
//        let maxZoomScale = scrollView.maximumZoomScale
//        view.layoutIfNeeded()
//        let visibleRectSize = scrollView.bounds.size
//        let imageSize = image.size
//        let hScale = visibleRectSize.width / imageSize.width
//        let vScale = visibleRectSize.height / imageSize.height
//        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
//        scrollView.setZoomScale(scale, animated: false)
//        scrollView.layoutIfNeeded()
//        let newContentSize = scrollView.contentSize
//        let x = (newContentSize.width - visibleRectSize.width) / 2
//        let y = (newContentSize.height - visibleRectSize.height) / 2
//        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
//    }
//}

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
        
        assert(imageURL != nil, "imageURL must be set before presenting SingleImageViewController")
        
        setupScrollView()
        setupActivityIndicator()
        loadImage()
    }
    
//    deinit {
//        imageView.kf.cancelDownloadTask()
//    }
    
    // MARK: - Setup
    
    private func setupScrollView() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
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
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let visibleSize = scrollView.bounds.size
        let imageSize = image.size
        
        let hScale = visibleSize.width / imageSize.width
        let vScale = visibleSize.height / imageSize.height
        
        let scale = min(max(scrollView.minimumZoomScale,
                            min(hScale, vScale)),
                        scrollView.maximumZoomScale)
        
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        
        let contentSize = scrollView.contentSize
        
        let offsetX = max((contentSize.width - visibleSize.width) / 2, 0)
        let offsetY = max((contentSize.height - visibleSize.height) / 2, 0)
        
        scrollView.setContentOffset(CGPoint(x: offsetX, y: offsetY), animated: false)
    }
}
