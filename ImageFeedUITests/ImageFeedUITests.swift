
import XCTest

final class ImageFeedUITests: XCTestCase {
    
    private var app = XCUIApplication() // переменная приложения
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    private func typeSlowly(_ text: String) {
        for character in text {
            app.typeText(String(character))
            usleep(120_000)
        }
    }
    
    let login = ""
    let password = ""
    
    func testAuth() throws {
        app.launchArguments = ["Reset"]
        app.launch()
        
        
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
        authButton.tap()
        
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 10))
        
        
        let loginTextField = webView.textFields.element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        loginTextField.typeText(login)
        
        
        if app.toolbars.buttons["Done"].exists {
            app.toolbars.buttons["Done"].tap()
        }
        
        
        let passwordTextField = webView.secureTextFields.element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5))
        
        typeSlowly(password)
        
        
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()
        
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        
        let tablesQuery = app.tables.firstMatch
        XCTAssertTrue(tablesQuery.waitForExistence(timeout: 10))
        
        let firstCell = tablesQuery.cells.element(boundBy: 0)
        
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
        
        let cellToLike = tablesQuery.cells.element(boundBy: 1)
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 5))
        while !cellToLike.isHittable {
            tablesQuery.swipeUp()
        }
        
        let likeButton = cellToLike.buttons["likeButton"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5))
        
        likeButton.tap()
        likeButton.tap()
        
        cellToLike.tap()
        
        let image = app.scrollViews.images.firstMatch
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        
        // Zoom in
        image.pinch(withScale: 3, velocity: 1)
        
        // Zoom out
        image.pinch(withScale: 0.5, velocity: -1)
        
        let backButton = app.buttons["Backward"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        backButton.tap()
    }
    
    func testProfile() throws {
        
        let profileTab = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(profileTab.waitForExistence(timeout: 15))
        profileTab.tap()
        sleep(3)
        XCTAssertTrue(app.staticTexts["Name Lastname"].exists)
        XCTAssertTrue(app.staticTexts["username"].exists)
        
        let logoutButton = app.buttons["logout button"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5))
        logoutButton.tap()
        
        let alert = app.alerts["Пока, пока!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        
        let yesButton = alert.buttons["Да"]
        XCTAssertTrue(yesButton.exists)
        yesButton.tap()
        
        
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 10))
    }
    
}
