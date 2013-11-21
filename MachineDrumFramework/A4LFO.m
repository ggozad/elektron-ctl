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
	BOOL doIncrement;
	double holdPhase;
}
@end



@implementation A4LFO

- (void)setClockInterpolationFactor:(NSInteger)clockInterpolationFactor
{
	if(clockInterpolationFactor > 0) _clockInterpolationFactor = clockInterpolationFactor;
}

- (void)setMode:(A4LFOMode)mode
{
	if(mode < A4LFOModeCount)
		_mode = mode;
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

- (void)tick
{
	[self incrementPhase];
}

- (void)trig
{
	if(_mode != A4LFOModeHold && _mode != A4LFOModeFree)
	{
		[self restart];
	}
	
	holdPhase = internalPhase;
}

- (void)restart
{
	internalPhase = _startPhase;
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
	if(_mode == a4lfomo)
	return sin( mdmath_map(internalPhase, 0, 1, 0, M_PI * 2));
}

@end
