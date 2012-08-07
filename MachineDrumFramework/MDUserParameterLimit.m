//
//  MDUserParameterLimit.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 8/5/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDUserParameterLimit.h"


@interface MDUserParameterLimit()
{
	int8_t _lower, _upper;
	int8_t _hardLower, _hardUpper;
}
@end

@implementation MDUserParameterLimit



- (void)setLower:(int8_t)lower
{
	if(lower < _hardLower)
		lower = _hardLower;
	if (lower > _hardUpper)
		lower = _hardUpper;
	
	if(lower > self.upper)
		_upper = lower;
	_lower = lower;
}

- (void)setUpper:(int8_t)upper
{
	if(upper > _hardUpper)
		upper = _hardUpper;
	if(upper < _hardLower)
		upper = _hardLower;
	
	if(upper < self.lower)
		_lower = upper;
	_upper = upper;
}

- (int8_t)lower
{
	return _lower;
}

- (int8_t)upper
{
	return _upper;
}

+ (id) parameterLimitWithhardLowerBound:(int8_t)lower hardUpperBound:(int8_t)upper;
{
	MDUserParameterLimit *l = [self new];
	
	if (lower > upper)
		upper = lower;
	
	if(upper < lower)
		lower = upper;
	
	l->_hardLower = lower;
	l->_hardUpper = upper;
	
	l.lower = lower;
	l.upper = upper;
	
	return l;
}

- (void)setLowerBound:(int8_t)lower upperBound:(int8_t)upper
{
	self.lower = lower;
	self.upper = upper;
}

@end
