//
//  A4APIStringNumericIterator.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 07/03/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import "A4APIStringNumericIterator.h"
#import "MDMath.h"

#define kIncreaseMax 32
#define kStartStopDelim @"^"
#define kIncrementDelim @"'"

typedef enum IterationMode
{
	IterationModeIncrement,
	IterationModeSteps
}
IterationMode;

A4ApiIteratorRange A4ApiIteratorRangeMake(double min, double max)
{
	A4ApiIteratorRange range;
	range.min = MIN(min, max);
	range.max = MAX(min, max);
	return range;
}

@interface A4APIStringNumericIterator ()
@property (nonatomic) BOOL tokenIsValid, rangeIsValid, noIteration, hasBeenReadOnce;
@property (nonatomic) double start, stop, current;
@property (nonatomic) double *increase, *steps;
@property (nonatomic) NSUInteger increaseLen, stepsLen;
@property (nonatomic) NSUInteger increaseIdx, stepsIdx;
@property (nonatomic) IterationMode iterationMode;
@property (nonatomic) A4ApiIteratorRange range;
@property (nonatomic) A4ApiIteratorRangeMode mode;
@property (nonatomic) A4ApiIteratorInputVal inValType;
@property (nonatomic) A4ApiIteratorReturnVal retValType;
@end;

@implementation A4APIStringNumericIterator


- (id)init
{
	if(self = [super init])
	{
		_increase = malloc(sizeof(double) * kIncreaseMax);
		_steps = malloc(sizeof(double) * kIncreaseMax);
	}
	return self;
}

- (void)dealloc
{
	free(_increase);
	free(_steps);
}

+ (instancetype) iteratorWithStringToken:(NSString *)token
								   range:(A4ApiIteratorRange)range
									mode:(A4ApiIteratorRangeMode)mode
								   inVal:(A4ApiIteratorInputVal)inVal
								  retVal:(A4ApiIteratorReturnVal)retVal
{
	A4APIStringNumericIterator *instance = [self new];
	instance.mode = mode;
	instance.range = range;
	instance.tokenIsValid = YES;
	instance.inValType = inVal;
	instance.retValType = retVal;
	
	token = [token stringByTrimmingCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789.^'-"] invertedSet]];
	NSArray *elements = [token componentsSeparatedByString:kStartStopDelim];
	
	if(elements.count < 1 || elements.count > 2)
	{
		instance.tokenIsValid = NO;
		return instance;
	}
	
	NSString *head = elements[0];
	
	if([head rangeOfString:kIncrementDelim].location != NSNotFound && elements.count > 1)
	{
		instance.tokenIsValid = NO;
		return instance;
	}
	
	if([head rangeOfString:kIncrementDelim].location != NSNotFound)
	{
		DLog(@"head: %@", head);
		instance.iterationMode = IterationModeSteps;
		NSArray *steps = [head componentsSeparatedByString:kIncrementDelim];
		NSMutableArray *strippedSteps = [NSMutableArray array];
		for(NSString *step in steps)
		{
			if(!step.length || ![self isFloat:step])
			{
				instance.tokenIsValid = NO;
				return instance;
			}
			
			[strippedSteps addObject:step];
		}
		
		instance.start = 66666666666;
		instance.stop = -66666666666;
		instance.rangeIsValid = YES;
		
		for(NSString *step in strippedSteps)
		{
			double doubVal = [step doubleValue];
			if(doubVal < instance.range.min || doubVal > instance.range.max)
			{
				instance.tokenIsValid = NO;
				return instance;
			}
			
			instance.start = MIN(doubVal, instance.start);
			instance.stop = MAX(doubVal, instance.stop);
			
			if(instance.start < instance.range.min || instance.start > instance.range.max ||
			   instance.stop < instance.range.min || instance.stop > instance.range.max)
			{
				instance.tokenIsValid = NO;
				return instance;
			}
			
			instance.steps[instance.stepsLen] = doubVal;
			instance.stepsLen++;
		}
		
		instance.current = instance.steps[0];
		return instance;
	}
	
	NSArray *tail = nil;
	
	if(elements.count == 2)
	{
		tail = [elements[1] componentsSeparatedByString:kIncrementDelim];
		for(NSString *tailElement in tail)
		{
			if(![self isFloat:tailElement])
			{
				instance.tokenIsValid = NO;
				return instance;
			}
		}
	}
	
	DLog(@"head: %@\ntail: %@", head, tail);
	
	if(elements.count == 1 && [self isFloat:elements[0]])
	{
		double doubVal = [elements[0] doubleValue];
		if(instance.inValType == A4ApiIteratorInputValInt) doubVal = round(doubVal);
		instance.start = instance.stop = instance.current = doubVal;
		instance.increase[0] = 0;
		instance.increaseLen = 1;
		instance.noIteration = YES;
		[instance checkRange];
		return instance;
	}
	else if (tail)
	{
		if(tail.count >= 1)
		{
			instance.start = [elements[0] doubleValue];
			instance.stop = [tail[0] doubleValue];
			
			if(instance.inValType == A4ApiIteratorInputValInt)
			{
				instance.start = round(instance.start);
				instance.stop = round(instance.stop);
			}
			
			int dir = 1;
			if(instance.start > instance.stop) dir = -1;
			
			if(tail.count == 1)
			{
				if(instance.stop > instance.start) instance.increase[0] = 1;
				else if(instance.stop < instance.start) instance.increase[0] = -1;
				else {instance.increase[0] = 0; /*instance.noIteration = YES;*/}
				instance.increaseLen = 1;
				instance.increaseIdx = 0;
			}
			else
			{
				
				instance.increaseLen = 0;
				if(tail.count >= kIncreaseMax)
				{
					instance.tokenIsValid = NO;
					return instance;
				}
				
				for(NSUInteger i = 1; i < tail.count; i++)
				{
					double doubVal = fabs([tail[i] doubleValue]) * dir;
					if(instance.inValType == A4ApiIteratorInputValInt)
					{
						doubVal = round(doubVal);
					}
					
					if(doubVal == 0)
					{
						instance.tokenIsValid = NO;
						return instance;
					}
					double numIterations = (MAX(instance.start, instance.stop) - MIN(instance.start, instance.stop)) / doubVal;
					if(fabs(numIterations) > 128)
					{
						instance.tokenIsValid = NO;
						return instance;
					}
					
					instance.increase[instance.increaseLen++] = doubVal;
				}
				
				instance.increaseIdx = 0;
			}
			
			
			instance.current = instance.start;
			[instance checkRange];
			return instance;
		}
	}
	
	
	else
	{
		instance.tokenIsValid = NO;
	}
	return instance;
}


- (void)checkRange
{
	_rangeIsValid = YES;
	
	if(_mode == A4ApiIteratorRangeModeBreak)
	{
		if((_retValType == A4ApiIteratorReturnValFloat &&
			( _current< _range.min || _current > _range.max || _current < MIN(_start, _stop) || _current > MAX(_start, _stop) )) ||
		   (_retValType == A4ApiIteratorReturnValInt &&
			( round(_current) < round(_range.min) || round(_current) > round(_range.max) ||
			 round(_current) < round(MIN(_start, _stop)) || round(_current) > round(MAX(_start, _stop)))) )
			_rangeIsValid = NO;
		
		if((_retValType == A4ApiIteratorReturnValFloat &&
			( _start < _range.min || _start > _range.max || _start < MIN(_start, _stop) || _start > MAX(_start, _stop) )) ||
		   (_retValType == A4ApiIteratorReturnValInt &&
			( round(_start) < round(_range.min) || round(_start) > round(_range.max) ||
			 round(_start) < round(MIN(_start, _stop)) || round(_start) > round(MAX(_start, _stop)))) )
			_rangeIsValid = NO;
		
		if((_retValType == A4ApiIteratorReturnValFloat &&
			( _stop < _range.min || _stop > _range.max || _stop < MIN(_start, _stop) || _stop > MAX(_start, _stop) )) ||
		   (_retValType == A4ApiIteratorReturnValInt &&
			( round(_stop) < round(_range.min) || round(_stop) > round(_range.max) ||
			 round(_stop) < round(MIN(_start, _stop)) || round(_stop) > round(MAX(_start, _stop)))) )
			_rangeIsValid = NO;
	}
}

- (BOOL)isValid
{
	if(!_tokenIsValid || !_rangeIsValid || (_mode == A4ApiIteratorRangeModeBreak && _noIteration && _hasBeenReadOnce)) return NO;
	return YES;
}

+ (BOOL) isFloat:(NSString *)str
{
	NSScanner *scnr = [NSScanner scannerWithString:str];
	return [scnr scanDouble:nil];
}

- (void)increment
{
	if(!_rangeIsValid) return;
	
	if(_iterationMode == IterationModeIncrement)
	{
		_current += _increase[_increaseIdx];
		if(_increaseLen)
		{
			_increaseIdx = (_increaseIdx + 1) % _increaseLen;
		}
		[self checkRange];
	}
	else
	{
		if(_stepsLen)
		{
			if(_mode == A4ApiIteratorRangeModeWrap)
			{
				_stepsIdx = (_stepsIdx + 1) % _stepsLen;
				
			}
			else if(_mode == A4ApiIteratorRangeModeBreak)
			{
				_stepsIdx++;
				if(_stepsIdx >= _stepsLen)
				{
					_stepsIdx = 0;
					_rangeIsValid = NO;
				}
			}
			else if(_mode == A4ApiIteratorRangeModeClamp)
			{
				_stepsIdx++;
				if(_stepsIdx >= _stepsLen)
				{
					_stepsIdx = _stepsLen-1;
				}
			}
			_current = _steps[_stepsIdx];
		}
		
	}
}

- (double)currentValue
{
	_hasBeenReadOnce = YES;
	
	if(_iterationMode == IterationModeIncrement)
	{
		if (_mode == A4ApiIteratorRangeModeClamp)
		{
			double val = _retValType == A4ApiIteratorReturnValFloat ? _current : round(_current);
			if(_retValType == A4ApiIteratorReturnValFloat)
			{
				val = mdmath_clamp(val, _range.min, _range.max);
			}
			else
			{
				val = mdmath_clamp(val, round(_range.min), round(_range.max));
			}
			return val;
		}
		else if (_mode == A4ApiIteratorRangeModeWrap)
		{
			double val = _retValType == A4ApiIteratorReturnValFloat ? _current : round(_current);
			if(_retValType == A4ApiIteratorReturnValFloat)
			{
				if(_range.max != _range.min)
				{
					while(val > _range.max) val -= (_range.max - _range.min) + 1;
					while(val < _range.min) val += (_range.max - _range.min) + 1;
				}
			}
			else
			{
				if(_range.max != _range.min)
				{
					while(round(_stop) > round(_range.max)) val -= (_range.max - _range.min) + 1;
					while(round(val) < round(_range.min)) val += (_range.max - _range.min) + 1;
				}
			}
			return val;
		}
		
		return _retValType == A4ApiIteratorReturnValFloat ? _current : round(_current);
	}
	else
	{
		return _retValType == A4ApiIteratorReturnValFloat ? _current : round(_current);
	}
}

@end
