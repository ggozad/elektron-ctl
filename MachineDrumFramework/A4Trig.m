//
//  A4Trig.c
//  MachineDrumFramework
//
//  Created by Jakob Penca on 9/24/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4Trig.h"
#import "MDMath.h"

const A4TrigFlagsStruct A4TRIGFLAGS =
{
	1<<0,
	1<<1,
	1<<2,
	1<<3,
	1<<4,
	1<<5,
	1<<6,
	1<<7,
	1<<8,
	1<<9,
	1<<10,
	0x1C1
};

A4Trig A4TrigMakeEmpty()
{
	A4Trig trig;
	
	trig.flags						= 0x00;
	trig.notes[0]					= 0xFF;
	trig.notes[1]					= 0xFF;
	trig.notes[2]					= 0xFF;
	trig.notes[3]					= 0xFF;
	trig.velocity					= 0xFF;
	trig.length						= 0xFF;
	trig.microTiming				= 0x00;
	trig.soundLock					= 0xFF;
	return trig;
}

A4Trig A4TrigMakeTrigless()
{
	A4Trig trig;
	
	trig.flags =					A4TRIGFLAGS.TRIGLESS;
	trig.notes[0]					= 0xFF;
	trig.notes[1]					= 0xFF;
	trig.notes[2]					= 0xFF;
	trig.notes[3]					= 0xFF;
	trig.velocity					= 0xFF;
	trig.length						= 0xFF;
	trig.microTiming				= 0x00;
	trig.soundLock					= 0xFF;
	return trig;
}


A4Trig A4TrigMakeDefault()
{
	A4Trig trig;
	
	trig.flags =					A4TRIGFLAGS.DEFAULT;
	trig.notes[0]					= 0xFF;
	trig.notes[1]					= 0xFF;
	trig.notes[2]					= 0xFF;
	trig.notes[3]					= 0xFF;
	trig.velocity					= 0xFF;
	trig.length						= 0xFF;
	trig.microTiming				= 0x00;
	trig.soundLock					= 0xFF;
	return trig;
}

A4Trig A4TrigMakeWithFlags(UInt16 flags)
{
	A4Trig trig;
	
	trig.flags =					flags;
	trig.notes[0]					= 0xFF;
	trig.notes[1]					= 0xFF;
	trig.notes[2]					= 0xFF;
	trig.notes[3]					= 0xFF;
	trig.velocity					= 0xFF;
	trig.length						= 0xFF;
	trig.microTiming				= 0x00;
	trig.soundLock					= 0xFF;
	return trig;
}

A4Trig A4TrigMakeDefaultWithNote(uint8_t note)
{
	A4Trig trig = A4TrigMakeDefault();
	trig.notes[0]					= note;
	trig.notes[1]					= 0xFF;
	trig.notes[2]					= 0xFF;
	trig.notes[3]					= 0xFF;
	return trig;
}

A4Trig A4TrigMake(UInt16 flags, uint8_t note, uint8_t velocity, uint8_t length, int8_t microtime, uint8_t soundlock)
{
	A4Trig trig;
	trig.flags = flags;
	trig.notes[0]					= note;
	trig.notes[1]					= 0xFF;
	trig.notes[2]					= 0xFF;
	trig.notes[3]					= 0xFF;
	trig.velocity = velocity;
	trig.length = length;
	trig.microTiming = microtime;
	trig.soundLock = soundlock;
	return trig;
}

