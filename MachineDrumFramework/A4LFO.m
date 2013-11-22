//
//  A4LFO.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 21/11/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4LFO.h"
#import "MDMath.h"

@interface A4LFO()
{
	double internalPhase;
	int8_t _speed;
	uint16_t _multiplier;
	BOOL doIncrement, didStartAfterStopPhase;
	double holdPhase;
}
@end



@implementation A4LFO

- (id)init
{
	if (self = [super init])
	{
		doIncrement = YES;
	}
	return self;
}

- (void)setClockInterpolationFactor:(NSInteger)clockInterpolationFactor
{
	if(clockInterpolationFactor > 0) _clockInterpolationFactor = clockInterpolationFactor;
}

- (void)setMode:(A4LFOMode)mode
{
	if(mode < A4LFOModeCount)
		_mode = mode;
	
	if(_mode != A4LFOModeOne && _mode != A4LFOModeHalf) doIncrement = YES;
}

- (void)setStartPhase:(A4TrackerParam_t)startPhase
{
	_startPhase = mdmath_clamp(startPhase, 0, 1);
}

- (void)setPhase:(A4TrackerParam_t)phase
{
	phase = mdmath_clamp(phase, 0, 1);
	internalPhase = phase;
}

- (A4TrackerParam_t)phase
{
	return internalPhase;
}

- (void)setSpeed:(uint8_t)speed
{
	if(speed < 128) _speed = speed - 64;
}

- (uint8_t)speed
{
	return _speed + 64;
}


- (void)setMultiplier:(A4LFOMultiplier)multiplier
{
	if(multiplier < A4LFOMultiplierCount)
	{
		_multiplier = 1 << multiplier;
	}
}

- (A4LFOMultiplier)multiplier
{
	for (int i = 0; i < A4LFOMultiplierCount; i++)
	{
		if(_multiplier >> i == 1) return i;
	}
	return 1;
}

- (void)tickWithTime:(double)time trig:(BOOL)trig;
{
	if(trig) [self trig];
	[self incrementPhase];
}

- (void)trig
{
	if(_mode == A4LFOModeTrig ||
	   _mode == A4LFOModeOne ||
	   _mode == A4LFOModeHalf)
	{
		[self restart];
	}
	
	holdPhase = internalPhase;
}

- (void)restart
{
	internalPhase = _startPhase;
	
	if(_mode == A4LFOModeOne ||
	   _mode == A4LFOModeHalf ||
	   _mode == A4LFOModeTrig)
	{
		doIncrement = YES;
		if(_mode == A4LFOModeHalf && internalPhase >= .5) didStartAfterStopPhase = YES;
		else if(_mode == A4LFOModeOne && internalPhase >= 1) didStartAfterStopPhase = YES;
		else didStartAfterStopPhase = NO;
	}
}

- (void) incrementPhase
{
	if(!doIncrement) return;
	
	internalPhase = internalPhase + mdmath_map(_speed * _multiplier, 0, 128, 0, 1.0/16/6/_clockInterpolationFactor);
		
	if(internalPhase > 1) internalPhase -= 1;
	else if(internalPhase < 0) internalPhase += 1;
}

- (A4TrackerParam_t)lfoValue
{
	double phase = internalPhase;
	if(_mode == A4LFOModeHold) phase = holdPhase;
	
	if(_shape == A4LFOWaveshapeTri)
	{
		if(phase < .25) return mdmath_map(phase, 0, .25, 0, 1);
		if(phase < .75) return mdmath_map(phase, .25, .75, 1, -1);
		return mdmath_map(phase, .75, 1, -1, 0);
	}
	else if (_shape == A4LFOWaveshapeSin)
	{
		return sin( mdmath_map(phase, 0, 1, 0, M_PI * 2));
	}
	else if (_shape == A4LFOWaveshapeSaw)
	{
		return mdmath_map(phase, 0, 1, 1, -1);
	}
	else if (_shape == A4LFOWaveshapeSqu)
	{
		if(phase < .5) return 1;
		return -1;
	}
	else if (_shape == A4LFOWaveshapeRmp)
	{
		if(phase < .5) return mdmath_map(phase, 0, .5, 0, 1);
		return 0;
	}
	
	return 0;
}

@end
