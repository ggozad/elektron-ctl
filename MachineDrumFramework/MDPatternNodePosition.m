//
//  MDPatternSelectionNodePosition.m
//  MachineDrumFrameworkOSX
//
//  Created by Jakob Penca on 7/20/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDPatternNodePosition.h"

@implementation MDPatternNodePosition

+ (MDPatternNodePosition *)nodePositionAtTrack:(uint8_t)t step:(uint8_t)s
{
	MDPatternNodePosition *pos = [self new];
	pos.track = t % 16;
	pos.step = s % 64;
	return pos;
}

- (void)setTrack:(uint8_t)track step:(uint8_t)step
{
	self.track = track % 16;
	self.step = step % 64;
}

@end
