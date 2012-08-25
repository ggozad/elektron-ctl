//
//  MDPatternTrigGenerator.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 8/7/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDPatternTrigGenerator.h"

@implementation MDPatternTrigGenerator

static float map(float value,
				 float istart, float istop,
				 float ostart, float ostop)
{
    return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
}

static int Wrap(int kX, int const kLowerBound, int const kUpperBound)
{
    int range_size = kUpperBound - kLowerBound + 1;
	
    if (kX < kLowerBound)
        kX += range_size * ((kLowerBound - kX) / range_size + 1);
	
    return kLowerBound + (kX - kLowerBound) % range_size;
}

- (void) generateTrigsWithStartStride:(uint8_t)startStride endStride:(uint8_t)endStride mode:(MDPatternTrigGeneratorMode)mode
{
	if(!self.pattern || !self.region) return;
	if(!startStride) startStride = 1;
	if(!endStride) endStride = 1;
	
	int t = self.region.track;
	int lt = t + self.region.numTracks;
	
	if(lt < t)
	{
		int tmp = lt;
		lt = t;
		t = tmp;
	}
	
	for (int track = t; track < lt; track++)
	{
		int s = self.region.step;
		int ls = self.region.step + self.region.numSteps;
		int step = s;
		
		if(ls > s)
		{
			
			while (step < ls)
			{
				[self setTrigInPattern:self.pattern atTrack:track step:step mode:mode];
				int stride = round(map(step, s, ls, startStride, endStride));
				step+=stride;
			}
		}
		else
		{
			int step = s-1;
			while (step > ls)
			{
				[self setTrigInPattern:self.pattern atTrack:track step:step mode:mode];
				int stride = roundf(map(step, s, ls, startStride, endStride));
				step-=stride;
			}
		}
	}
}

- (void) setTrigInPattern: (MDPattern *) p atTrack:(int)t step:(int)s mode:(MDPatternTrigGeneratorMode)mode
{
	t = Wrap(t, 0, 15);
	s = Wrap(s, 0, 63);
	
	if(mode == MDPatternTrigGeneratorMode_Replace)
	{
		[p setTrigAtTrack:t step:s toValue:0];
		[p setTrigAtTrack:t step:s toValue:1];
	}
	else if(mode == MDPatternTrigGeneratorMode_Toggle)
	{
		[p toggleTrigAtTrack:t step:s];
	}
	else if(mode == MDPatternTrigGeneratorMode_Remove)
	{
		[p setTrigAtTrack:t step:s toValue:0];
	}
	else if(mode == MDPatternTrigGeneratorMode_Fill)
	{
		[p setTrigAtTrack:t step:s toValue:1];
	}
}



@end
