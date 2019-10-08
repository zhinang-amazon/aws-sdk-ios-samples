//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AWSMobileClient
import XCTest

class DropInUITest: XCTestCase {
    var app: XCUIApplication?

    override func setUp() {
        continueAfterFailure = false
        app = UIActions.launchApp()
        UIActions.tapSignOut()
    }

    override func tearDown() {}

    func testSignInUIAppears() {
        // Given the app launch succeeds, When the user is signed-out, then present the drop-in SignIn UI

        XCTAssertTrue(UIElements.SignInScreen.navigationBar.waitForExistence(timeout: uiTimeout))

        let tablesQuery = app!.tables
        XCTAssertTrue(tablesQuery.staticTexts["User Name"].exists)
        XCTAssertTrue(tablesQuery.staticTexts["Password"].exists)
        XCTAssertTrue(app!.buttons["Sign In"].exists)
    }
}
