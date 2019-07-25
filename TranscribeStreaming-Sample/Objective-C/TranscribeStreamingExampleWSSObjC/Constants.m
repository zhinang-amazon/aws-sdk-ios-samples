//
//  Constants.m
//  TranscribeStreamingExampleWSSObjC
//
//  Created by Schmelter, Tim on 7/24/19.
//  Copyright © 2019 Amazon Web Services. All rights reserved.
//

#import "Constants.h"

@implementation Constants

+ (NSString *)AWSAccessKey {
    return @"YourAccessKey";
}

+ (NSString *)AWSSecretAccessKey {
    return @"YourSecretAccessKey";
}

+ (AWSRegionType)AWSTranscribeStreamingRegion {
    return AWSRegionUSEast1;
}

@end
