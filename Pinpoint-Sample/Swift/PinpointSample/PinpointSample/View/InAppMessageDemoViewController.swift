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
    var timer = Timer()
    var secondsElapsed = 0
    var selectedStyle: Int = 0

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var triggerSplashButton: UIButton!
    @IBOutlet var triggerDialogButton: UIButton!

    @IBAction func triggerSplashMessages(_: UIButton) {
        recordEventTrigger(name: "splashMessage")
        startTimer()
    }

    @IBAction func triggerDialogMessages(_: UIButton) {
        recordEventTrigger(name: "dialogMessage")
        startTimer()
    }

    @IBAction func primeButtonTapped(_: UIButton) {
        switch selectedStyle {
        case 0:
            pinpoint.inAppMessagingModule.localSplashIAM()
        case 1:
            pinpoint.inAppMessagingModule.localDialogIAM()
        case 2:
            pinpoint.inAppMessagingModule.localBannerIAM()
        default:
            break
        }
    }

    @IBAction func styleSegmentedControl(_ sender: UISegmentedControl) {
        selectedStyle = sender.selectedSegmentIndex
    }

    @IBAction func backgroundSwitchToggled(_ sender: UISwitch) {
        if sender.isOn {
            backgroundImageView.alpha = 1
            statusLabel.alpha = 0
            titleLabel.alpha = 0
            triggerSplashButton.alpha = 0
            triggerDialogButton.alpha = 0
        } else {
            backgroundImageView.alpha = 0
            statusLabel.alpha = 1
            titleLabel.alpha = 1
            triggerSplashButton.alpha = 1
            triggerDialogButton.alpha = 1
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        pinpoint = (UIApplication.shared.delegate as! AppDelegate).pinpoint!
        pinpoint.inAppMessagingModule.delegate = self
        statusLabel.alpha = 0
        titleLabel.alpha = 0
        triggerSplashButton.alpha = 0
        triggerDialogButton.alpha = 0
    }

    private func recordEventTrigger(name: String) {
        let analyticsClient = pinpoint.analyticsClient
        let eventType = "eventTrigger.\(name)"
        let event = analyticsClient.createEvent(withEventType: eventType)
        analyticsClient.record(event).continueOnSuccessWith { _ in
            print(">>> \(eventType) Event recorded...")
        }
        // statusLabel.text = "\(eventType) event sent"
    }

    func startTimer() {
        endTimer()
        secondsElapsed = 0
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(updateTime),
                                     userInfo: nil,
                                     repeats: true)
    }

    @objc func updateTime() {
        secondsElapsed += 1
        statusLabel.text = "Timer: \(timeFormatted(secondsElapsed))"
    }

    func endTimer() {
        timer.invalidate()
    }

    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        //     let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension InAppMessageDemoViewController: InAppMessagingDelegate {
    func primaryButtonClicked(message: AWSPinpointIAMModel) {
        print("\(message.name).primaryButtonClicked")
        // if message.name.contains("local") {
        //    statusLabel.text = "\(message.name) primary button clicked"
        // } else {
        let primaryButtonURL = URL(string: message.customParam["primaryButtonURL"]!)
        UIApplication.shared.openURL(primaryButtonURL!)
        // }
    }

    func secondaryButtonClicked(message: AWSPinpointIAMModel) {
        print("\(message.name).secondaryButtonClicked")
        if let secondaryButtonURL = URL(string: message.customParam["secondaryButtonURL"] ?? "") {
            UIApplication.shared.openURL(secondaryButtonURL)
        }
    }

    func messageDismissed(message: AWSPinpointIAMModel) {
        print("\(message.name).messageDismissed")
    }

    func displayInvoked(message: AWSPinpointIAMModel) {
        endTimer()
        if message.name.contains("eventTrigger") {
            statusLabel.text = "\(message.name) received time: \(timeFormatted(secondsElapsed))"
        } else {
            // statusLabel.text = "\(message.name) displayed"
        }
    }
}
