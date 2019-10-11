//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import XCTest

struct UIElements {
//    static var app: XCUIApplication {
//        return XCUIApplication()
//    }
    static var app: XCUIApplication {
        UIActions.app
    }

    struct SignInScreen {
        static var navigationBar: XCUIElement {
            app.navigationBars["Sign In"]
        }

        static var signInButton: XCUIElement {
            app.buttons["Sign In"]
        }
    }

    struct AlbumsScreen {
        static var navigationBar: XCUIElement {
            app.navigationBars["Albums"]
        }

        static var addAlbumButton: XCUIElement {
            navigationBar.buttons["Add"]
        }

        static var signOutButton: XCUIElement {
            navigationBar.buttons["Sign Out"]
        }

        static var editButton: XCUIElement {
            navigationBar.buttons["Edit"]
        }

        static var editDoneButton: XCUIElement {
            navigationBar.buttons["Done"]
        }

        static func albumNameTextField(albumName: String) -> XCUIElement {
            XCUIApplication().collectionViews.textFields[albumName + "_name"]
        }
    }

    struct PhotosScreen {
        static var navigationBar: XCUIElement {
            app.navigationBars["Photos"]
        }

        static var backButton: XCUIElement {
            navigationBar.buttons["Albums"]
        }

        static var addPhotoButton: XCUIElement {
            navigationBar.buttons["Add"]
        }

        static var addedPhotoCell: XCUIElement {
            app.collectionViews.children(matching: .cell).element(boundBy: 0).otherElements.containing(.progressIndicator, identifier: "Progress").element
        }
    }

    struct PhotoScreen {
        static var navigationBar: XCUIElement {
            app.navigationBars["Photo"]
        }

        static var backButton: XCUIElement {
            navigationBar.buttons["Photos"]
        }

        static var fullSizeImage: XCUIElement {
            app.images["fullSizeImage"]
        }

        static var fullSizeImageProgressView: XCUIElement {
            app/*@START_MENU_TOKEN@*/.progressIndicators["fullSizeImageDownloadProgressView"]/*[[".progressIndicators[\"Progress\"]",".progressIndicators[\"fullSizeImageDownloadProgressView\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        }
    }

    static func collectionViewCell(identifier: String!) -> XCUIElement {
        let collectionViewsQuery = app.collectionViews
        return collectionViewsQuery.cells[identifier]
    }
}
