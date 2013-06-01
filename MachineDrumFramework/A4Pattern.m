//
//  A4Pattern.m
//  A4Sysex
//
//  Created by Jakob Penca on 3/28/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4Pattern.h"

@implementation A4Pattern

- (uint8_t)kit
{
	const uint8_t *bytes = self.data.bytes;
	return bytes[0x37ef];
}

- (void)setKit:(uint8_t)kit
{
	uint8_t *bytes = self.data.mutableBytes;
	bytes[0x37ef] = kit;
	[self updateChecksum];
}

@end
