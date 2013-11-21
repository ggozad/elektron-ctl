//
//  MDSongParser.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 6/30/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "MDSongParser.h"
#import "MDSong.h"
#import "MDSysexUtil.h"
#import "MDSongRow.h"

@interface MDSongParser()
+ (BOOL) songDataIsValid:(NSData *)data;
+ (BOOL) checksumIsValid:(NSData *)data;
+ (BOOL) messageLengthIsValid:(NSData *)data;
+ (NSData *)dataForSongRow:(MDSongRow *)songRow;
+ (MDSongRow *)songRowForData:(NSData *)d;
@end

@implementation MDSongParser

const uint8_t header[] = {0xf0, 0x00, 0x20, 0x3c, 0x02, 0x00, 0x69, 0x02, 0x02};

+ (NSData *)sysexDataFromSong:(MDSong *)song
{
	NSMutableData *d = [NSMutableData dataWithBytes:header length:0x09];
	char pos = song.position;
	[d appendBytes:&pos length:1];
	
	const char *inString = [song.name cStringUsingEncoding:NSASCIIStringEncoding];
	
	NSUInteger len = StrLength(inString);
	if(len > 8) len = 8;
	
	char nameBytes[16];
	for (int i = 0; i < 16; i++) nameBytes[i] = 0;
	for(int i = 0; i < len; i++)
		nameBytes[i] = inString[i];
	
	[d appendData:[NSData dataWithBytes:&nameBytes length:16]];
	for (MDSongRow *row in song.rows)
	{
		[d appendData:[MDSysexUtil dataPackedWith7BitSysexEncoding:[self dataForSongRow:row]]];
	}
	
	uint8_t tail[] = {0,0,0,0,0xf7};
	
	uint16_t calcedChecksum = 0;
	uint16_t checksumBytesLength = 12 * song.rows.count + 17;
	
	const uint8_t *bytes = d.bytes;
	bytes += 0x09;
	
	for (int i = 0; i < checksumBytesLength; i++)
	{
		calcedChecksum += bytes[i] & 0x7f;
	}
	
	calcedChecksum &= 0x3fff;
	tail[0] = calcedChecksum >> 7;
	tail[1] = calcedChecksum & 0x7f;
	
	
	uint16_t messageLength = d.length + 2 - 0x07;
	messageLength &= 0x3fff;
	tail[2] = messageLength >> 7;
	tail[3] = messageLength & 0x7f;

	[d appendBytes:tail length:5];
	return d;
}

+ (MDSong *)songFromSysexData:(NSData *)data
{
	if(![self songDataIsValid:data])
	{
		DLog(@"invalid data, bailing");
		return nil;
	}
	
	const uint8_t *bytes = data.bytes;
	NSUInteger len = data.length;
	NSUInteger numberOfSongRows = (len - 0x1a - 5) / 12;
	DLog(@"num rows: %d", numberOfSongRows);
	
	MDSong *song = [MDSong new];
	song.position = bytes[0x09];
	song.name = [NSString stringWithCString:(const char *)bytes+0x0a encoding:NSASCIIStringEncoding];
	
	for (int i = 0; i < numberOfSongRows; i++)
	{
		NSData *subData = [data subdataWithRange:NSMakeRange(0x1a + i*12, 12)];
		MDSongRow *row = [self songRowForData:[MDSysexUtil dataUnpackedFrom7BitSysexEncoding:subData]];
		[song.rows addObject:row];
	}
	return song;
}

+ (MDSongRow *)songRowForData:(NSData *)d
{
	const char *bytes = d.bytes;
	MDSongRow *row = [MDSongRow new];
	
	row.pattern = bytes[0];
	row.kit = bytes[1];
	row.loopCount = bytes[2];
	row.rowJump = bytes[3];
	
	uint16_t *mute = (uint16_t *)(bytes+4);
	uint16_t muteValue = CFSwapInt16BigToHost(*mute);
	row.mutes = muteValue;
	
	uint16_t *tempo = (uint16_t *)(bytes+6);
	uint16_t tempoValue = CFSwapInt16BigToHost(*tempo);
	row.tempo = tempoValue / 24.0;
	
	row.start = bytes[8];
	row.stop = bytes[9];
	
	return row;
}

+ (NSData *)dataForSongRow:(MDSongRow *)songRow
{
	uint8_t *bytes = malloc(10);
	memset(bytes, 0, 10);
	
	bytes[0] = (uint8_t) songRow.pattern;
	bytes[1] = (uint8_t) songRow.kit;
	bytes[2] = (uint8_t) songRow.loopCount;
	bytes[3] = (uint8_t) songRow.rowJump;
	uint16_t *mute = (uint16_t *)(bytes+4);
	*mute = CFSwapInt16HostToBig(songRow.mutes);
	uint16_t *tempo = (uint16_t *)(bytes+6);
	*tempo = CFSwapInt16HostToBig((uint16_t) (songRow.tempo * 24.0));
	
	bytes[8] = songRow.start;
	bytes[9] = songRow.stop;
	
	NSData *d = [NSData dataWithBytesNoCopy:bytes length:10 freeWhenDone:YES];
	return d;
}

+ (BOOL)songDataIsValid:(NSData *)data
{
	//DLog(@"sanity checking kit data...");
	const uint8_t *bytes = data.bytes;
	
	if(data.length < 0x1e + 12)
	{
		DLog(@"data length (0x%X) incorrect, bailing.", data.length);
		return NO;
	}
	
	if(bytes[0x06] != 0x69)
	{
		DLog(@"not song ID, bailing.");
		return NO;
	}
	
	if(![self messageLengthIsValid:data] ||
	   ![self checksumIsValid:data]) return NO;
	
	DLog(@"OK");
	
	return YES;
}

+ (BOOL)messageLengthIsValid:(NSData *)data
{
	const uint8_t *bytes = (const uint8_t *)data.bytes;
	uint16_t dLen = data.length;
	uint16_t len = data.length - 10;
	uint16_t mLen = (bytes[dLen - 3] << 7) | (bytes[dLen - 2] & 0x7f);
	if(len != mLen)
	{
		return NO;
	}
	DLog(@"length ok");
	return YES;
}

+ (BOOL)checksumIsValid:(NSData *)data
{
	uint16_t checksum = 0;
	NSUInteger checksumStartPos = 0x09;
	NSUInteger checksumEndPos = data.length - 5;
	
	const uint8_t *bytes = data.bytes;
	
	for (NSUInteger j = checksumStartPos; j < checksumEndPos; j++)
	{
		checksum += bytes[j];
	}
	
	checksum &= 0x3fff;
	
	if(bytes[checksumEndPos] != checksum >> 7
	   ||
	   bytes[checksumEndPos + 1] != (checksum & 0x7f))
	{
		return NO;
	}
	
	DLog(@"checksum ok");
	return YES;
}

@end
