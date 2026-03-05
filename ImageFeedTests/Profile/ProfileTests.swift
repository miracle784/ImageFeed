@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {
    
    func test_viewDidLoad_callsUpdateProfileDetails() {
        // Given
        let viewSpy = ProfileViewSpy()
        let profileServiceStub = ProfileServiceStub()
        let tokenStorageStub = TokenStorageStub()
        
        tokenStorageStub.token = "test_token"
        
        let presenter = ProfilePresenter(
            profileService: profileServiceStub,
            tokenStorage: tokenStorageStub
        )
        
        presenter.view = viewSpy
        let expectation = expectation(description: "updateProfileDetails called")
        
        viewSpy.onUpdateProfileDetails = {
            expectation.fulfill()
        }
        
        // When
        presenter.viewDidLoad()
        
        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(viewSpy.updateProfileDetailsCalled)
    }
    
    
    @MainActor
    func testViewControllerCallsPresenterViewDidLoad() {
        // given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewController()
        viewController.configure(presenter)
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    @MainActor
    func testPresenterCallsViewOnLogoutTap() {
        // given
        let viewSpy = ProfileViewSpy()
        let presenter = ProfilePresenter()
        presenter.view = viewSpy
        
        // when
        presenter.didTapLogout()
        
        // then
        XCTAssertTrue(viewSpy.showLogoutConfirmationCalled)
    }
}

final class ProfileServiceStub: ProfileServiceProtocol {
    func fetchProfile(
        _ token: String,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        let profile = Profile(
            username: "test",
            name: "Test User",
            loginName: "@test",
            bio: "bio"
        )
        
        completion(.success(profile))
    }
}

final class TokenStorageStub: OAuth2TokenStorageProtocol {
    var token: String?
}
