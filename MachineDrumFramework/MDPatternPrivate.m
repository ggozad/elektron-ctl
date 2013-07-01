//
//  MDPattern.m
//  sysexingApp
//
//  Created by Jakob Penca on 6/14/12.
//
//

#import "MDPatternPrivate.h"
#import "MDPatternParser.h"
#import "MDPatternTrack.h"
#import "MDPatternParameterLocks.h"

static void SetTrig(void *slf, int32_t *pattern, NSUInteger step, BOOL active)
{
	
	
	
	if(step >= 32)
	{
		MDPatternPrivate *p = (__bridge MDPatternPrivate *)slf;
		
		if(pattern == &p->slidePattern_00_31)
			pattern = &p->slidePattern_32_63;
		
		else if(pattern == &p->accentPattern_00_31)
			pattern = &p->accentPattern_32_63;
		
		else if(pattern == &p->swingPattern_00_31)
			pattern = &p->swingPattern_32_63;
		
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

@implementation MDPatternPrivate

- (id)init
{
	if(self = [super init])
	{
		self.tracks = [NSArray arrayWithObjects:
					  [MDPatternTrack new],
					  [MDPatternTrack new],
					  [MDPatternTrack new],
					  [MDPatternTrack new],
					  
					  [MDPatternTrack new],
					  [MDPatternTrack new],
					  [MDPatternTrack new],
					  [MDPatternTrack new],
					  
					  [MDPatternTrack new],
					  [MDPatternTrack new],
					  [MDPatternTrack new],
					  [MDPatternTrack new],
					  
					  [MDPatternTrack new],
					  [MDPatternTrack new],
					  [MDPatternTrack new],
					  [MDPatternTrack new],
					  nil];
		
		self.locks = [MDPatternParameterLocks new];
		self.locks.pattern = self;
	}
	return self;
}

+ (id)patternWithData:(NSData *)data
{
	return [MDPatternParser patternFromSysexData:data];
}

- (NSData *)sysexData
{
	return [MDPatternParser sysexDataFromPattern:self];
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




@end
