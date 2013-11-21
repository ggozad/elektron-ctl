//
//  A4TrackerTrack.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 10/11/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A4Sound.h"
#import "A4Pattern.h"
#import "A4Project.h"
#import "A4SequencerTrack.h"
@class A4Sequencer;

@interface A4TrackerTrack : NSObject
@property (nonatomic, weak) A4Sequencer *sequencer;
@property (nonatomic) NSInteger clockMultiplier, clockInterpolationFactor;
@property (nonatomic) A4TrackerParam_t *paramsPostParams;
@property (nonatomic) A4TrackerParam_t *paramsPostLocks;
@property (nonatomic) A4TrackerParam_t *paramsPostModulations;
@property (nonatomic) A4TrackerParam_t *paramsPostNote;
@property (nonatomic, strong) A4Kit *sourceKit;
@property (nonatomic, strong) A4PatternTrack *sourceTrack;
@property (nonatomic, strong) A4Project *sourceProject;
@property (nonatomic) uint8_t trackIdx;
@property (nonatomic) GateEvent nextGateEvent, currentGateEvent;
@property (nonatomic) GateEvent nextGateEventTrigless, currentGateEventTrigless;
@property (nonatomic) GateEvent nextProperGateEvent;
@property (nonatomic) GateEvent lastProperGateEvent;
- (void) openGateAtStep:(uint8_t)step trig:(A4Trig)trig context:(TrigContext)context time:(A4TrackerParam_t)time;
- (void) closeGateWithContext:(TrigContext)context time:(A4TrackerParam_t)time;
- (void) openTriglessGateAtStep:(uint8_t)step trig:(A4Trig)trig time:(A4TrackerParam_t)time;
- (void) closeTriglessGateWithTime:(A4TrackerParam_t)time;
- (void) updateContinuousValuesWithTime:(A4TrackerParam_t)time;
- (void) tick;
@end
