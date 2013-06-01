//
//  MDAudioRecorder.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 5/12/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class MDAudioRecorder;

@protocol MDAudioRecorderDelegate <NSObject>
- (void) audioRecorderDidFinishRecording:(MDAudioRecorder *) audioRecorder;
@end

@interface MDAudioRecorder : NSObject <AVAudioRecorderDelegate>
@property AVAudioRecorder *recorder;
@property NSTimeInterval maximumRecordingTime;
@property (nonatomic, strong) NSURL *fileUrl;
@property id<MDAudioRecorderDelegate>delegate;
@property (getter = isRecording) BOOL recording;

+ (id) recorderWithFileURL:(NSURL *)fileUrl;
- (void) startRecording;
- (void) stopRecording;

@end
