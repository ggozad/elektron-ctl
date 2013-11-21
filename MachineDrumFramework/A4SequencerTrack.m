//
//  A4SequenceTrackerTrack.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 01/11/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4SequencerTrack.h"
#import "MDMath.h"

NSInteger clockticksForNoteLength(uint8_t len, NSInteger mult)
{
	if(len <= 30) return mdmath_map(len, 0, 30, 1, 12 * mult);
	if(len <= 46) return mdmath_map(len, 31, 46, 13 * mult, 24 * mult);
	if(len <= 62) return mdmath_map(len, 47, 62, 25 * mult, 48 * mult);
	if(len <= 78) return mdmath_map(len, 63, 78, 51 * mult, 96 * mult);
	if(len <= 94) return mdmath_map(len, 79, 94, 102 * mult, 192 * mult);
	if(len <= 110) return mdmath_map(len, 95, 110, 204 * mult, 384 * mult);
	if(len <= 126) return mdmath_map(len, 110, 126, 408 * mult, 768 * mult);
	return -1;
}

int int8cmp(const void *aa, const void *bb)
{
    const int8_t *a = aa, *b = bb;
    return (*a < *b) ? -1 : (*a > *b);
}

GateEvent gateEventNull()
{
	GateEvent event;
	event.step = -1;
	event.clockOn = -1;
	event.clockOff = -1;
	event.clocksPassed = 0;
	event.type = GateEventTypeUndefined;
	return event;
}

@implementation NSValue(GateEvent)
+(instancetype)valueWithGateEvent:(GateEvent)gateEvent
{
	return [NSValue valueWithBytes:&gateEvent objCType:@encode(GateEvent)];
}

- (GateEvent)gateEventValue
{
	GateEvent gateEvent; [self getValue:&gateEvent]; return gateEvent;
}
@end

@interface A4SequencerTrack()
@property (nonatomic, strong) NSMutableArray *gateEventValues, *gateEventValuesTrigless;
@property (nonatomic) BOOL playing, noteGateIsOpen, triglessGateIsOpen;
@property (nonatomic) A4Trig currentTrig, currentTriglessTrig;
@property (nonatomic) NSInteger trackLength;
@property (nonatomic) TrigContext currentTrigContext;
@property (nonatomic) uint8_t step;
- (void) notifyDelegateGateOn;
- (void) notifyDelegateGateOff;
- (void) notifyDelegateTriglessGateOn;
- (void) notifyDelegateTriglessGateOff;
@end

@implementation A4SequencerTrack

- (id)init
{
	if(self = [super init])
	{
		_gateEventValues = @[].mutableCopy;
		_gateEventValuesTrigless = @[].mutableCopy;
		_nextGate = gateEventNull();
		_nextTriglessGate = gateEventNull();
		_nextProperGate = gateEventNull();
		_currentOpenGate = gateEventNull();
		_currentOpenTriglessGate = gateEventNull();
		_clockInterpolationFactor = 1;
		_arp.speed = 1;
	}
	return self;
}

- (void)setClockInterpolationFactor:(NSInteger)clockInterpolationFactor
{
	if(clockInterpolationFactor < 1) clockInterpolationFactor = 1;
	_clockInterpolationFactor = clockInterpolationFactor;
}

- (void)setTrack:(A4PatternTrack *)track
{
	_track = track;
	[self refreshTrackEvents];
	[self refreshNextGateEventWithStrtClk:_clock];
	
	
	
}

- (void) refreshArpNotesForStep:(uint8_t)step
{
	if(_arp.isActive)
	{
		_arp.notesIdx = 0;
		_arp.notesLen = 1;
		
		int arpNotes[3];
		
		for (int i = 0; i < 3; i++)
		{
			uint8_t lock = _track.arp->noteLocks[i][step];
			if(lock != A4NULL) arpNotes[i] = lock - 64;
			else arpNotes[i] = _track.arp->notes[i] - 64;
		}
		
		_arp.noteOffsets[0] = 0;
		
		for (int i = 0; i < 3; i++)
		{
			BOOL alreadyAdded = NO;
			for (int j = 0; j < _arp.notesLen; j++)
			{
				if(arpNotes[j] == 0 || _arp.noteOffsets[j] == arpNotes[j])
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
		
		if(_track.arp->mode > A4ArpModeTrue)
		{
			qsort(_arp.noteOffsets, _arp.notesLen, sizeof(int8_t), int8cmp);
		}
	}
}

- (void)refreshTrackEvents
{
	if(!_track) return;
	
	_currentTrigContext = TrigContextProperTrig;
	_arp.isActive = _track.arp->mode > 0;
	_arp.speed = (_track.arp->speed + 1) * _clockInterpolationFactor;
	_arp.patternLength = _track.arp->patternLength+1;
	_arp.noteLengthClocks = clockticksForNoteLength(_track.arp->noteLength, _clockInterpolationFactor);
	
	double trackQuantize = _track.settings->quantizeAmount / 127.0;
	double globalQuantize = _track.pattern.quantize / 127.0;
	double overallQuantize = 1 - mdmath_clamp(trackQuantize+globalQuantize, 0, 1);
	
	switch(_track.pattern.timeScale)
	{
		case A4PatternPulsesPerStep_3: { _clockMultiplier =  3; break; }
		case A4PatternPulsesPerStep_4: { _clockMultiplier =  4; break; }
		case A4PatternPulsesPerStep_6: { _clockMultiplier =  6; break; }
		case A4PatternPulsesPerStep_8: { _clockMultiplier =  8; break; }
		case A4PatternPulsesPerStep_12:{ _clockMultiplier = 12; break; }
		case A4PatternPulsesPerStep_24:{ _clockMultiplier = 24; break; }
		case A4PatternPulsesPerStep_48:{ _clockMultiplier = 48; break; }
		default:{ _clockMultiplier = 6; break;}
	}
		
	_trackLength = _track.pattern.masterLength;
	if(_track.pattern.timeMode == A4PatternTimeModeAdvanced)
	{
		_trackLength = _track.settings->trackLength;
	}
	
	int clockupperBound = _trackLength * _clockInterpolationFactor * _clockMultiplier - 1;
	
	[_gateEventValues removeAllObjects];
	[_gateEventValuesTrigless removeAllObjects];
	
	GateEvent event;
	
	for (NSInteger stepIdx = 0; stepIdx < _trackLength; stepIdx++)
	{
		A4Trig trig = [_track trigAtStep:stepIdx];
		if(((trig.flags & A4TRIGFLAGS.TRIG) ^ (trig.flags & A4TRIGFLAGS.TRIGLESS)) && !(trig.flags & A4TRIGFLAGS.MUTE))
		{
			uint8_t len = trig.length;
			if(len == A4NULL) len = _track.settings->trigLength;
			int8_t mTim = trig.microTiming;
			
			NSInteger clockOn = stepIdx * _clockInterpolationFactor * _clockMultiplier +
			(_clockInterpolationFactor * mTim / 4 * overallQuantize);
			NSInteger eventLengthClockTicks = clockticksForNoteLength(len, _clockInterpolationFactor);
			
			NSInteger clockOff;
			if(eventLengthClockTicks == -1) clockOff = -1;
			else clockOff = mdmath_wrap((int)clockOn+(int)eventLengthClockTicks, 0, clockupperBound);
			
			event.clockOn = clockOn;
			event.clockOff = clockOff;
			event.clockLen = eventLengthClockTicks;
			event.clocksPassed = 0;
			event.step = stepIdx;
			
			if(trig.flags & A4TRIGFLAGS.TRIG)
			{
				event.type = GateEventTypeTrig;
				[_gateEventValues addObject:[NSValue valueWithGateEvent:event]];
			}
			else
			{
				event.type = GateEventTypeTrigless;
				[_gateEventValuesTrigless addObject:[NSValue valueWithGateEvent:event]];
			}
		}
	}
	
	NSComparisonResult (^comparator)(id, id) = ^NSComparisonResult(id obj1, id obj2)
	{
		NSValue *val1 = obj1;
		NSValue *val2 = obj2;
		
		GateEvent a = [val1 gateEventValue];
		GateEvent b = [val2 gateEventValue];
		
		if(a.clockOn < b.clockOn) return NSOrderedAscending;
		if(a.clockOn > b.clockOn) return NSOrderedDescending;
		else
		{
			if(a.step < b.step) return NSOrderedAscending;
			if(a.step > b.step) return NSOrderedDescending;
			return NSOrderedSame;
		}
	};

	[_gateEventValues sortUsingComparator:comparator];
	[_gateEventValuesTrigless sortUsingComparator:comparator];
}

- (void)start
{
	_noteGateIsOpen = NO;
	_triglessGateIsOpen = NO;
	_arp.gateIsOpen = NO;
	_arp.gateClockCount = 0;
	_arp.clock = 0;
	_arp.notesStep = 0;
	_arp.step = 0;
	_arp.octave = 0;
	_arp.gateIsOpen = NO;
	_arp.notesIdx = 0;
	_clock = 0;
	_playing = YES;
	_step = 0;
	
	[self refreshNextGateEventWithStrtClk:0];
	[self refreshNextGateEventTriglessWithStrtClk:0];
}

- (void)stop
{
	if(_arp.gateIsOpen || _noteGateIsOpen)
	{
		[self notifyDelegateGateOff];
	}
	if(_triglessGateIsOpen)
	{
		[self notifyDelegateTriglessGateOff];
	}
	
	_playing = NO;
	_noteGateIsOpen = NO;
	_triglessGateIsOpen = NO;
	_arp.gateIsOpen = NO;
	_arp.step = 0;
	_arp.octave = 0;
	_arp.notesIdx = 0;
	_arp.clock = 0;
	_arp.notesStep = 0;
}

- (void)continue
{
	_noteGateIsOpen = NO;
	_triglessGateIsOpen = NO;
	_arp.gateIsOpen = NO;
	_arp.step = 0;
	_arp.octave = 0;
	_arp.notesIdx = 0;
	_arp.clock = 0;
	_playing = YES;
}

- (void)clockTick
{
	if(_playing)
	{
//		DLog(@"tick %d", _clockInTrack);
		
		
		if(_clock == _nextTriglessGate.clockOn)
		{
			_triglessGateIsOpen = YES;
			
			if(_gateEventValuesTrigless.count)
			{
				_currentOpenTriglessGate = _nextTriglessGate;
				[self refreshNextGateEventTriglessWithStrtClk:_clock+1];
			}
			
			[self updateCurrentTriglessTrig];
			[self notifyDelegateTriglessGateOn];
		}
		
		if(_clock == _nextGate.clockOn)
		{
			_noteGateIsOpen = YES;
		
			if(_gateEventValues.count)
			{
				_currentOpenGate = _nextGate;
				[self refreshNextGateEventWithStrtClk:_clock+1];
			}
			
			if(_arp.isActive)
			{
				[self refreshArpNotesForStep:_currentOpenGate.step];
				_arp.clock = 0;
				_currentTrigContext = TrigContextProperTrig;
				_arp.step = 0;
				_arp.notesStep = 0;
			}
			else
			{
				[self updateCurrentTrig];
				[self notifyDelegateGateOn];
			}
		}
		
		if(_arp.isActive)
		{
			if(_noteGateIsOpen && _arp.clock % _arp.speed == 0)
			{
				if([_track arpPatternStateAtStep: _arp.step % _arp.patternLength])
				{
					if(_arp.clock > 0) _currentTrigContext = TrigContextArpTrig;
					_arp.gateIsOpen= YES;
					_arp.gateClockCount = 0;
					[self updateCurrentTrig];
					[self notifyDelegateGateOn];
				}
				_arp.step++;
			}
			if(_arp.gateIsOpen)
			{
				_arp.gateClockCount++;
				if(_arp.gateClockCount == _arp.noteLengthClocks)
				{
					_arp.gateIsOpen = NO;
					[self notifyDelegateGateOff];
				}
			}
			
			_arp.clock++;
			if(_arp.clock == NSIntegerMax) _arp.clock -= NSIntegerMax;
		}
		
		if(_noteGateIsOpen && _currentOpenGate.clocksPassed == _currentOpenGate.clockLen)
		{
			_noteGateIsOpen = NO;
			if(!_arp.gateIsOpen)
			{
				[self notifyDelegateGateOff];
			}
		}
		if(_triglessGateIsOpen && _currentOpenTriglessGate.clocksPassed == _currentOpenTriglessGate.clockLen)
		{
			_triglessGateIsOpen = NO;
			[self notifyDelegateTriglessGateOff];
		}
		
		if(_noteGateIsOpen) _currentOpenGate.clocksPassed++;
		if(_triglessGateIsOpen) _currentOpenTriglessGate.clocksPassed++;
		
		
		[self incrementClock];
	}
}

- (void) incrementClock
{
	_clock++;
	if(_clock == _clockMultiplier * _clockInterpolationFactor * _trackLength)
	{
		_clock = 0;
		[self refreshNextGateEventWithStrtClk:_clock];
	}
}

- (void)refreshNextGateEventWithStrtClk:(NSInteger)strtClk;
{
	NSInteger idx = -1;
	NSInteger i = 0;
	for(NSValue *val in _gateEventValues)
	{
		GateEvent event = [val gateEventValue];
		if(event.clockOn >= strtClk)
		{
			idx = i; break;
		}
		i++;
	}
	
	if(idx == -1)
	{
		i = 0;
		for(NSValue *val in _gateEventValues)
		{
			GateEvent event = [val gateEventValue];
			if(event.clockOn >= 0)
			{
				idx = i; break;
			}
			i++;
			
			if(event.clockOn == strtClk) break;
		}
	}
	
	if(idx == -1)
	{
		_nextGate = gateEventNull();
	}
	else
	{
		_nextGate = [_gateEventValues[idx] gateEventValue];
	}
	
	[self refreshNextProperGateEvent];
}

- (void)refreshNextGateEventTriglessWithStrtClk:(NSInteger)strtClk;
{
	NSInteger idx = -1;
	NSInteger i = 0;
	for(NSValue *val in _gateEventValuesTrigless)
	{
		GateEvent event = [val gateEventValue];
		if(event.clockOn >= strtClk)
		{
			idx = i; break;
		}
		i++;
	}
	
	if(idx == -1)
	{
		i = 0;
		for(NSValue *val in _gateEventValuesTrigless)
		{
			GateEvent event = [val gateEventValue];
			if(event.clockOn >= 0)
			{
				idx = i; break;
			}
			i++;
			
			if(event.clockOn == strtClk) break;
		}
	}
	
	if(idx == -1)
	{
		_nextTriglessGate = gateEventNull();
	}
	else
	{
		_nextTriglessGate = [_gateEventValuesTrigless[idx] gateEventValue];
	}
	
	[self refreshNextProperGateEvent];
}

- (void) refreshNextProperGateEvent
{
	GateEvent nextGateEvent = _nextGate;
	GateEvent nextTriglessGateEvent = _nextTriglessGate;
	int numClocksToNextGate = -1;
	int numClocksToNextTriglessGate = -1;
	NSInteger trackLenClocks = _clockMultiplier * _trackLength;
	
	if(nextGateEvent.clockOn > -1)
	{
		if(_clock < nextGateEvent.clockOn)
			numClocksToNextGate = nextGateEvent.clockOn - _clock;
		else
		{
			int lenClocks = trackLenClocks - _clock;
			lenClocks += nextGateEvent.step;
			numClocksToNextGate = lenClocks;
		}
	}
	if(nextTriglessGateEvent.clockOn > -1)
	{
		if(_clock < nextTriglessGateEvent.clockOn)
			numClocksToNextTriglessGate = nextTriglessGateEvent.clockOn - _clock;
		else
		{
			int lenClocks = trackLenClocks - _clock;
			lenClocks += nextTriglessGateEvent.step;
			numClocksToNextTriglessGate = lenClocks;
		}
	}
	if(numClocksToNextTriglessGate != -1 && numClocksToNextGate != -1)
	{
		if(numClocksToNextTriglessGate < numClocksToNextGate)
		{
			_nextProperGate =  nextTriglessGateEvent;
		}
		else
		{
			_nextProperGate = nextGateEvent;
		}
	}
	else if (numClocksToNextTriglessGate != -1)
	{
		_nextProperGate = nextTriglessGateEvent;
	}
	else if (numClocksToNextGate != -1)
	{
		_nextProperGate = nextGateEvent;
	}
	else _nextProperGate = gateEventNull();
}

- (void)reset
{
	_clock = 0;
	[self refreshTrackEvents];
	[self refreshNextGateEventWithStrtClk:_clock];
	[self refreshNextGateEventTriglessWithStrtClk:_clock];
}

- (void) updateCurrentTriglessTrig
{
	A4Trig trig = [_track trigAtStep:_currentOpenTriglessGate.step];
	_currentTriglessTrig = trig;
	if(_currentTriglessTrig.note != A4NULL && _track.settings->keyScale > 0)
	{
		[self constrainKeyInCurrentTriglessTrig];
	}
}

- (void) updateCurrentTrig
{
	A4Trig trig = [_track trigAtStep:_currentOpenGate.step];
	if(trig.note == A4NULL) trig.note = _track.settings->trigNote;
	if(trig.length == A4NULL) trig.length = _track.settings->trigLength;
	if(trig.velocity == A4NULL) trig.velocity = _track.settings->trigVelocity;
	int note = trig.note;
	BOOL arpPatternStepActive = [_track arpPatternStateAtStep:_arp.step % _arp.patternLength];
	A4ArpMode arpMode = _track.arp->mode;
	
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
			_arp.octave = mdmath_rand(0, _track.arp->range);
		}
		else
		{
			int l = _arp.notesLen;
			if(arpMode == A4ArpModeCycle){ l += l-2; if (l < 1) l = 1;}
			if(l > 0 &&
			   _track.arp->range &&
			   _arp.notesStep % l == 0 &&
			   _arp.notesStep > 0 &&
			   arpPatternStepActive)
			{
				_arp.octave = (_arp.octave + 1) % (_track.arp->range + 1);
			}
		}
		
		note = note + _arp.noteOffsets[_arp.notesIdx];
		note = note + _arp.octave * 12;
		trig.note = mdmath_clamp(note + _track.arp->patternOffsets[_arp.step % _arp.patternLength], 0, 127);
		trig.length = _track.arp->noteLength;
		if(trig.velocity == A4NULL) trig.velocity = _track.settings->trigVelocity;
		
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
	
	_currentTrig = trig;
	if(_track.settings->keyScale > 0)
	{
		[self constrainKeyInCurrentTrig];
	}
}



- (void) constrainKeyInCurrentTrig
{
	_currentTrig.note = [A4PatternTrack constrainKeyInTrack:_track note:_currentTrig.note];
}

- (void) constrainKeyInCurrentTriglessTrig
{
	_currentTriglessTrig.note = [A4PatternTrack constrainKeyInTrack:_track note:_currentTriglessTrig.note];
}

- (void)notifyDelegateGateOn
{
	[_delegate a4SequencerTrack:self didOpenGateWithTrig:_currentTrig step:_currentOpenGate.step context:_currentTrigContext];
}

- (void)notifyDelegateGateOff
{
	[_delegate a4SequencerTrack:self didCloseGateWithTrig:_currentTrig step:_currentOpenGate.step context:_currentTrigContext];
}

- (void)notifyDelegateTriglessGateOn
{
	[_delegate a4SequencerTrack:self didOpenTriglessGateWithTrig:_currentTriglessTrig step:_currentOpenTriglessGate.step];
}

- (void)notifyDelegateTriglessGateOff
{
	[_delegate a4SequencerTrack:self didCloseTriglessGateWithTrig:_currentTriglessTrig step:_currentOpenTriglessGate.step];
}

@end
