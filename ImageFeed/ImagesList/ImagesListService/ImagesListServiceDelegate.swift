import Foundation

protocol ImagesListServiceDelegate: AnyObject {
    func imagesListServiceDidUpdatePhotos(
        _ service: ImagesListServiceProtocol
    )
    
    func imagesListServiceDidUpdatePhoto(
        _ service: ImagesListServiceProtocol,
        at index: Int
    )
}
