@testable import ImageFeed
import XCTest
final class ImagesListTests: XCTestCase {
    func testPresenterCallsViewDidLoad() {
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        
        viewController.presenter = presenter
        presenter.view = viewController
        
        viewController.setValue(UITableView(), forKey: "tableView")
        
        _ = viewController.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsWillDisplayRow() {
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()

        viewController.presenter = presenter
        presenter.view = viewController

        let tableView = UITableView()
        viewController.setValue(tableView, forKey: "tableView")

        _ = viewController.view

        let indexPath = IndexPath(row: 5, section: 0)

        viewController.tableView(
            tableView,
            willDisplay: UITableViewCell(),
            forRowAt: indexPath
        )

        XCTAssertEqual(presenter.willDisplayCalledWith, 5)
    }
    
    func testLikeButtonCallsPresenter() {
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()

        viewController.presenter = presenter
        presenter.view = viewController

        let tableView = TableViewIndexPathSpy()
        tableView.stubIndexPath = IndexPath(row: 3, section: 0)

        viewController.setValue(tableView, forKey: "tableView")

        _ = viewController.view

        let cell = ImagesListCell()

        viewController.imageListCellDidTapLike(cell)

        XCTAssertEqual(presenter.didTapLikeCalledWith, 3)
    }
    
    func testPresenterReloadRowOnPhotoUpdate() {
        let service = ImagesListServiceMock()
        let view = ImagesListViewSpy()
        let presenter = ImagesListPresenter(service: service)
        presenter.view = view

        let exp = expectation(description: "reloadRow called")

        view.onReload = {
            exp.fulfill()
        }

        presenter.imagesListServiceDidUpdatePhoto(service, at: 4)

        wait(for: [exp], timeout: 1)

        XCTAssertEqual(view.reloadRowCalledWith, 4)
    }
    
    func testPresenterShowsErrorWhenLikeFails() {
        let service = ImagesListServiceMock()
        service.shouldFailLike = true
        service.photos = [Photo.stub()]

        let view = ImagesListViewSpy()
        let presenter = ImagesListPresenter(service: service)
        presenter.view = view

        let exp = expectation(description: "error shown")

        view.onError = {
            exp.fulfill()
        }

        presenter.didTapLike(at: 0)

        wait(for: [exp], timeout: 1)

        XCTAssertEqual(view.errorMessage, "Не удалось поставить лайк")
    }
}

final class ImagesListServiceMock: ImagesListServiceProtocol {

    weak var delegate: ImagesListServiceDelegate?

    var photos: [Photo] = []

    var shouldFailLike = false

    func fetchPhotosNextPage() {}

    func changeLike(
        photoId: String,
        isLike: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        if shouldFailLike {
            completion(.failure(NSError(domain: "", code: 0)))
        } else {
            completion(.success(()))
        }
    }
}

final class TableViewIndexPathSpy: UITableView {

    var stubIndexPath: IndexPath?

    override func indexPath(for cell: UITableViewCell) -> IndexPath? {
        return stubIndexPath
    }
}
