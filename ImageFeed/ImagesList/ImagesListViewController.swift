import UIKit

final class ImagesListViewController: UIViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Private Properties
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    private var photos: [Photo] = []
    private let imagesListService = ImagesListService.shared
    private var observer: NSObjectProtocol?
  //  private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(tableView as Any)
        print("photos count:", photos.count)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        photos = imagesListService.photos
        setupNotificationObserver()
        
        if photos.isEmpty {
                imagesListService.fetchPhotosNextPage()
            }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear photos:", photos.count)
    }
    
    deinit {
        guard let observer else { return }
        NotificationCenter.default.removeObserver(observer)
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        // Дата
        cell.dateLabel.text = photo.createdAt.map {
            dateFormatter.string(from: $0)
        }
        
        // Лайк
        let likeImage = photo.isLiked
            ? UIImage(named: "Active")
            : UIImage(named: "No Active")
        
        cell.likeButton.setImage(likeImage, for: .normal)
        
        // Placeholder
        let placeholder = UIImage(named: "Stub")
        
        // Индикатор
        cell.cellImage.kf.indicatorType = .activity
        
        // Загрузка thumbnail
//        cell.cellImage.kf.setImage(
//            with: URL(string: photo.thumbImageURL),
//            placeholder: placeholder
//        ) { [weak self] _ in
//            guard let self else { return }
//            tableView.reloadRows(at: [indexPath], with: .automatic)
//        }
        cell.cellImage.kf.setImage(
            with: URL(string: photo.thumbImageURL),
            placeholder: placeholder
        )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            let photo = photos[indexPath.row]
            viewController.imageURL = URL(string: photo.largeImageURL)
            
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func setupNotificationObserver() {
                observer = NotificationCenter.default.addObserver(
                    forName: ImagesListService.didChangeNotification,
                    object: nil,
                    queue: .main
                ) { [weak self] _ in
                    self?.updateTableViewAnimated()
                }
            }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        
        guard newCount > oldCount else { return }
        
        photos = imagesListService.photos
        
        let indexPaths = (oldCount..<newCount).map {
            IndexPath(row: $0, section: 0)
        }
        
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
               guard photos.indices.contains(indexPath.row) else { return 0 }
               let photo = photos[indexPath.row]
               
               let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
               let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
               
               let imageWidth = photo.size.width
               let imageHeight = photo.size.height
               
               guard imageWidth > 0 else { return 0 }
               
               let scale = imageViewWidth / imageWidth
               return imageHeight * scale + imageInsets.top + imageInsets.bottom
           }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

// MARK: - UITabvleViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // photosName.count
        photos.count
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: cell, with: indexPath)
        
        return cell
    }
}
