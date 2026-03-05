
import Foundation

protocol ImagesListViewProtocol: AnyObject {
    func insertRows(at indexPaths: [IndexPath])
        func reloadRow(at index: Int)
        func showError(message: String)

}
