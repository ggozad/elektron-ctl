//
//  A4Kit.m
//  A4Sysex
//
//  Created by Jakob Penca on 3/28/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4Kit.h"

@implementation A4Kit


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

- (void)setName:(NSString *)name
{
	name = [name uppercaseString];
	NSCharacterSet * set =
	[[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789+-=&/#@?\%$0123456789\""] invertedSet];
	name = [[name componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
	
	NSUInteger len = name.length;
	if (len > 15) len = 15;
	name = [name substringWithRange:NSMakeRange(0, len)];
	
	const uint8_t *cString = (const uint8_t *)[[name uppercaseString] cStringUsingEncoding:NSASCIIStringEncoding];
	unsigned long cStringLength = strlen((const char *)cString);
	
	uint8_t *bytes = self.data.mutableBytes;
	bytes += 0xf;
	
	for (int j = 0; j < 15; j++)
		bytes[j] = 0;
	
	int i = 0;

	for (int j = 0; j < cStringLength; j++)
	{
		bytes[i++] = cString[j];
		if(i == 3 || i == 11) i++;
	}
	
	[self updateChecksum];
}

- (NSString *)name
{
	uint8_t buf[16] = {0};
	NSString *name = @"";
	uint8_t *bytes = self.data.mutableBytes;
	bytes += 0xf;
	
	for (int i = 0, j = 0; i < 15; i++)
	{
		buf[i] = bytes[j];
		j++;
		if(j == 3 || j == 11) j++;
	}
	
	name = [NSString stringWithCString:(const char *)&buf encoding:NSASCIIStringEncoding];
	return name;
}


@end
