//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AWSS3
import Foundation
import UIKit

class ExpandPhotoViewController: UIViewController {
    @IBOutlet var expandPhotoImageView: UIImageView!
    @IBOutlet var expandPhotoProgressView: UIProgressView!
    var selectedPhoto: Photo!
    var accessType: AccessSpecifier!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Photo"
        displayFullSizeImage()
    }

    private func displayFullSizeImage() {
        expandPhotoProgressView.progress = 0.0
        expandPhotoProgressView.accessibilityIdentifier = "fullSizeImageDownloadProgressView"
        let downloadExpression = AWSS3TransferUtilityDownloadExpression()
        downloadExpression.progressBlock = { _, progress in
            DispatchQueue.main.async {
                if self.expandPhotoProgressView.progress < Float(progress.fractionCompleted) {
                    self.expandPhotoProgressView.progress = Float(progress.fractionCompleted)
                }
            }
        }

        var downloadCompletionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?

        downloadCompletionHandler = { (task, _, data, error) -> Void in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }

            if task.status == .completed {
                print("Download full size image successful.")
                DispatchQueue.main.async { // error checking
                    self.expandPhotoImageView.image = UIImage(data: data!)
                    self.expandPhotoImageView.accessibilityIdentifier = "fullSizeImage"
                }
            }
        }

        RemoteStorage.getImageFromBucket(id: selectedPhoto.key + "_big", accessType: accessType,
                                         downloadExpression: downloadExpression,
                                         downloadCompletionHandler: downloadCompletionHandler)
    }
}
