//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AWSAppSync
import Foundation
import UIKit

protocol AlbumCollectionViewCellDelegate: AnyObject {
    func deleteAlbum(cell: AlbumCollectionViewCell)
    func updateAlbumName(cell: AlbumCollectionViewCell)
}

class AlbumCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    @IBOutlet var albumThumbnail: UIImageView!

    @IBOutlet var albumTitleField: UITextField!

    @IBOutlet var albumDeleteBackgroundView: UIVisualEffectView!

    var albumId: GraphQLID! // identifier used during addition and deletion of Albums

    weak var albumCollectionViewCellDelegate: AlbumCollectionViewCellDelegate?

    var editMode: Bool = false {
        didSet {
            albumDeleteBackgroundView.isHidden = !editMode
        }
    }

    var albumImageName: String! {
        didSet {
            albumThumbnail.image = UIImage(named: albumImageName)
            albumThumbnail.image?.accessibilityIdentifier = albumTitle + "_img"
            albumThumbnail.image?.isAccessibilityElement = true
            albumDeleteBackgroundView.layer.cornerRadius = albumDeleteBackgroundView.bounds.width / 2.0
            albumDeleteBackgroundView.layer.masksToBounds = true
            albumDeleteBackgroundView.isHidden = !editMode
        }
    }

    var albumTitle: String! {
        didSet {
            albumTitleField.text = albumTitle
            albumTitleField.accessibilityIdentifier = albumTitle + "_name"
            albumTitleField.isAccessibilityElement = true
        }
    }

    @IBAction func deleteAlbumDidTap(_: Any) {
        albumCollectionViewCellDelegate?.deleteAlbum(cell: self)
    }

    @IBAction func updateAlbumName(_: Any) {
        albumTitleField.tintColor = UIColor.clear
        albumCollectionViewCellDelegate?.updateAlbumName(cell: self)
    }
}
