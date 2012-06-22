//
//  MDPatternParameterLocks.m
//  sysexingApp
//
//  Created by Jakob Penca on 6/14/12.
//
//

#import "MDPatternParameterLocks.h"
#import "MDPattern.h"
#import "MDParameterLockRow.h"

@interface MDPatternParameterLocks()
{
	//uint8_t _rowCount;
	//uint8_t _totalCount;
}
@end


@implementation MDPatternParameterLocks

- (id)init
{
	if(self = [super init])
	{
		_lockRows = [NSMutableArray array];
	}
	return self;
}

- (void)clearLocksAtTrack:(uint8_t)t step:(uint8_t)s
{
	for(NSUInteger i = [self.lockRows count]; i > 0; i--)
	{
		MDParameterLockRow *row = [_lockRows objectAtIndex:i];
		if(row.track == t)
		{
			[row setStep:s toValue:-1]; _totalCount--;
			if([row isEmpty])
			{
				[self.lockRows removeObject:row];
				_rowCount--;
			}
		}
	}
}

- (BOOL)setLock:(MDParameterLock *)lock
{
	//DLog(@"track %2ld param %2ld step %2ld -> %3ld", lock.track, lock.param, lock.step, lock.lockValue);
	if( ! [[self.pattern.tracks objectAtIndex:lock.track] trigAtStep:lock.step])
	{
		//DLog(@"no step!");
		return NO;
	}
	
	
	
	MDParameterLockRow *existingLockRow = nil;
	for (MDParameterLockRow *row in self.lockRows)
	{
		if(row.track == lock.track && row.param == lock.param)
		{
			existingLockRow = row;
			break;
		}
		
	}
	
	if(existingLockRow)
	{
		[existingLockRow setStep:lock.step toValue:lock.lockValue];
	}
	else
	{
		if(self.lockRows.count < 64)
		{
			MDParameterLockRow *row = [MDParameterLockRow parameterLockRowForLock:lock];
			[self.lockRows addObject:row];
		}
		else
			DLog(@"trying to add row when full. fuck this!");
		
		
		[self.lockRows sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
		{
			MDParameterLockRow *r1 = obj1;
			MDParameterLockRow *r2 = obj2;
			
			if(r1.track > r2.track)
				return NSOrderedDescending;
			else if(r1.track < r2.track)
				return NSOrderedAscending;
			
			if(r1.param > r2.param)
				return NSOrderedDescending;
			else if(r1.param < r2.param)
				return NSOrderedAscending;
			
			DLog(@"COMPARISON FAIL!");
			
			return NSOrderedSame;
		}];
		
		
		
	}
	
	
	
	return YES;
}

- (void)printRows
{
	for (MDParameterLockRow *row in self.lockRows)
	{
		DLog(@"%@", [row description]);
	}
}


@end
