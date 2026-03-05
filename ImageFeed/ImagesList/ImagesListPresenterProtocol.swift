import Foundation
protocol ImagesListPresenterProtocol {
    var photosCount: Int { get }
    
    func viewDidLoad()
    func photo(at index: Int) -> Photo
    func didTapLike(at index: Int)
    func willDisplayCell(at index: Int)
}
