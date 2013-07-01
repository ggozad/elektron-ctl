//
//  MDPatternDiffs.m
//  yolo
//
//  Created by Jakob Penca on 5/30/13.
//
//

#import "MDPatternDiffs.h"
#import "MDMachinedrumPublic.h"

@interface MDPatternDiffs()
{
	uint16_t flags;
}
+ (MDPattern *) additionsBetweenEarlierPattern:(MDPattern *)earlierPattern laterPattern:(MDPattern *)laterPattern;
+ (MDPattern *) deletionsBetweenEarlierPattern:(MDPattern *)earlierPattern laterPattern:(MDPattern *)laterPattern;
@end

@implementation MDPatternDiffs

+ (NSUInteger)dataLength
{
	return 0x1522*2 + 2;
}

+ (MDPatternDiffs *)diffsBetweenEarlierPattern:(MDPattern *)earlierPattern laterPattern:(MDPattern *)laterPattern
{
	MDPatternDiffs *diffs = [self new];
	diffs.earlierPattern = earlierPattern;
	diffs.laterPattern = laterPattern;
	diffs.insertions = [self additionsBetweenEarlierPattern:diffs.earlierPattern laterPattern:diffs.laterPattern];
	diffs.deletions = [self deletionsBetweenEarlierPattern:diffs.earlierPattern laterPattern:diffs.laterPattern];
	[diffs calculateFlags];
	return diffs;
}

+ (MDPatternDiffs *)diffsWithData:(NSData *)data
{
	NSData *insertionsData = [data subdataWithRange:NSMakeRange(0, 0x1522)];
	NSData *deletionsData = [data subdataWithRange:NSMakeRange(0x1522, 0x1522)];
	NSData *flagsData = [data subdataWithRange:NSMakeRange(0x1522*2, 2)];
	
	MDPatternDiffs *diffs = [self new];
	diffs.insertions = [MDPattern patternWithData:insertionsData];
	diffs.deletions = [MDPattern patternWithData:deletionsData];
	const uint16_t *flagsPtr = flagsData.bytes;
	diffs->flags = *flagsPtr;
	return diffs;
}

- (NSData *)data
{
	NSMutableData *data = [self.insertions.sysexData mutableCopy];
	[data appendData:self.deletions.sysexData];
	[data appendData:[NSData dataWithBytes:&self->flags length:2]];
	return data;
}

- (void)calculateFlags
{
	flags = 0;
	
	if(self.earlierPattern.swingAmount != self.laterPattern.swingAmount)
	{
		flags |= 1;
	}
	if(self.earlierPattern.accentAmount != self.laterPattern.accentAmount)
	{
		flags |= (1 << 1);
	}
	if(self.earlierPattern.length != self.laterPattern.length)
	{
		flags |= (1 << 2);
	}
	if(self.earlierPattern.scale != self.laterPattern.scale)
	{
		flags |= (1 << 3);
	}
	if(self.earlierPattern.tempoMultiplier != self.laterPattern.tempoMultiplier)
	{
		flags |= (1 << 4);
	}
	
	if(self.earlierPattern.accentEditAllFlag != self.laterPattern.accentEditAllFlag)
	{
		flags |= (1 << 5);
	}
	if(self.earlierPattern.swingEditAllFlag != self.laterPattern.swingEditAllFlag)
	{
		flags |= (1 << 6);
	}
	if(self.earlierPattern.slideEditAllFlag != self.laterPattern.slideEditAllFlag)
	{
		flags |= (1 << 7);
	}
}

- (void)applyDiffs
{
	if(flags & 1)
	{
		self.earlierPattern.swingAmount = self.insertions.swingAmount;
	}
	if(flags & (1<<1))
	{
		self.earlierPattern.accentAmount = self.insertions.accentAmount;
	}
	if(flags & (1<<2))
	{
		self.earlierPattern.length = self.insertions.length;
	}
	if(flags & (1<<3))
	{
		self.earlierPattern.scale = self.insertions.scale;
	}
	if(flags & (1<<4))
	{
		self.earlierPattern.tempoMultiplier = self.insertions.tempoMultiplier;
	}
	if(flags & (1<<5))
	{
		self.earlierPattern.accentEditAllFlag = self.insertions.accentEditAllFlag;
	}
	if(flags & (1<<6))
	{
		self.earlierPattern.swingEditAllFlag = self.insertions.swingEditAllFlag;
	}
	if(flags & (1<<7))
	{
		self.earlierPattern.slideEditAllFlag = self.insertions.slideEditAllFlag;
	}
}

- (void) applyToEarlierPattern
{
	for (int trackIndex = 0; trackIndex < 16; trackIndex++)
	{
		for (int stepIndex = 0; stepIndex < 64; stepIndex++)
		{
			if([self.insertions hasLockAtTrack:trackIndex step:stepIndex])
			{
				for (int param = 0; param < 24; param++)
				{
					MDParameterLock *addedLock =
					[self.insertions lockAtTrack:trackIndex step:stepIndex param:param];
					
					if(addedLock)
					{
						[self.earlierPattern setLock:addedLock setTrigIfNone:YES];
					}
				}
			}
			
			if([self.deletions hasLockAtTrack:trackIndex step:stepIndex])
			{
				for (int param = 0; param < 24; param++)
				{
					MDParameterLock *removedLock =
					[self.deletions lockAtTrack:trackIndex step:stepIndex param:param];
					
					if(removedLock)
					{
						[self.earlierPattern clearLock:removedLock clearTrig:NO];
					}
				}
			}
			
			if([self.insertions trigAtTrack:trackIndex step:stepIndex])
			{
				[self.earlierPattern setTrigAtTrack:trackIndex step:stepIndex toValue:YES];
			}
			
			if([self.deletions trigAtTrack:trackIndex step:stepIndex])
			{
				[self.earlierPattern setTrigAtTrack:trackIndex step:stepIndex toValue:NO];
			}
		}
	}
	[self applyDiffs];
}

+ (MDPattern *)additionsBetweenEarlierPattern:(MDPattern *)earlierPattern laterPattern:(MDPattern *)laterPattern
{
	MDPattern *additions = [MDPattern pattern];
	additions.swingAmount = laterPattern.swingAmount;
	additions.accentAmount = laterPattern.accentAmount;
	additions.length = laterPattern.length;
	additions.scale = laterPattern.scale;
	additions.tempoMultiplier = laterPattern.tempoMultiplier;
	additions.accentEditAllFlag = laterPattern.accentEditAllFlag;
	additions.swingEditAllFlag = laterPattern.swingEditAllFlag;
	additions.slideEditAllFlag = laterPattern.slideEditAllFlag;
	
	for (int stepIndex = 0; stepIndex < 64; stepIndex++)
	{
		if([laterPattern globalAccentTrigAtStep:stepIndex] && ![earlierPattern globalAccentTrigAtStep:stepIndex])
		{
			[additions setGlobalAccentTrigAtStep:stepIndex to:YES];
		}
		
		if([laterPattern globalSlideTrigAtStep:stepIndex] && ![earlierPattern globalSlideTrigAtStep:stepIndex])
		{
			[additions setGlobalSlideTrigAtStep:stepIndex to:YES];
		}
		
		if([laterPattern globalSwingTrigAtStep:stepIndex] && ![earlierPattern globalSwingTrigAtStep:stepIndex])
		{
			[additions setGlobalSwingTrigAtStep:stepIndex to:YES];
		}
	}
	
	for (int trackIndex = 0; trackIndex < 16; trackIndex++)
	{
		for (int stepIndex = 0; stepIndex < 64; stepIndex++)
		{
			if([laterPattern trigAtTrack:trackIndex step:stepIndex] && ![earlierPattern trigAtTrack:trackIndex step:stepIndex])
			{
				[additions setTrigAtTrack:trackIndex step:stepIndex toValue:YES];
			}
			
			if([laterPattern accentTrigAtTrack:trackIndex step:stepIndex] && ![earlierPattern accentTrigAtTrack:trackIndex step:stepIndex])
			{
				[additions setAccentTrigAtTrack:trackIndex step:stepIndex to:YES];
			}
			
			if([laterPattern swingTrigAtTrack:trackIndex step:stepIndex] && ![earlierPattern swingTrigAtTrack:trackIndex step:stepIndex])
			{
				[additions setswingTrigAtTrack:trackIndex step:stepIndex to:YES];
			}
			
			if([laterPattern slideTrigAtTrack:trackIndex step:stepIndex] && ![earlierPattern slideTrigAtTrack:trackIndex step:stepIndex])
			{
				[additions setSlideTrigAtTrack:trackIndex step:stepIndex to:YES];
			}
			
			if([laterPattern hasLockAtTrack:trackIndex step:stepIndex])
			{
				for (int param = 0; param < 24; param++)
				{
					MDParameterLock *lockLater = [laterPattern lockAtTrack:trackIndex step:stepIndex param:param];
					if(lockLater)
					{
						MDParameterLock *lockEarlier = [earlierPattern lockAtTrack:trackIndex step:stepIndex param:param];
						if(!lockEarlier || lockLater.lockValue != lockEarlier.lockValue)
						{
							[additions setLock:lockLater setTrigIfNone:YES];
						}
					}
				}
			}
		}
	}
	return additions;
}

+ (MDPattern *)deletionsBetweenEarlierPattern:(MDPattern *)earlierPattern laterPattern:(MDPattern *)laterPattern
{
	MDPattern *deletions = [MDPattern pattern];
	
	for (int stepIndex = 0; stepIndex < 64; stepIndex++)
	{
		if(![laterPattern globalAccentTrigAtStep:stepIndex] && [earlierPattern globalAccentTrigAtStep:stepIndex])
		{
			[deletions setGlobalAccentTrigAtStep:stepIndex to:YES];
		}
		
		if(![laterPattern globalSlideTrigAtStep:stepIndex] && [earlierPattern globalSlideTrigAtStep:stepIndex])
		{
			[deletions setGlobalSlideTrigAtStep:stepIndex to:YES];
		}
		
		if(![laterPattern globalSwingTrigAtStep:stepIndex] && [earlierPattern globalSwingTrigAtStep:stepIndex])
		{
			[deletions setGlobalSwingTrigAtStep:stepIndex to:YES];
		}
	}
	
	for (int trackIndex = 0; trackIndex < 16; trackIndex++)
	{
		for (int stepIndex = 0; stepIndex < 64; stepIndex++)
		{
			if(![laterPattern trigAtTrack:trackIndex step:stepIndex] && [earlierPattern trigAtTrack:trackIndex step:stepIndex])
			{
				[deletions setTrigAtTrack:trackIndex step:stepIndex toValue:YES];
			}
			
			if(![laterPattern accentTrigAtTrack:trackIndex step:stepIndex] && [earlierPattern accentTrigAtTrack:trackIndex step:stepIndex])
			{
				[deletions setAccentTrigAtTrack:trackIndex step:stepIndex to:YES];
			}
			
			if(![laterPattern swingTrigAtTrack:trackIndex step:stepIndex] && [earlierPattern swingTrigAtTrack:trackIndex step:stepIndex])
			{
				[deletions setswingTrigAtTrack:trackIndex step:stepIndex to:YES];
			}
			
			if(![laterPattern slideTrigAtTrack:trackIndex step:stepIndex] && [earlierPattern slideTrigAtTrack:trackIndex step:stepIndex])
			{
				[deletions setSlideTrigAtTrack:trackIndex step:stepIndex to:YES];
			}
			
			if([earlierPattern hasLockAtTrack:trackIndex step:stepIndex])
			{
				for (int param = 0; param < 24; param++)
				{
					MDParameterLock *lockEarlier = [earlierPattern lockAtTrack:trackIndex step:stepIndex param:param];
					if(lockEarlier)
					{
						MDParameterLock *lockLater = [laterPattern lockAtTrack:trackIndex step:stepIndex param:param];
						if(!lockLater)
						{
							[deletions setLock:lockLater setTrigIfNone:YES];
						}
					}
				}
			}
		}
	}
	return deletions;
}

@end
