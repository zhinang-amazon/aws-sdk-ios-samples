//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AWSAppSync
import AWSMobileClient
import AWSS3
import Foundation
import UIKit

protocol PhotoCollectionViewCellDelegate: AnyObject {
    func deletePhoto(cell: PhotoCollectionViewCell)
}

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet var photoThumbnail: UIImageView!
    @IBOutlet var photoDeleteBackgroundView: UIVisualEffectView!
    @IBOutlet var photoThumbnailDownloadProgressView: UIProgressView!

    weak var photoCollectionViewCellDelegate: PhotoCollectionViewCellDelegate?

    var photoId: GraphQLID!
    var accessType: AccessSpecifier!
    var thumbnail: UIImage?
    var editMode: Bool = false {
        didSet {
            photoDeleteBackgroundView.isHidden = !editMode
        }
    }

    var photoImageName: String! {
        didSet {
            // store the actual sized image in s3
            // use only thumbnail to display
            photoThumbnailDownloadProgressView.progress = 0.0

            let downloadExpression = AWSS3TransferUtilityDownloadExpression()
            downloadExpression.progressBlock = { _, progress in
                DispatchQueue.main.async {
                    if self.photoThumbnailDownloadProgressView.progress < Float(progress.fractionCompleted) {
                        self.photoThumbnailDownloadProgressView.progress = Float(progress.fractionCompleted)
                    }
                }
            }

            var downloadCompletionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?

            downloadCompletionHandler = { (task, _, data, error) -> Void in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }

                if task.status == .completed {
                    print("Download successful.")
                    DispatchQueue.main.async {
                        self.photoThumbnail.image = UIImage(data: data!)
                    }
                }
            }

            RemoteStorage.getImageFromBucket(id: photoImageName + "_small",
                                             accessType: accessType,
                                             downloadExpression: downloadExpression,
                                             downloadCompletionHandler: downloadCompletionHandler)
        }
    }

    @IBAction func deletePhotoDidTap(_: Any) {
        photoCollectionViewCellDelegate?.deletePhoto(cell: self)
    }
}
