//
//  MDMachinedrumGlobalSettingsParser.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 9/2/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDMachinedrumGlobalSettingsParser.h"
#import "MDMachinedrumGlobalSettings.h"
#import "MDMachinedrumPublic.h"

@interface MDMachinedrumGlobalSettingsParser()
// VALIDITY

+ (BOOL) settingsDataIsValid:(NSData *)data;
+ (BOOL) checksumIsValid:(NSData *)data;
+ (BOOL) messageLengthIsValid:(NSData *)data;
+ (NSUInteger) messageLengthForData:(NSData *)data;


@end

@implementation MDMachinedrumGlobalSettingsParser

+ (id)sysexDataFromGlobalSettings:(MDMachinedrumGlobalSettings *)globalSettings
{
	return nil;
}

+ (id)globalSettingsFromSysexData:(NSData *)d
{
	if(![self settingsDataIsValid:d])
		return nil;
	
	const char *bytes = d.bytes;
	
	MDMachinedrumGlobalSettings *s = [MDMachinedrumGlobalSettings new];
	s.originalPosition = bytes[0x09];
	//DLog(@"slot: %d", s.originalPosition);
	s.routing = bytes[0x0A];
	s.midiBaseChannel = bytes[0xAD];
	s.mechanicalSettings = bytes[0xAE];
	[s setTempoFromLowByte:bytes[0xB0] highByte:bytes[0xAF]];
	s.extendedMode = bytes[0xB1];
	[self parseKeyMapStructureIntoGlobalSettings:s fromData:d];
	
	uint8_t sync = bytes[0xB2];
	s.clockIn = sync & 0x01;
	s.transportIn = sync & 0x10;
	s.clockOut = sync & 0x20;
	s.transportOut = sync & 0x40;
	s.localControl = bytes[0xB3] & 0x01;
	
	MDMachinedrumGlobalSettings_ExternalTrigSettings tLeft, tRight;
	tLeft.track = bytes[0xB4];
	tRight.track = bytes[0xB5];
	tLeft.gate = bytes[0xB6];
	tRight.gate = bytes[0xB7];
	tLeft.sense = bytes[0xB8];
	tRight.sense = bytes[0xB9];
	tLeft.minLevel = bytes[0xBA];
	tRight.minLevel = bytes[0xBB];
	tLeft.maxLevel = bytes[0xBC];
	tRight.maxLevel = bytes[0xBD];
	
	s.trigSettingsA = tLeft;
	s.trigSettingsB = tRight;
	
	s.programChangeSettings = bytes[0xBE];
	s.programChangeTrigMode = bytes[0xBF];
	
	return s;
}

+ (void) parseKeyMapStructureIntoGlobalSettings:(MDMachinedrumGlobalSettings *)s fromData:(NSData *)d
{
	const char *packedBytes = d.bytes;
	packedBytes = &packedBytes[0x1A];
	NSData *packedData = [NSData dataWithBytes:packedBytes length:147];
	NSData *unpackedData = [MDSysexUtil dataUnpackedFrom7BitSysexEncoding:packedData];
	const unsigned char *unpackedBytes = unpackedData.bytes;
	//NSUInteger unpackedLength = unpackedData.length;
	
	s.keyMapStructure = (uint8_t *)unpackedBytes;
	/*
	DLog(@"keymap structure length: %ld", unpackedLength);
	printf("\n\n\n");
	for (int i = 0; i < unpackedLength; i++)
	{
		printf("[%03d:%03d] ", i, unpackedBytes[i]);
	}
	printf("\n\n\n");
	 */
}

+ (BOOL)settingsDataIsValid:(NSData *)data
{
	const char *bytes = data.bytes;
	
	//DLog(@"sanity checking settings data...");
	if(data.length != 0xC5)
	{
		DLog(@"data length incorrect, bailing...");
		return NO;
	}
	
	if(bytes[0x06] != 0x50)
	{
		DLog(@"not settings ID, bailing.");
		return NO;
	}
	
	if(![self messageLengthIsValid:data] ||
	   ![self checksumIsValid:data]) return NO;
	
	DLog(@"OK");
	return YES;
}

+ (NSUInteger)messageLengthForData:(NSData *)data
{
	NSUInteger dataLength = data.length;
	uint8_t messageLengthLowerBits = ((const char *)data.bytes)[dataLength - 2] & 0x7f;
	uint8_t messageLengthUpperBits = ((const char *)data.bytes)[dataLength - 3] & 0x7f;
	uint16_t messageLength = (messageLengthUpperBits << 7) | messageLengthLowerBits;
	return messageLength & 0x3fff;
}

+ (BOOL)checksumIsValid:(NSData *)data
{
	NSUInteger dataLength = data.length;
	uint8_t checksumLowerBits = ((const char *)data.bytes)[dataLength - 4] & 0x7f;
	uint8_t checksumUpperBits = ((const char *)data.bytes)[dataLength - 5] & 0x7f;
	uint16_t checksum = checksumLowerBits | (checksumUpperBits << 7);
	uint16_t checksumBytesLength = dataLength - 5 - 0x09;
	uint16_t calcedChecksum = 0;
	
	const uint8_t *bytes = &data.bytes[0x09];
	
	for (int i = 0; i < checksumBytesLength; i++)
	{
		calcedChecksum += bytes[i] & 0x7f;
	}
	
	calcedChecksum &= 0x3fff;
	
	//DLog(@"checksum: %d calculated: %d", checksum, calcedChecksum);
	
	if(calcedChecksum != checksum)
	{
		DLog(@"checksum incorrect (%d)! bailing.", calcedChecksum);
		return NO;
	}
	return YES;
}

+ (BOOL)messageLengthIsValid:(NSData *)data
{
	NSUInteger dataLength = data.length;
	
	uint8_t messageLengthLowerBits = ((const char *)data.bytes)[dataLength - 2] & 0x7f;
	uint8_t messageLengthUpperBits = ((const char *)data.bytes)[dataLength - 3] & 0x7f;
	uint16_t messageLength = (messageLengthUpperBits << 7) | messageLengthLowerBits;
	
	uint16_t calcedMessageLength = dataLength - 10;
	//DLog(@"message length from data: %d calculated: %d", messageLength, calcedMessageLength);
	if(calcedMessageLength != messageLength)
	{
		DLog(@"message length incorrect! bailing.");
		return NO;
	}
	return YES;
}

@end
