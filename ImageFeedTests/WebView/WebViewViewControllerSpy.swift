
@testable import ImageFeed
import Foundation

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {

    var presenter: WebViewPresenterProtocol?
    var loadRequestCalled = false

    func load(request: URLRequest) {
        loadRequestCalled = true
    }

    func setProgressValue(_ newValue: Float) {
        // не нужен в этом тесте
    }

    func setProgressHidden(_ isHidden: Bool) {
        // не нужен в этом тесте
    }
}
