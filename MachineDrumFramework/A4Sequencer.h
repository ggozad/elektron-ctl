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
- (void) a4Sequencer: (A4Sequencer *) sequencer didOpenGateInTrack:(uint8_t)trackIdx withTrig:(A4Trig)trig atStep:(uint8_t)step context:(TrigContext) context;
- (void) a4Sequencer: (A4Sequencer *) sequencer didCloseGateInTrack:(uint8_t)trackIdx withTrig:(A4Trig)trig atStep:(uint8_t)step context:(TrigContext) context;
- (void) a4Sequencer: (A4Sequencer *) sequencer didOpenTriglessGateInTrack:(uint8_t)trackIdx withTrig:(A4Trig)trig atStep:(uint8_t)step;
- (void) a4Sequencer: (A4Sequencer *) sequencer didCloseTriglessGateInTrack:(uint8_t)trackIdx withTrig:(A4Trig)trig atStep:(uint8_t)step;
@end

@interface A4Sequencer : NSObject <A4SequencerTrackDelegate, A4ProjectDelegate>
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
