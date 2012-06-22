//
//  MDPitch.h
//  sysexingApp3
//
//  Created by Jakob Penca on 6/22/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef MD_PITCH_STRUCTS
#define MD_PITCH_STRUCTS

typedef struct MDlalalalala
{
	int la;
	
}MDlalalalala;


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

#endif


@interface MDPitch : NSObject

+ (MDNoteRange) noteRangeForMachineAbsoluteRange:(MDMachineAbsoluteNoteRange)fr;
+ (uint8_t) pitchParamValueForNote:(uint8_t)note withFrequencyRange:(MDMachineAbsoluteNoteRange)fr;

@end
