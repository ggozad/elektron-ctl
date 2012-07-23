//
//  MDPatternSelectionRectangle.m
//  MachineDrumFrameworkOSX
//
//  Created by Jakob Penca on 7/20/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDPatternSelectionRectangle.h"

@implementation MDPatternSelectionRectangle

+ (id)selectionRectangleAtTrack:(uint8_t)t step:(uint8_t)s numTracks:(uint8_t)nt numSteps:(uint8_t)ns
{
	MDPatternSelectionRectangle *r = [self new];
	
	r.track = t%16;
	r.step = s%64;
	r.numTracks = nt%16;
	r.numSteps = ns%64;
	
	return r;
}

@end
