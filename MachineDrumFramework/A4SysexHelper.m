//
//  A4SysexHelper.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 9/9/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4SysexHelper.h"
#import "MDSysexUtil.h"
#import "A4Sound.h"
#import "A4Kit.h"
#import "A4Pattern.h"
#import "NSData+MachinedrumBundle.h"

@implementation A4SysexHelper

+ (BOOL) kitPayload:(const char *) payloadA isEqualToKitPayload:(const char*)payloadB
{
	for (int track = 0; track < 4; track++)
	{
		const char *soundA = payloadA + 0x20 + track*A4MessagePayloadLengthSound;
		const char *soundB = payloadB + 0x20 + track*A4MessagePayloadLengthSound;
		if (! [self soundPayload:soundA isEqualToSoundPayload:soundB]) return NO;
	}
	NSUInteger offset = 0x5D8;
	return ! memcmp(payloadA + offset, payloadB + offset, A4MessagePayloadLengthKit - offset);
}

+ (BOOL) soundPayload:(const char *)payloadA isEqualToSoundPayload:(const char*)payloadB
{
	const char *a = payloadA;
	const char *b = payloadB;
	NSUInteger offset = 0x1C;
	return ! memcmp(a + offset, b + offset, A4MessagePayloadLengthSound - offset);
}


+ (BOOL)sound:(A4Sound *)soundA isEqualToSound:(A4Sound *)soundB
{
	return [self soundPayload:soundA.payload isEqualToSoundPayload:soundB.payload];
}

+ (BOOL)soundIsEqualToDefaultSound:(A4Sound *)sound
{
	static NSData *defaultSoundData;
    static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
        
		defaultSoundData = [NSData dataFromMachinedrumBundleResourceWithName:@"defaultSound" ofType:@"payload"];
		
    });

	const char *a = sound.payload;
	const char *b = defaultSoundData.bytes;
	return [self soundPayload:a isEqualToSoundPayload:b];
}

+ (BOOL)kit:(A4Kit *)kitA isEqualToKit:(A4Kit *)kitB
{
	return [self kitPayload:kitA.payload isEqualToKitPayload:kitB.payload];
}

+ (BOOL)kitIsEqualToDefaultKit:(A4Kit *)kit
{
	static NSData *defaultKitData;
    static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
        
		defaultKitData = [NSData dataFromMachinedrumBundleResourceWithName:@"defaultKit" ofType:@"payload"];
		
    });
	
	const char *a = kit.payload;
	const char *b = defaultKitData.bytes;
	return [self kitPayload:a isEqualToKitPayload:b];
}

+ (BOOL)pattern:(A4Pattern *)patternA isEqualToPattern:(A4Pattern *)patternB
{
	if(!patternA && ! patternB) return YES;
	if(!patternA || !patternB) return NO;
	
	return [[MDSysexUtil md5StringFromData:[self patternDataBlankingKitAndTrackNotesFromPatternData:[patternA.payloadData mutableCopy]]] isEqualToString:
			[MDSysexUtil md5StringFromData:[self patternDataBlankingKitAndTrackNotesFromPatternData:[patternB.payloadData mutableCopy]]]];
}

+ (NSData *) patternDataBlankingKitAndTrackNotesFromPatternData:(NSMutableData *)data
{
	char *bytes = data.mutableBytes;
	
	for (int trackIdx = 0; trackIdx < 6; trackIdx++)
	{
		bytes[4 + trackIdx * A4MessagePayloadLengthTrack + 0x180] = 0;
		bytes[4 + trackIdx * A4MessagePayloadLengthTrack + 0x181] = 0;
		bytes[4 + trackIdx * A4MessagePayloadLengthTrack + 0x182] = 0;
	}
	
	bytes[0x30F2] = 0;
	
	return data;
}

+ (BOOL)patternIsEqualToDefaultPattern:(A4Pattern *)pattern
{
	for (int trackIdx = 0; trackIdx < 6; trackIdx++)
	{
		UInt16 *flags = [pattern track:trackIdx].flags;
		for (int step = 0; step < 64; step++)
		{
			if((CFSwapInt16BigToHost(flags[step]) & A4TRIGFLAGS.TRIG) ||
			   (CFSwapInt16BigToHost(flags[step]) & A4TRIGFLAGS.TRIGLESS)) return NO;
		}
	}
	return YES;
}

+ (NSString *)patternStorageStringForSlot:(uint8_t)slot
{
	return [NSString stringWithFormat:@"%C%02d", slot/16+0x41, slot%16+1];
}

+ (NSString *)a4PValDescriptionForPVal:(A4PVal)pVal
{
	int16_t intVal = pVal.coarse | pVal.fine << 8;
	intVal = CFSwapInt16BigToHost(intVal);
	return [NSString stringWithFormat:@"{param: 0x%02X i: %d coarse: 0x%X fine: 0x%X (%d) double: %f normalized: %f}", pVal.param, intVal, pVal.coarse, (uint8_t)pVal.fine, pVal.fine, A4PValDoubleVal(pVal), A4PValDoubleValNormalized(pVal)];
}

+ (void)setName:(NSString *)name inPayloadLocation:(void *)location
{
	name = [name uppercaseString];
	NSCharacterSet * set =
	[[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+-=&/#@?\\%$0123456789 "] invertedSet];
	name = [[name componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
	
	NSUInteger len = name.length;
	if (len > 15) len = 15;
	name = [name substringWithRange:NSMakeRange(0, len)];
	
	const char *cString = (const char *)[[name uppercaseString] cStringUsingEncoding:NSASCIIStringEncoding];
	unsigned long cStringLength = strlen((const char *)cString);
	
	uint8_t *bytes = location;
	
	memset(bytes, 0, 16);
	memmove(bytes, cString, cStringLength);
}

+ (NSString *)nameAtPayloadLocation:(const void *)location
{
	const uint8_t *bytes = location;
	return [NSString stringWithCString:(const char *)bytes encoding:NSASCIIStringEncoding];
}

@end
