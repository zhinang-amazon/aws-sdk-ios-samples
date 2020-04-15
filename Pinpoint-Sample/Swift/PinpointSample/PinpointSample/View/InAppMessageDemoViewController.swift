//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AWSPinpoint
import UIKit

class InAppMessageDemoViewController: UIViewController {
    var pinpoint: AWSPinpoint!
    var iamModule: InAppMessagingModule!

    @IBOutlet var statusLable: UILabel!
    @IBAction func retrieveMessages(_: UIButton) {
        iamModule.retrieveEligibleInAppMessages()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        pinpoint = (UIApplication.shared.delegate as! AppDelegate).pinpoint!
        iamModule = InAppMessagingModule(delegate: self)
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}

extension InAppMessageDemoViewController: InAppMessagingDelegate {
    func primaryButtonClicked(message: AWSPinpointSplashModel) {
        print("MasterViewController.primaryButtonClicked")
        // let primaryButtonURL = URL(string: message.customParam["primaryButtonURL"]!)
        // UIApplication.shared.openURL(primaryButtonURL!)
        statusLable.text = "\(message.name) primary button clicked"
    }

    func secondaryButtonClicked(message: AWSPinpointSplashModel) {
        print("MasterViewController.secondaryButtonClicked")
        // let secondaryButtonURL = URL(string: message.customParam["secondaryButtonURL"]!)
        // UIApplication.shared.openURL(secondaryButtonURL!)
        statusLable.text = "\(message.name) secondary button clicked"
    }

    func messageDismissed(message: AWSPinpointSplashModel) {
        print("MasterViewController.messageDismissed")
        statusLable.text = "\(message.name) dismissed by user"
    }
}
