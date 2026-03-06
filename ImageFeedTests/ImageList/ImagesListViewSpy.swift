@testable import ImageFeed
import Foundation

final class ImagesListViewSpy: ImagesListViewProtocol {

    var insertedIndexPaths: [IndexPath] = []
    var reloadRowCalledWith: Int?
    var errorMessage: String?

    var onReload: (() -> Void)?
    var onError: (() -> Void)?
    func insertRows(at indexPaths: [IndexPath]) {
        insertedIndexPaths = indexPaths
    }

    func reloadRow(at index: Int) {
        reloadRowCalledWith = index
        onReload?()
    }

    func showError(message: String) {
        errorMessage = message
        onError?()
    }
}
