//
//  MDPatternPublicWrapper.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 6/19/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDPattern.h"
#import "MDPatternPrivate.h"
#import "MDPatternTrack.h"
#import "MDPatternParameterLocks.h"

@interface MDPattern()
@property (strong, nonatomic) MDPatternPrivate *privatePattern;
@end

@implementation MDPattern

- (BOOL)accentEditAllFlag
{
	return self.privatePattern.accentEditAllFlag;
}

- (void)setAccentEditAllFlag:(BOOL)accentEditAllFlag
{
	self.privatePattern.accentEditAllFlag = accentEditAllFlag;
}

- (BOOL)swingEditAllFlag
{
	return self.privatePattern.swingEditAllFlag;
}

- (void)setSwingEditAllFlag:(BOOL)swingEditAllFlag
{
	self.privatePattern.swingEditAllFlag = swingEditAllFlag;
}

- (BOOL)slideEditAllFlag
{
	return self.privatePattern.slideEditAllFlag;
}

- (void)setSlideEditAllFlag:(BOOL)slideEditAllFlag
{
	self.privatePattern.slideEditAllFlag = slideEditAllFlag;
}

- (uint8_t)accentAmount
{
	return self.privatePattern.accentAmount;
}

- (void)setAccentAmount:(uint8_t)accentAmount
{
	self.privatePattern.accentAmount = accentAmount;
}

- (uint8_t)swingAmount
{
	return self.privatePattern.swingAmount;
}

- (void)setSwingAmount:(uint8_t)swingAmount
{
	self.privatePattern.swingAmount = swingAmount;
}



+ (MDPattern *)patternWithPattern:(MDPattern *)inPattern
{
	NSData *data = [inPattern sysexData];
	return [MDPattern patternWithData:data];
}

+ (MDPattern *)pattern
{
	MDPattern *p = [MDPattern new];
	[p setLength:16];
	[p setScale:MDPatternScale_16];
	return p;
}

+ (MDPattern *)patternWithData:(NSData *)sysexData
{
	MDPattern *p = [MDPattern new];
	p.privatePattern = [MDPatternPrivate patternWithData:sysexData];
	return p;
}

- (id)init
{
	if(self = [super init])
	{
		self.privatePattern = [MDPatternPrivate new];
	}
	return self;
}

- (BOOL)isEmpty
{
	BOOL hasSteps = NO;
	for (int track = 0; track < 16; track++)
	{
		BOOL hasStepInTrack = NO;
		for (int step = 0; step < 64; step++)
		{
			if([self trigAtTrack:track step:step])
			{
				hasStepInTrack = YES;
				break;
			}
		}
		if(hasStepInTrack)
		{
			hasSteps = YES;
			break;
		}
	}
	
	return !hasSteps;
}

- (uint8_t)numberOfUniqueLocks
{
	return self.privatePattern.locks.lockRows.count;
}

- (void)clearLock:(MDParameterLock *)lock clearTrig:(BOOL)clearTrig
{
	[self clearLockAtTrack:lock.track param:lock.param step:lock.step clearTrig:clearTrig];
}

- (BOOL)setLock:(MDParameterLock *)lock setTrigIfNone:(BOOL)setTrig
{
	//DLog(@"***\nsetting lock..");
	BOOL success = [self.privatePattern.locks setLock:lock];
	if(!success && setTrig)
	{
		//DLog(@"failed, setting trig...");
		[self setTrigAtTrack:lock.track step:lock.step toValue:YES];
		success = [self.privatePattern.locks setLock:lock];
		if(!success)
		{
			//DLog(@"setting lock after setting trig failed..");
			//DLog(@"setting trig %@", [self trigAtTrack:lock.track step:lock.step] ? @"succeeded" : @"failed");
		}
		else
		{
			//DLog(@"succeeded.");
		}
	}
	return success;
}

- (void)clearLockAtTrack:(uint8_t)t param:(uint8_t)p step:(uint8_t)s clearTrig:(BOOL) clearTrig
{
	MDParameterLock *lock = [MDParameterLock lockForTrack:t param:p step:s value:-1];
	[self.privatePattern.locks clearLock:lock];
	if(clearTrig) [self setTrigAtTrack:t step:s toValue:0];
}

- (MDParameterLock *)lockAtTrack:(uint8_t)track step:(uint8_t)step param:(uint8_t)param
{
	return [self.privatePattern.locks lockAtTrack:track step:step param:param];
}

- (void)setTrigAtTrack:(uint8_t)t step:(uint8_t)s toValue:(BOOL)val
{
	if(t >= 16) return;
	if(s >= 64) return;
	
	if(!val)
		[self.privatePattern.locks clearLocksAtTrack:t step:s];
	
	MDPatternTrack *track = [self.privatePattern.tracks objectAtIndex:t];
	//DLog(@"setting trig at track: %d step: %d", t, s);
	[track setTrigAtStep:s to:val];
}

- (BOOL)trigAtTrack:(uint8_t)t step:(uint8_t)s
{
	if(t >= 16) return NO;
	if(s >= 64) return NO;
	MDPatternTrack *track = [self.privatePattern.tracks objectAtIndex:t];
	return [track trigAtStep:s];
}

- (BOOL)hasLockAtTrack:(uint8_t)track step:(uint8_t)step
{
	return [self.privatePattern.locks hasLockAtTrack:track step:step];
}

- (void)toggleTrigAtTrack:(uint8_t)track step:(uint8_t)step
{
	if(track >= 16) return;
	if(step >= 64) return;
	BOOL on = [self trigAtTrack:track step:step];
	[self setTrigAtTrack:track step:step toValue:!on];
}

- (BOOL) globalSlideTrigAtStep:(NSUInteger) step
{
	return [self.privatePattern slideTrigAtStep:step];
}

- (BOOL) globalAccentTrigAtStep:(NSUInteger) step
{
	return [self.privatePattern accentTrigAtStep:step];
}

- (BOOL) globalSwingTrigAtStep:(NSUInteger) step
{
	return [self.privatePattern swingTrigAtStep:step];
}

- (void) setGlobalSlideTrigAtStep:(NSUInteger) step to:(BOOL) active
{
	[self.privatePattern setSlideTrigAtStep:step to:active];
}

- (void) setGlobalAccentTrigAtStep:(NSUInteger) step to:(BOOL) active
{
	[self.privatePattern setAccentTrigAtStep:step to:active];
}

- (void) setGlobalSwingTrigAtStep:(NSUInteger) step to:(BOOL) active
{
	[self.privatePattern setswingTrigAtStep:step to:active];
}

- (BOOL) slideTrigAtTrack:(NSUInteger)track step:(NSUInteger) step
{
	return [[self.privatePattern.tracks objectAtIndex:track] slideTrigAtStep:step];
}

- (BOOL) accentTrigAtTrack:(NSUInteger)track step:(NSUInteger) step
{
	return [[self.privatePattern.tracks objectAtIndex:track] accentTrigAtStep:step];
}

- (BOOL) swingTrigAtTrack:(NSUInteger)track step:(NSUInteger) step
{
	return [[self.privatePattern.tracks objectAtIndex:track] swingTrigAtStep:step];
}

- (void) setSlideTrigAtTrack:(NSUInteger)track step:(NSUInteger) step to:(BOOL) active
{
	[[self.privatePattern.tracks objectAtIndex:track] setSlideTrigAtStep:step to:active];
}

- (void) setAccentTrigAtTrack:(NSUInteger)track step:(NSUInteger) step to:(BOOL) active
{
	[[self.privatePattern.tracks objectAtIndex:track] setAccentTrigAtStep:step to:active];
}

- (void) setswingTrigAtTrack:(NSUInteger)track step:(NSUInteger) step to:(BOOL) active
{
	[[self.privatePattern.tracks objectAtIndex:track] setswingTrigAtStep:step to:active];
}

- (void)setLength:(uint8_t)len
{
	if(len <= 64) self.privatePattern.length = len;
}

- (uint8_t)length
{
	return self.privatePattern.length;
}

- (void)setScale:(MDPatternScale)scale
{
	self.privatePattern.scale = scale;
}

- (MDPatternScale)scale
{
	return self.privatePattern.scale;
}

- (void)setKitNumber:(uint8_t)kit
{
	if(kit < 64) self.privatePattern.kitNumber = kit;
}

- (uint8_t)kitNumber
{
	return self.privatePattern.kitNumber;
}

- (NSData *)sysexData
{
	NSData *d = [self.privatePattern sysexData];
	return d;
}

- (void)setSavePosition:(uint8_t)slot
{
	if(slot > 127) slot = 0;
	self.privatePattern.originalPosition = slot;
}

- (uint8_t)savePosition
{
	return self.privatePattern.originalPosition;
}

- (void)setTempoMultiplier:(uint8_t)tempoMultiplier
{
	if(tempoMultiplier > 3) tempoMultiplier = 0;
	self.privatePattern.tempoMultiplier = tempoMultiplier;
}

- (uint8_t)tempoMultiplier
{
	return self.privatePattern.tempoMultiplier;
}

- (id)copy
{
	return [[self class] patternWithPattern:self];
}


@end
