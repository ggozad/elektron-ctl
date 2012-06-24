//
//  MDParameterLockRow.m
//  sysexingApp
//
//  Created by Jakob Penca on 6/14/12.
//
//

#import "MDParameterLockRow.h"

@implementation MDParameterLockRow

- (id)init
{
	if(self = [super init])
	{
		char bytes[64];
		for(int i = 0; i < 64; i++) bytes[i] = 0xFF;
		self.valueStepData = [NSData dataWithBytes:&bytes length:64];
	}
	return self;
}

- (void)setStep:(uint8_t)step toValue:(int8_t)value
{
	char *bytes = (char *) self.valueStepData.bytes;
	bytes[step] = value;
	
	
	
	self.valueStepData = [NSData dataWithBytes:bytes length:64];
	
	bytes = (char *) self.valueStepData.bytes;
	
	if(bytes[step] != value) DLog(@"FOOOOOCK");
}

- (BOOL)isEmpty
{
	char *bytes = (char *) self.valueStepData.bytes;
	BOOL empty = YES;
	for (int i = 0; i < 64; i++)
	{
		if(bytes[i] > -1)
		{
			empty = NO;
			break;
		}
	}
	return empty;
}

+ (MDParameterLockRow *)parameterLockRowForTrack:(uint8_t)track param:(uint8_t)param withValueStepData:(NSData *)data
{
	MDParameterLockRow *row = [MDParameterLockRow new];
	
	NSAssert(track < 16, @"track out of range");
	NSAssert(param < 24, @"param out of range");
	NSAssert(data.length == 64, @"data out of range");
	
	row.track = track;
	row.param = param;
	row.valueStepData = data;
	return row;
}

+ (MDParameterLockRow *)parameterLockRowForLock:(MDParameterLock *)lock
{
	MDParameterLockRow *row = [MDParameterLockRow new];
	
	row.track = lock.track;
	row.param = lock.param;
	[row setStep:lock.step toValue:lock.lockValue];
	
	return row;
}

- (NSString *)description
{
	const char *bytes = self.valueStepData.bytes;
	NSString *stepValsString = @"";
	
	for(int i = 0; i < 64; i++)
	{
		stepValsString = [stepValsString stringByAppendingFormat:@"%3d ", bytes[i]];
		if(i == 31) stepValsString = [stepValsString stringByAppendingString:@"\n"];
	}
		
	
	return [NSString stringWithFormat:@"t: %02d p: %02d s:\n%@", self.track, self.param, stepValsString];
}

@end
