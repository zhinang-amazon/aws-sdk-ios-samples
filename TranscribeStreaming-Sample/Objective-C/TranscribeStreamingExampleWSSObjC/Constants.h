//
//  Constants.h
//  TranscribeStreamingExampleWSSObjC
//
//  Created by Schmelter, Tim on 7/24/19.
//  Copyright © 2019 Amazon Web Services. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSCore/AWSCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface Constants: NSObject

+ (NSString *)AWSAccessKey;
+ (NSString *)AWSSecretAccessKey;
+ (AWSRegionType)AWSTranscribeStreamingRegion;

@end

NS_ASSUME_NONNULL_END
