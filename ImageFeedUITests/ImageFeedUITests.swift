
import XCTest

final class ImageFeedUITests: XCTestCase {
    
    private var app = XCUIApplication() // переменная приложения
    
    override func setUpWithError() throws {
        continueAfterFailure = false

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
        app.launch()
        let tablesQuery = app.tables
        
       
        XCTAssertTrue(tablesQuery.element.waitForExistence(timeout: 10))
        
    
        tablesQuery.element.swipeUp()
   
        let likeButton = tablesQuery.buttons["like button off"].firstMatch
        

        XCTAssertTrue(likeButton.waitForExistence(timeout: 10))
   
        let coordinate = likeButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        
        if likeButton.frame.origin.y.isInfinite {
            app.swipeUp()
        }
        
        coordinate.tap()
        
        let likeButtonOn = tablesQuery.buttons["like button on"].firstMatch
        XCTAssertTrue(likeButtonOn.waitForExistence(timeout: 5))
   
        likeButtonOn.tap()
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5))
  
        tablesQuery.cells.element(boundBy: 1).tap()
        
       
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        app.buttons["Backward"].tap()
    }
    
    func testProfile() throws {
        app.launch()
        sleep(3)
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
