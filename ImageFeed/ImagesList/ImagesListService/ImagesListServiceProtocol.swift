
import Foundation

protocol ImagesListServiceProtocol: AnyObject { 
    var photos: [Photo] { get }
    var delegate: ImagesListServiceDelegate? { get set }
    
    func fetchPhotosNextPage()
    func changeLike(
        photoId: String,
        isLike: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}
