//
//  MDProcedureTrigGenerator.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 6/26/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDProcedureTrigGenerator.h"

@implementation MDProcedureTrigGenerator

- (void)processPattern:(MDPatternPublicWrapper *)pattern kit:(MDKit *)kit
{
	if(self.track > 15) return;
	if(self.stride < 1) return;
	if(self.startTrig >= 64) return;
	if(self.endTrig >= 64) return;

	BOOL b = [self evaluateConditions];
	if(!b) return;
	
	for(int i = self.startTrig; i < self.endTrig; i+= self.stride)
	{
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
