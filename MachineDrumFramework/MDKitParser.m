//
//  MDKitParser.m
//  sysexingApp
//
//  Created by Jakob Penca on 6/11/12.
//
//

#import "MDKitParser.h"
#import "MDKit.h"
#import "MDSysexUtil.h"

@interface MDKitParser()

// VALIDITY

+ (BOOL) kitDataIsValid:(NSData *)data;
+ (BOOL) checksumIsValid:(NSData *)data;
+ (BOOL) messageLengthIsValid:(NSData *)data;

// BUILDING A KIT

+ (void) hydrateKit:(MDKit *)kit originalPositionFromData:(NSData *)data;
+ (void) hydrateKit:(MDKit *)kit nameFromData:(NSData *)data;
+ (void) hydrateKit:(MDKit *)kit trackParamsFromData:(NSData *)data;
+ (void) hydrateKit:(MDKit *)kit levelsFromData:(NSData *)data;
+ (void) hydrateKit:(MDKit *)kit drumModelsFromData:(NSData *)data;
+ (void) hydrateKit:(MDKit *)kit LFOSettingsFromData:(NSData *)data;
+ (void) hydrateKit:(MDKit *)kit reverbSettingsFromData:(NSData *)data;
+ (void) hydrateKit:(MDKit *)kit delaySettingsFromData:(NSData *)data;
+ (void) hydrateKit:(MDKit *)kit EQSettingsFromData:(NSData *)data;
+ (void) hydrateKit:(MDKit *)kit dynamicsSettingsFromData:(NSData *)data;
+ (void) hydrateKit:(MDKit *)kit trigGroupsFromData:(NSData *)data;

// BUILDING DATA

+ (NSData *) dataForOriginalPositonInKit: (MDKit *) kit;
+ (NSData *) dataForNameInKit: (MDKit *)kit;
+ (NSData *) dataForTrackParamsInKit: (MDKit *)kit;
+ (NSData *) dataForLevelsInKit: (MDKit *)kit;
+ (NSData *) dataForDrumModelsInKit: (MDKit *)kit;
+ (NSData *) dataForLFOSettingsInKit: (MDKit *)kit;
+ (NSData *) dataForReverbSettingsInKit: (MDKit *)kit;
+ (NSData *) dataForDelaySettingsInKit: (MDKit *)kit;
+ (NSData *) dataForEQSettingsInKit: (MDKit *)kit;
+ (NSData *) dataForDynamicsSettingsInKit: (MDKit *)kit;
+ (NSData *) dataForTrigGroupsInKit: (MDKit *)kit;
+ (NSData *) dataEndOfMessageData:(NSData *)data; 

@end


@implementation MDKitParser


#pragma mark - public class methods

+ (NSData *)sysexDataFromKit:(MDKit *)kit
{
	//TODO: check kit integrity
	
	BOOL kitIsGood = YES;
	if(!kitIsGood) return nil;
	
	
	NSMutableData *data = [NSMutableData data];
	char header[] = {0xf0, 0x00, 0x20, 0x3c, 0x02, 0x00, 0x52, 0x04, 0x01};
	[data appendBytes:&header length:0x09];
	
	[data appendData:[self dataForOriginalPositonInKit:kit]];
	[data appendData:[self dataForNameInKit:kit]];
	[data appendData:[self dataForTrackParamsInKit:kit]];
	[data appendData:[self dataForLevelsInKit:kit]];
	[data appendData:[self dataForDrumModelsInKit:kit]];
	[data appendData:[self dataForLFOSettingsInKit:kit]];
	[data appendData:[self dataForReverbSettingsInKit:kit]];
	[data appendData:[self dataForDelaySettingsInKit:kit]];
	[data appendData:[self dataForEQSettingsInKit:kit]];
	[data appendData:[self dataForDynamicsSettingsInKit:kit]];
	[data appendData:[self dataForTrigGroupsInKit:kit]];
	[data appendData:[self dataEndOfMessageData:data]];
	
	return data;
}

+ (MDKit *)kitFromSysexData:(NSData *)data
{
	if(![self kitDataIsValid:data]) return nil;
	MDKit *kit = [MDKit new];
	
	NSLog(@"hydrating kit:");
	
	[self hydrateKit:kit originalPositionFromData:data];
	[self hydrateKit:kit nameFromData:data];
	[self hydrateKit:kit trackParamsFromData:data];
	[self hydrateKit:kit levelsFromData:data];
	[self hydrateKit:kit drumModelsFromData:data];
	[self hydrateKit:kit LFOSettingsFromData:data];
	[self hydrateKit:kit reverbSettingsFromData:data];
	[self hydrateKit:kit delaySettingsFromData:data];
	[self hydrateKit:kit EQSettingsFromData:data];
	[self hydrateKit:kit dynamicsSettingsFromData:data];
	[self hydrateKit:kit trigGroupsFromData:data];
	
	return kit;
}




#pragma mark - data building


+ (NSData *)dataForOriginalPositonInKit:(MDKit *)kit
{
	uint8_t posByte = kit.originalPosition;
	return [NSData dataWithBytes:&posByte length:1];
}

+ (NSData *)dataForNameInKit:(MDKit *)kit
{	
	return kit.kitName;
}

+ (NSData *)dataForTrackParamsInKit:(MDKit *)kit
{
	uint8_t bytes[24*16];
	NSUInteger index = 0;
	for (int i = 0; i < 16; i++)
	{
		MDKitTrack *track = [kit.tracks objectAtIndex:i];
		for (int j = 0; j < 24; j++)
		{
			MDKitTrackParams *trackParams = track.params;
			bytes[index++] = [trackParams valueForParam:j] & 0x7f;
		}
	}
	return [NSData dataWithBytes:&bytes length:24*16];
}

+ (NSData *)dataForLevelsInKit:(MDKit *)kit
{
	uint8_t bytes[16];
	
	for (int i = 0; i < 16; i++)
	{
		MDKitTrack *track = [kit.tracks objectAtIndex:i];
		bytes[i] = track.level.intValue & 0x7f;
	}
	
	return [NSData dataWithBytes:&bytes length:16];
}

+ (NSData *)dataForDrumModelsInKit:(MDKit *)kit
{
	char unpackedBytes[16*4];
	for (int i = 0; i < 16*4; i++)
		unpackedBytes[i] = 0;
	
	for (int i = 0; i < 16; i++)
	{
		MDKitTrack *track = [kit.tracks objectAtIndex:i];
		unpackedBytes[3 + i * 4] = track.machine;
	}
	
	NSData *unpackedData = [NSData dataWithBytes:&unpackedBytes length:16*4];
	NSData *packedData = [MDSysexUtil dataPackedWith7BitSysexEncoding:unpackedData];
	return packedData;
}


+ (NSData *)dataForLFOSettingsInKit:(MDKit *)kit
{
	NSUInteger unpackedLength = 36 * 16;
	char unpackedBytes[unpackedLength];
	
	for (int i = 0; i < unpackedLength; i++)
	{
		unpackedBytes[i] = 0;
	}
	
	for (int i = 0; i < 16; i++)
	{
		MDKitTrack *track = [kit.tracks objectAtIndex:i];
		MDKitLFOSettings *trackLFOSettings = track.lfoSettings;
		
		char *unpackedBytesPerTrack = &unpackedBytes[i * 36];
		unpackedBytesPerTrack[0x00] = trackLFOSettings.destinationTrack.intValue & 0x7f;
		unpackedBytesPerTrack[0x01] = trackLFOSettings.destinationParam.intValue & 0x7f;
		unpackedBytesPerTrack[0x02] = trackLFOSettings.shape1.intValue & 0x7f;
		unpackedBytesPerTrack[0x03] = trackLFOSettings.shape2.intValue & 0x7f;
		unpackedBytesPerTrack[0x04] = trackLFOSettings.type & 0x7f;
		
		const char *internalStateBytes = trackLFOSettings.internalState.bytes;
		for (int j = 0; j < 31; j++)
		{
			unpackedBytesPerTrack[0x05 + j] = internalStateBytes[j];
		}
	}
	
	NSData *packedData = [MDSysexUtil dataPackedWith7BitSysexEncoding:
						  [NSData dataWithBytes:&unpackedBytes length: 36 * 16]];
	return packedData;
}


+ (NSData *)dataForReverbSettingsInKit:(MDKit *)kit
{
	NSData *d = [MDSysexUtil dataFromNumbersArray:kit.reverbSettings];
	//DLog(@"rev settings data repack: %@", d);
	return d;
}

+ (NSData *)dataForDelaySettingsInKit:(MDKit *)kit
{
	return [MDSysexUtil dataFromNumbersArray:kit.delaySettings];
}

+ (NSData *)dataForEQSettingsInKit:(MDKit *)kit
{
	return [MDSysexUtil dataFromNumbersArray:kit.eqSettings];
}

+ (NSData *)dataForDynamicsSettingsInKit:(MDKit *)kit
{
	return [MDSysexUtil dataFromNumbersArray:kit.dynamicsSettings];
}

+ (NSData *)dataForTrigGroupsInKit:(MDKit *)kit
{
	int8_t unpackedBytes[32];
	
	for (int i = 0; i < 16; i++)
	{
		MDKitTrack *track = [kit.tracks objectAtIndex:i];
		unpackedBytes[i] = track.trigGroup;
		unpackedBytes[i + 0x10] = track.muteGroup;
	}
	
	return [MDSysexUtil dataPackedWith7BitSysexEncoding:
			[NSData dataWithBytes:&unpackedBytes length:32]];
}


+ (NSData *)dataEndOfMessageData:(NSData *)data
{
	char endBytes[] = {0,0,0,0,0xf7};
	
	uint16_t calcedChecksum = 0;
	uint16_t checksumBytesLength = (0x4a7 + 37) - 0x09;
	
	const uint8_t *bytes = &data.bytes[0x09];
	
	for (int i = 0; i < checksumBytesLength; i++)
	{
		calcedChecksum += bytes[i] & 0x7f;
	}
	
	calcedChecksum &= 0x3fff;
	endBytes[0] = calcedChecksum >> 7;
	endBytes[1] = calcedChecksum & 0x7f;
	
	
	uint16_t messageLength = data.length + 2 - 0x07;
	messageLength &= 0x3fff;
	endBytes[2] = messageLength >> 7;
	endBytes[3] = messageLength & 0x7f;
	
	
	//DLog(@"checksum of repacked kit data: %d", calcedChecksum);
	
	return [NSData dataWithBytes:&endBytes length:5];
}



#pragma mark - kit building


+ (BOOL)kitDataIsValid:(NSData *)data
{
	NSLog(@"sanity checking kit data...");
	const uint8_t *bytes = data.bytes;
	
	if(data.length < 0x4d1)
	{
		DLog(@"data length (0x%X) incorrect, bailing.", data.length);
		return NO;
	}
	
	if(bytes[0x06] != 0x52)
	{
		NSLog(@"not kit ID, bailing.");
		return NO;
	}
	
	if(![self messageLengthIsValid:data] ||
	   ![self checksumIsValid:data]) return NO;

	return YES;
}








+ (void) hydrateKit:(MDKit *)kit  originalPositionFromData:(NSData *)data;
{
	kit.originalPosition = ((const char *)data.bytes)[0x09];
	//DLog(@"original position: %d", kit.originalPosition);
}

+ (void) hydrateKit:(MDKit *)kit nameFromData:(NSData *)data
{
	const char *name = &((const char *)data.bytes)[0x0a];
	kit.kitName = [NSData dataWithBytes:name length:16];
	//DLog(@"name: %@ bytes: %s", kit.kitName, name);
}

+ (void)hydrateKit:(MDKit *)kit trackParamsFromData:(NSData *)data
{
	for (int i = 0; i < 16; i++)
	{
		MDKitTrack *track = [kit.tracks objectAtIndex:i];
		const char *paramsTrack = &((const char *)data.bytes)[0x1a + i*24];
		
		for (int j = 0; j < 24; j++)
		{
			[track.params setParam:j toValue:paramsTrack[j]];
		}
	}
}

+ (void)hydrateKit:(MDKit *)kit levelsFromData:(NSData *)data
{
	const char *trackLevels = &((const char *)data.bytes)[0x19a]; // +16
	//DLog(@"track levels: \n");
	for (int i  = 0; i < 16; i++)
	{
		MDKitTrack *track = [kit.tracks objectAtIndex:i];
		track.level = [NSNumber numberWithInt:trackLevels[i]];
		//printf("%d ", track.level.intValue);
	}
	//printf("\n\n");
}

+ (void)hydrateKit:(MDKit *)kit drumModelsFromData:(NSData *)data
{
	// NSData is a Cocoa class which is just a convenient wrapper
	// around any blob of bytes, easier to pass around in method calls etc.
	// the data argument here is just the entire sysex kit message,
	// has nothing to do with what Elektron describe as data in the sysex docs.
	
	const char *packedDrumModelBytes = &((const char *)data.bytes)[0x1aa]; // grab the packed bytes from the sysex message
	NSUInteger packedDrumModelsLength = 74;							// when packed, they're 74 bytes
	
	// now unpack them.
	// my MDSysexUtil class handles unpacking the 7bit encoding:
	
	NSData *packedDrumModelsData = [NSData dataWithBytes:packedDrumModelBytes length:packedDrumModelsLength];
	NSData *drumModelsUnpacked = [MDSysexUtil dataUnpackedFrom7BitSysexEncoding: packedDrumModelsData];
	
	// grab the bytes from the unpacked data
	// these are 16*4 = 64 bytes:
	
	const char *drumModelsUnpackedBytes = drumModelsUnpacked.bytes;
	
	printf("\n");
	
	for (int i = 0; i < 16; i++) // loop through tracks
	{
		// here's the interesting part.
		// every track gets 4 bytes for its drum model, the first 3 of which are just 0,
		// we only need every 4th byte.
		// so in the subscript brackets below, 3 + i * 4 would give you the first bytes per track,
		// we offset that by 3 to get the machine number we want.
		
		MDMachineID model = drumModelsUnpackedBytes[3 + i * 4];
		MDKitTrack *track = [kit.tracks objectAtIndex:i];			// get track at i
		track.machine = model;								// and set its drum model
		
		DLog(@"track %2d machine: %d", i, track.machine);
		
		
	}
	
	printf("\n");
}

+ (void)hydrateKit:(MDKit *)kit LFOSettingsFromData:(NSData *)data
{
	const char *lfoSettings = &((const char *)data.bytes)[0x1f4]; // +659
	NSUInteger lfoSettingsLength = 659;
	NSData *lfoSettingsUnpacked = [MDSysexUtil dataUnpackedFrom7BitSysexEncoding:
								   [NSData dataWithBytes:lfoSettings length:lfoSettingsLength]];
	
	const char *lfoSettingsUnpackedBytes = lfoSettingsUnpacked.bytes;
	
	
	//DLog(@"LFO settings: \n\n");
	
	for (int i  = 0; i < 16; i++)
	{
		MDKitTrack *track = [kit.tracks objectAtIndex:i];
		const char *lfoPerTrack = &lfoSettingsUnpackedBytes[i * 36];
		
		MDKitLFOSettings *lfo = track.lfoSettings;
		lfo.destinationTrack = [NSNumber numberWithInt:lfoPerTrack[0x00]];
		lfo.destinationParam = [NSNumber numberWithInt:lfoPerTrack[0x01]];
		lfo.shape1 = [NSNumber numberWithInt:lfoPerTrack[0x02]];
		lfo.shape2 = [NSNumber numberWithInt:lfoPerTrack[0x03]];
		lfo.type = lfoPerTrack[0x04];
		lfo.internalState = [NSData dataWithBytes:&lfoPerTrack[0x05] length:31];
		
		//DLog(@"lfo internal state: %@", lfo.internalState);
		
		//DLog(@"track %d:", i);
		//DLog(@"%@", lfo);
		
	}
	//printf("\n\n");
}

+ (void)hydrateKit:(MDKit *)kit reverbSettingsFromData:(NSData *)data
{
	kit.reverbSettings = [MDSysexUtil numbersFromBytes:&((const char *)data.bytes)[0x487] withLength:8];
	//DLog(@"reverb settings: %@", kit.reverbSettings);
}

+ (void)hydrateKit:(MDKit *)kit delaySettingsFromData:(NSData *)data
{
	kit.delaySettings = [MDSysexUtil numbersFromBytes:&((const char *)data.bytes)[0x48f] withLength:8];
	//DLog(@"delay settings: %@", kit.delaySettings);
}

+ (void)hydrateKit:(MDKit *)kit EQSettingsFromData:(NSData *)data
{
	kit.eqSettings = [MDSysexUtil numbersFromBytes:&((const char *)data.bytes)[0x497] withLength:8];
	//DLog(@"eq settings: %@", kit.eqSettings);
}

+ (void)hydrateKit:(MDKit *)kit dynamicsSettingsFromData:(NSData *)data
{
	kit.dynamicsSettings = [MDSysexUtil numbersFromBytes:&((const char *)data.bytes)[0x49f] withLength:8];
	//DLog(@"dynamics settings: %@", kit.dynamicsSettings);
}

+ (void)hydrateKit:(MDKit *)kit trigGroupsFromData:(NSData *)data
{
	NSData *unpackedTrigGroups = [MDSysexUtil dataUnpackedFrom7BitSysexEncoding:
								  [NSData dataWithBytes:&((const char *)data.bytes)[0x4a7] length:37]];
	
	
	const char *trigGroupBytes = unpackedTrigGroups.bytes;
	
	
	//DLog(@"trig groups: \n\n");
	for (int i = 0; i < 16; i++)
	{
		int8_t trigAtTrack = trigGroupBytes[i];
		int8_t muteAtTrack = trigGroupBytes[i + 0x10];
		MDKitTrack *track = [kit.tracks objectAtIndex:i];
		track.trigGroup = trigAtTrack;
		track.muteGroup = muteAtTrack;
		
		//printf("track %d trigs: %d mutes: %d\n", i, track.trigGroup, track.muteGroup);
	}
	//printf("\n\n");
	
}

+ (BOOL)checksumIsValid:(NSData *)data
{
	uint8_t checksumUpperBits = ((const char *)data.bytes)[0x4cd] & 0x7f;
	uint8_t checksumLowerBits = ((const char *)data.bytes)[0x4cc] & 0x7f;
	uint16_t checksum = checksumUpperBits | (checksumLowerBits << 7);
	//DLog(@"checksum: %d", checksum);
	
	uint16_t checksumBytesLength = (0x4a7 + 37) - 0x09;
	uint16_t calcedChecksum = 0;
	
	const uint8_t *bytes = &data.bytes[0x09];
	
	for (int i = 0; i < checksumBytesLength; i++)
	{
		calcedChecksum += bytes[i] & 0x7f;
	}
	
	calcedChecksum &= 0x3fff;
	
	
	if(calcedChecksum != checksum)
	{
		//DLog(@"checksum incorrect (%d)! bailing.", calcedChecksum);
		return NO;
	}
	

	return YES;
}

//TODO: is it necessary to check this with a kit?
+ (BOOL) messageLengthIsValid:(NSData *)data
{
	uint8_t messageLengthLowerBits = ((const char *)data.bytes)[0x4cf] & 0x7f;
	uint8_t messageLengthUpperBits = ((const char *)data.bytes)[0x4ce] & 0x7f;
	uint16_t messageLength = (messageLengthUpperBits << 7) | messageLengthLowerBits;
	
	uint16_t calcedMessageLength = data.length - 10;
	
	//DLog(@"message length from data: %d calculated: %d", messageLength, calcedMessageLength);
	
	
	if(calcedMessageLength != messageLength)
	{
		//DLog(@"message length incorrect! bailing.");
		return NO;
	}

	
	return YES;
}

@end
