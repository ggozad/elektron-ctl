//
//  A4APIStringNumericIterator.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 07/03/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum A4ApiIteratorRangeMode
{
	A4ApiIteratorRangeModeBreak,
	A4ApiIteratorRangeModeClamp,
	A4ApiIteratorRangeModeWrap,
}
A4ApiIteratorRangeMode;

typedef struct A4ApiIteratorRange
{
	double min;
	double max;
}
A4ApiIteratorRange;

A4ApiIteratorRange A4ApiIteratorRangeMake(double min, double max);

typedef enum A4ApiIteratorReturnVal
{
	A4ApiIteratorReturnValInt,
	A4ApiIteratorReturnValFloat
}
A4ApiIteratorReturnVal;

typedef enum A4ApiIteratorInputVal
{
	A4ApiIteratorInputValInt,
	A4ApiIteratorInputValFloat
}
A4ApiIteratorInputVal;

@interface A4APIStringNumericIterator : NSObject
@property (nonatomic, readonly) BOOL isValid;
+ (instancetype) iteratorWithStringToken:(NSString *)token
								   range:(A4ApiIteratorRange)range
									mode:(A4ApiIteratorRangeMode)mode
								   inVal:(A4ApiIteratorInputVal) inVal
								  retVal:(A4ApiIteratorReturnVal) retVal;
- (double) currentValue;
- (void) increment;
@end
