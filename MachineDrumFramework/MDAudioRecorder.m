//
//  MDAudioRecorder.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 5/12/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "MDAudioRecorder.h"

@interface MDAudioRecorder()
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation MDAudioRecorder

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
	self.recorder = nil;
	DLog(@"done");
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
	DLog(@"error");
}

+ (id)recorderWithFileURL:(NSURL *)fileUrl
{
	MDAudioRecorder *r = [self new];
	r.maximumRecordingTime = 2;
	r.fileUrl = fileUrl;
	return r;
}

- (id)init
{
	if(self = [super init])
	{
		
	}
	return self;
}

- (void)startRecording
{
	if(!self.fileUrl)
	{
		DLog(@"no URL... bail");
		return;
	}
	
#if TARGET_OS_IPHONE
	
	// TODO audiosession
	
	
#endif
	
	NSError *err = nil;
	NSDictionary *settings = @{
							
							AVFormatIDKey				: @(kAudioFormatLinearPCM),
	   AVSampleRateKey				: @(44100),
	   AVNumberOfChannelsKey		: @(1),
	   AVLinearPCMBitDepthKey		: @(16),
	   AVLinearPCMIsBigEndianKey	: @(NO),
	   AVLinearPCMIsFloatKey		: @(NO),
	   AVEncoderAudioQualityKey	: @(AVAudioQualityMax)
	   };
	self.recorder = [[AVAudioRecorder alloc] initWithURL:self.fileUrl
											 settings:settings
												error:&err];
	
	if(err) DLog(@"err: %@", err);
	
	self.recorder.delegate = self;
	[self.recorder prepareToRecord];
	[self.recorder record];

	self.timer = [NSTimer scheduledTimerWithTimeInterval:self.maximumRecordingTime
									 target:self
								   selector:@selector(timeOut:)
								   userInfo:nil
									repeats:NO];
	
	self.recording = YES;
}

- (void) timeOut:(NSTimer *)t
{
	DLog(@"timeOut!");
	[self stopRecording];
	self.recorder = nil;
}

- (void)stopRecording
{
	if([self.recorder isRecording])
	{
		[self.timer invalidate];
		[self.recorder stop];
	}
	[self.delegate audioRecorderDidFinishRecording:self];
	self.recorder = nil;
	self.recording = NO;
}

@end
