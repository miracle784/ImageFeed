@testable import ImageFeed
import Foundation

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {

    weak var view: ImagesListViewProtocol?

    var viewDidLoadCalled = false
    var willDisplayCalledWith: Int?
    var didTapLikeCalledWith: Int?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func willDisplayCell(at index: Int) {
        willDisplayCalledWith = index
    }

    func didTapLike(at index: Int) {
        didTapLikeCalledWith = index
    }

    var photosCount: Int { 0 }
    func photo(at index: Int) -> Photo { Photo.stub() }
}
