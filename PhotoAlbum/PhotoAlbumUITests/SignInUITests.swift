//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AWSMobileClient
import XCTest

class SignInUITests: XCTestCase {
    var app: XCUIApplication?

    override func setUp() {
        continueAfterFailure = false
        app = UIActions.launchApp()
        UIActions.tapSignOut()
    }

    override func tearDown() {
        UIActions.tapSignOut()
    }

    func testSignInWithValidCredentials() {
        // Given the app launches, When valid sign in, then load the albums screen

        UIActions.signInWithValidCredentials()
        XCTAssertTrue(UIElements.AlbumsScreen.navigationBar.waitForExistence(timeout: networkTimeout))
    }

    func testSignInWithInvalidCredentials() {
        // Given the app launches, When invalid sign in, then show "UserNotFoundException" alert and no page navigation

        UIActions.signInWith(username: "guesser", password: "simpleguess")
        let usernotfoundexceptionAlert = app!.alerts["UserNotFoundException"]
        XCTAssertTrue(usernotfoundexceptionAlert.waitForExistence(timeout: networkTimeout))

        usernotfoundexceptionAlert.buttons["Retry"].tap()

        XCTAssertTrue(UIElements.SignInScreen.navigationBar.waitForExistence(timeout: networkTimeout))
    }
}
