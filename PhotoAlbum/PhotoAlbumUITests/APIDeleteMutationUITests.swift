//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest

class APIDeleteMutationUITests: XCTestCase {
    let albumName = UUID().uuidString
    let accessType = "Public"
    var app: XCUIApplication?

    override func setUp() {
        continueAfterFailure = false
        app = UIActions.launchApp()
        UIActions.signInWithValidCredentials()
        UIActions.createNewAlbumWith(albumName: albumName, accessType: accessType)
    }

    override func tearDown() {
        UIActions.tapSignOut()
    }

    func testDeleteMutation() {
        // Given valid sign-in, create album mutation succeeds
        // when the user deletes the created album
        // then verify delete mutation succeeds from the corresponding AlbumCollectionViewCell

        let albumCell = UIElements.collectionViewCell(identifier: albumName)
        let albumNameTextField = UIElements.AlbumsScreen.albumNameTextField(albumName: albumName)

        UIActions.deleteAlbumWith(albumName: albumName)

        XCTAssertFalse(albumCell.exists)
        XCTAssertFalse(albumNameTextField.exists)
    }
}
