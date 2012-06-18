//
//  MDPatternTrack.m
//  sysexingApp
//
//  Created by Jakob Penca on 6/14/12.
//
//

#import "MDPatternTrack.h"
#import "MDSysexUtil.h"

@implementation MDPatternTrack

- (BOOL)hasTrigAtStep:(NSUInteger)step
{
	if(step < 32)
		return CFSwapInt32BigToHost(self.trigPattern_00_31) & (1 << step) ? 1 : 0;
	else
		return CFSwapInt32BigToHost(self.trigPattern_32_63) & (1 << step) ? 1 : 0;
}

- (void)setTrigAtStep:(NSUInteger)step to:(BOOL)active
{
	//TODO: test this!
	if(step < 32)
	{
		if(active)
			self.trigPattern_00_31 |= (1 << step);
		else
			self.trigPattern_00_31 &= ~(1 << step);
	}
	else
	{
		if(active)
			self.trigPattern_32_63 |= (1 << step);
		else
			self.trigPattern_32_63 &= ~(1 << step);
	}
	
	
}

@end
