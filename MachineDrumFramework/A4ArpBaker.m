//
//  A4ArpBaker.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 27/02/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import "A4ArpBaker.h"
#import "MDMath.h"

#define A4ArpBakerNextGateStartNone (-666)

typedef struct ArpTrig
{
	A4Trig trig;
	uint8_t step;
	BOOL okay, skip;
}
ArpTrig;


typedef struct ArpState
{
	float nextParentGateStart;
	float parentGateStart;
	float parentGateLength;
	float stepIncrease;
	float currentTrigPos;
	A4Trig parentTrig;
	
	BOOL isActive;
	BOOL triglessIsActive;
	
	BOOL down;
	int8_t noteOffsets[4];
	uint8_t octave;
	uint8_t notesLen;
	uint8_t notesIdx;
	uint8_t notesStep;
	uint8_t step;
	NSInteger speed;
	uint8_t patternLength;
	uint8_t noteLength;
}
ArpState;

static int int8cmp(const void *aa, const void *bb)
{
    const int8_t *a = aa, *b = bb;
    return (*a < *b) ? -1 : (*a > *b);
}


@interface A4ArpBaker()
@property (nonatomic) ArpState arp;
@property (nonatomic, strong) A4Pattern *pattern, *modPattern;
@property (nonatomic) uint8_t trackIdx;
@property (nonatomic) A4PVal *locksBuf;
@property (nonatomic) uint8_t locksLen;
@end


@implementation A4ArpBaker

- (id)init
{
	if(self = [super init])
	{
		self.locksBuf = malloc(sizeof(A4PVal) * 128);
	}
	return self;
}

- (void)dealloc
{
	free(self.locksBuf);
}

- (ArpTrig) ArpTrigNext
{
	int trackLen = _pattern.masterLength;
	if(_pattern.timeMode == A4PatternTimeModeAdvanced)
	{
		trackLen = [_pattern track:_trackIdx].settings->trackLength;
	}
	
	ArpTrig t;
	A4Trig trig = [self updateArp];
	t.trig = trig;
	int step = roundf(_arp.currentTrigPos);
	t.step = mdmath_wrap(step, 0, trackLen-1);
	t.trig.microTiming = roundf(mdmath_map(_arp.currentTrigPos - step, -1, 1, -24, 24));
	
	t.okay = _arp.currentTrigPos < _arp.parentGateStart + _arp.parentGateLength;
	
	if(t.okay && _arp.nextParentGateStart != A4ArpBakerNextGateStartNone)
	{
		BOOL wrap = NO;
		if(_arp.currentTrigPos > trackLen) wrap = YES;
		float rest = _arp.currentTrigPos - (int)_arp.currentTrigPos;
		float currentTrigPosWrapped = mdmath_wrap((int) _arp.currentTrigPos, 0, trackLen-1) + rest;
		
		if(! wrap && _arp.parentGateStart < _arp.nextParentGateStart &&
		   _arp.currentTrigPos >= _arp.nextParentGateStart)
		{
			t.okay = NO;
		}
		
		if( wrap && _arp.parentGateStart > _arp.nextParentGateStart &&
		   currentTrigPosWrapped >= _arp.nextParentGateStart)
		{
			t.okay = NO;
		}
	}
	
	t.skip = ![[_pattern track:_trackIdx] arpPatternStateAtStep:_arp.step % _arp.patternLength];
	
	A4Trig trigless = [_pattern trigAtStep:t.step inTrack:_trackIdx];
	if(trigless.flags & A4TRIGFLAGS.TRIGLESS)
	{
		A4LocksForTrackAndStep(_pattern, t.step, _trackIdx, _locksBuf, &_locksLen);
	}
	
	_arp.currentTrigPos += _arp.stepIncrease;
	_arp.step++;
	return t;
}


- (void) resetArpToStep:(uint8_t) step inTrack:(uint8_t)trackIdx
{
	A4PatternTrack *track = [_pattern track:trackIdx];
	A4Trig trig = [track trigAtStepAllFieldsFilled:step];
	if(trig.flags & A4TRIGFLAGS.TRIG)
	{
		A4LocksForTrackAndStep(_pattern, step, trackIdx, _locksBuf, &_locksLen);
		
		float scale = A4PatternPulsesPerStepForTimescale(_pattern.timeScale) / 6.0;
		int trackLen = _pattern.masterLength;
		if(_pattern.timeMode == A4PatternTimeModeAdvanced)
		{
			trackLen = [_pattern track:_trackIdx].settings->trackLength;
		}
		
		int nextStepStart = mdmath_wrap(step + 1, 0, trackLen-1);
		_arp.nextParentGateStart = A4ArpBakerNextGateStartNone;
		for (int i = nextStepStart; i < nextStepStart + trackLen; i++)
		{
			int iWrapped = mdmath_wrap(i, 0, trackLen-1);
			A4Trig nextTrig = [track trigAtStepAllFieldsFilled:iWrapped];
			if(nextTrig.flags & A4TRIGFLAGS.TRIG && iWrapped != step)
			{
				float startPos = (iWrapped + mdmath_map(trig.microTiming, -24, 24, -1, 1)) * scale;
				while (startPos > trackLen) startPos -= trackLen;
				_arp.nextParentGateStart = startPos;
				break;
			}
		}
		
		_arp.parentTrig = trig;
		_arp.speed = [_pattern track:trackIdx].arp->speed + 1;
		_arp.isActive = [_pattern track:trackIdx].arp->mode > 0;
		float parentGateLength = A4ParamEnvGateLengthMultiplier(_arp.parentTrig.length);
		parentGateLength = mdmath_clampf(parentGateLength, 0, trackLen);
		
		_arp.parentGateLength = parentGateLength;
		float startPos = (step + mdmath_map(trig.microTiming, -24, 24, -1, 1)) * scale;
		while (startPos > trackLen) startPos -= trackLen;
		_arp.parentGateStart = startPos;
		float stepsPerArpStep = mdmath_map(_arp.speed, 6, 12, 1, 2) / scale;
		_arp.stepIncrease = stepsPerArpStep;
		_arp.currentTrigPos = _arp.parentGateStart;
		_arp.patternLength = track.arp->patternLength + 1;
		_arp.octave = 0;
		_arp.step = 0;
		_arp.down = NO;
		
		[self refreshArpNotesForStep:step inTrack:trackIdx];
	}
}


- (void) refreshArpNotesForStep:(uint8_t)step inTrack:(uint8_t) trackIdx
{
	if(_arp.isActive)
	{
		A4PatternTrack *track = [_pattern track:trackIdx];
		_arp.notesIdx = 0;
		_arp.notesLen = 1;
		
		int arpNotes[3];
		
		for (int i = 0; i < 3; i++)
		{
			uint8_t lock = track.arp->noteLocks[i][step];
			if(lock != A4NULL) arpNotes[i] = lock - 64;
			else arpNotes[i] = track.arp->notes[i] - 64;
		}
		
		_arp.noteOffsets[0] = 0;
		
		for (int i = 0; i < 3; i++)
		{
			BOOL alreadyAdded = NO;
			for (int j = 0; j < _arp.notesLen; j++)
			{
				if(arpNotes[i] == 0 || _arp.noteOffsets[j] == arpNotes[i])
				{
					alreadyAdded = YES;
					break;
				}
			}
			if(!alreadyAdded)
			{
				_arp.noteOffsets[_arp.notesLen++] = arpNotes[i];
			}
		}
		
		if(track.arp->mode > A4ArpModeTrue)
		{
			qsort(_arp.noteOffsets, _arp.notesLen, sizeof(int8_t), int8cmp);
		}
	}
}

- (A4Trig) updateArp
{
	if(!_arp.isActive) return A4TrigMakeEmpty();
	A4PatternTrack *track = [_pattern track:_trackIdx];
	A4Trig trig = _arp.parentTrig;
	int note = trig.notes[0];
	for(int i = 1; i < 4; i++)
	{
		trig.notes[i] = A4NULL;
	}
	
	BOOL arpPatternStepActive = [track arpPatternStateAtStep:_arp.step % _arp.patternLength];
	A4ArpMode arpMode = track.arp->mode;
	
	if(_arp.isActive)
	{
		if(_arp.step == 0)
		{
			_arp.down = NO;
			_arp.octave = 0;
			_arp.notesIdx = 0;
			_arp.notesStep = 0;
			
			if(arpMode == A4ArpModeDown)
			{
				_arp.notesIdx = _arp.notesLen-1;
			}
		}
		
		if(arpMode == A4ArpModeRandom)
		{
			_arp.octave = mdmath_rand(0, track.arp->range);
		}
		else
		{
			int l = _arp.notesLen;
			if(arpMode == A4ArpModeCycle){ l += l-2; if (l < 1) l = 1;}
			if(l > 0 &&
			   track.arp->range &&
			   _arp.notesStep % l == 0 &&
			   _arp.notesStep > 0 &&
			   arpPatternStepActive)
			{
				_arp.octave = (_arp.octave + 1) % (track.arp->range + 1);
			}
		}
		
		note = note + _arp.noteOffsets[_arp.notesIdx];
		note = note + _arp.octave * 12;
		trig.notes[0] = mdmath_clamp(note + track.arp->patternOffsets[_arp.step % _arp.patternLength], 0, 127);
		trig.length = track.arp->noteLength;
		if(trig.velocity == A4NULL) trig.velocity = track.settings->trigVelocity;
		
		if(_arp.notesLen >= 1 && arpPatternStepActive)
		{
			_arp.notesStep++;
			if(arpMode == A4ArpModeUp || arpMode == A4ArpModeTrue)
			{
				_arp.notesIdx = mdmath_wrap(_arp.notesIdx + 1, 0, _arp.notesLen-1);
			}
			else if(arpMode == A4ArpModeDown)
			{
				_arp.notesIdx = mdmath_wrap(_arp.notesIdx - 1, 0, _arp.notesLen-1);
			}
			else if(arpMode == A4ArpModeCycle)
			{
				if(_arp.down)
				{
					if(_arp.notesIdx == 0)
					{
						_arp.down = NO;
						_arp.notesIdx++;
					}
					else
					{
						_arp.notesIdx--;
					}
				}
				else
				{
					if(_arp.notesIdx == _arp.notesLen-1)
					{
						_arp.down = YES;
						_arp.notesIdx--;
					}
					else
					{
						_arp.notesIdx++;
					}
				}
			}
			else if (arpMode == A4ArpModeShuffle)
			{
				int i = _arp.notesIdx;
				if(_arp.notesLen > 1) while (i == _arp.notesIdx) i = mdmath_rand(0, _arp.notesLen-1);
				_arp.notesIdx = i;
			}
			else if (arpMode == A4ArpModeRandom)
			{
				_arp.notesIdx = mdmath_rand(0, _arp.notesLen-1);
			}
		}
	}
	
	return trig;
}

- (A4Pattern *)bakeArpInPattern:(A4Pattern *)pattern track:(uint8_t)trackIdx
{
	if(trackIdx > 5) return pattern;
	A4PatternTrack *track = [pattern track:trackIdx];
	if(track.arp->mode == A4ArpModeOff) return pattern;
	
	NSData *sysexData = [pattern sysexData];
	self.pattern = [A4Pattern messageWithSysexData:sysexData];
	self.modPattern = [A4Pattern messageWithSysexData:sysexData];
	[self.modPattern clearTrack:trackIdx];
	self.trackIdx = trackIdx;
	
	uint8_t clockTicksPerArpTrig = track.arp->speed + 1;
	uint8_t clockTicksPerSequencerStep = A4PatternPulsesPerStepForTimescale(pattern.timeScale);
	
	float arpToStepRatio = clockTicksPerArpTrig / (float) clockTicksPerSequencerStep;
	if(arpToStepRatio < 1) return pattern;
	
	uint8_t trackLen = track.settings->trackLength;
	if(pattern.timeMode == A4PatternTimeModeNormal)
		trackLen = pattern.masterLength;
	
	for(int stepIdx = 0; stepIdx < 64; stepIdx++)
	{
		A4Trig originalTrig = [track trigAtStepAllFieldsFilled:stepIdx];
		
		if(originalTrig.flags & A4TRIGFLAGS.TRIG)
		{
			[self resetArpToStep:stepIdx inTrack:trackIdx];
			
			for (int clrStepIdx = stepIdx; clrStepIdx < 64; clrStepIdx++)
			{
				[_modPattern clearTrigAtStep:clrStepIdx inTrack:trackIdx];
			}
			
			while(1)
			{
				ArpTrig t = [self ArpTrigNext];
				if(!t.okay) break;
				if(t.skip) continue;
				[_modPattern setTrig:t.trig atStep:t.step inTrack:trackIdx];
				
				for(int i = 0; i < _locksLen; i++)
				{
					[_modPattern setLock:_locksBuf[i] atStep:t.step inTrack:trackIdx];
				}
			}
		}
	}
	

	[_modPattern track:trackIdx].arp->mode = A4ArpModeOff;
	return _modPattern;
}



@end
