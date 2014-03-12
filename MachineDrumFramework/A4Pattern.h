//
//  A4Pattern.h
//  A4Sysex
//
//  Created by Jakob Penca on 3/28/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//



#import "A4SysexMessage.h"
#import "A4PatternTrack.h"
#import "A4Trig.h"
#import "A4Params.h"

#pragma once

@class A4Pattern;

#define A4PatternMasterLengthInfinite 1
#define A4PatternMasterChangeOff 1

typedef enum A4PatternTimeMode
{
	A4PatternTimeModeNormal,
	A4PatternTimeModeAdvanced
}
A4PatternTimeMode;

typedef enum A4PatternPulsesPerStep
{
	A4PatternPulsesPerStep_3 = 0x00, // 2
	A4PatternPulsesPerStep_4 = 0x01, // 3/2
	A4PatternPulsesPerStep_6 = 0x02,  // 1
	A4PatternPulsesPerStep_8 = 0x03,  // 3/4
	A4PatternPulsesPerStep_12 = 0x04,  // 1/2
	A4PatternPulsesPerStep_24 = 0x05,  // 1/4
	A4PatternPulsesPerStep_48 = 0x06   // 1/8
}
A4PatternPulsesPerStep;

typedef enum A4PatternTimeScale
{
	A4PatternTimeScale_2_1 = 0x00,  // 2
	A4PatternTimeScale_3_2 = 0x01,  // 3/2
	A4PatternTimeScale_1_1 = 0x02,  // 1
	A4PatternTimeScale_3_4 = 0x03,  // 3/4
	A4PatternTimeScale_1_2 = 0x04,  // 1/2
	A4PatternTimeScale_1_4 = 0x05,  // 1/4
	A4PatternTimeScale_1_8 = 0x06   // 1/8
}
A4PatternTimeScale;


typedef struct A4LockRow
{
	uint8_t parameterID;
	uint8_t track;
	uint8_t pattern[64];
}
A4LockRow;

typedef struct A4LockStorage
{
	A4LockRow row[128];
}
A4LockStorage;

typedef struct A4PatternSettings
{
	UInt16  masterLength;
	UInt16  masterChange;
	uint8_t kit;
	uint8_t UNKNOWN;
	uint8_t timeMode;
	uint8_t timeScale;
	uint8_t quantize;
}
A4PatternSettings;

uint8_t A4PatternPulsesPerStepForTimescale(A4PatternTimeScale timeScale);
BOOL A4LocksForTrackAndStep(A4Pattern *pattern, uint8_t step, uint8_t track, A4PVal *locks, uint8_t *len);
BOOL A4LocksCreateForTrackAndStep(A4Pattern *pattern, uint8_t step, uint8_t track, A4PVal **locks, uint8_t *len);
void A4LocksRelease(A4PVal **locks);

@interface A4Pattern : A4SysexMessage

@property (nonatomic) A4LockStorage *locks;
@property (nonatomic, readonly) uint8_t numberOfUsedLocks;
@property (nonatomic, strong) NSMutableArray *tracks;
@property (nonatomic) UInt16  masterLength;
@property (nonatomic) UInt16  masterChange;
@property (nonatomic) uint8_t kit;
@property (nonatomic) A4PatternTimeMode timeMode;
@property (nonatomic) A4PatternTimeScale timeScale;
@property (nonatomic) uint8_t quantize;
@property (nonatomic, readonly, copy) NSArray *soundLocks;

+ (A4Pattern *)defaultPattern;

- (void) setArpNoteLock:(uint8_t)n forNote: (uint8_t) i atStep:(uint8_t) step inTrack:(uint8_t)track;
- (uint8_t) arpNoteLockForNote:(uint8_t) i atStep:(uint8_t) step inTrack:(uint8_t)track;
- (void) setArpPatternState:(BOOL)state atStep:(uint8_t)step inTrack:(uint8_t)track;
- (BOOL) arpPatternStateAtStep:(uint8_t)step inTrack:(uint8_t)track;

- (void) setTrig:(A4Trig) trig atStep:(uint8_t) step inTrack:(uint8_t) track;
- (void) setTrig:(A4Trig) trig withLock:(A4PVal)lock atStep:(uint8_t) step inTrack:(uint8_t) track;
- (A4Trig) trigAtStep:(uint8_t)step inTrack:(uint8_t)track;
- (A4PVal) setLock:(A4PVal)lock atStep:(uint8_t)step inTrack:(uint8_t)track;
- (A4PVal) lockForParam:(A4Param)param atStep:(uint8_t)step inTrack:(uint8_t)track;

- (void) clearLockForParam:(A4Param)param atStep:(uint8_t)step inTrack:(uint8_t)track;
- (void) clearAllLocksForParam:(A4Param)param inTrack:(uint8_t)track;
- (void) clearAllLocksAtStep:(uint8_t)step inTrack:(uint8_t)track;
- (void) clearTrigAtStep:(uint8_t)step inTrack:(uint8_t)track;
- (BOOL) clearAllLocksInTrack:(uint8_t)track;
- (BOOL) clearAllLocks;
- (void) clearTrack:(uint8_t)track;

- (void) shiftTrack:(uint8_t)track steps:(int8_t) shift;

- (A4PatternTrack *) track:(uint8_t)i;
- (A4PatternTrack *) track:(uint8_t)i copy:(BOOL)copy;
- (A4PatternTrack *) copyTrack:(A4PatternTrack *)track toIndex:(uint8_t)i;
- (BOOL) isDefaultPattern;
- (BOOL) isEqualToPattern:(A4Pattern *)pattern;

- (void)replaceSoundLockIndex:(uint8_t)oldIndex withSoundLockIndex:(uint8_t)newIndex;

@end
