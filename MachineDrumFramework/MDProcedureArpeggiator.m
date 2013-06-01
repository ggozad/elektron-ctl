//
//  MDProcedureArpeggiator.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 6/27/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDProcedureArpeggiator.h"
#import "MDParameterLock.h"

@implementation MDProcedureArpeggiator

- (void)processPattern:(MDPattern *)pattern kit:(MDKit *)kit
{
	[super processPattern:pattern kit:kit];
	
	self.startVal = self.startVal % 128;
	self.stopVal = self.stopVal % 128;
	
	self.param = self.param % 24;
	int8_t dir = self.direction ? -1 : 1;
	
	
	if(dir == -1)
	{
		uint8_t t = self.startVal;
		self.startVal = self.stopVal;
		self.stopVal = t;
	}
	
	if(self.wrapMode != MDProcedureArpeggiatorWrapMode_WRAP)
	{
		if(abs(self.stopVal - self.startVal) > self.increment)
			self.increment = abs(self.stopVal - self.startVal);
	}
	
	int8_t val = self.startVal;
	uint8_t min = self.startVal;
	uint8_t max = self.stopVal;
	
	if(self.stopVal < self.startVal)
	{
		min = self.stopVal;
		max = self.startVal;
	}
	
	for (int i = self.startTrig; i < self.endTrig; i+=self.stride)
	{
		if([pattern trigAtTrack:self.track step:i])
		{
			MDParameterLock *l = [MDParameterLock lockForTrack:self.track param:self.param step:i value:val];
			
			[pattern setLock:l
			   setTrigIfNone:NO];
			
			
			val += dir * self.increment;
			
			while (val < min) val = max - (abs(min-val));
			while (val > max) val = min + (abs(val-max));
		}
	}
}

@end
