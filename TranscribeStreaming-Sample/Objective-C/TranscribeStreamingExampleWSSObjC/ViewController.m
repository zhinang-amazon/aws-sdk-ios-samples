//
//  ViewController.m
//  TranscribeStreamingExampleWSSObjC
//
//  Created by Schmelter, Tim on 7/24/19.
//  Copyright © 2019 Amazon Web Services. All rights reserved.
//

#import <AWSTranscribeStreaming/AWSTranscribeStreaming.h>
#import "Constants.h"

#import "ViewController.h"

@interface ViewController()<AWSTranscribeStreamingClientDelegate>

@property (nullable, nonatomic, strong) AWSTranscribeStreaming *transcribeStreaming;
@property (weak, nonatomic) IBOutlet UITextView *transcriptionTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[AWSDDLog sharedInstance] setLogLevel:AWSDDLogLevelDebug];
    [[AWSDDLog sharedInstance] addLogger:[AWSDDTTYLogger sharedInstance]];

    AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:Constants.AWSAccessKey
                                                                                                      secretKey:Constants.AWSSecretAccessKey];

    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:Constants.AWSTranscribeStreamingRegion
                                                                         credentialsProvider:credentialsProvider];

    [AWSTranscribeStreaming registerTranscribeStreamingWithConfiguration:configuration
                                                                  forKey:@"TranscribeStreamingDemo"];

    self.transcribeStreaming = [AWSTranscribeStreaming TranscribeStreamingForKey:@"TranscribeStreamingDemo"];
}

#pragma mark - Actions

- (IBAction)didTapStart:(id)sender {
    [self initiateTranscribeStreamingRequest];
}

- (void)updateTranscription:(NSString *)transcription {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.transcriptionTextView.text = transcription;
    });
}

#pragma mark - TranscribeStreaming support

- (void)initiateTranscribeStreamingRequest {
    [self updateTranscription:@"Initiating request"];

    AWSTranscribeStreamingStartStreamTranscriptionRequest *request = [AWSTranscribeStreamingStartStreamTranscriptionRequest new];

    request.languageCode = AWSTranscribeStreamingLanguageCodeEnUS;
    request.mediaEncoding = AWSTranscribeStreamingMediaEncodingPcm;
    request.mediaSampleRateHertz = @(8000);

    [self.transcribeStreaming setDelegate:self
                            callbackQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)];

    [self.transcribeStreaming startTranscriptionWSS:request];
}

- (void)streamAudio {
    [self updateTranscription:@"Streaming audio"];

    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"hello_world" ofType:@"wav"];
    if (!soundFilePath) {
        AWSDDLogError(@"Could not locate sound file hello_world.wav");
        return;
    }

    AWSDDLogDebug(@"%@", soundFilePath);

    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    NSData *audioData = [NSData dataWithContentsOfURL:soundFileURL];

    NSDictionary<NSString *, NSString *> *headers = @{
                                                      @":content-type": @"audio/wav",
                                                      @":message-type": @"event",
                                                      @":event-type": @"AudioEvent"
                                                      };

    NSInteger startPos = 0;
    NSInteger chunkSize = 4096;
    NSInteger nextSize = MIN(chunkSize, ([audioData length] - startPos));
    AWSDDLogDebug(@"Audio length %lu", (unsigned long)[audioData length]);

    @autoreleasepool {
        while (startPos < [audioData length]) {
            AWSDDLogVerbose(@"Sending %lu bytes", nextSize);
            NSData *dataChunk = [audioData subdataWithRange:NSMakeRange(startPos, nextSize)];
            [self.transcribeStreaming sendData:dataChunk headers:headers];
            startPos = startPos + nextSize;
            nextSize = MIN(chunkSize, ([audioData length] - startPos));
        }
    }

    AWSDDLogDebug(@"Sending end frame");
    [self.transcribeStreaming sendEndFrame];
}

#pragma mark - AWSTranscribeStreamingTranscriptResultStream

- (void)didReceiveEvent:(nullable AWSTranscribeStreamingTranscriptResultStream *)event
          decodingError:(nullable NSError *)decodingError {
    if (decodingError) {
        AWSDDLogError(@"decodingError %@", decodingError);
        return;
    }

    if (!event) {
        AWSDDLogError(@"Stream event is nil");
        return;
    }

    AWSDDLogDebug(@"Stream event: %@", event);

    AWSTranscribeStreamingTranscriptEvent * _Nullable transcriptEvent = event.transcriptEvent;
    if (!transcriptEvent) {
        AWSDDLogError(@"transcriptEvent is nil: event may be an error: %@", event);
        return;
    }

    if (!transcriptEvent.transcript || !transcriptEvent.transcript.results) {
        AWSDDLogDebug(@"No results, waiting for next event");
        return;
    }

    AWSTranscribeStreamingResult *firstResult = [transcriptEvent.transcript.results firstObject];
    if (!firstResult) {
        AWSDDLogDebug(@"firstResult nil--possibly a partial result");
        return;
    }

    AWSTranscribeStreamingAlternative *firstAlternative = [firstResult.alternatives firstObject];
    if (!firstAlternative) {
        AWSDDLogDebug(@"firstAlternative is nil--possibly a partial result");
        return;
    }

    [self updateTranscription:firstAlternative.transcript];

    if (firstResult.isPartial) {
        AWSDDLogDebug(@"Partial result received, waiting for next event (results: %@)", transcriptEvent.transcript.results);
        return;
    }

    AWSDDLogInfo(@"Full transcription result received: %@", firstResult);

    AWSDDLogWarn(@"Transcription finished, ending transcription");
    [self.transcribeStreaming endTranscription];
}

- (void)connectionStatusDidChange:(AWSTranscribeStreamingClientConnectionStatus)connectionStatus
                        withError:(NSError *)error {
    if (error) {
        AWSDDLogError(@"WS connection change - Error %@", error);
        return;
    }

    NSString *statusString = [ViewController displayStringForConnectionStatus:connectionStatus];
    AWSDDLogDebug(@"WS connection change - status %@", statusString);
    switch (connectionStatus) {
        case AWSTranscribeStreamingClientConnectionStatusConnected:
            [self streamAudio];
            break;
        default:
            break;
    }
}

+ (NSString *)displayStringForConnectionStatus:(AWSTranscribeStreamingClientConnectionStatus)status {
    switch (status) {
        case AWSTranscribeStreamingClientConnectionStatusConnecting:
            return @"Connecting";
        case AWSTranscribeStreamingClientConnectionStatusConnected:
            return @"Connected";
        case AWSTranscribeStreamingClientConnectionStatusClosing:
            return @"Closing";
        case AWSTranscribeStreamingClientConnectionStatusClosed:
            return @"Closed";
        default:
            return @"Unknown";
    }
}

@end
