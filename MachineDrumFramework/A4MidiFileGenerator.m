//
//  A4MidiFileGenerator.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 11/02/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import "A4MidiFileGenerator.h"
#import "A4Pattern.h"
#import "SMF.h"
#import "MDMath.h"

@implementation A4MidiFileGenerator

+ (NSData *)smfDataForPattern:(A4Pattern *)pattern
{
	SMF *smf = [SMF new];
	smf.format = SMFFormatMultiTrack;
	smf.ticksPerBeat = 32767;
	int numSteps = pattern.masterLength;
	
	float clockDivider = 1;
	switch(pattern.timeScale)
	{
		case A4PatternTimeScale_1_8:{clockDivider = 1/8.0; break;}
		case A4PatternTimeScale_1_4:{clockDivider = 1/4.0; break;}
		case A4PatternTimeScale_1_2:{clockDivider = 1/2.0; break;}
		case A4PatternTimeScale_3_4:{clockDivider = 3/4.0; break;}
		case A4PatternTimeScale_1_1:{clockDivider = 1/1.0; break;}
		case A4PatternTimeScale_3_2:{clockDivider = 3/2.0; break;}
		case A4PatternTimeScale_2_1:{clockDivider = 2/1.0; break;}
	}
	
	float ticksPerStep = smf.ticksPerBeat/4/clockDivider;
	
	for(int trk = 0; trk < 6; trk++)
	{
		A4PatternTrack *patternTrack = [pattern track:trk];
		SMFTrack *smfTrack = [SMFTrack new];
		[smf.tracks addObject:smfTrack];
		if(pattern.timeMode == A4PatternTimeModeAdvanced) numSteps = patternTrack.settings->trackLength;
		
		float trackQuantize = patternTrack.settings->quantizeAmount / 127.0;
		float globalQuantize = pattern.quantize / 127.0;
		float overallQuantize = 1 - mdmath_clampf(trackQuantize+globalQuantize, 0, 1);
		
		for(int stp = 0; stp < numSteps; stp++)
		{
			A4Trig trig = [patternTrack trigAtStep:stp];
			
			if(trig.flags & A4TRIGFLAGS.TRIG)
			{
				if(trig.velocity == A4NULL) trig.velocity = patternTrack.settings->trigVelocity;
				if(trig.length == A4NULL) trig.length = patternTrack.settings->trigLength;
				if(trig.notes[0] == A4NULL) trig.notes[0] = patternTrack.settings->trigNote;
				if(trig.length == 127) trig.length = 126; // clamp INF length
				
				float startTick = stp * ticksPerStep;
				float normalizedMTime = mdmath_mapf(trig.microTiming, -24, 24, -1, 1);
				normalizedMTime *= overallQuantize;
				
				startTick += ticksPerStep * normalizedMTime;
				if(startTick < 0)
				{
					startTick += ticksPerStep * numSteps;
				};
				
				float stopTick = startTick + ticksPerStep * A4ParamEnvGateLengthMultiplier(trig.length);
				stopTick = mdmath_clamp(stopTick, 0, ticksPerStep * numSteps);
				
				for(int noteIdx = 0; noteIdx < 4; noteIdx++)
				{
					if(trig.notes[noteIdx] != A4NULL)
					{
						MidiNoteOn noteOn;
						noteOn.channel = 0;
						
						if(noteIdx == 0)
						{
							noteOn.note = trig.notes[noteIdx];
							noteOn.note = [A4PatternTrack constrainKeyInTrack:patternTrack note:noteOn.note];
						}
						else
						{
							int note = trig.notes[0] + (int)trig.notes[noteIdx] - 0x40;
							noteOn.note = [A4PatternTrack constrainKeyInTrack:patternTrack note:mdmath_clamp(note, 0, 127)];
						}
						noteOn.velocity = trig.velocity;
						
						SMFEvent *event = [SMFEvent smfEventWithAbsoluteTick:(NSUInteger)startTick noteOn:noteOn];
						[smfTrack insertEvent:event];
						
						MidiNoteOff noteOff;
						noteOff.channel = noteOn.channel;
						noteOff.note = noteOn.note;
						noteOff.velocity = noteOn.velocity;
						
						event = [SMFEvent smfEventWithAbsoluteTick:(NSUInteger)stopTick noteOff:noteOff];
						[smfTrack insertEvent:event];
					}
				}
			}
		}
		
		SMFEndOfTrackEvent *eof = [SMFEndOfTrackEvent smfEndOfTrackEventWithAbsoluteTick:ticksPerStep*numSteps];
		[smfTrack insertEvent:eof];
	}
	
	return smf.data;
}

@end
