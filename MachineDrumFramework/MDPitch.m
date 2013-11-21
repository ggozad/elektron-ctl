//
//  MDPitch.m
//  sysexingApp3
//
//  Created by Jakob Penca on 6/22/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDPitch.h"
#import "MDMath.h"

MDMachineAbsoluteNoteRange MDMachineAbsoluteNoteRangeMake(float l, float h)
{
	MDMachineAbsoluteNoteRange r;
	r.lowest = l;
	r.highest = h;
	return r;
}


@implementation MDPitch

+ (BOOL)machineIsPitchable:(MDMachineID)mid
{
	MDMachineAbsoluteNoteRange r = [self absoluteNoteRangeForMachineID:mid];
	if(r.lowest > 0 || r.highest > 0) return YES;
	return NO;
}

+ (uint8_t)noteClosestToPitchParamValue:(uint8_t)pitch forMachineID:(MDMachineID)mid
{
	MDMachineAbsoluteNoteRange r = [self absoluteNoteRangeForMachineID:mid];
	uint8_t n = roundf(mdmath_map(pitch, 0, 127, r.lowest, r.highest));
	if(n < 128) return n; return 0;
}

+ (double)noteForPitchParamValue:(uint8_t)pitch forMachineID:(MDMachineID)mid
{
	MDMachineAbsoluteNoteRange r = [self absoluteNoteRangeForMachineID:mid];
	return mdmath_map(pitch, 0, 127, r.lowest, r.highest);
}

+ (MDNoteRange)noteRangeForMachineAbsoluteRange:(MDMachineAbsoluteNoteRange)fr
{
	int8_t min = ceilf(fr.lowest);
	int8_t max = floorf(fr.highest);
	MDNoteRange r;
	r.minNote = min;
	r.maxNote = max;
	return r;
}

+ (int8_t)pitchParamValueForNote:(uint8_t)note withAbsoluteNoteRange:(MDMachineAbsoluteNoteRange)fr rangeMode:(MDPitchRangeMode)rangeMode
{
	if(fr.lowest == 0 && fr.highest == 0) return -1;
	
	// old version differs from Processing pitchplot implementation:
	
	//MDNoteRange nr = [self noteRangeForMachineAbsoluteRange:fr];
	//if(nr.minNote == 0 && nr.maxNote == 0) return -1;
	//if(note < nr.minNote || note > nr.maxNote) return -1;
	//NSInteger pitchVal = (NSInteger)roundf(map(note, nr.minNote, nr.maxNote, 0, 127));
	
	
	int pitchVal = roundf(mdmath_map(note, fr.lowest, fr.highest, 0, 127));
	if(pitchVal >= 0 && pitchVal <= 127) return (int8_t)pitchVal;
	
	if(rangeMode == MDPitchRangeMode_CLAMP)
	{
		if(note < fr.lowest)
			return roundf(mdmath_map(ceilf(fr.lowest), fr.lowest, fr.highest, 0, 127));
		return roundf(mdmath_map(floorf(fr.highest), fr.lowest, fr.highest, 0, 127));
	}
	if(rangeMode == MDPitchRangeMode_WRAP)
	{
		int octaveShifts = 0;
		int maxOctaves = 12;
		int wrappedNote = note;
		
		while (octaveShifts++ < maxOctaves)
		{
			if(note < fr.lowest)
				wrappedNote += 12;
			else
				wrappedNote -= 12;
			
			pitchVal = roundf(mdmath_map(wrappedNote, fr.lowest, fr.highest, 0, 127));
			if(pitchVal >= 0 && pitchVal <= 127) return (int8_t)pitchVal;
		}
	}
	return -1;
}

+ (int8_t)pitchParamValueForNote:(uint8_t)note forMachine:(MDMachineID)machineID rangeMode:(MDPitchRangeMode)rangeMode
{
	MDMachineAbsoluteNoteRange r = [self absoluteNoteRangeForMachineID: machineID];
	return [self pitchParamValueForNote:note withAbsoluteNoteRange:r rangeMode:rangeMode];
}

+ (int8_t)pitchParamValueForNote:(uint8_t)note forMachineName:(NSUInteger)machineName rangeMode:(MDPitchRangeMode)rangeMode
{
	MDMachineID mid = [MDKitMachine machineIDForMachineName:machineName];
	MDMachineAbsoluteNoteRange r = [self absoluteNoteRangeForMachineID: mid];
	return [self pitchParamValueForNote:note withAbsoluteNoteRange:r rangeMode:rangeMode];
}

+ (MDNoteRange)noteRangeForMachine:(MDMachineID)machineID
{
	return [self noteRangeForMachineAbsoluteRange:[self absoluteNoteRangeForMachineID:machineID]];
}

+ (MDMachineAbsoluteNoteRange)absoluteNoteRangeForMachineID:(MDMachineID)mid
{
	MDMachineName name = [MDKitMachine machineNameFromMachineID:mid];
	
	if(name == MDMachineName_TRX_B2) return MDMachineAbsoluteNoteRangeMake(6.6, 44.4);
	if(name == MDMachineName_TRX_BD) return MDMachineAbsoluteNoteRangeMake(23.1, 46.6);
	if(name == MDMachineName_TRX_CB) return MDMachineAbsoluteNoteRangeMake(76.0, 79.2);
	if(name == MDMachineName_TRX_CL) return MDMachineAbsoluteNoteRangeMake(82.2, 103.0);
	if(name == MDMachineName_TRX_RS) return MDMachineAbsoluteNoteRangeMake(52.8, 64.7);
	if(name == MDMachineName_TRX_SD) return MDMachineAbsoluteNoteRangeMake(52.8, 64.7);
	if(name == MDMachineName_TRX_XC) return MDMachineAbsoluteNoteRangeMake(41.0, 64.6);
	if(name == MDMachineName_TRX_XT) return MDMachineAbsoluteNoteRangeMake(38.0, 61.6);
	
	if(name == MDMachineName_EFM_BD) return MDMachineAbsoluteNoteRangeMake(20.4, 67.4);
	if(name == MDMachineName_EFM_CP) return MDMachineAbsoluteNoteRangeMake(46.8, 112.2);
	if(name == MDMachineName_EFM_CY) return MDMachineAbsoluteNoteRangeMake(56.9, 86.7);
	if(name == MDMachineName_EFM_HH) return MDMachineAbsoluteNoteRangeMake(58.8, 88.5);
	if(name == MDMachineName_EFM_RS) return MDMachineAbsoluteNoteRangeMake(58.8, 106.4);
	if(name == MDMachineName_EFM_SD) return MDMachineAbsoluteNoteRangeMake(46.8, 76.5);
	if(name == MDMachineName_EFM_XT) return MDMachineAbsoluteNoteRangeMake(29.1, 52.6);
		
	return MDMachineAbsoluteNoteRangeMake(0, 0);
}



@end
