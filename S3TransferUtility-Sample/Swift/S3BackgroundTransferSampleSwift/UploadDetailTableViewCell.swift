//
//  UploadDetailTableViewCell.swift
//  S3TransferUtilitySampleSwift
//
//  Created by Schmelter, Tim on 7/18/19.
//  Copyright © 2019 Amazon. All rights reserved.
//

import UIKit

class UploadDetailTableViewCell: UITableViewCell {

    static let reuseIdentifier = "UploadDetailTableViewCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    weak var item: UploadItem? {
        didSet {
            guard let item = item else {
                return
            }
            
            textLabel?.text = item.key
            detailTextLabel?.text = item.detailCellLabelText
            
            item.statusDidUpdate = { [weak self] in
                DispatchQueue.main.async {
                    self?.detailTextLabel?.text = item.detailCellLabelText
                }
            }
        }
    }
    
    override func prepareForReuse() {
        item?.statusDidUpdate = nil
        item = nil
    }

}
