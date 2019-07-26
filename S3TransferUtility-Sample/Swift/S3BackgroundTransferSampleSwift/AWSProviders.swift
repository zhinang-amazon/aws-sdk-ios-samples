//
//  AWSProviders.swift
//  S3TransferUtilitySampleSwift
//
//  Created by Schmelter, Tim on 7/18/19.
//  Copyright © 2019 Amazon. All rights reserved.
//

import UIKit

import AWSS3

// Note that there are several dangerous uses of force-unwraps in this file. A production app should properly handle error cases.
struct AWSProviders {
    static private(set) var isInitialized = false
    
    static var transferUtility: AWSS3TransferUtility {
        return AWSS3TransferUtility.s3TransferUtility(forKey: Constants.transferUtilityKey)!
    }
    
    static func initialize(for application: UIApplication,
                           withLaunchOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) {
        // No op
        AWSDDLog.sharedInstance.logLevel = .debug
        AWSDDLog.sharedInstance.add(AWSDDTTYLogger.sharedInstance)
        initializeS3TransferUtility()
    }
    
    static func initialize(_ application: UIApplication,
                           toHandleEventsForBackgroundURLSession identifier: String,
                           completionHandler: @escaping () -> Void) {
        initializeS3TransferUtility()

        //provide the completionHandler to the TransferUtility to support background transfers.
        AWSS3TransferUtility.interceptApplication(application,
                                                  handleEventsForBackgroundURLSession: identifier,
                                                  completionHandler: completionHandler)
    }
    
    static var transferUtilityIsInitialized = false
    static func initializeS3TransferUtility() {
        if transferUtilityIsInitialized {
            return
        }

        transferUtilityIsInitialized = true

        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: Constants.region,
                                                                identityPoolId: Constants.identityPoolId)

        let configuration = AWSServiceConfiguration(region: .USEast2,
                                                    credentialsProvider: credentialsProvider)!
        
        if let prefValue = UserDefaults.standard.value(forKey: "PersistentDataStorageKey.wifiOnlyUploads") as? String, prefValue.lowercased() == "false" {
            configuration.allowsCellularAccess = true
        } else {
            configuration.allowsCellularAccess = false
        }
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let transferUtilityConfiguration = AWSS3TransferUtilityConfiguration()
        
        if let prefValue = UserDefaults.standard.value(forKey: "PersistentDataStorageKey.s3TransferAccelerationEnabled") as? String,
            prefValue == "true" {
            transferUtilityConfiguration.isAccelerateModeEnabled = true
        } else {
            transferUtilityConfiguration.isAccelerateModeEnabled = false
        }
        
        transferUtilityConfiguration.retryLimit = 5
        
        AWSS3TransferUtility.register(with: configuration,
                                      transferUtilityConfiguration: transferUtilityConfiguration,
                                      forKey: Constants.transferUtilityKey)

        // Retrieve credentials to ensure we have one whenever we start the batch uploads.
        // This is an asynchronous call, but we don't need it to be completed before proceeding with initialization,
        // so we'll fire and forget.
        credentialsProvider.credentials()
    }
}

