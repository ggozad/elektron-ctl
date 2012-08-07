//
//  MDPatternPublicWrapper.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 6/19/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDPattern.h"

@interface MDPattern()
@property (strong, nonatomic) MDPatternPrivate *pattern;
@end

@implementation MDPattern

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
	p.pattern = [MDPatternPrivate patternWithData:sysexData];
	return p;
}

- (id)init
{
	if(self = [super init])
	{
		self.pattern = [MDPatternPrivate new];
	}
	return self;
}

- (uint8_t)numberOfUniqueLocks
{
	return self.pattern.locks.lockRows.count;
}

- (void)clearLock:(MDParameterLock *)lock clearTrig:(BOOL)clearTrig
{
	[self clearLockAtTrack:lock.track param:lock.param step:lock.step clearTrig:clearTrig];
}

- (BOOL)setLock:(MDParameterLock *)lock setTrigIfNone:(BOOL)setTrig
{
	//DLog(@"***\nsetting lock..");
	BOOL success = [self.pattern.locks setLock:lock];
	if(!success && setTrig)
	{
		//DLog(@"failed, setting trig...");
		[self setTrigAtTrack:lock.track step:lock.step toValue:YES];
		success = [self.pattern.locks setLock:lock];
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
	[self.pattern.locks clearLock:lock];
	if(clearTrig) [self setTrigAtTrack:t step:s toValue:0];
}

- (MDParameterLock *)lockAtTrack:(uint8_t)track step:(uint8_t)step param:(uint8_t)param
{
	return [self.pattern.locks lockAtTrack:track step:step param:param];
}

- (void)setTrigAtTrack:(uint8_t)t step:(uint8_t)s toValue:(BOOL)val
{
	if(t >= 16) return;
	if(s >= 64) return;
	
	if(!val)
		[self.pattern.locks clearLocksAtTrack:t step:s];
	
	MDPatternTrack *track = [self.pattern.tracks objectAtIndex:t];
	//DLog(@"setting trig at track: %d step: %d", t, s);
	[track setTrigAtStep:s to:val];
}

- (BOOL)trigAtTrack:(uint8_t)t step:(uint8_t)s
{
	if(t >= 16) return NO;
	if(s >= 64) return NO;
	MDPatternTrack *track = [self.pattern.tracks objectAtIndex:t];
	return [track trigAtStep:s];
}

- (void)toggleTrigAtTrack:(uint8_t)track step:(uint8_t)step
{
	if(track >= 16) return;
	if(step >= 64) return;
	BOOL on = [self trigAtTrack:track step:step];
	[self setTrigAtTrack:track step:step toValue:!on];
}

- (void)setLength:(uint8_t)len
{
	if(len <= 64) self.pattern.length = len;
}

- (void)setScale:(MDPatternScale)scale
{
	if(scale > 0 && scale < 4)
		self.pattern.scale = scale;
}

- (void)setKitNumber:(uint8_t)kit
{
	if(kit < 64) self.pattern.kitNumber = kit;
}

- (NSData *)sysexData
{
	NSData *d = [self.pattern sysexData];
	return d;
}

- (void)setSavePosition:(uint8_t)slot
{
	if(slot > 127) slot = 0;
	self.pattern.originalPosition = slot;
}

- (id)copy
{
	return [[self class] patternWithPattern:self];
}


@end
