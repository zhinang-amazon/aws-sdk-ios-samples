//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AWSAppSync
import Foundation

struct Photo {
    let id: GraphQLID
    let name: String
    let bucket: String
    let key: String
    let backedUp: Bool
    let thumbnail: UIImage?

    init(id: GraphQLID, name: String, bucket: String, key: String, backedUp: Bool?, thumbnail: UIImage?) {
        self.id = id
        self.name = name
        self.bucket = bucket
        self.key = key
        if backedUp != nil {
            self.backedUp = backedUp!
        } else {
            self.backedUp = true
        }
        self.thumbnail = thumbnail
    }
}
