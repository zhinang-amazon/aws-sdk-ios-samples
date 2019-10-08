//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import XCTest

struct UtilitiesForStorageUITests {
    static func setupUpload(albumName: String, accessType: String) {
        UIActions.signInWithValidCredentials()
        UIActions.createNewAlbumWith(albumName: albumName, accessType: accessType)
        let albumCell = UIElements.collectionViewCell(identifier: albumName)
        albumCell.tap()
    }

    static func teardownUpload(albumName: String) {
        UIElements.PhotosScreen.backButton.tap()
        UIActions.deleteAlbumWith(albumName: albumName)
        UIActions.tapSignOut()
    }

    static func uploadAddPhoto() {
        let photosNavigationBar = UIElements.PhotosScreen.navigationBar
        _ = photosNavigationBar.waitForExistence(timeout: uiTimeout)

        photosNavigationBar.buttons["Add"].tap()
    }

    static func setupDownload(albumName: String, accessType: String) {
        setupUpload(albumName: albumName, accessType: accessType)
        uploadAddPhoto()
        let addedPhotoCell = UIElements.PhotosScreen.addedPhotoCell
        _ = addedPhotoCell.waitForExistence(timeout: networkTimeout)
    }

    static func teardownDownload(albumName: String) {
        UIElements.PhotoScreen.backButton.tap()
        teardownUpload(albumName: albumName)
    }

    static func downloadFullSizeImage() {
        let addedPhotoCell = UIElements.PhotosScreen.addedPhotoCell
        addedPhotoCell.tap()
        let fullSizeImage = UIElements.PhotoScreen.fullSizeImage

        // attempt - 1
        let firstAttemptSuccess: Bool = fullSizeImage.waitForExistence(timeout: networkTimeout)

        // attempt - 2
        if !firstAttemptSuccess {
            UIElements.PhotoScreen.backButton.tap()
            addedPhotoCell.tap()
            _ = fullSizeImage.waitForExistence(timeout: networkTimeout)
        }
    }
}
