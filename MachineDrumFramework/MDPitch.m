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
							  float ostart, float ostop)
{
    return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
}

MDMachineAbsoluteNoteRange MDMachineAbsoluteNoteRangeMake(float l, float h)
{
	MDMachineAbsoluteNoteRange r;
	r.lowest = l;
	r.highest = h;
	return r;
}


@implementation MDPitch

+ (MDNoteRange)noteRangeForMachineAbsoluteRange:(MDMachineAbsoluteNoteRange)fr
{
	int8_t min = ceilf(fr.lowest);
	int8_t max = floorf(fr.highest);
	MDNoteRange r;
	r.minNote = min;
	r.maxNote = max;
	return r;
}

+ (int8_t)pitchParamValueForNote:(uint8_t)note withAbsoluteNoteRange:(MDMachineAbsoluteNoteRange)fr
{
	if(fr.lowest == 0 && fr.highest == 0) return -1;
	MDNoteRange nr = [self noteRangeForMachineAbsoluteRange:fr];
	if(nr.minNote == 0 && nr.maxNote == 0) return -1;
	if(note < nr.minNote || note > nr.maxNote) return -1;
	int8_t pitchVal = (int8_t)roundf(map(note, nr.minNote, nr.maxNote, 0, 127));
	return pitchVal;
	return -1;
}

+ (int8_t)pitchParamValueForNote:(uint8_t)note forMachine:(MDMachineID)machineID
{
	MDMachineAbsoluteNoteRange r = [self absoluteNoteRangeForMachineID: machineID];
	MDNoteRange nr = [self noteRangeForMachine:machineID];
	if(note < nr.minNote || note > nr.maxNote) return -1;
	int8_t pitchVal = [self pitchParamValueForNote:note withAbsoluteNoteRange:r];
	return pitchVal;
	return -1;
}

+ (int8_t)pitchParamValueForNote:(uint8_t)note forMachineName:(NSUInteger)machineName
{
	MDMachineID mid = [MDKitMachine machineIDForMachineName:machineName];
	MDMachineAbsoluteNoteRange r = [self absoluteNoteRangeForMachineID: mid];
	MDNoteRange nr = [self noteRangeForMachineAbsoluteRange:r];
	if(note < nr.minNote || note > nr.maxNote) return -1;
	int8_t pitchVal = [self pitchParamValueForNote:note withAbsoluteNoteRange:r];
	return pitchVal;
	return -1;
}

+ (MDNoteRange)noteRangeForMachine:(MDMachineID)machineID
{
	return [self noteRangeForMachineAbsoluteRange:[self absoluteNoteRangeForMachineID:machineID]];
}

+ (MDMachineAbsoluteNoteRange)absoluteNoteRangeForMachineID:(MDMachineID)mid
{
	MDMachineName name = [MDKitMachine machineNameFromMachineID:mid];
	
	if(name == MDMachineName_TRX_B2) return MDMachineAbsoluteNoteRangeMake(6.6, 44.5);
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
	if(name == MDMachineName_EFM_XT) return MDMachineAbsoluteNoteRangeMake(29.1, 52.2);
	
	return MDMachineAbsoluteNoteRangeMake(0, 0);
}



@end
