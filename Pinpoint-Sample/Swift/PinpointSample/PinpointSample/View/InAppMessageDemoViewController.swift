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
    // var iamModule: InAppMessagingModule!

    @IBOutlet var statusLable: UILabel!
    @IBAction func triggerSplashMessages(_: UIButton) {
        recordEventTrigger(name: "splashMessage")
    }

    @IBAction func triggerDialogMessages(_: UIButton) {
        recordEventTrigger(name: "dialogMessage")
    }

    @IBAction func localSplashMessage(_: UIButton) {
        pinpoint.inAppMessagingModule.localSplashIAM()
    }

    @IBAction func localDialogMessage(_: UIButton) {
        pinpoint.inAppMessagingModule.localDialogIAM()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        pinpoint = (UIApplication.shared.delegate as! AppDelegate).pinpoint!
        // iamModule = InAppMessagingModule(delegate: self)
    }

    private func recordEventTrigger(name: String) {
        let analyticsClient = pinpoint.analyticsClient
        let eventType = "eventTrigger.\(name)"
        let event = analyticsClient.createEvent(withEventType: eventType)
        analyticsClient.record(event).continueOnSuccessWith { _ in
            print(">>> \(eventType) Event recorded...")
        }
        statusLable.text = "\(eventType) event sent"
    }
}

// extension InAppMessageDemoViewController: InAppMessagingDelegate {
//    func primaryButtonClicked(message: AWSPinpointIAMModel) {
//        print("\(message.name).primaryButtonClicked")
//        // let primaryButtonURL = URL(string: message.customParam["primaryButtonURL"]!)
//        // UIApplication.shared.openURL(primaryButtonURL!)
//        statusLable.text = "\(message.name) primary button clicked"
//    }
//
//    func secondaryButtonClicked(message: AWSPinpointIAMModel) {
//        print("\(message.name).secondaryButtonClicked")
//        // let secondaryButtonURL = URL(string: message.customParam["secondaryButtonURL"]!)
//        // UIApplication.shared.openURL(secondaryButtonURL!)
//        statusLable.text = "\(message.name) secondary button clicked"
//    }
//
//    func messageDismissed(message: AWSPinpointIAMModel) {
//        print("\(message.name).messageDismissed")
//        statusLable.text = "\(message.name) dismissed by user"
//    }
// }
