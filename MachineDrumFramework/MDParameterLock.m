//
//  MDParameterLock.m
//  sysexingApp
//
//  Created by Jakob Penca on 6/14/12.
//
//

#import "MDParameterLock.h"

@interface MDParameterLock()
{
	NSInteger _lockValue;
	NSUInteger _track;
	NSUInteger _step;
	NSUInteger _param;
}
@end


@implementation MDParameterLock

+ (MDParameterLock *)lockForTrack:(NSUInteger)track param:(NSUInteger)p step:(NSUInteger)s value:(NSInteger)v
{
	if(s > 63) return nil;
	if(track > 15) return nil;
	if(p > 24) return nil;
	if(v < -1 || v > 127) return nil;
	
	MDParameterLock *lock = [MDParameterLock new];
	lock->_step = s;
	lock->_track = track < 16 ? track : 0;
	lock->_param = p < 24 ? p : 0;
	lock->_lockValue = v >= -2 && v < 128 ? v : -1;
	
	return lock;
}

- (id)init
{
	if(self = [super init])
	{
		_lockValue = -1;
	}
	return self;
}

- (id)copy
{
	return [MDParameterLock lockForTrack:self.track param:self.param step:self.step value:self.lockValue];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ | t: %ld s: %ld p: %ld v: %ld", [super description], self.track, self.step, self.param, self.lockValue];
}

@end
