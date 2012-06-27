//
//  MDProcedureTrigGenerator.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 6/26/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDProcedureTrigGenerator.h"

@implementation MDProcedureTrigGenerator

- (id)init
{
	if(self = [super init])
	{
		self.endTrig = 63;
		self.stride = 1;
	}
	return self;
}

- (void)processPattern:(MDPatternPublicWrapper *)pattern kit:(MDKit *)kit
{
	[super processPattern:pattern kit:kit];
	
	for(int i = self.startTrig; i <= self.endTrig; i+= self.stride)
	{
		BOOL b = [self evaluateConditions];
		if(!b) continue;
		
		if(self.mode == MDProcedureTrigGeneratorMode_ADD)
		{
			[pattern setTrigAtTrack:self.track step:i toValue:1];
		}
		else if(self.mode == MDProcedureTrigGeneratorMode_TOGGLE)
		{
			[pattern toggleTrigAtTrack:self.track step:i];
		}
		else if(self.mode == MDProcedureTrigGeneratorMode_REMOVE)
		{
			[pattern setTrigAtTrack:self.track step:i toValue:0];
		}
	}
}

@end
