//
//  MDUserParameter.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 8/5/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDUserParameterValue.h"


static inline int Wrap(int kX, int const kLowerBound, int const kUpperBound)
{
    int range_size = kUpperBound - kLowerBound + 1;
	
    if (kX < kLowerBound)
        kX += range_size * ((kLowerBound - kX) / range_size + 1);
	
    return kLowerBound + (kX - kLowerBound) % range_size;
}

@interface MDUserParameterValue()
{
	int8_t _mutableValue;
	int8_t _innerValue;
}
@end



@implementation MDUserParameterValue

- (void)resetToInnerValue
{
	[self setMutableValue:self.innerValue];
}

- (id)init
{
	if(self = [super init])
	{
		self.limit = [MDUserParameterLimit parameterLimitWithhardLowerBound:0 hardUpperBound:127];
	}
	
	return self;
}

- (void)setMutableValue:(int8_t)mutableValue
{
	if(self.wrapMode == MDUserParameterWrapMode_Ignore)
	{
		if(mutableValue < self.limit.lower || mutableValue > self.limit.upper)
			return;
		_mutableValue = mutableValue;
	}
	else if(self.wrapMode == MDUserParameterWrapMode_Wrap)
	{
		mutableValue = Wrap(mutableValue, self.limit.lower, self.limit.upper);
		_mutableValue = mutableValue;
	}
	else if(self.wrapMode == MDUserParameterWrapMode_Clamp)
	{
		if(mutableValue < self.limit.lower) mutableValue = self.limit.lower;
		if(mutableValue > self.limit.upper) mutableValue = self.limit.upper;
		_mutableValue = mutableValue;
	}
}

- (void)setInnerValue:(int8_t)innerValue
{
	if(self.wrapMode == MDUserParameterWrapMode_Ignore)
	{
		if(innerValue < self.limit.lower || innerValue > self.limit.upper)
			return;
		_innerValue = innerValue;
	}
	else if(self.wrapMode == MDUserParameterWrapMode_Wrap)
	{
		innerValue = Wrap(innerValue, self.limit.lower, self.limit.upper);
		_innerValue = innerValue;
	}
	else if(self.wrapMode == MDUserParameterWrapMode_Clamp)
	{
		if(innerValue < self.limit.lower) innerValue = self.limit.lower;
		if(innerValue > self.limit.upper) innerValue = self.limit.upper;
		_innerValue = innerValue;
	}
}

- (int8_t)innerValue
{
	return _innerValue;
}

- (int8_t)mutableValue
{
	return _mutableValue;
}


@end
