import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let description: String?
    let likedByUser: Bool
    let urls: UrlsResult
}

struct UrlsResult: Decodable {
    let thumb: String
    let full: String
}

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
                print("Ошибка загрузки фото:", error.localizedDescription)
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
}
