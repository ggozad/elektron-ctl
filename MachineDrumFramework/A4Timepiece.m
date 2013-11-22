//
//  A4Timepiece.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 13/11/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4Timepiece.h"
#import <QuartzCore/QuartzCore.h>

@implementation A4Timepiece

static double lastTickTime;
static uint8_t len = 16;
static double delta[16];

+ (double)secondsBetweenClockTicks
{
	// TODO: this is bullshit.
	
	double sum = 0;
	for(int i = 0; i < len; i++)
	{
		sum+=delta[i];
	}
	return sum/len;
}

+ (void) tickWithTime:(double)time
{	
	for(int i = 1; i < len; i++)
	{
		delta[i-1] = delta[i];
	}
	
	if(time - lastTickTime > 0)
	{
		delta[len-1] = time - lastTickTime;
		lastTickTime = time;
	}
}

@end
