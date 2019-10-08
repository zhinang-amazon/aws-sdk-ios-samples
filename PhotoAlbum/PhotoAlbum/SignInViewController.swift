//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AWSAppSync
import AWSAuthCore
import AWSAuthUI
import AWSMobileClient
import AWSS3
import UIKit

class SignInViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        showSignIn()
    }

    func showSignIn() {
        AWSMobileClient.sharedInstance().showSignIn(navigationController: navigationController!,
                                                    signInUIOptions: SignInUIOptions(
                                                        canCancel: false,
                                                        logoImage: UIImage(named: "AppLogo"),
                                                        backgroundColor: UIColor.black
                                                    )) { signInState, error in
            guard error == nil else {
                print("error logging in: \(error!.localizedDescription)")
                return
            }

            guard let signInState = signInState else {
                print("signInState unexpectedly empty in \(#function)")
                return
            }

            switch signInState {
            case .signedIn:
                AWSServiceManager.signInHandler(parentViewController: self)
            // AWSServiceManager.initializeMobileClient()
            default: return
            }
        }
    }
}
