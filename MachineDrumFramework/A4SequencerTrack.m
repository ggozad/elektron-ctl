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
	event.context = TrigContextProperTrig;
	event.type = GateEventTypeTrig;
	event.trig = A4TrigMakeEmpty();
	event.voices[0] = A4NULL;
	event.voices[1] = A4NULL;
	event.voices[2] = A4NULL;
	event.voices[3] = A4NULL;
	event.id = -1;
	return event;
}


static NSInteger GateEventIDGenerate()
{
	static NSInteger id;
	id++;
	if(id == NSIntegerMax) id = 0;
	return id;
}

static void GateEventSetID(GateEvent *event)
{
	event->id = GateEventIDGenerate();
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
@property (nonatomic, strong) NSMutableArray *gateEventValues;
@property (nonatomic) BOOL playing;
@property (nonatomic) NSInteger trackLength;
@property (nonatomic) uint8_t step;

#define kMaxOpenGates 128

@property (nonatomic) GateEvent nextGate;



@end

@implementation A4SequencerTrack

- (id)init
{
	if(self = [super init])
	{
		_openGates = malloc(sizeof(GateEvent) * kMaxOpenGates);
		_onEventsForThisTick = malloc(sizeof(GateEvent) * kMaxOpenGates);
		_offEventsForThisTick = malloc(sizeof(GateEvent) * kMaxOpenGates);
		_gateEventValues = @[].mutableCopy;
		_clockInterpolationFactor = 1;
		_arp.speed = 1;
	}
	return self;
}

- (void)dealloc
{
	free(_openGates);
	free(_onEventsForThisTick);
	free(_offEventsForThisTick);
}

- (void)setMuted:(BOOL)muted
{
	if(_muted != muted)
	{
		if(muted)
		{
			[self cancelActiveGatesAndArp];
		}
		else
		{
			[self refreshNextGateEventWithStrtClk:_clock];
		}
		_muted = muted;
	}
}

- (GateEvent)openGate:(GateEvent)event
{
	return [self addGateEvent:event];
}

- (GateEvent)closeGate:(GateEvent)event
{
	return [self removeGateEvent:event];
}

- (GateEvent) addGateEvent:(GateEvent) event
{
	if(_numberOfOpenGates == kMaxOpenGates) return gateEventNull();
	
	for(int i = 0; i < _numberOfOpenGates; i++)
	{
		if(_openGates[i].id == event.id) return gateEventNull();
	}
	
	_openGates[_numberOfOpenGates++] = event;
	return event;
}

- (GateEvent) removeGateEvent:(GateEvent) event
{
	if(!_numberOfOpenGates) return gateEventNull();
	
	for(int i = _numberOfOpenGates-1; i >= 0; i--)
	{
		GateEvent currEvent = _openGates[i];
		if(event.id == currEvent.id)
		{
			int numGatesToMove = (_numberOfOpenGates-1)-i;
			if(numGatesToMove >= 1)
			{
				memmove(&_openGates[i], &_openGates[i+1], sizeof(GateEvent) * numGatesToMove);
			}
			_numberOfOpenGates--;
			return currEvent;
		}
	}
	return gateEventNull();
}

- (GateEvent) lastUsedGateEventWithType:(GateEventType)type
{
	GateEvent event = gateEventNull();
	for(int i = _numberOfOpenGates-1 ; i >= 0; i--)
	{
		GateEvent openEvent = _openGates[i];
		if(openEvent.clockOn == _clock && openEvent.type == type)
		{
			event = openEvent; break;
		}
	}
	return event;
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
	
	GateEvent event = gateEventNull();
	
	for (NSInteger stepIdx = 0; stepIdx < _trackLength; stepIdx++)
	{
		A4Trig trig = [_track trigAtStep:stepIdx];
		if(((trig.flags & A4TRIGFLAGS.TRIG) ^ (trig.flags & A4TRIGFLAGS.TRIGLESS)) && !(trig.flags & A4TRIGFLAGS.MUTE))
		{
			if(trig.length == A4NULL) trig.length = _track.settings->trigLength;
			if(trig.velocity == A4NULL) trig.velocity = _track.settings->trigVelocity;
			
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
			event.trig = trig;
			event.context = TrigContextProperTrig;
			event.track = _trackIdx;
			
			if(trig.flags & A4TRIGFLAGS.TRIG)
			{
				event.type = GateEventTypeTrig;
			}
			else
			{
				event.type = GateEventTypeTrigless;
			}
			
			[_gateEventValues addObject:[NSValue valueWithGateEvent:event]];
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
}

- (void) cancelActiveGatesAndArp
{
	_arp.gateIsOpen = NO;
	_arp.step = 0;
	_arp.octave = 0;
	_arp.notesIdx = 0;
	_arp.clock = 0;
	_arp.notesStep = 0;
	_offEventsLength = 0;
	
	for(int i = 0; i < _numberOfOpenGates; i++)
	{
		if(i >= _numberOfOpenGates) break;
		_offEventsForThisTick[_offEventsLength++] = _openGates[i];
	}
}

- (void)start
{
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
}

- (void)stop
{
	_playing = NO;
	[self cancelActiveGatesAndArp];
}

- (void)continue
{
	_arp.gateIsOpen = NO;
	_arp.step = 0;
	_arp.octave = 0;
	_arp.notesIdx = 0;
	_arp.clock = 0;
	_playing = YES;
	
	[self refreshNextGateEventWithStrtClk:_clock];
}



- (void)clockTick
{
	_onEventsLength = 0;
	_offEventsLength = 0;
	
	for(int i = 0; i < _numberOfOpenGates; i++)
	{
		if(i >= _numberOfOpenGates) break;
		_openGates[i].clocksPassed++;
		if(_openGates[i].clocksPassed == _openGates[i].clockLen)
		{
			_offEventsForThisTick[_offEventsLength++] = _openGates[i];
		}
	}
	
	if(_playing)
	{
		if(!_muted)
		{
			if(_clock == _nextGate.clockOn)
			{
				GateEvent e = _nextGate;
				GateEventSetID(&e);
				_onEventsForThisTick[_onEventsLength++] = e;
				[self refreshNextGateEventWithStrtClk:_clock+1];
			}
		}
		
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
		if(_gateEventValues.count)
		{
			_nextGate = [_gateEventValues[0] gateEventValue];
		}
		else
		{
			_nextGate = gateEventNull();
		}
	}
	else
	{
		_nextGate = [_gateEventValues[idx] gateEventValue];
	}
}

- (void)reset
{
	_clock = 0;
	[self refreshTrackEvents];
	[self refreshNextGateEventWithStrtClk:_clock];
}

/*
- (void) updateArp
{
	if(!_arp.isActive) return;
	A4Trig trig = _arp.event.trig;
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
	
	if(_track.settings->keyScale > 0)
	{
		[self constrainKeyInCurrentTrig];
	}
}
*/


- (void) updateCurrentTrig
{
	
}



- (void) constrainKeyInTrig:(A4Trig *)trig
{
	for(int i = 0; i < 4; i++)
	{
		trig->notes[i] = [A4PatternTrack constrainKeyInTrack:_track note:trig->notes[i]];
	}
}

@end
