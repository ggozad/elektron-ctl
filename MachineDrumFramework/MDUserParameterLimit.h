//
//  MDUserParameterLimit.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 8/5/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDUserParameterLimit : NSObject
@property int8_t lower, upper;
@property (readonly) int8_t hardLower, hardUpper;

+ (id) parameterLimitWithhardLowerBound:(int8_t)lower hardUpperBound:(int8_t)upper;
- (void) setLowerBound:(int8_t)lower upperBound:(int8_t)upper;

@end
