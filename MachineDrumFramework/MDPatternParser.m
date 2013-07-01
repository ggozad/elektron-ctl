//
//  MDPatternParser.m
//  sysexingApp
//
//  Created by Jakob Penca on 6/14/12.
//
//

#import "MDPatternParser.h"
#import "MDSysexUtil.h"
#import "MDParameterLockRow.h"
#import "MDPatternTrack.h"
#import "MDParameterLockRow.h"
#import "MDPatternParameterLocks.h"

#define kPatternMessageLengthShort (5400 - 2647)
#define kPatternMessageLengthLong 5400


@interface MDPatternParser()

// VALIDITY

+ (BOOL) patternDataIsValid:(NSData *)data;
+ (BOOL) checksumIsValid:(NSData *)data;
+ (BOOL) messageLengthIsValid:(NSData *)data;
+ (NSUInteger) messageLengthForData:(NSData *)data;

// BUILDING A PATTERN

+ (void) hydratePattern:(MDPatternPrivate *)pattern withOriginalPositionFromData:(NSData *)data;
+ (void) hydratePattern:(MDPatternPrivate *)pattern withTrigPatternFromData:(NSData *)data;
+ (void) hydratePattern:(MDPatternPrivate *)pattern withAccentPatternFromData:(NSData *)data;
+ (void) hydratePattern:(MDPatternPrivate *)pattern withAccentAmountFromData:(NSData *)data;
+ (void) hydratePattern:(MDPatternPrivate *)pattern withPatternLengthFromData:(NSData *)data;
+ (void) hydratePattern:(MDPatternPrivate *)pattern withTempoMultiplierFromData:(NSData *)data;
+ (void) hydratePattern:(MDPatternPrivate *)pattern withScaleFromData:(NSData *)data;
+ (void) hydratePattern:(MDPatternPrivate *)pattern withKitNumberFromData:(NSData *)data;
+ (void) hydratePattern:(MDPatternPrivate *)pattern withNumberOfLockedRowsFromData:(NSData *)data;
+ (void) hydratePattern:(MDPatternPrivate *)pattern withLocksFromData:(NSData *)data;
+ (void) hydratePattern:(MDPatternPrivate *)pattern withExtraPatternFromData:(NSData *)data;
+ (void) hydratePattern:(MDPatternPrivate *)pattern withOptionalExtraPatternFromData:(NSData *)data;

// BUILDING DATA

+ (NSData *)dataForOriginalPositionInPattern: (MDPatternPrivate *)pattern;
+ (NSData *)dataForTrigPatternInPattern: (MDPatternPrivate *)pattern;
+ (NSData *)dataForLockPatternInPattern: (MDPatternPrivate *)pattern;
+ (NSData *)dataForAccentPatternInPattern: (MDPatternPrivate *)pattern;
+ (NSData *)dataForAccentAmountInPattern: (MDPatternPrivate *)pattern;
+ (NSData *)dataForPatternLengthInPattern: (MDPatternPrivate *)pattern;
+ (NSData *)dataForTempoMultiplierInPattern: (MDPatternPrivate *)pattern;
+ (NSData *)dataForScaleInPattern: (MDPatternPrivate *)pattern;
+ (NSData *)dataForKitInPattern: (MDPatternPrivate *)pattern;
+ (NSData *)dataForNumberOfLockedRowsInPattern: (MDPatternPrivate *)pattern;
+ (NSData *)dataForLocksInPattern: (MDPatternPrivate *)pattern;
+ (NSData *)dataForExtraPatternInPattern: (MDPatternPrivate *)pattern;
+ (NSData *)dataForOptionalExtraPatternInPattern: (MDPatternPrivate *)pattern;

+ (NSData *)dataForEndOfMessageData:(NSData *)data;

@end

@implementation MDPatternParser

#pragma mark - public class methods

+ (MDPatternPrivate *)patternFromSysexData:(NSData *)data
{	
	if(![self patternDataIsValid:data])
		return nil;
		
	
	NSUInteger messageLength = [self messageLengthForData: data];
	
	MDPatternPrivate *pattern = [MDPatternPrivate new];
	
	//DLog(@"hydrating pattern:");
	
	[self hydratePattern:pattern withOriginalPositionFromData:data];
	[self hydratePattern:pattern withTrigPatternFromData:data];
	
	if(messageLength == kPatternMessageLengthLong)
	{
		//DLog(@"got long pattern message. parsing optional pattern data:");
		[self hydratePattern:pattern withOptionalExtraPatternFromData:data];
	}

	[self hydratePattern:pattern withLocksFromData:data];
	[self hydratePattern:pattern withAccentPatternFromData:data];
	[self hydratePattern:pattern withAccentAmountFromData:data];
	[self hydratePattern:pattern withPatternLengthFromData:data];
	[self hydratePattern:pattern withTempoMultiplierFromData:data];
	[self hydratePattern:pattern withScaleFromData:data];
	[self hydratePattern:pattern withKitNumberFromData:data];
	[self hydratePattern:pattern withNumberOfLockedRowsFromData:data];
	
	[self hydratePattern:pattern withExtraPatternFromData:data];
	
		
	return pattern;
}




+ (NSData *)sysexDataFromPattern:(MDPatternPrivate *)pattern
{
	//TODO: check pattern integrity
	BOOL patternIsGood = YES;
	if(!patternIsGood) return nil;
	
	//TODO: differentiate short and long patterns
	BOOL isLongPattern = YES;
	
	NSMutableData *data = [NSMutableData data];
	char header[] = {0xf0, 0x00, 0x20, 0x3c, 0x02, 0x00, 0x67, 0x03, 0x01};
	[data appendBytes:&header length:0x09];
	
	[data appendData:[self dataForOriginalPositionInPattern:pattern]];
	[data appendData:[self dataForTrigPatternInPattern:pattern]];
	[data appendData:[self dataForLockPatternInPattern:pattern]];
	[data appendData:[self dataForAccentPatternInPattern:pattern]];
	[data appendData:[self dataForAccentAmountInPattern:pattern]];
	[data appendData:[self dataForPatternLengthInPattern:pattern]];
	[data appendData:[self dataForTempoMultiplierInPattern:pattern]];
	[data appendData:[self dataForScaleInPattern:pattern]];
	[data appendData:[self dataForKitInPattern:pattern]];
	[data appendData:[self dataForNumberOfLockedRowsInPattern:pattern]];
	[data appendData:[self dataForLocksInPattern:pattern]];
	[data appendData:[self dataForExtraPatternInPattern:pattern]];
	if(isLongPattern)
		[data appendData:[self dataForOptionalExtraPatternInPattern:pattern]];
	[data appendData:[self dataForEndOfMessageData:data]];
	
//	DLog(@"done building data, validating..");
	
	BOOL success = [self patternDataIsValid:data];
	if(success) return data;
	return nil;
}


#pragma mark - data building

+ (NSData *)dataForOriginalPositionInPattern:(MDPatternPrivate *)pattern
{
	uint8_t posByte = pattern.originalPosition;
	return [NSData dataWithBytes:&posByte length:1];
}

+ (NSData *)dataForTrigPatternInPattern:(MDPatternPrivate *)pattern
{
	int32_t unpackedBytes[16];
	for (int i = 0; i < 16; i++)
	{
		MDPatternTrack *t = [pattern.tracks objectAtIndex:i];
		unpackedBytes[i] = CFSwapInt32HostToBig(t->trigPattern_00_31);
	}
	
	return [MDSysexUtil dataPackedWith7BitSysexEncoding:[NSData dataWithBytes:&unpackedBytes length:16*4]];
}

+ (NSData *)dataForLockPatternInPattern:(MDPatternPrivate *)pattern
{
	int32_t bytes[16];
	for (int i = 0; i < 16; i++)
		bytes[i] = 0;
	
	MDPatternParameterLocks *locks = pattern.locks;
	
	for (MDParameterLockRow *row in locks.lockRows)
	{
		bytes[row.track] |= 1 << row.param;
	}
	
	for (int i = 0; i < 16; i++)
	{
		bytes[i] = CFSwapInt32HostToBig(bytes[i]);
	}
		
	/*
	DLog(@"lock pattern: \n\n");
	for (int i = 0; i < 16; i++)
	{
		printf("%s\n", [[MDSysexUtil getBitStringForInt:bytes[i]] cStringUsingEncoding:NSASCIIStringEncoding]);
	}
	*/
		
	
	return [MDSysexUtil dataPackedWith7BitSysexEncoding:[NSData dataWithBytes:&bytes length:16 * 4]];
}

+ (NSData *)dataForAccentPatternInPattern:(MDPatternPrivate *)pattern
{
	int32_t bytes[4];
	for (int i = 0; i < 4; i++)
		bytes[i] = 0;
	
	bytes[0x00] = CFSwapInt32HostToBig(pattern->accentPattern_00_31);
	bytes[0x01] = CFSwapInt32HostToBig(pattern->slidePattern_00_31);
	bytes[0x02] = CFSwapInt32HostToBig(pattern->swingPattern_00_31);
	bytes[0x03] = CFSwapInt32HostToBig(pattern.swingAmount);
	
	return [MDSysexUtil dataPackedWith7BitSysexEncoding:[NSData dataWithBytes:&bytes length:4*4]];
}

+ (NSData *)dataForAccentAmountInPattern:(MDPatternPrivate *)pattern
{
	uint8_t byte = pattern.accentAmount;
	return [NSData dataWithBytes:&byte length:1];
}

+ (NSData *)dataForPatternLengthInPattern:(MDPatternPrivate *)pattern
{
	uint8_t byte = pattern.length;
	return [NSData dataWithBytes:&byte length:1];
}

+ (NSData *)dataForTempoMultiplierInPattern:(MDPatternPrivate *)pattern
{
	uint8_t byte = pattern.tempoMultiplier;
	return [NSData dataWithBytes:&byte length:1];
}

+ (NSData *)dataForScaleInPattern:(MDPatternPrivate *)pattern
{
	uint8_t byte = pattern.scale;
	return [NSData dataWithBytes:&byte length:1];
}

+ (NSData *)dataForKitInPattern:(MDPatternPrivate *)pattern
{
	uint8_t byte = pattern.kitNumber;
	return [NSData dataWithBytes:&byte length:1];
}

+ (NSData *)dataForNumberOfLockedRowsInPattern:(MDPatternPrivate *)pattern
{
	uint8_t byte = pattern.numberOfLockedRows_UNUSED;
	return [NSData dataWithBytes:&byte length:1];
}

+ (NSData *)dataForLocksInPattern:(MDPatternPrivate *)pattern
{
	signed char bytes[64 * 32];
	for (int i = 0; i < 64*32; i++)
		bytes[i] = 0;
	
	MDPatternParameterLocks *locks = pattern.locks;
	int i = 0;
	for (MDParameterLockRow *row in locks.lockRows)
	{
		//DLog(@"row %d", i);
		const signed char *rowBytes = row.valueStepData.bytes;
		
		for (int j = 0; j < 32; j++)
		{
			bytes[i * 32 + j] = rowBytes[j];
		}
		i++;
		if(i == 64) break;
	}
	
	return [MDSysexUtil dataPackedWith7BitSysexEncoding:[NSData dataWithBytes:&bytes length:32*64]];
}

+ (NSData *)dataForExtraPatternInPattern:(MDPatternPrivate *)pattern
{
	char bytes[51*4];
	for (int i = 0; i < 51*4; i++)
		bytes[i] = 0;
	
	
	bytes[0x03] = pattern.accentEditAllFlag ? 0x01 : 0x00;
	bytes[0x07] = pattern.slideEditAllFlag ? 0x01 : 0x00;
	bytes[0x0b] = pattern.swingEditAllFlag ? 0x01 : 0x00;
	
	int i = 0;
	int32_t *patternsBytes = (int32_t *) &bytes[0x0c];
	for (MDPatternTrack *track in pattern.tracks)
	{
		patternsBytes[     i] = CFSwapInt32HostToBig(track->accentPattern_00_31);
		patternsBytes[i + 16] = CFSwapInt32HostToBig(track->slidePattern_00_31);
		patternsBytes[i + 32] = CFSwapInt32HostToBig(track->swingPattern_00_31);
		i++;
	}
	
	return [MDSysexUtil dataPackedWith7BitSysexEncoding:[NSData dataWithBytes:&bytes length:51*4]];
}

+ (NSData *)dataForOptionalExtraPatternInPattern:(MDPatternPrivate *)pattern
{
	char bytes[2316];
	for (int i = 0; i < 2316; i++)
		bytes[i] = 0;
	
	
	int32_t *trigTracks = (int32_t *)bytes;
	int32_t *accentPatternPerTrack =  (int32_t *) &bytes[0x84c];
	int32_t *slidePatternPerTrack =  (int32_t *) &bytes[0x88c];
	int32_t *swingPatternPerTrack =  (int32_t *) &bytes[0x8cc];
	
	for (int i = 0; i < 16; i++)
	{
		MDPatternTrack *track = [pattern.tracks objectAtIndex:i];
		trigTracks[i] = CFSwapInt32HostToBig(track->trigPattern_32_63);
		accentPatternPerTrack[i] = CFSwapInt32HostToBig(track->accentPattern_32_63);
		slidePatternPerTrack[i] = CFSwapInt32HostToBig(track->slidePattern_32_63);
		swingPatternPerTrack[i] = CFSwapInt32HostToBig(track->swingPattern_32_63);
	}
	
	signed char *locksBytes = (signed char *) &bytes[0x04c];
	
	MDPatternParameterLocks *locks = pattern.locks;
	int i = 0;
	for (MDParameterLockRow *row in locks.lockRows)
	{
		//DLog(@"row %d", i);
		const signed char *rowBytes = row.valueStepData.bytes;
		rowBytes += 32;
		
		for (int j = 0; j < 32; j++)
		{
			locksBytes[i * 32 + j] = rowBytes[j];
		}
		i++;
		if(i == 64) break;
	}
	
//	DLog(@"locks bytes:\n%@", [NSData dataWithBytes:locksBytes length:64*32]);

		
	int32_t *accentPattern = (int32_t *) &bytes[0x040];
	accentPattern[0x00] = CFSwapInt32HostToBig(pattern->accentPattern_32_63);
	accentPattern[0x01] = CFSwapInt32HostToBig(pattern->slidePattern_32_63);
	accentPattern[0x02] = CFSwapInt32HostToBig(pattern->swingPattern_32_63);
	
	return [MDSysexUtil dataPackedWith7BitSysexEncoding:[NSData dataWithBytes:&bytes length:2316]];
}


+ (NSData *)dataForEndOfMessageData:(NSData *)data
{
	char endBytes[] = {0,0,0,0,0xf7};
	
	uint16_t calcedChecksum = 0;
	uint16_t checksumBytesLength = 0;
	if(data.length == 0xac6)
		checksumBytesLength = (0x9dc + 234) - 0x09;
	else if(data.length == 0x151d)
		checksumBytesLength = (0xac6 + 2647) - 0x09;
	else
		DLog(@"data length is 0x%x", data.length);
	
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


#pragma mark - pattern building

+ (BOOL)patternDataIsValid:(NSData *)data
{
	//DLog(@"sanity checking data...");
	const char *bytes = data.bytes;
	
	/*
	for(int i = 0; i < data.length-1; i++)
	{
		if(bytes[i] == 0xf7)
		{
			DLog(@"message end where it shouldn't be: 0x%x", i);
		}
	}
	*/
	
	if(data.length != 0xacb && data.length != 0x1522)
	{
		DLog(@"data length (0x%X) incorrect, bailing.", data.length);
		return NO;
	}
	
	if(bytes[0x06] != 0x67)
	{
		DLog(@"not pattern ID, bailing.");
		return NO;
	}
	
	if(![self messageLengthIsValid:data] ||
	   ![self checksumIsValid:data]) return NO;
	
	//DLog(@"OK");
	
	return YES;
}

+ (void)hydratePattern:(MDPatternPrivate *)pattern withOriginalPositionFromData:(NSData *)data
{
	pattern.originalPosition = ((const char *)data.bytes)[0x09];
}

+ (void)hydratePattern:(MDPatternPrivate *)pattern withTrigPatternFromData:(NSData *)data
{
	const char *dataBytes = data.bytes;
	NSData *packedTrigPatternData = [NSData dataWithBytes:&dataBytes[0x0a] length:74];
	NSData *unpackedTrigPattern = [MDSysexUtil dataUnpackedFrom7BitSysexEncoding:
								   packedTrigPatternData];
	
	
	const int32_t *trigTracks = unpackedTrigPattern.bytes;
	for (int i = 0; i < 16; i++)
	{
		MDPatternTrack *track = [pattern.tracks objectAtIndex:i];
		track->trigPattern_00_31 = CFSwapInt32BigToHost(trigTracks[i]);
		
		//NSString *binString = @"";
		//binString = [binString stringByAppendingString:[MDSysexUtil getBitStringForInt:track.trigs]];
		//DLog(@"trigs for track %2d: %@ | as int: %d", i, binString, track.trigs);
	}
}

+ (void)hydratePattern:(MDPatternPrivate *)pattern withLocksFromData:(NSData *)data
{
	const char *dataBytes = data.bytes;
	
	NSData *packedLockPatternData = [NSData dataWithBytes:&dataBytes[0x54] length:74];
	NSData *unpackedLockPattern = [MDSysexUtil dataUnpackedFrom7BitSysexEncoding:
								   packedLockPatternData];
	
	const int32_t *lockPatternBytes = unpackedLockPattern.bytes;

	NSData *packedLocksData = [NSData dataWithBytes: &dataBytes[0xb7] length:2341];
	NSData *unpackedLocksData = [MDSysexUtil dataUnpackedFrom7BitSysexEncoding:packedLocksData];
	
	const char *locksBytes = unpackedLocksData.bytes;
	
	const char *locksBytes64 = NULL;
	if(data.length == 0x1522)
	{
		const uint8_t *packedBytes = &((const uint8_t *)data.bytes)[0xac6];
		const char *unpackedBytes = [MDSysexUtil dataUnpackedFrom7BitSysexEncoding:[NSData dataWithBytes:packedBytes length:2647]].bytes;
		locksBytes64 = &unpackedBytes[0x04c];
	}
	
	NSUInteger totalReceivedLocks = 0;
	
	for (int i = 0; i < 64; i++)
	{
		const char *row = &locksBytes[i * 32];
		const char *row64 = NULL;
		if(locksBytes64) row64 = &locksBytes64[i * 32];
		
		char firstStep = row[0];
		BOOL rowHasLockTrigs = NO;
		
		for (int j = 0; j < 32; j++)
		{
			if(row[j] != firstStep)
			{
				rowHasLockTrigs = YES;
				break;
			}
		}
		if(rowHasLockTrigs)
			for (int j = 0; j < 32; j++)
				if(row[j] > -1) totalReceivedLocks++;
		
		if(row64)
		{
			firstStep = row64[0];
			rowHasLockTrigs = NO;
			
			for (int j = 0; j < 32; j++)
			{
				if(row64[j] != firstStep)
				{
					rowHasLockTrigs = YES;
					break;
				}
				
			}
			if(rowHasLockTrigs)
				for (int j = 0; j < 32; j++)
					if(row64[j] > -1) totalReceivedLocks++;
		}
	}
	
	const char *bytesForCurrentRow = locksBytes;
	const char *bytesForCurrentRow64 = locksBytes64;
	
	NSUInteger totalHydratedLocks = 0;
	
	for (uint8_t track = 0; track < 16; track++)
	{
		if(lockPatternBytes[track])
		{
			int32_t val = CFSwapInt32HostToBig(lockPatternBytes[track]);
			
			for (uint8_t param = 0; param < 24; param++)
			{
				if(val & (1 << param))
				{
					for (uint8_t step = 0; step < 32; step++)
					{
						int8_t value = bytesForCurrentRow[step];
						if(value > -1)
						{
							MDParameterLock *
							lock = [MDParameterLock lockForTrack:track
														   param:param
															step:step
														   value:value];
							
							if([pattern.locks setLock:lock]);
						
								
	
								//totalHydratedLocks++;
						}
					}
					if(locksBytes64)
					{
						for (uint8_t step = 0; step < 32; step++)
						{
							int8_t value = bytesForCurrentRow64[step];
							if(value > -1)
							{
								MDParameterLock *
								lock = [MDParameterLock lockForTrack:track
															   param:param
																step:step + 32
															   value:value];
								
								if([pattern.locks setLock:lock])
									totalHydratedLocks++;
							}
						}
					}
					
					bytesForCurrentRow += 32;
					bytesForCurrentRow64 += 32;
				}
			}
		}
	}
}


+ (void)hydratePattern:(MDPatternPrivate *)pattern withAccentAmountFromData:(NSData *)data
{
	const uint8_t *bytes = data.bytes;
	pattern.accentAmount = bytes[0xb1];
	//DLog(@"accent amount: %d", pattern.accentAmount);
}

+ (void)hydratePattern:(MDPatternPrivate *)pattern withPatternLengthFromData:(NSData *)data
{
	const uint8_t *bytes = data.bytes;
	pattern.length = bytes[0xb2];
	//DLog(@"length: %d", pattern.length);
}

+ (void)hydratePattern:(MDPatternPrivate *)pattern withTempoMultiplierFromData:(NSData *)data
{
	const uint8_t *bytes = data.bytes;
	pattern.tempoMultiplier = bytes[0xb3];
	//DLog(@"tempo multiplier: %d", pattern.tempoMultiplier);
}

+ (void)hydratePattern:(MDPatternPrivate *)pattern withScaleFromData:(NSData *)data
{
	const uint8_t *bytes = data.bytes;
	pattern.scale = bytes[0xb4];
	//DLog(@"scale: %d", pattern.scale);
}

+ (void)hydratePattern:(MDPatternPrivate *)pattern withKitNumberFromData:(NSData *)data
{
	const uint8_t *bytes = data.bytes;
	pattern.kitNumber = bytes[0xb5];
	//DLog(@"kit number: %d", pattern.kitNumber);
}

+ (void)hydratePattern:(MDPatternPrivate *)pattern withNumberOfLockedRowsFromData:(NSData *)data
{
	const uint8_t *bytes = data.bytes;
	pattern.numberOfLockedRows_UNUSED = bytes[0xb6];
	//DLog(@"num locked rows (unused): %d", pattern.numberOfLockedRows_UNUSED);
}


+ (void)hydratePattern:(MDPatternPrivate *)pattern withAccentPatternFromData:(NSData *)data
{
	const uint8_t *packedBytes = &((const uint8_t *)data.bytes)[0x9e];
	const int32_t *unpackedBytes = [MDSysexUtil dataUnpackedFrom7BitSysexEncoding:[NSData dataWithBytes:packedBytes length:19]].bytes;
	
	pattern->accentPattern_00_31 = CFSwapInt32BigToHost(unpackedBytes[0x00]);
	pattern->slidePattern_00_31 = CFSwapInt32BigToHost(unpackedBytes[0x01]);
	pattern->swingPattern_00_31 = CFSwapInt32BigToHost(unpackedBytes[0x02]);
	pattern.swingAmount = CFSwapInt32BigToHost(unpackedBytes[0x03]); //TODO: map this!
	
	/*
	DLog(@"accent pattern: %@", [MDSysexUtil getBitStringForInt:pattern.accentPattern]);
	DLog(@" slide pattern: %@", [MDSysexUtil getBitStringForInt:pattern.slidePattern]);
	DLog(@" swing pattern: %@", [MDSysexUtil getBitStringForInt:pattern.swingPattern]);
	DLog(@"  swing amount: %@ as int: %d", [MDSysexUtil getBitStringForInt:pattern.swingAmount], pattern.swingAmount);
	 */
}


+ (void)hydratePattern:(MDPatternPrivate *)pattern withExtraPatternFromData:(NSData *)data
{
	const uint8_t *packedBytes = &((const uint8_t *)data.bytes)[0x9dc];
	const char *unpackedBytes = [MDSysexUtil dataUnpackedFrom7BitSysexEncoding:[NSData dataWithBytes:packedBytes length:234]].bytes;
	
	pattern.accentEditAllFlag = unpackedBytes[0x03] ? YES : NO;
	pattern.slideEditAllFlag = unpackedBytes[0x07] ? YES : NO;
	pattern.swingEditAllFlag = unpackedBytes[0x0b] ? YES : NO;
	
	/*
	for(int i = 0; i < 12; i++)
	{
		DLog(@"0x%x: 0x%x", i, unpackedBytes[i]);
	}
	
	
	DLog(@"accent edit all: %@", pattern.accentEditAllFlag ? @"YES" : @"NO");
	DLog(@" slide edit all: %@", pattern.slideEditAllFlag ? @"YES" : @"NO");
	DLog(@" swing edit all: %@", pattern.swingEditAllFlag ? @"YES" : @"NO");
	*/
	
	const int32_t *unpackedBytesAsInts = (int32_t *) &unpackedBytes[0x0c];
	
	for(int i = 0; i < 16; i++)
	{
		MDPatternTrack *track = [pattern.tracks objectAtIndex:i];
		track->accentPattern_00_31 = CFSwapInt32BigToHost(unpackedBytesAsInts[i]);
		track->slidePattern_00_31 = CFSwapInt32BigToHost(unpackedBytesAsInts[i + 16]);
		track->swingPattern_00_31 = CFSwapInt32BigToHost(unpackedBytesAsInts[i + 32]);
		
		/*
		DLog(@"track %2d accentPattern: %@", i, [MDSysexUtil getBitStringForInt:track.accentPattern]);
		DLog(@"track %2d  slidePattern: %@", i, [MDSysexUtil getBitStringForInt:track.slidePattern]);
		DLog(@"track %2d  swingPattern: %@\n\n", i, [MDSysexUtil getBitStringForInt:track.swingPattern]);
		 */
	}
}

+ (void)hydratePattern:(MDPatternPrivate *)pattern withOptionalExtraPatternFromData:(NSData *)data
{
	// ** ALL LOCKS ** are handled in the locks parsing method
	
	
	const uint8_t *packedBytes = &((const uint8_t *)data.bytes)[0xac6];
	const char *unpackedBytes = [MDSysexUtil dataUnpackedFrom7BitSysexEncoding:[NSData dataWithBytes:packedBytes length:2647]].bytes;
	
	
	const int32_t *trigTracks = (int32_t *) unpackedBytes;
	const int32_t *accentPatternPerTrack =  (int32_t *) &unpackedBytes[0x84c];
	
	for (int i = 0; i < 16; i++)
	{
		MDPatternTrack *track = [pattern.tracks objectAtIndex:i];
		track->trigPattern_32_63 = CFSwapInt32BigToHost(trigTracks[i]);
		
		track->accentPattern_32_63 = CFSwapInt32BigToHost(accentPatternPerTrack[i]);
		track->slidePattern_32_63 = CFSwapInt32BigToHost(accentPatternPerTrack[i + 16]);
		track->swingPattern_32_63 = CFSwapInt32BigToHost(accentPatternPerTrack[i + 32]);
		
		
		/*
		 DLog(@"track %2d accentPattern: %@ %@", i, [MDSysexUtil getBitStringForInt:track.accentPattern_32_63], [MDSysexUtil getBitStringForInt:track.accentPattern_00_31]);
		 DLog(@"track %2d  slidePattern: %@ %@", i, [MDSysexUtil getBitStringForInt:track.slidePattern_32_63], [MDSysexUtil getBitStringForInt:track.slidePattern_00_31]);
		 DLog(@"track %2d  swingPattern: %@ %@\n\n", i, [MDSysexUtil getBitStringForInt:track.swingPattern_32_63], [MDSysexUtil getBitStringForInt:track.swingPattern_00_31]);
		 */

		
		/*
		NSString *binString = @"";
		binString = [binString stringByAppendingString:[MDSysexUtil getBitStringForInt:track.trigPattern_32_63]];
		DLog(@"additional trigs for track %2d: %@ | as int: %d", i, binString, track.trigPattern_32_63);
		 */
	}
	
	const int32_t *accentPattern =  (int32_t *) &unpackedBytes[0x040];
	pattern->accentPattern_32_63 = CFSwapInt32BigToHost(accentPattern[0x00]);
	pattern->slidePattern_32_63 = CFSwapInt32BigToHost(accentPattern[0x01]);
	pattern->swingPattern_32_63 = CFSwapInt32BigToHost(accentPattern[0x02]);
	
	
	
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



@end
