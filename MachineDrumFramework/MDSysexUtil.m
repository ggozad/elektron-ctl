//
//  MDSysexUtil.m
//  sysexingApp
//
//  Created by Jakob Penca on 6/11/12.
//
//

#import "MDSysexUtil.h"
#import <CommonCrypto/CommonDigest.h>

@implementation MDSysexUtil


+ (NSString *)md5StringFromData:(NSData *)data
{
    void *cData = malloc([data length]);
    unsigned char resultCString[16];
    [data getBytes:cData length:[data length]];
	
    CC_MD5(cData, (CC_LONG)[data length], resultCString);
    free(cData);
	
    NSString *result = [NSString stringWithFormat:
                        @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                        resultCString[0], resultCString[1], resultCString[2], resultCString[3], 
                        resultCString[4], resultCString[5], resultCString[6], resultCString[7],
                        resultCString[8], resultCString[9], resultCString[10], resultCString[11],
                        resultCString[12], resultCString[13], resultCString[14], resultCString[15]
                        ];
    return result;
}


+ (BOOL)compareData:(NSData *)data0 withData:(NSData *)data1
{
	if(!data0)
	{
		DLog(@"left data is nil");
		return NO;
	}
	
	if(!data1)
	{
		DLog(@"right data is nil");
		return NO;
	}
	
	NSUInteger bytesLength = data0.length;
	
	if(data0.length != data1.length )
	{
		DLog(@"different length %ld vs. %ld", data0.length, data1.length);
		if(data1.length < bytesLength) bytesLength = data1.length;
	}
	
	DLog(@"comparing data byte by byte...");
	
	
	const char *data0Bytes = data0.bytes;
	const char *data1Bytes = data1.bytes;
	NSUInteger diffCount = 0;
	
	for (int i = 0; i < bytesLength; i++)
	{
		if(data0Bytes[i] != data1Bytes[i])
		{
			DLog(@"diff @ 0x%02X : %02X | %02X", i, data0Bytes[i], data1Bytes[i]);
			diffCount++;
		}
	}
	
	DLog(@"found %ld diffs.", diffCount);
	
	return [[self md5StringFromData:data0] isEqualToString:[self md5StringFromData:data1]];
}


+ (NSData *)dataFromHexString:(NSString *)hexStr
{
	NSMutableData *data = [[NSMutableData alloc] init];
	unsigned char wholeByte;
	char byte_chars[3] = {'\0','\0','\0'};
	NSUInteger commandLength = [hexStr length];
	
	for (int i = 0; i < commandLength/2; i++)
	{
		byte_chars[0] = [hexStr characterAtIndex:i*2];
		byte_chars[1] = [hexStr characterAtIndex:i*2+1];
		wholeByte = strtol(byte_chars, NULL, 16);
		[data appendBytes:&wholeByte length:1];
	}
	return data;
}

+ (NSData *)dataPackedWith7BitSysexEncoding:(NSData *)inData
{
	NSUInteger inLength = inData.length;
	uint8_t *outDataBytes;
	NSUInteger outLength = 0;
	
	int blocksOfSevenInBytes = inLength / 7;
	if(inLength > 0 && inLength % 7 == 0) blocksOfSevenInBytes-=1;
	blocksOfSevenInBytes += 1;
	outLength = blocksOfSevenInBytes + inLength;
	
	outDataBytes = calloc(outLength, 1);
	outDataBytes[0] = 0;
	
	const uint8_t *inBytes = [inData bytes];
	NSUInteger count7 = 0;
	NSUInteger outIndex = 0;
	
	for (int i = 0; i < inLength; i++)
	{
		uint8_t rest = inBytes[i] & 0x7f;
		uint8_t msb = inBytes[i] & 0x80;
		msb = msb >> 7;
		
		outDataBytes[outIndex] |= msb << (6 - count7);
		outDataBytes[outIndex + 1 + count7] = rest;
		
		if(++count7 == 7)
		{
			outIndex += 8;
			outDataBytes[outIndex] = 0;
			count7 = 0;
		}
	}
	
	return  [NSData dataWithBytesNoCopy:outDataBytes length:outLength freeWhenDone:YES];
}

+ (NSData *)dataUnpackedFrom7BitSysexEncoding:(NSData *)inData
{
	const signed char *inBytes = inData.bytes;
	NSUInteger inLength = inData.length;
	
	NSUInteger cnt;
	NSUInteger cnt2 = 0;
	uint8_t msbByte = 0;
	NSUInteger outLength = 0;
	
	for (cnt = 0; cnt < inLength; cnt++)
		if(cnt % 8 != 0)
			outLength++;
	
	void *outBytes = calloc(outLength, 1);
	
	for (cnt = 0; cnt < inLength; cnt++)
	{
		if ((cnt % 8) == 0)
		{
			msbByte = inBytes[cnt];
		}
		else
		{
			msbByte <<= 1;
			uint8_t *currentOutByte = outBytes + cnt2++;
			*currentOutByte = inBytes[cnt] | (msbByte & 0x80);
		}
	}
	
	return [NSData dataWithBytesNoCopy:outBytes length:outLength freeWhenDone:YES];
}

+ (NSMutableArray *)numbersFromBytes:(const char *)bytes withLength:(NSUInteger)length
{
	NSMutableArray *array = [NSMutableArray array];
	for (int i = 0; i < length; i++)
	{
		NSNumber *n = [NSNumber numberWithInt:bytes[i]];
		if(n.intValue < 0) n = [NSNumber numberWithInt:0];
		if(n.intValue > 127) n = [NSNumber numberWithInt:127];
		[array addObject: n];
	}
	
	
	return array;
}

+ (NSData *) dataFromNumbersArray:(NSArray *)numbersArray
{
	NSUInteger count = numbersArray.count;
	char vals[count];
	for (int i = 0; i < count; i++)
	{
		vals[i] = 0;
		vals[i] = [[numbersArray objectAtIndex:i] intValue];
		//DLog(@"nsnumber intval: %d vals[%d]: %d", [[numbersArray objectAtIndex:i] intValue], vals[i]);
	}
	return [NSData dataWithBytes:&vals length:count];
}

+ (NSString *)getBitStringForInt:(int)value
{
	value = CFSwapInt32HostToBig(value);
    NSString *bits = @"";
	
    for(int i = 0; i < 32; i ++) {
        bits = [NSString stringWithFormat:@"%i%@", value & (1 << i) ? 1 : 0, bits];
    }
	
    return bits;
}

+ (NSData *)dataWithInvalidBytesStrippedFromData:(NSData *)data
{
	const unsigned char *bytes = data.bytes;
	NSUInteger length = data.length;
	
	unsigned char newBytes[length];
	NSUInteger newBytesIndex = 0;
	
	for (int i = 0; i < length; i++)
	{
		if((i == 0 || i == length-1) ||
		   ! (bytes[i] & 0x80 ))
		{
			newBytes[newBytesIndex++] = bytes[i];
		}
		else
			DLog(@"stripped a byte at 0x%x value: 0x%x", i, bytes[i]);
	}
	
	NSUInteger newLength = newBytesIndex;
	NSUInteger diff = length - newLength;
	
	DLog(@"stripped %ld %@.", diff, diff == 1 ? @"byte" : @"bytes");
	DLog(@"new length: %ld", newLength);
	
	if(diff)
		return [NSData dataWithBytes:&newBytes length:newLength];
	
	return data;
}


@end
