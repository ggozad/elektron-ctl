//
//  A4Trig.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 9/22/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <MacTypes.h>
#import <stdint.h>
#import "A4Params.h"

#pragma once

typedef struct A4TrigFlagsStruct
{
	UInt16 TRIG;
	UInt16 TRIGLESS;
	UInt16 MUTE;
	UInt16 ACCENT;
	UInt16 NOTESLIDE;
	UInt16 PARAMSLIDE;
	UInt16 NOTE;
	UInt16 ENV1;
	UInt16 ENV2;
	UInt16 LFO1;
	UInt16 LFO2;
	UInt16 DEFAULT;
}
A4TrigFlagsStruct;

typedef struct A4Trig
{
	UInt16	flags;
	uint8_t notes[4];
	uint8_t velocity;
	uint8_t length;
	int8_t  microTiming;
	uint8_t soundLock;
}
A4Trig;

extern const A4TrigFlagsStruct A4TRIGFLAGS;

A4Trig A4TrigMakeEmpty();
A4Trig A4TrigMakeTrigless();
A4Trig A4TrigMakeDefault();
A4Trig A4TrigMakeWithFlags(UInt16 flags);
A4Trig A4TrigMakeDefaultWithNote(uint8_t note);
A4Trig A4TrigMake(UInt16 flags, uint8_t note, uint8_t velocity, uint8_t length, int8_t microtime, uint8_t soundlock);



