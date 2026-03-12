import XCTest

final class AppFlowUITests: XCTestCase {
    func testLoginScreenElementsVisible() throws {
        try XCTSkipUnless(isBackendReachable(), "Backend is not reachable at 127.0.0.1:8080")
        let app = launchAppForUITest()

        XCTAssertTrue(app.textFields["server_url_field"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.textFields["username_field"].exists)
        XCTAssertTrue(app.secureTextFields["password_field"].exists)
        XCTAssertTrue(app.buttons["auth_submit_button"].exists)
        XCTAssertTrue(app.buttons["auth_toggle_button"].exists)
    }

    func testRegisterFlowEntersMainTabs() throws {
        try XCTSkipUnless(isBackendReachable(), "Backend is not reachable at 127.0.0.1:8080")

        let app = launchAppForUITest()

        let usernameField = app.textFields["username_field"]
        XCTAssertTrue(usernameField.waitForExistence(timeout: 10))

        let toggleButton = app.buttons["auth_toggle_button"]
        XCTAssertTrue(toggleButton.exists)
        toggleButton.tap()

        let now = Int(Date().timeIntervalSince1970)
        let username = "ui_\(now)"
        let password = "Passw0rd_\(now)"

        usernameField.tap()
        usernameField.typeText(username)

        let passwordField = app.secureTextFields["password_field"]
        XCTAssertTrue(passwordField.exists)
        passwordField.tap()
        passwordField.typeText(password)

        let submit = app.buttons["auth_submit_button"]
        XCTAssertTrue(submit.isEnabled)
        submit.tap()

        XCTAssertTrue(app.tabBars.buttons["时间线"].waitForExistence(timeout: 20))
        XCTAssertTrue(app.tabBars.buttons["搜索"].exists)
        XCTAssertTrue(app.tabBars.buttons["我的订阅"].exists)
    }

    func testSearchAndSubscribeFlow() throws {
        try XCTSkipUnless(isBackendReachable(), "Backend is not reachable at 127.0.0.1:8080")
        let app = launchAppForUITest()

        let usernameField = app.textFields["username_field"]
        XCTAssertTrue(usernameField.waitForExistence(timeout: 10))

        let toggleButton = app.buttons["auth_toggle_button"]
        toggleButton.tap()

        let now = Int(Date().timeIntervalSince1970)
        usernameField.tap()
        usernameField.typeText("ui_sub_\(now)")

        let passwordField = app.secureTextFields["password_field"]
        passwordField.tap()
        passwordField.typeText("Passw0rd_\(now)")

        app.buttons["auth_submit_button"].tap()
        XCTAssertTrue(app.tabBars.buttons["搜索"].waitForExistence(timeout: 20))

        app.tabBars.buttons["搜索"].tap()

        let keywordField = app.textFields["search_keyword_field"]
        XCTAssertTrue(keywordField.waitForExistence(timeout: 10))
        keywordField.tap()
        keywordField.typeText("bible")
        keywordField.typeText("\n")

        let firstResultTitle = app.staticTexts["search_podcast_title"].firstMatch
        if !firstResultTitle.waitForExistence(timeout: 10) {
            app.buttons["search_submit_button"].tap()
        }
        XCTAssertTrue(firstResultTitle.waitForExistence(timeout: 20))

        let subscribeButton = app.buttons["subscribe_button"].firstMatch
        XCTAssertTrue(subscribeButton.waitForExistence(timeout: 10))
        subscribeButton.tap()

        app.tabBars.buttons["我的订阅"].tap()
        XCTAssertTrue(app.staticTexts["subscription_podcast_title"].waitForExistence(timeout: 20))
    }

    private func launchAppForUITest() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-ui-test-reset"]
        app.launchEnvironment["UI_TEST_BACKEND_URL"] = "http://127.0.0.1:8080/api/v1"
        app.launch()
        return app
    }

    private func isBackendReachable() -> Bool {
        guard let url = URL(string: "http://127.0.0.1:8080/health") else {
            return false
        }

        let semaphore = DispatchSemaphore(value: 0)
        var reachable = false

        URLSession.shared.dataTask(with: url) { _, response, _ in
            if let http = response as? HTTPURLResponse {
                reachable = (200...299).contains(http.statusCode)
            }
            semaphore.signal()
        }.resume()

        _ = semaphore.wait(timeout: .now() + 5)
        return reachable
    }

}
