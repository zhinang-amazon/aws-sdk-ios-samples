//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest

class APICreateMutationUITests: XCTestCase {
    let albumName = UUID().uuidString
    let accessType = "Public"
    var app: XCUIApplication?

    override func setUp() {
        continueAfterFailure = false
        app = UIActions.launchApp()
        UIActions.signInWithValidCredentials()
    }

    override func tearDown() {
        UIActions.deleteAlbumWith(albumName: albumName)
        UIActions.tapSignOut()
    }

    func testCreateMutation() {
        // Given valid sign-in
        // When the user creates an album
        // then verify that create mutation succeeds from the corresponding AlbumCollectionViewCell

        let albumCell = UIElements.collectionViewCell(identifier: albumName)
        let albumNameTextField = UIElements.AlbumsScreen.albumNameTextField(albumName: albumName)

        UIActions.createNewAlbumWith(albumName: albumName, accessType: accessType)

        XCTAssertTrue(albumCell.exists)
        XCTAssertTrue(albumNameTextField.exists)
        XCTAssertEqual(albumNameTextField.value as? String, albumName)
    }
}
