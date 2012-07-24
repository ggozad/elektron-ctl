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
    int range = kUpperBound - kLowerBound + 1;
	kX = ((kX-kLowerBound) % range);
	if (kX<0)
		return kUpperBound + 1 + kX;
	else
		return kLowerBound + kX;
}

@implementation MDPatternRegion

+ (id)regionAtTrack:(uint8_t)t step:(uint8_t)s numberOfTracks:(int8_t)nt numberOfSteps:(int8_t)ns
{
	MDPatternRegion *r = [self new];
	
	r.track = t%16;
	r.step = s%64;
	
	//if(nt > 0) nt %= 16;
	//if(ns > 0) ns %= 64;
	
	r.numTracks = Wrap(nt, -15, 16);
	r.numSteps = Wrap(ns, -63, 64);
	
	DLog(@"nt: %d ns: %d", nt, ns);
	
	return r;
}

@end
