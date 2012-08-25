//
//  MDPitch.h
//  sysexingApp3
//
//  Created by Jakob Penca on 6/22/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDConstants.h"
#import "MDKitMachine.h"

#ifndef MD_PITCH_STRUCTS
#define MD_PITCH_STRUCTS


typedef enum MDPitchOctaves
{
	MDPitchOctave_MINUS_TWO = 0,
	MDPitchOctave_MINUS_ONE = 12,
	MDPitchOctave_ZERO = 24,
	MDPitchOctave_ONE = 36,
	MDPitchOctave_TWO = 48,
	MDPitchOctave_THREE = 60,
	MDPitchOctave_FOUR = 72,
	MDPitchOctave_FIVE = 84,
	MDPitchOctave_SIX = 96,
	MDPitchOctave_SEVEN = 108,
	MDPitchOctave_EIGHT = 120
}
MDPitchOctaves;

typedef enum MDPitchNotes
{
	MDPitchNote_C,
	MDPitchNote_C_SHARP,
	MDPitchNote_D,
	MDPitchNote_D_SHARP,
	MDPitchNote_E,
	MDPitchNote_F,
	MDPitchNote_F_SHARP,
	MDPitchNote_G,
	MDPitchNote_G_SHARP,
	MDPitchNote_A,
	MDPitchNote_A_SHARP,
	MDPitchNote_B
}
MDPitchNotes;

typedef enum MDPitchRangeMode
{
	MDPitchRangeMode_IGNORE,
	MDPitchRangeMode_WRAP,
	MDPitchRangeMode_CLAMP
}
MDPitchRangeMode;


typedef struct MDNoteRange
{
	uint8_t minNote;
	uint8_t maxNote;
}
MDNoteRange;

typedef struct MDMachineAbsoluteNoteRange
{
	float lowest;
	float highest;
}
MDMachineAbsoluteNoteRange;

MDMachineAbsoluteNoteRange MDMachineAbsoluteNoteRangeMake(float l, float h);

#endif


@interface MDPitch : NSObject

+ (BOOL) machineIsPitchable:(MDMachineID)mid;
+ (MDNoteRange) noteRangeForMachineAbsoluteRange:(MDMachineAbsoluteNoteRange)fr;
+ (MDNoteRange) noteRangeForMachine:(MDMachineID)machineID;

+ (uint8_t) noteClosestToPitchParamValue: (uint8_t) pitch forMachineID: (MDMachineID)mid;
+ (int8_t) pitchParamValueForNote:(uint8_t)note withAbsoluteNoteRange:(MDMachineAbsoluteNoteRange)fr rangeMode:(MDPitchRangeMode)rangeMode;
+ (int8_t) pitchParamValueForNote:(uint8_t)note forMachine:(MDMachineID)machineID rangeMode:(MDPitchRangeMode)rangeMode;
+ (int8_t) pitchParamValueForNote:(uint8_t)note forMachineName:(NSUInteger)machineName rangeMode:(MDPitchRangeMode)rangeMode;
+ (MDMachineAbsoluteNoteRange)absoluteNoteRangeForMachineID:(MDMachineID)mid;

@end
