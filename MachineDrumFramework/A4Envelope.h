//
//  A4Envelope.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 14/11/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A4Params.h"
//#pragma once

A4TrackerParam_t ADRParamNormalizedToSeconds(A4TrackerParam_t normalizedParamValue); // convert normalised ADR param to seconds
A4TrackerParam_t secondsToNormalizedADRParam(A4TrackerParam_t seconds); // convert seconds to normalized ADR param
A4TrackerParam_t envExpToLin(A4TrackerParam_t normalizedParamValue); // convert envelope value from EXP to LIN
A4TrackerParam_t envLinToExp(A4TrackerParam_t normalizedParamValue); // convert envelope value from LIN to EXP

typedef enum A4EnvelopeShape
{
	A4EnvelopeShapeLinLin,
	A4EnvelopeShapeLinLinReset,
	A4EnvelopeShapeLinExp,
	A4EnvelopeShapeLinExpReset,
	A4EnvelopeShapeExpLin,
	A4EnvelopeShapeExpLinReset,
	A4EnvelopeShapeExpExp,
	A4EnvelopeShapeExpExpReset,
	A4EnvelopeShapePrcLin,
	A4EnvelopeShapePrcLinReset,
	A4EnvelopeShapePrcExp,
	A4EnvelopeShapePrcExpReset,
}
A4EnvelopeShape;

@interface A4Envelope : NSObject
@property (nonatomic, readonly) A4TrackerParam_t normalizedValue;
@property (nonatomic) A4EnvelopeShape shape;
@property (nonatomic) uint8_t attackVal;
@property (nonatomic) uint8_t decayVal;
@property (nonatomic) uint8_t sustainVal;
@property (nonatomic) uint8_t releaseVal;
@property (nonatomic, readonly) BOOL isOpen;
- (void) openWithTime:(A4TrackerParam_t)time;
- (void) closeWithTime:(A4TrackerParam_t)time;
- (void) updateWithTime:(A4TrackerParam_t)time;
- (void) reset;
@end
