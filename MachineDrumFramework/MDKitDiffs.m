//
//  MDKitDiffs.m
//  yolo
//
//  Created by Jakob Penca on 5/31/13.
//
//

#import "MDKitDiffs.h"
#import "MDMachinedrumPublic.h"

@interface MDKitDiffs()
{
	uint32_t *trackParamFlags;
	uint32_t masterParamFlags;
	uint16_t machineFlags;
	uint32_t trigGroupFlags;
	uint16_t levelsFlags;
}
@end
@implementation MDKitDiffs


+ (NSUInteger)dataLength
{
	return 16*4+4+2+4+2;
}

- (NSData *)data
{
	NSMutableData *data = [NSMutableData dataWithBytes: trackParamFlags length:16*4];
	[data appendBytes: &masterParamFlags length:4];
	[data appendBytes: &machineFlags length:2];
	[data appendBytes:&trigGroupFlags length:4];
	[data appendBytes:&levelsFlags length:2];
	return data;
}

+ (MDKitDiffs *)diffsWithData:(NSData *)d
{
	MDKitDiffs *diffs = [MDKitDiffs new];
	
	const unsigned char *bytes = d.bytes;
	memcpy(diffs->trackParamFlags, bytes, 16*4);
	bytes += 16*4;
	
	uint32_t *masterFlags = (uint32_t *) &bytes;
	diffs->masterParamFlags = *masterFlags;
	bytes += 4;
	
	uint16_t *machineFlags = (uint16_t *) &bytes;
	diffs->machineFlags = *machineFlags;
	bytes += 2;
	
	uint32_t *trigGroupFlags = (uint32_t *) &bytes;
	diffs->trigGroupFlags = *trigGroupFlags;
	bytes += 4;
	
	uint16_t *levelsFlags = (uint16_t *) &bytes;
	diffs->levelsFlags = *levelsFlags;
	
	return diffs;
}

+ (MDKitDiffs *)diffsBetweenEarlierKit:(MDKit *)earlierKit laterKit:(MDKit *)laterKit
{
	MDKitDiffs *diffs = [MDKitDiffs new];
	[diffs calculateDiffsWithEarlierKit:earlierKit laterKit:laterKit];
	return diffs;
}

- (id)init
{
	if(self = [super init])
	{
		trackParamFlags = calloc(16, 4);
	}
	return self;
}

- (void) calculateDiffsWithEarlierKit:(MDKit *)earlierKit laterKit:(MDKit *)laterKit
{
	for (int i = 0; i < 16; i++)
	{
		MDKitTrack *earlierTrack = [earlierKit.tracks objectAtIndex:i];
		MDKitTrack *laterTrack = [laterKit.tracks objectAtIndex:i];
		MDKitTrackParams *earlierParams = earlierTrack.params;
		MDKitTrackParams *laterParams = laterTrack.params;
		
		if(earlierTrack.machine != laterTrack.machine)
		{
			machineFlags |= 1 << i;
		}
		else
		{
			machineFlags &= ~(1 << i);
		}
		
		if(earlierTrack.level.charValue != laterTrack.level.charValue)
		{
			levelsFlags |= 1 << i;
		}
		else
		{
			levelsFlags &= ~(1 << i);
		}
		
		if(earlierTrack.muteGroup != laterTrack.muteGroup)
		{
			trigGroupFlags |= 1 << i;
		}
		else
		{
			trigGroupFlags &= ~(1 << i);
		}
		
		if(earlierTrack.trigGroup != laterTrack.trigGroup)
		{
			trigGroupFlags |= 1 << (i+16);
		}
		else
		{
			trigGroupFlags &= ~(1 << (i + 16));
		}
		
		
		for (int param = 0; param < 24; param++)
		{
			uint8_t earlierParam = [earlierParams valueForParam:param];
			uint8_t laterParam = [laterParams valueForParam:param];
			if(earlierParam != laterParam)
			{
				trackParamFlags[i] |= (uint32_t)1 << param;
			}
			else
			{
				trackParamFlags[i] &= ~((uint32_t)1 << param);
			}
		}
		
		MDKitLFOSettings *earlierLfo = earlierTrack.lfoSettings;
		MDKitLFOSettings *laterLfo = laterTrack.lfoSettings;
		
		if(earlierLfo.destinationTrack.charValue != laterLfo.destinationTrack.charValue)
		{
			trackParamFlags[i] |= (1 << (24 + 0));
		}
		else
		{
			trackParamFlags[i] &= ~(1 << (24 + 0));
		}
		
		if(earlierLfo.destinationParam.charValue != laterLfo.destinationParam.charValue)
		{
			trackParamFlags[i] |= (1 << (24 + 1));
		}
		else
		{
			trackParamFlags[i] &= ~(1 << (24 + 1));
		}
		
		if(earlierLfo.shape1.charValue != laterLfo.shape1.charValue)
		{
			trackParamFlags[i] |= (1 << (24 + 2));
		}
		else
		{
			trackParamFlags[i] &= ~(1 << (24 + 2));
		}
		
		if(earlierLfo.shape2.charValue != laterLfo.shape2.charValue)
		{
			trackParamFlags[i] |= (1 << (24 + 3));
		}
		else
		{
			trackParamFlags[i] &= ~(1 << (24 + 3));
		}
		
		if(earlierLfo.type != laterLfo.type)
		{
			trackParamFlags[i] |= (1 << (24 + 4));
		}
		else
		{
			trackParamFlags[i] &= ~(1 << (24 + 4));
		}
	}
	
	for (int i = 0; i < 8; i++)
	{
		if([earlierKit valueForDelayParam:i] != [laterKit valueForDelayParam:i])
		{
			masterParamFlags |= 1 << (i+0);
		}
		else
		{
			masterParamFlags &= ~(1 << (i+0));
		}
		
		if([earlierKit valueForReverbParam:i] != [laterKit valueForReverbParam:i])
		{
			masterParamFlags |= 1 << (i+8);
		}
		else
		{
			masterParamFlags &= ~(1 << (i+8));
		}
		
		if([earlierKit valueForEQParam:i] != [laterKit valueForEQParam:i])
		{
			masterParamFlags |= 1 << (i+16);
		}
		else
		{
			masterParamFlags &= ~(1 << (i+16));
		}
		
		if([earlierKit valueForDynamicsParam:i] != [laterKit valueForDynamicsParam:i])
		{
			masterParamFlags |= 1 << (i+24);
		}
		else
		{
			masterParamFlags &= ~(1 << (i+24));
		}
	}
}

- (void)applyDiffsFromKit:(MDKit *)laterKit toKit:(MDKit *)earlierKit
{
	for (int i = 0; i < 16; i++)
	{
		MDKitTrack *earlierTrack = [earlierKit.tracks objectAtIndex:i];
		MDKitTrack *laterTrack = [laterKit.tracks objectAtIndex:i];
		MDKitTrackParams *earlierParams = earlierTrack.params;
		MDKitTrackParams *laterParams = laterTrack.params;
		
		if(machineFlags & (1 << i))
		{
			earlierTrack.machine = laterTrack.machine;
		}
		
		if(levelsFlags & (1 << i))
		{
			earlierTrack.level = @(laterTrack.level.charValue);
		}
		
		if(trigGroupFlags & (1 << i))
		{
			earlierTrack.muteGroup = laterTrack.muteGroup;
		}
		
		if(trigGroupFlags & (1 << (i+16)))
		{
			earlierTrack.trigGroup = laterTrack.trigGroup;
		}
		
		for (int param = 0; param < 24; param++)
		{
			if(trackParamFlags[i] & (1 << param))
			{
				[earlierParams setParam:param toValue:[laterParams valueForParam:param]];
			}
		}
		
		MDKitLFOSettings *earlierLfo = earlierTrack.lfoSettings;
		MDKitLFOSettings *laterLfo = laterTrack.lfoSettings;
		
		if(trackParamFlags[i] & (1 << (24+0)))
		{
			earlierLfo.destinationTrack = @(laterLfo.destinationTrack.charValue);
		}
		if(trackParamFlags[i] & (1 << (24+1)))
		{
			earlierLfo.destinationParam = @(laterLfo.destinationParam.charValue);
		}
		if(trackParamFlags[i] & (1 << (24+2)))
		{
			earlierLfo.shape1 = @(laterLfo.shape1.charValue);
		}
		if(trackParamFlags[i] & (1 << (24+3)))
		{
			earlierLfo.shape2 = @(laterLfo.shape2.charValue);
		}
		if(trackParamFlags[i] & (1 << (24+4)))
		{
			earlierLfo.type = laterLfo.type;
		}
	}
	
	for (int i = 0; i < 8; i++)
	{
		if(masterParamFlags & (1 << (i + 0)))
		{
			[earlierKit setDelayParam:i toValue:[laterKit valueForDelayParam:i]];
		}
		if(masterParamFlags & (1 << (i + 8)))
		{
			[earlierKit setReverbParam:i toValue:[laterKit valueForReverbParam:i]];
		}
		if(masterParamFlags & (1 << (i + 16)))
		{
			[earlierKit setEQParam:i toValue:[laterKit valueForEQParam:i]];
		}
		if(masterParamFlags & (1 << (i + 24)))
		{
			[earlierKit setDynamixParam:i toValue:[laterKit valueForDynamicsParam:i]];
		}
	}
}

- (void)dealloc
{
	free(trackParamFlags);
}

@end
