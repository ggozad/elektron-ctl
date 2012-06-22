//
//  MDPitch.m
//  sysexingApp3
//
//  Created by Jakob Penca on 6/22/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDPitch.h"

static float map(float value,
				float istart, float istop,
							  float ostart, float ostop) {
    return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
}

@implementation MDPitch

+ (MDNoteRange)noteRangeForMachineAbsoluteRange:(MDMachineAbsoluteNoteRange)fr
{
	uint8_t min = ceilf(fr.lowest);
	uint8_t max = ceilf(fr.highest);
	MDNoteRange r;
	r.minNote = min;
	r.maxNote = max;
	return r;
}

+ (uint8_t)pitchParamValueForNote:(uint8_t)note withFrequencyRange:(MDMachineAbsoluteNoteRange)fr
{
	MDNoteRange nr = [self noteRangeForMachineAbsoluteRange:fr];
	return (uint8_t)roundf(map(note, nr.minNote, nr.maxNote, 0, 127));
}




@end
