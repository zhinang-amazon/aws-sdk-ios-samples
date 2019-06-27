//
//  UploadBatchTableViewController.swift
//  S3TransferUtilitySampleSwift
//
//  Created by Schmelter, Tim on 7/18/19.
//  Copyright © 2019 Amazon. All rights reserved.
//

import UIKit
import AWSS3

class UploadBatchTableViewController: UITableViewController {
    
    private var items = [UploadItem]()
    
    override func viewDidLoad() {
        tableView.register(UploadDetailTableViewCell.self,
                           forCellReuseIdentifier: UploadDetailTableViewCell.reuseIdentifier)

        populateItemsFromUploadQueue()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Upload all",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapUploadButton))
    }
    
    func populateItemsFromUploadQueue() {
        guard let uploadTasks = AWSProviders.transferUtility.getUploadTasks().result as? [AWSS3TransferUtilityUploadTask] else {
            print("Can't get upload tasks")
            return
        }
        
        var inProcessItems = [UploadItem]()

        for uploadTask in uploadTasks {
            let key = uploadTask.key
            let uploadItem = UploadItem(withKey: key)
            inProcessItems.append(uploadItem)
            
            uploadTask.setCompletionHandler(makeCompletionHandler(for: uploadItem))
            uploadTask.setProgressBlock(makeProgressBlock(for: uploadItem))
        }
        
        items = inProcessItems.sorted { $0.key < $1.key }
    }

    @objc func didTapUploadButton() {
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        var inProcessItems = [UploadItem]()
        for i in 1 ... 300 {
            let nameWithoutExtension = String(format: "img_%03d", i)
            let fileExtension = "jpg"
            let key = "public/\(nameWithoutExtension).\(fileExtension)"
            
            guard let path = Bundle.main.path(forResource: nameWithoutExtension, ofType: fileExtension, inDirectory: "testImages") else {
                print("Unable to get path for \(key)")
                continue
            }
            
            let uploadItem = UploadItem(withKey: key)
            inProcessItems.append(uploadItem)
            
            let expression = AWSS3TransferUtilityUploadExpression()
            expression.progressBlock = makeProgressBlock(for: uploadItem)
            
            let url = URL(fileURLWithPath: path)
            
            AWSProviders.transferUtility.uploadFile(
                url,
                bucket: Constants.bucket,
                key: key,
                contentType: "image/jpeg",
                expression: expression,
                completionHandler: makeCompletionHandler(for: uploadItem)
                ).continueWith { [weak uploadItem] task -> AnyObject? in
                    guard let uploadItem = uploadItem else {
                        return nil
                    }
                    
                    if let error = task.error {
                        print("Error creating upload task for \(key): \(error)")
                        uploadItem.status = .error
                        return nil
                    }
                    
                    guard let _ = task.result else {
                        print("Result unexpectedly nil creating upload task for \(key)")
                        uploadItem.status = .error
                        return nil
                    }
                    
                    uploadItem.status = .waiting
                    return nil
            }
        }
        
        items = inProcessItems
        tableView.reloadData()
    }
    
    func makeCompletionHandler(for uploadItem: UploadItem) -> AWSS3TransferUtilityUploadCompletionHandlerBlock {
        let completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock = { [weak uploadItem] task, error in
            guard let uploadItem = uploadItem else {
                return
            }
            
            if let error = error {
                print("Error uploading \(uploadItem.key): \(error)")
                return
            }
            
            uploadItem.status = .completed
        }
        return completionHandler
    }
    
    func makeProgressBlock(for uploadItem: UploadItem) -> AWSS3TransferUtilityProgressBlock {
        let progressBlock: AWSS3TransferUtilityProgressBlock = { [weak uploadItem] task, progress in
            guard let uploadItem = uploadItem else {
                return
            }
            
            uploadItem.status = .inProgress
            
            let fractionCompleted = Float(progress.fractionCompleted)
            
            if fractionCompleted > uploadItem.progress {
                uploadItem.progress = fractionCompleted
            }
        }
        return progressBlock
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UploadDetailTableViewCell.reuseIdentifier,
                                                 for: indexPath) as! UploadDetailTableViewCell

        let item = items[indexPath.row]

        cell.item = item
        
        return cell
    }
    
}

class UploadItem {
    var identifier: String?
    let key: String
    var statusDidUpdate: (() -> Void)?
    
    var status: AWSS3TransferUtilityTransferStatusType {
        didSet {
            statusDidUpdate?()
        }
    }
    
    var progress: Float {
        didSet {
            statusDidUpdate?()
        }
    }
    
    init(withKey key: String) {
        self.key = key
        progress = 0.0
        status = .unknown
    }
}

extension UploadItem {
    var detailCellLabelText: String {
        if status == .inProgress {
            return String(format: "In progress: %1.2f%%", progress * 100.0)
        }
        
        return status.displayText
    }
}

extension AWSS3TransferUtilityTransferStatusType {
    var displayText: String {
        switch self {
        case .cancelled:
            return "Cancelled"
        case .completed:
            return "Completed"
        case .error:
            return "Error"
        case .inProgress:
            return "In Progress"
        case .paused:
            return "Paused"
        case .unknown:
            return "Unknown"
        case .waiting:
            return "Waiting"
        @unknown default:
            return "Unknown"
        }
    }
}
