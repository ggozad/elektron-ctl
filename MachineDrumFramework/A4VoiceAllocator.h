//
//  A4VoiceAllocator.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 30/11/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A4Pattern.h"
#import "A4SequencerTrack.h"

typedef enum A4VoiceAllocationMode
{
	A4VoiceAllocationModeReset,
	A4VoiceAllocationModeRotate,
	A4VoiceAllocationModeReassign,
	A4VoiceAllocationModeUnison
}
A4VoiceAllocationMode;

@class A4VoiceAllocator;
@protocol A4VoiceAllocatorDelegate <NSObject>
- (void) a4VoiceAllocator:(A4VoiceAllocator *)allocator didStealVoice:(uint8_t)voice noteIdx:(uint8_t) noteIdx gate:(GateEvent)event;
- (void) a4VoiceAllocator:(A4VoiceAllocator *)allocator didNullifyGate:(GateEvent)event;
@end

@interface A4VoiceAllocator : NSObject

@property (nonatomic) A4VoiceAllocationMode mode;
@property (nonatomic, weak) id<A4VoiceAllocatorDelegate> delegate;
@property (nonatomic) uint8_t polyphonicVoices; // lower nibble bitmask;
@property (nonatomic) uint8_t freeVoices; // lower nibble bitmask;

- (void) reset;
- (void) setVoice:(uint8_t) voiceIdx polyphonic:(BOOL) active;
- (BOOL) isVoicePolyphonic:(uint8_t) voiceIdx;
- (BOOL) isVoiceFree:(uint8_t) voiceIdx;
- (void) handleOffRequests:(GateEvent *)gates len:(NSUInteger)len;
- (void) handleOnRequests:(GateEvent *)gates len:(NSUInteger)len;
@end
