//
//  A4VoiceAllocator.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 30/11/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A4Pattern.h"

typedef enum A4VoiceAllocationMode
{
	A4VoiceAllocationModeReset,
	A4VoiceAllocationModeRotate,
	A4VoiceAllocationModeReassign,
	A4VoiceAllocationModeUnison
}
A4VoiceAllocationMode;


typedef struct A4TrackVoicePair
{
	int8_t track;
	int8_t voice;
}
A4TrackVoicePair;

A4TrackVoicePair A4TrackVoicePairMake(uint8_t track, uint8_t voice);

@class A4VoiceAllocator;

@protocol A4VoiceAllocatorDelegate <NSObject>
- (void) a4VoiceAllocator:(A4VoiceAllocator *) allocator willStealVoice:(A4TrackVoicePair)voicePair;
@end


@interface A4VoiceAllocator : NSObject
@property (nonatomic) A4VoiceAllocationMode mode;
@property (nonatomic) uint8_t polyphonicVoices; // lower nibble bitmask;
@property (nonatomic) uint8_t freeVoices; // lower nibble bitmask;
@property (nonatomic, readonly) A4TrackVoicePair oldestVoice;
@property (nonatomic, readonly) A4TrackVoicePair newestVoice;
@property (nonatomic, weak) id<A4VoiceAllocatorDelegate>delegate;

- (void) setVoice:(uint8_t) voiceIdx polyphonic:(BOOL) active;
- (BOOL) isVoicePolyphonic:(uint8_t) voiceIdx;
- (BOOL) isVoiceFree:(uint8_t) voiceIdx;
- (int8_t)openGateAtTrack:(uint8_t)trackIdx withTrig:(A4Trig)trig;
- (void) closeGateAtTrack:(uint8_t)trackIdx;
- (int8_t)openTriglessGateAtTrack:(uint8_t)trackIdx withTrig:(A4Trig)trig;
- (void) closeTriglessGateAtTrack:(uint8_t)trackIdx;
@end
