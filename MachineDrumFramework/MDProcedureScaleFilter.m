//
//  MDProcedureScaleFilter.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 6/27/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDProcedureScaleFilter.h"
#import "MDPitch.h"
#import "MDParameterLock.h"

@implementation MDProcedureScaleFilter

uint8_t base = MDPitchNote_C;

- (void)processPattern:(MDPattern *)pattern kit:(MDKit *)kit
{
	MDKitTrack *kitTrack = [kit.tracks objectAtIndex:self.track];
	MDMachineID mid = kitTrack.machine;
	
	MDNoteRange nr = [MDPitch noteRangeForMachine:mid];
	if(nr.minNote == 0 && nr.maxNote == 0)
	{
		DLog(@"note range uncool for mid: %d", mid);
		return;
	}
	
	
	for (int step = 0; step < 64; step++)
	{
		if([pattern trigAtTrack:self.track step:step])
		{
			uint8_t oldPitch = 0;
			MDParameterLock *lock = [pattern lockAtTrack:self.track step:step param:0];
			if(lock)
			{
				oldPitch = lock.lockValue;
			}
			else
			{
				MDKitTrack *t = [kit.tracks objectAtIndex:self.track];
				MDKitTrackParams *p = t.params;
				oldPitch = [p valueForParam:0];
			}
			
			
			uint8_t oldNote = [MDPitch noteClosestToPitchParamValue: oldPitch forMachineID: mid];
			
			uint8_t oldNoteStrippedFromOctave = oldNote % 12;
			uint8_t octave = oldNote / 12;
			
			uint8_t newNote = 0;

			for (int i = 0; i < self.scale.count; i++)
			{
				uint8_t currentNoteFromScale = (self.baseNote + [[self.scale objectAtIndex:i] integerValue]) % 12;
				DLog(@"current note: %d", currentNoteFromScale);
				if(currentNoteFromScale >= oldNoteStrippedFromOctave)
				{
				
					newNote = currentNoteFromScale;
					DLog(@"new note: %d", newNote);
					break;
				}
			}
			newNote += octave * 12;
			//DLog(@"old note: %d, octave: %d, strippedNote: %d, new note: %d", oldNote, octave, oldNoteStrippedFromOctave, newNote);
			
			int8_t newPitch = [MDPitch pitchParamValueForNote:newNote forMachine:mid rangeMode:MDPitchRangeMode_WRAP];
			
			//DLog(@"old pitch: %d new pitch: %d", oldPitch, newPitch);
			
			if(newPitch != -1 && newPitch < 128)
				[pattern setLock:[MDParameterLock lockForTrack:self.track param:0 step:step value:newPitch] setTrigIfNone:NO];
			else
			{
				if(lock)
					[pattern clearLockAtTrack:self.track param:0 step:step clearTrig:YES];
				else
					[pattern setTrigAtTrack:self.track step:step toValue:0];
			}
				
		}
	}
}

@end
