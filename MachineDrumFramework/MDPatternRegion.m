//
//  MDPatternSelectionRectangle.m
//  MachineDrumFrameworkOSX
//
//  Created by Jakob Penca on 7/20/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDPatternRegion.h"

static int Wrap(int kX, int const kLowerBound, int const kUpperBound)
{
    int range_size = kUpperBound - kLowerBound + 1;
	
    if (kX < kLowerBound)
        kX += range_size * ((kLowerBound - kX) / range_size + 1);
	
    return kLowerBound + (kX - kLowerBound) % range_size;
}


@interface MDPatternRegion()
{
	uint8_t _track;
	uint8_t _step;
	
	int8_t _numTracks;
	int8_t _numSteps;
}
@end




@implementation MDPatternRegion

- (void)changeNumSteps:(int8_t)s numTracks:(int8_t)t
{
	[self setNumSteps:self.numSteps + s];
	[self setNumTracks:self.numTracks + t];
}

- (void)translateStep:(int8_t)s track:(int8_t)t
{
	[self setStep:self.step + s];
	[self setTrack:self.track + t];
}

- (void)setNumSteps:(int8_t)numSteps
{
	if(numSteps == 0)
	{
		if(_numSteps < 0) numSteps = 1;
		else numSteps = -1;
	}
	
	_numSteps = Wrap(numSteps, -64, 64);
}

- (int8_t)numSteps
{
	return _numSteps;
}

- (void)setNumTracks:(int8_t)numTracks
{
	if(numTracks == 0)
	{
		if(_numTracks < 0) numTracks = 1;
		else numTracks = -1;
	}
	_numTracks = Wrap(numTracks, -16, 16);
}

- (int8_t)numTracks
{
	return _numTracks;
}

- (void)setTrack:(uint8_t)track
{
	_track = Wrap(track, 0, 15);
}

- (uint8_t)track
{
	return _track;
}

- (void)setStep:(uint8_t)step
{
	_step = Wrap(step, 0, 63);
}

- (uint8_t)step
{
	return _step;
}


+ (id)regionAtTrack:(uint8_t)t step:(uint8_t)s numberOfTracks:(int8_t)nt numberOfSteps:(int8_t)ns
{
	if(nt == 0) nt = 1;
	if(ns == 0) ns = 1;
	
	MDPatternRegion *r = [self new];
	
	r.track = t%16;
	r.step = s%64;
	
	r.numTracks = Wrap(nt, -16, 16);
	r.numSteps = Wrap(ns, -64, 64);
	
	return r;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ t: %d s: %d nt: %d ns: %d", [super description], self.track, self.step, self.numTracks, self.numSteps];
}

@end
