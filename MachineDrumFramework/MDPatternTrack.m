//
//  MDPatternTrack.m
//  sysexingApp
//
//  Created by Jakob Penca on 6/14/12.
//
//

#import "MDPatternTrack.h"
#import "MDSysexUtil.h"


static void SetTrig(void *slf, int32_t *pattern, NSUInteger step, BOOL active)
{
	if(step >= 32)
	{
		MDPatternTrack *t = (__bridge MDPatternTrack *)slf;
		
		if(pattern == &t->trigPattern_00_31)
			pattern = &t->trigPattern_32_63;
		
		else if(pattern == &t->slidePattern_00_31)
			pattern = &t->slidePattern_32_63;
		
		else if(pattern == &t->accentPattern_00_31)
			pattern = &t->accentPattern_32_63;
		
		else if(pattern == &t->swingPattern_00_31)
			pattern = &t->swingPattern_32_63;
		
		else return;
	}
	
	
	if(step < 32)
	{
		unsigned long newTrig =  (1 << step);
		if(active)
			*pattern |= newTrig;
		else
			*pattern &= ~newTrig;
	}
	else
	{
		step -= 32;
		unsigned long newTrig =  (1 << step);
		if(active)
			*pattern |= newTrig;
		else
			*pattern &= ~newTrig;
	}
}


@implementation MDPatternTrack



- (BOOL)trigAtStep:(NSUInteger)step
{
	if(step < 32)
		return trigPattern_00_31 & (1 << step) ? 1 : 0;
	else
	{
		step -= 32;
		return trigPattern_32_63 & (1 << step) ? 1 : 0;
	}
}

- (BOOL)slideTrigAtStep:(NSUInteger)step
{
	if(step < 32)
		return slidePattern_00_31 & (1 << step) ? 1 : 0;
	else
	{
		step -= 32;
		return slidePattern_32_63 & (1 << step) ? 1 : 0;
	}
}

- (BOOL)swingTrigAtStep:(NSUInteger)step
{
	if(step < 32)
		return swingPattern_00_31 & (1 << step) ? 1 : 0;
	else
	{
		step -= 32;
		return swingPattern_32_63 & (1 << step) ? 1 : 0;
	}
}

- (BOOL)accentTrigAtStep:(NSUInteger)step
{
	if(step < 32)
		return accentPattern_00_31 & (1 << step) ? 1 : 0;
	else
	{
		step -= 32;
		return accentPattern_32_63 & (1 << step) ? 1 : 0;
	}
}


- (void)setTrigAtStep:(NSUInteger)step to:(BOOL)active
{
	SetTrig((__bridge void *)(self), &self->trigPattern_00_31, step, active);	
}

- (void)setAccentTrigAtStep:(NSUInteger)step to:(BOOL)active
{
	SetTrig((__bridge void *)(self), &self->accentPattern_00_31, step, active);
}

- (void)setSlideTrigAtStep:(NSUInteger)step to:(BOOL)active
{
	SetTrig((__bridge void *)(self), &self->slidePattern_00_31, step, active);
}

- (void)setswingTrigAtStep:(NSUInteger)step to:(BOOL)active
{
	SetTrig((__bridge void *)(self), &self->swingPattern_00_31, step, active);
}




@end
