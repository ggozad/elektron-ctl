//
//  A4PatternTrack.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 9/21/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A4Sound.h"
#import "A4Trig.h"

typedef struct A4Steps16
{
	UInt16 steps[0x40];
}
A4Steps16;

typedef struct A4Steps8
{
	uint8_t steps[0x40];
}
A4Steps8;

typedef enum A4ArpMode
{
	A4ArpModeOff,
	A4ArpModeTrue,
	A4ArpModeUp,
	A4ArpModeDown,
	A4ArpModeCycle,
	A4ArpModeShuffle,
	A4ArpModeRandom,
}
A4ArpMode;

typedef enum A4KeyScale
{
	A4KeyScaleOff,
	A4KeyScaleMaj,
	A4KeyScaleMin
}
A4KeyScale;

typedef enum A4NoteValue
{
	A4NoteValueC,
	A4NoteValueCS,
	A4NoteValueD,
	A4NoteValueDS,
	A4NoteValueE,
	A4NoteValueF,
	A4NoteValueFS,
	A4NoteValueG,
	A4NoteValueGS,
	A4NoteValueA,
	A4NoteValueAS,
	A4NoteValueB
}
A4NoteValue;

typedef struct A4TrackSettings
{
	uint8_t trigNote;
	uint8_t trigVelocity;
	uint8_t trigLength;
	uint8_t UNKNOWN_1;
	uint8_t keyboardOctave;
	uint8_t UNKNOWN_2;
	uint8_t trackLength;
	uint8_t quantizeAmount;
	uint8_t keyNote;
	uint8_t keyScale;
	uint8_t transposable;
}
A4TrackSettings;

typedef struct A4Arp
{
	uint8_t mode;
	uint8_t speed;
	uint8_t range;
	uint8_t legato;
	uint8_t noteLength;
	uint8_t UNKNOWN_1;
	uint8_t notes[0x3];
	uint8_t noteLocks[3][64];
	uint8_t patternLength;
	UInt16  pattern;
	int8_t patternOffsets[0x10];
}
A4Arp;

@class A4Pattern;

@interface A4PatternTrack : NSObject

@property (nonatomic, assign) A4Pattern *pattern;
@property (nonatomic) char *payload;
@property (nonatomic) BOOL ownsPayload;
@property (nonatomic) UInt16 *flags;
@property (nonatomic) uint8_t *notes;
@property (nonatomic) uint8_t *velocities;
@property (nonatomic) uint8_t *lengths;
@property (nonatomic) uint8_t *microtimes;
@property (nonatomic) uint8_t *soundLocks;
@property (nonatomic) A4Arp *arp;
@property (nonatomic) A4TrackSettings *settings;

- (void) setArpNoteLock:(uint8_t)n forNote: (uint8_t) i atStep:(uint8_t) step;
- (uint8_t) arpNoteLockForNote:(uint8_t) i atStep:(uint8_t) step;
- (void) setArpPatternState:(BOOL)state atStep:(uint8_t)step;
- (BOOL) arpPatternStateAtStep:(uint8_t)step;

+ (int) constrainKeyInTrack: (A4PatternTrack *)track note:(int)note;
+ (A4PatternTrack *)trackWithPayloadAddress:(char *)addr pattern:(A4Pattern *)pattern;
- (void) clearAllTrigs;
- (void) setTrig:(A4Trig)trig atStep:(uint8_t)step;
- (A4Trig) trigAtStep:(uint8_t)step;
- (void) clearTrigAtStep:(uint8_t)step;

@end
