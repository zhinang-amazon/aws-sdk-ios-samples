//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AWSAppSync
import Foundation

struct AlbumCollection {
    let username: String
    let albums: [Album]

    init(username: String, albums: [Album]) {
        self.username = username
        self.albums = albums
    }

    init(username: String) {
        self.init(username: username, albums: [Album]())
    }
}
