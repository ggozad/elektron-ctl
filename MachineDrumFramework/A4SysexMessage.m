//
//  A4SysexMessage.m
//  A4Sysex
//
//  Created by Jakob Penca on 3/28/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4SysexMessage.h"

@implementation A4SysexMessage

+ (id)messageWithData:(NSData *)data
{
	A4SysexMessage *instance = [self new];
	instance.data = [data mutableCopy];
	return instance;
}

- (void)setPosition:(uint8_t)position
{
	uint8_t *bytes = self.data.mutableBytes;
	bytes[0x9] = position;
	[self updateChecksum];
}

- (uint8_t)position
{
	const uint8_t *bytes = self.data.bytes;
	uint8_t pos = bytes[0x9];
	return pos;
}

- (void) updateChecksum
{
	uint8_t *bytes = (uint8_t *) self.data.mutableBytes;
	uint16_t checksum = 0;
	
	NSUInteger checksumStartPos = 0x0a;
	NSUInteger checksumEndPos = self.data.length - 5;
	
	for (NSUInteger j = checksumStartPos; j < checksumEndPos; j++)
	{
		bytes[j] &= 0x7f;
		checksum += bytes[j];
	}
	checksum &= 0x3fff;
	bytes[checksumEndPos] = checksum >> 7;
	bytes[checksumEndPos + 1] = checksum & 0x7f;
}

- (BOOL)checksumIsValid
{
	const uint8_t *bytes = (const uint8_t *) self.data.mutableBytes;
	uint16_t checksum = 0;
	NSUInteger checksumStartPos = 0x0a;
	NSUInteger checksumEndPos = self.data.length - 5;
	
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
	return YES;
}

- (BOOL)messageLengthIsValid
{
	const uint8_t *bytes = (const uint8_t *)self.data.bytes;
	uint16_t dLen = self.data.length;
	uint16_t len = self.data.length - 10;
	uint16_t mLen = (bytes[dLen - 3] << 7) | (bytes[dLen - 2] & 0x7f);
	if(len != mLen)
	{
		//DLog(@"len: %d mLen: %d", len, mLen);
		return NO;
	}
	
	
	return YES;
}


@end
