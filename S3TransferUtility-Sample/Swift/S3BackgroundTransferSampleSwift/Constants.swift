/*
* Copyright 2010-2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

import Foundation
import AWSCore

// Warning: To run this sample correctly, you must set the following constants.
struct Constants {
    static let testImageKey: String = "public/test-image.png"

    static let identityPoolId = "us-east-2:94c7f5d1-213d-417e-8d0c-e12b4c5cd08f"
    static let bucket = "s3multiuploadc508f20638024de9aa4c3847aaaf7131-dev"
    static let region = AWSRegionType.USEast2
    static let transferUtilityKey = "awsS3TransferUtilityKey"
}
