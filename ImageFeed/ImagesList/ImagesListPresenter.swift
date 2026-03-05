import Foundation

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    weak var view: ImagesListViewProtocol?
    private let service: ImagesListServiceProtocol
    private var lastKnownPhotosCount: Int = 0
   
    init(service: ImagesListServiceProtocol) {
        
        self.service = service
        self.service.delegate = self
    }
    
    // MARK: - Data
    
    var photosCount: Int {
        service.photos.count
    }
    
    func photo(at index: Int) -> Photo {
        service.photos[index]
    }
    
    // MARK: - Lifecycle
    
    func viewDidLoad() {
        lastKnownPhotosCount = service.photos.count

            if service.photos.isEmpty {
                service.fetchPhotosNextPage()
            }
    }
    
    // MARK: - Pagination
    
    func willDisplayCell(at index: Int) {
        if index == service.photos.count - 1 {
            service.fetchPhotosNextPage()
        }
    }
    
    // MARK: - Like
    
    func didTapLike(at index: Int) {
        let photo = service.photos[index]
        
        service.changeLike(
            photoId: photo.id,
            isLike: !photo.isLiked
        ) { [weak self] result in
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if case .failure = result {
                    self.view?.showError(message: "Не удалось поставить лайк")
                }
            }
        }
    }
}

extension ImagesListPresenter: ImagesListServiceDelegate {
    
    func imagesListServiceDidUpdatePhotos(
        _ service: ImagesListServiceProtocol
    ) {
        let newCount = service.photos.count
        let oldCount = lastKnownPhotosCount
        lastKnownPhotosCount = newCount
        
        guard newCount > oldCount else { return }
        
        let indexPaths = (oldCount..<newCount).map {
            IndexPath(row: $0, section: 0)
        }
        
        view?.insertRows(at: indexPaths)
    }
    
    func imagesListServiceDidUpdatePhoto(
        _ service: ImagesListServiceProtocol,
        at index: Int
    ) {
        DispatchQueue.main.async {
            self.view?.reloadRow(at: index)
        }
    }
}
