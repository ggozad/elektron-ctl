//
//  A4Sequencer.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 08/11/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A4SequencerTrack.h"
#import "A4Project.h"
#import "A4VoiceAllocator.h"

@class A4Sequencer;

typedef enum A4SequencerMode
{
	A4SequencerModeQueue,
	A4SequencerModeStart,
	A4SequencerModeJump
}
A4SequencerMode;

@protocol A4SequencerDelegate <NSObject, A4ProjectDelegate>
- (void) a4SequencerDidChangePattern: (A4Sequencer *) sequencer;
- (void) a4SequencerDidReachEndOfPattern: (A4Sequencer *) sequencer;
- (void) a4SequencerDidStop:(A4Sequencer *)sequencer;
- (void) a4SequencerDidContinue:(A4Sequencer *)sequencer;
- (void) a4SequencerDidStart:(A4Sequencer *)sequencer;
- (void) a4SequencerDidReset:(A4Sequencer *)sequencer;
- (void) a4Sequencer: (A4Sequencer *) sequencer didOpenGate:(GateEvent)gateEvent;
- (void) a4Sequencer: (A4Sequencer *) sequencer didCloseGate:(GateEvent)gateEvent;
- (void) a4Sequencer: (A4Sequencer *) sequencer didStealVoice:(uint8_t)voice noteIdx:(uint8_t)noteIdx gate:(GateEvent)event;
@end

@interface A4Sequencer : NSObject <A4ProjectDelegate, A4VoiceAllocatorDelegate>
@property (nonatomic, strong) A4VoiceAllocator *voiceAllocator;
@property (nonatomic, strong) A4Kit *kit;
@property (nonatomic, readonly) BOOL playing;
@property (strong, nonatomic) A4Project *project;
@property (nonatomic, strong) NSMutableArray *tracks;
@property (nonatomic) NSInteger clockMultiplier, clockInterpolationFactor;
@property (nonatomic, weak) id<A4SequencerDelegate>delegate;
+ (instancetype) sequencerWithDelegate:(id<A4SequencerDelegate>)delegate;
- (BOOL) setPattern:(A4Pattern *)pattern;
- (A4Pattern *)pattern;
- (void) setPattern:(A4Pattern *)pattern mode:(A4SequencerMode)mode;
- (void) start;
- (void) continue;
- (void) stop;
- (void) reset;
- (void) clockTick;
@end
