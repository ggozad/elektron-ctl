//
//  BufferPlayer.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 3/20/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>

@interface BufferPlayer : NSObject
@property (nonatomic, strong) NSData *audioData;
@property AudioStreamBasicDescription asbd;
- (void) setAudioData:(NSData *)audioData asbd:(AudioStreamBasicDescription) asbd;
- (void) setLoopStart:(NSUInteger)s end:(NSUInteger)e;
- (void) start;
- (void) stop;
- (void) bang;
@end
