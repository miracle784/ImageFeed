import Foundation

extension PhotoResult {
    func toPhoto(dateFormatter: ISO8601DateFormatter) -> Photo {
        return Photo(
            id: id,
            size: CGSize(width: width, height: height),
            createdAt: createdAt.flatMap { dateFormatter.date(from: $0) },
            welcomeDescription: description,
            thumbImageURL: urls.thumb,
            largeImageURL: urls.full,
            isLiked: likedByUser
        )
    }
}

final class ImagesListService {
    
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var likeTask: URLSessionTask?
    private var lastLoadedPage: Int?
    private let dateFormatter = ISO8601DateFormatter()
    
    private init() {}
    
    func fetchPhotosNextPage() {
        
        if task != nil { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let request = makeRequest(page: nextPage) else { return }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            
            guard let self = self else { return }
            self.task = nil
            
            switch result {
                
            case .success(let results):
                let newPhotos = results.map { $0.toPhoto(dateFormatter: self.dateFormatter) }
                
                self.photos.append(contentsOf: newPhotos)
                self.lastLoadedPage = nextPage
                
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self
                )
                
            case .failure(let error):
                print("[ImagesListService.fetchPhotosNextPage]: Network error page=\(nextPage) error=\(error)")
                
            }
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeRequest(page: Int) -> URLRequest? {
        
        guard let token = OAuth2TokenStorage.shared.token else { return nil }
        
        var components = URLComponents(string: "https://api.unsplash.com/photos")
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        guard let url = components?.url else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func changeLike(
        photoId: String,
        isLike: Bool,
        _ completion: @escaping (Result<Void, Error>) -> Void
    ) {
        likeTask?.cancel()
        
        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.data(for: request) { [weak self] result in
            guard let self = self else { return }
            self.likeTask = nil
            
            switch result {
            case .success:
                
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let oldPhoto = self.photos[index]
                    
                    let newPhoto = Photo(
                        id: oldPhoto.id,
                        size: oldPhoto.size,
                        createdAt: oldPhoto.createdAt,
                        welcomeDescription: oldPhoto.welcomeDescription,
                        thumbImageURL: oldPhoto.thumbImageURL,
                        largeImageURL: oldPhoto.largeImageURL,
                        isLiked: !oldPhoto.isLiked
                    )
                    
                    self.photos[index] = newPhoto
                }
                
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self
                )
                
                completion(.success(()))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        likeTask = task
        task.resume()
    }
    
    func resetImages() {
        photos = []
    }
}
