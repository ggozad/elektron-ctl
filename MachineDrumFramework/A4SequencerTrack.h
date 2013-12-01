//
//  A4SequenceTrackerTrack.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 01/11/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A4Pattern.h"

#pragma once

@class A4SequencerTrack;


typedef enum TrigContext
{
	TrigContextProperTrig,
	TrigContextArpTrig,
}
TrigContext;

typedef enum GateEventType
{
	GateEventTypeUndefined,
	GateEventTypeTrig,
	GateEventTypeTrigless
}
GateEventType;

typedef struct GateEvent
{
	NSInteger step;
	NSInteger clockOn;
	NSInteger clockLen;
	NSInteger clocksPassed;
	NSInteger clockOff;
	GateEventType type;
}
GateEvent;

typedef struct ArpState
{
	BOOL isActive;
	BOOL gateIsOpen;
	BOOL down;
	int8_t noteOffsets[4];
	uint8_t octave;
	uint8_t notesLen;
	uint8_t notesIdx;
	uint8_t notesStep;
	uint8_t step;
	NSInteger speed;
	uint8_t patternLength;
	NSInteger noteLengthClocks;
	NSInteger gateClockCount;
	NSInteger clock;
}
ArpState;

GateEvent gateEventNull();

@protocol A4SequencerTrackDelegate <NSObject>
- (void) a4SequencerTrack:(A4SequencerTrack *)sequencerTrack didOpenGateWithTrig:(A4Trig)trig step:(uint8_t)step context:(TrigContext)ctxt;
- (void) a4SequencerTrack:(A4SequencerTrack *)sequencerTrack didCloseGateWithTrig:(A4Trig)trig step:(uint8_t)step context:(TrigContext)ctxt;
- (void) a4SequencerTrack:(A4SequencerTrack *)sequencerTrack didOpenTriglessGateWithTrig:(A4Trig)trig step:(uint8_t)step;
- (void) a4SequencerTrack:(A4SequencerTrack *)sequencerTrack didCloseTriglessGateWithTrig:(A4Trig)trig step:(uint8_t)step;
@end

@interface A4SequencerTrack : NSObject
@property (nonatomic, readonly) GateEvent currentOpenGate, nextGate;
@property (nonatomic, readonly) GateEvent currentOpenTriglessGate, nextTriglessGate;
@property (nonatomic, readonly) GateEvent nextProperGate;
@property (nonatomic) ArpState arp;
@property (nonatomic) NSInteger clock;
@property (nonatomic) BOOL mute;
@property (nonatomic, weak) A4PatternTrack *track;
@property (nonatomic) uint8_t trackIdx;
@property (nonatomic, weak) id<A4SequencerTrackDelegate> delegate;
@property (nonatomic) NSInteger clockMultiplier, clockInterpolationFactor;
- (void) clockTick;
- (void) start;
- (void) stop;
- (void) reset;
- (void) continue;
@end
