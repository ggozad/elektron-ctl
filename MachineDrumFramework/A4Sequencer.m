//
//  A4Sequencer.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 08/11/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4Sequencer.h"



@interface A4Sequencer ()
@property (nonatomic, strong) A4Pattern *queuedPattern;
@property (nonatomic) NSInteger clock;
@end

@implementation A4Sequencer

- (void)a4SequencerTrack:(A4SequencerTrack *)sequencerTrack didOpenGateWithTrig:(A4Trig)trig step:(uint8_t)step context:(TrigContext)ctxt
{
	[_delegate a4Sequencer:self didOpenGateInTrack:sequencerTrack.trackIdx withTrig:trig atStep:step context:ctxt];
}

- (void)a4SequencerTrack:(A4SequencerTrack *)sequencerTrack didCloseGateWithTrig:(A4Trig)trig step:(uint8_t)step context:(TrigContext)ctxt
{
	[_delegate a4Sequencer:self didCloseGateInTrack:sequencerTrack.trackIdx withTrig:trig atStep:step context:ctxt];
}

- (void)a4SequencerTrack:(A4SequencerTrack *)sequencerTrack didOpenTriglessGateWithTrig:(A4Trig)trig step:(uint8_t)step
{
	[_delegate a4Sequencer:self didOpenTriglessGateInTrack:sequencerTrack.trackIdx withTrig:trig atStep:step];
}

- (void)a4SequencerTrack:(A4SequencerTrack *)sequencerTrack didCloseTriglessGateWithTrig:(A4Trig)trig step:(uint8_t)step
{
	[_delegate a4Sequencer:self didCloseTriglessGateInTrack:sequencerTrack.trackIdx withTrig:trig atStep:step];
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

- (void) setPattern:(A4Pattern *)pattern
{
	@synchronized(self)
	{
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
		
		[self.delegate a4SequencerDidChangePattern:self];
	}
}

- (id)init
{
	if(self = [super init])
	{
		self.project = [A4Project defaultProject];
		self.tracks = @[].mutableCopy;
		for(int i = 0; i < 6; i++)
		{
			A4SequencerTrack *track = [A4SequencerTrack new];
			track.delegate = self;
			track.trackIdx = i;
			[_tracks addObject:track];
		}
		
		self.clockInterpolationFactor = 1;
		self.pattern = [_project patternAtPosition:0];
	}
	return self;
}

+ (instancetype)sequencerWithDelegate:(id<A4SequencerDelegate>)delegate
{
	A4Sequencer *instance = [self new];
	instance.delegate = delegate;
	return instance;
}


@end
