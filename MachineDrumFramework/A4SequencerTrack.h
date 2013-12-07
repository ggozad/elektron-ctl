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
	GateEventTypeTrig,
	GateEventTypeTrigless
}
GateEventType;

typedef struct GateEvent
{
	int8_t track;
	int8_t step;
	NSInteger clockOn;
	NSInteger clockLen;
	NSInteger clocksPassed;
	NSInteger clockOff;
	GateEventType type;
	TrigContext context;
	A4Trig trig;
	uint8_t voices[4];
	NSInteger id;
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
	GateEvent event;
}
ArpState;

GateEvent gateEventNull();

@interface NSValue(GateEvent)
+(instancetype)valueWithGateEvent:(GateEvent)gateEvent;
- (GateEvent)gateEventValue;
@end

@interface A4SequencerTrack : NSObject
@property (nonatomic) ArpState arp;
@property (nonatomic) NSInteger clock;
@property (nonatomic) BOOL mute;
@property (nonatomic, weak) A4PatternTrack *track;
@property (nonatomic) uint8_t trackIdx;
@property (nonatomic) NSInteger clockMultiplier, clockInterpolationFactor;
@property (nonatomic) GateEvent *onEventsForThisTick, *offEventsForThisTick;
@property (nonatomic) NSUInteger onEventsLength, offEventsLength;
@property (nonatomic) GateEvent *openGates;
@property (nonatomic) NSUInteger numberOfOpenGates;
- (void) clockTick;
- (void) start;
- (void) stop;
- (void) reset;
- (void) continue;
- (GateEvent) openGate:(GateEvent)event;
- (GateEvent) closeGate:(GateEvent)event;
@end
