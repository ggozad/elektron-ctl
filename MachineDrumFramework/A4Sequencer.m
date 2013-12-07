//
//  A4Sequencer.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 08/11/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4Sequencer.h"



@interface A4Sequencer ()
{
	A4Pattern *_pattern;
}
@property (nonatomic, strong) A4Pattern *queuedPattern;
@property (nonatomic) NSInteger clock;
@property (nonatomic) GateEvent *requestedOnEvents, *requestedOffEvents;
@property (nonatomic) NSUInteger requestedOnEventsLen, requestedOffEventsLen;
@end

@implementation A4Sequencer

- (BOOL)a4Project:(A4Project *)project shouldStoreReceivedKit:(A4Kit *)kit
{
	return [_delegate a4Project:project shouldStoreReceivedKit:kit];
}

- (BOOL)a4Project:(A4Project *)project shouldStoreReceivedSound:(A4Sound *)sound
{
	return [_delegate a4Project:project shouldStoreReceivedSound:sound];
}

- (BOOL)a4Project:(A4Project *)project shouldStoreReceivedPattern:(A4Pattern *)pattern
{
	if([_delegate a4Project:project shouldStoreReceivedPattern:pattern])
	{
		if (! _pattern || _pattern.position == pattern.position)
		{
			if(! [_pattern isEqualToPattern:pattern])
			{
				[self setPattern:pattern mode:A4SequencerModeJump];
			}
		}
		return YES;
	}
	return NO;
}

- (void)clockTick
{
	if(_playing)
	{
		for(A4SequencerTrack *trk in _tracks)
		{
			[trk clockTick];
		}
		_clock++;
		_requestedOnEventsLen = 0;
		_requestedOffEventsLen = 0;
		
		[self accumulateClosedGatesFromTracksToFreedVoices];
		[self handleOffRequests];
		[self accumulateOpenedGatesFromTracksToRequestedVoices];
		[self handleOnRequests];
		
		[self checkEndOfPattern];
	}
}

- (void) accumulateClosedGatesFromTracksToFreedVoices
{
	for(int i = 0; i < 4; i++)
	{
		A4SequencerTrack *track = _tracks[i];
		if(track.offEventsLength)
		{
			for(int i = 0; i < track.offEventsLength; i++)
			{
				GateEvent event = track.offEventsForThisTick[i];
				_requestedOffEvents[_requestedOffEventsLen++] = event;
			}
		}
	}
}

- (void) accumulateOpenedGatesFromTracksToRequestedVoices
{
	for(int i = 0; i < 4; i++)
	{
		A4SequencerTrack *track = _tracks[i];
		if(track.onEventsLength)
		{
			for(int i = 0; i < track.onEventsLength; i++)
			{
				GateEvent event = track.onEventsForThisTick[i];
				_requestedOnEvents[_requestedOnEventsLen++] = event;
			}
		}
	}
}

- (void) handleOnRequests
{
	if(_requestedOnEventsLen)
	{
		[self.voiceAllocator handleOnRequests:_requestedOnEvents len:_requestedOnEventsLen];
		for(int i = 0; i < _requestedOnEventsLen; i++)
		{
			BOOL hasVoice = NO;
			for(int j = 0; j < 4; j++)
			{
				if(_requestedOnEvents[i].voices[j] != A4NULL){ hasVoice = YES; break;}
			}
			if(hasVoice)
			{
				[_tracks[_requestedOnEvents[i].track] openGate:_requestedOnEvents[i]];
				[self.delegate a4Sequencer:self didOpenGate:_requestedOnEvents[i]];
			}
		}
	}
	
}

- (void) handleOffRequests
{
	if(_requestedOffEventsLen)
	{
		[self.voiceAllocator handleOffRequests:_requestedOffEvents len:_requestedOffEventsLen];
		for(int i = 0; i < _requestedOffEventsLen; i++)
		{
			[_tracks[_requestedOffEvents[i].track] closeGate:_requestedOffEvents[i]];
			[self.delegate a4Sequencer:self didCloseGate:_requestedOffEvents[i]];
		}
	}
}

- (void)a4VoiceAllocator:(A4VoiceAllocator *)allocator didStealVoice:(uint8_t)voice noteIdx:(uint8_t)noteIdx gate:(GateEvent)event
{
	A4SequencerTrack *track = _tracks[event.track];
	GateEvent *openGates = track.openGates;
	GateEvent affectedEvent;
	BOOL didSteal = NO;
	for (int i = 0; i < track.numberOfOpenGates; i++)
	{
		
		if(openGates[i].id == event.id)
		{
			if(openGates[i].voices[noteIdx] == voice)
			{
				openGates[i].voices[noteIdx] = A4NULL;
				affectedEvent = openGates[i];
				didSteal = YES;
			}
		}
	}
	
	if(didSteal)
	{
		[self.delegate a4Sequencer:self didStealVoice:voice noteIdx:noteIdx gate:affectedEvent];
	}
}

- (void)a4VoiceAllocator:(A4VoiceAllocator *)allocator didNullifyGate:(GateEvent)event
{
	event = [_tracks[event.track] closeGate:event];
	if(event.step > -1)
	{
		[self.delegate a4Sequencer:self didCloseGate:event];
	}
}

- (void) checkEndOfPattern
{
	if((_pattern.masterLength != A4PatternMasterLengthInfinite &&
		_pattern.masterChange != A4PatternMasterChangeOff &&
		(_clock == _clockInterpolationFactor * _clockMultiplier * _pattern.masterLength ||
		 (_clock == _clockInterpolationFactor * _clockMultiplier *_pattern.masterChange &&
		  self.queuedPattern)))
	   ||
	   (_pattern.masterChange != A4PatternMasterChangeOff &&
		_pattern.masterLength == A4PatternMasterLengthInfinite &&
		(_clock == _clockInterpolationFactor * _clockMultiplier * _pattern.masterChange &&
		 self.queuedPattern))
	   ||
	   ((_pattern.masterChange == A4PatternMasterChangeOff &&
		 _pattern.masterLength != A4PatternMasterLengthInfinite) &&
		_clock == _clockInterpolationFactor * _clockMultiplier * _pattern.masterLength))
	{
		[self reachedEndOfPattern];
	}
}

- (void) reachedEndOfPattern
{
	[self.delegate a4SequencerDidReachEndOfPattern:self];
	_clock = 0;
	
	if(self.queuedPattern)
	{
		self.pattern = self.queuedPattern;
		for(A4SequencerTrack *trk in _tracks)
		{
			[trk reset];
		}
		self.queuedPattern = nil;
	}
	else
	{
		self.pattern = [self.project patternAtPosition:self.pattern.position];
		for(A4SequencerTrack *trk in _tracks)
		{
			[trk reset];
		}
	}
}

- (void)reset
{
	_clock = 0;
	for(A4SequencerTrack *trk in _tracks)
	{
		[trk reset];
	}
	[_delegate a4SequencerDidReset:self];
}

- (void)continue
{
	_playing = YES;
	for(A4SequencerTrack *trk in _tracks)
	{
		[trk continue];
	}
	[_delegate a4SequencerDidContinue:self];
}

- (void)start
{
	if(self.queuedPattern)
	{
		self.pattern = self.queuedPattern;
		self.queuedPattern = nil;
	}
	_clock = 0;
	_playing = YES;
	for(A4SequencerTrack *trk in _tracks)
	{
		[trk start];
	}
	[_delegate a4SequencerDidStart:self];
}

- (void)setClockInterpolationFactor:(NSInteger)clockInterpolationFactor
{
	if(clockInterpolationFactor < 1) clockInterpolationFactor = 1;
	_clockInterpolationFactor = clockInterpolationFactor;
	
	for(A4SequencerTrack *trk in _tracks)
	{
		trk.clockInterpolationFactor = clockInterpolationFactor;
	}
}

- (void)stop
{
	_playing = NO;
	for(A4SequencerTrack *trk in _tracks)
	{
		[trk stop];
	}
	
	[self accumulateClosedGatesFromTracksToFreedVoices];
	[self handleOffRequests];
	[self.voiceAllocator reset];
	
	[_delegate a4SequencerDidStop:self];
}


- (void)setPattern:(A4Pattern *)pattern mode:(A4SequencerMode)mode
{
	if(mode == A4SequencerModeJump || mode == A4SequencerModeStart)
	{
		self.pattern = pattern;
		if(mode == A4SequencerModeStart)
		{
			[self reset];
		}
	}
	else if (mode == A4SequencerModeQueue)
	{
		if(_playing) self.queuedPattern = pattern;
		else self.pattern = pattern;
	}
}

- (void)setKit:(A4Kit *)kit
{
	_kit = kit;
	self.voiceAllocator.mode = kit.polyphony->allocationMode;
	self.voiceAllocator.polyphonicVoices = (kit.polyphony->activeVoices) & 0x0F;
}

- (BOOL) setPattern:(A4Pattern *)pattern
{
	@synchronized(self)
	{
		if([pattern isEqualToPattern:_pattern]) return NO;
		
		_pattern = [A4Pattern messageWithSysexData:pattern.sysexData];
		switch(_pattern.timeScale)
		{
			case A4PatternPulsesPerStep_3: { self.clockMultiplier =  3; break; }
			case A4PatternPulsesPerStep_4: { self.clockMultiplier =  4; break; }
			case A4PatternPulsesPerStep_6: { self.clockMultiplier =  6; break; }
			case A4PatternPulsesPerStep_8: { self.clockMultiplier =  8; break; }
			case A4PatternPulsesPerStep_12:{ self.clockMultiplier = 12; break; }
			case A4PatternPulsesPerStep_24:{ self.clockMultiplier = 24; break; }
			case A4PatternPulsesPerStep_48:{ self.clockMultiplier = 48; break; }
			default:{ self.clockMultiplier = 6; break;}
		}
		
		for(int i = 0; i < 6; i++)
		{
			A4SequencerTrack *seqTrack = _tracks[i];
			seqTrack.track = _pattern.tracks[i];
		}
		
		self.kit = [self.project kitAtPosition:_pattern.position];
		[self.delegate a4SequencerDidChangePattern:self];
		return YES;
	}
}

- (A4Pattern *)pattern
{
	return _pattern;
}

- (id)init
{
	if(self = [super init])
	{
		_requestedOnEvents = malloc(sizeof(GateEvent) * 32);
		_requestedOffEvents = malloc(sizeof(GateEvent) * 32);
		self.project = [A4Project defaultProject];
		self.project.delegate = self;
		self.voiceAllocator = [A4VoiceAllocator new];
		self.voiceAllocator.delegate = self;
		self.tracks = @[].mutableCopy;
		for(int i = 0; i < 6; i++)
		{
			A4SequencerTrack *track = [A4SequencerTrack new];
			track.trackIdx = i;
			[_tracks addObject:track];
		}
		
		self.clockInterpolationFactor = 1;
		self.pattern = [_project patternAtPosition:0];
	}
	return self;
}

- (void)dealloc
{
	free(_requestedOnEvents);
	free(_requestedOffEvents);
}

+ (instancetype)sequencerWithDelegate:(id<A4SequencerDelegate>)delegate
{
	A4Sequencer *instance = [self new];
	instance.delegate = delegate;
	return instance;
}


@end
