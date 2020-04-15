//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AWSPinpoint
import UIKit

class MasterViewController: UITableViewController {
    var detailViewController: DetailViewController?
    var objects = [Any]()

    var pinpoint: AWSPinpoint!
    var iamModule: InAppMessagingModule!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count - 1] as! UINavigationController).topViewController as? DetailViewController
        }

        pinpoint = (UIApplication.shared.delegate as! AppDelegate).pinpoint!
        iamModule = InAppMessagingModule(delegate: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        iamModule.retrieveEligibleInAppMessages()
    }

    @objc func insertNewObject(_: Any) {
        objects.insert(NSDate(), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)

        let analyticsClient = pinpoint.analyticsClient
        let eventType = "eventTrigger.insertNewObject"
        let event = analyticsClient.createEvent(withEventType: eventType)
        analyticsClient.record(event).continueOnSuccessWith { _ in
            print(">>> \(eventType) Event recorded...")
        }

        // iamModule.retrieveEligibleInAppMessages()
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! NSDate
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = objects[indexPath.row] as! NSDate
        cell.textLabel!.text = object.description
        return cell
    }

    override func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class
            // insert it into the array, and add a new row to the table view.
        }
    }
}

extension MasterViewController: InAppMessagingDelegate {
    func primaryButtonClicked(message: AWSPinpointSplashModel) {
        print("MasterViewController.primaryButtonClicked")
        let primaryButtonURL = URL(string: message.customParam["primaryButtonURL"]!)
        UIApplication.shared.openURL(primaryButtonURL!)
    }

    func secondaryButtonClicked(message: AWSPinpointSplashModel) {
        print("MasterViewController.secondaryButtonClicked")
        let secondaryButtonURL = URL(string: message.customParam["secondaryButtonURL"]!)
        UIApplication.shared.openURL(secondaryButtonURL!)
    }

    func messageDismissed(message _: AWSPinpointSplashModel) {
        print("MasterViewController.messageDismissed")
    }
}
