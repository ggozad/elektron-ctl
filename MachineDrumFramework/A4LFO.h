//
//  A4LFO.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 21/11/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A4Params.h"


typedef enum A4LFOWaveshape
{
	A4LFOWaveshapeTri,
	A4LFOWaveshapeSin,
	A4LFOWaveshapeSqu,
	A4LFOWaveshapeSaw,
	A4LFOWaveshapeExp,
	A4LFOWaveshapeRmp,
	A4LFOWaveshapeRnd
}
A4LFOWaveshape;

typedef enum A4LFOMultiplier
{
	A4LFOMultiplier1x,
	A4LFOMultiplier2x,
	A4LFOMultiplier4x,
	A4LFOMultiplier8x,
	A4LFOMultiplier16x,
	A4LFOMultiplier32x,
	A4LFOMultiplier64x,
	A4LFOMultiplier128,
	A4LFOMultiplier256x,
	A4LFOMultiplier512x,
	A4LFOMultiplier1024x,
	A4LFOMultiplier2048x,
	A4LFOMultiplierCount
}
A4LFOMultiplier;

typedef enum A4LFOMode
{
	A4LFOModeFree,
	A4LFOModeTrig,
	A4LFOModeHold,
	A4LFOModeOne,
	A4LFOModeHalf,
	A4LFOModeCount
}
A4LFOMode;

@interface A4LFO : NSObject
@property (nonatomic) A4LFOMode mode;
@property (nonatomic) uint8_t speed;
@property (nonatomic) A4LFOMultiplier multiplier;
@property (nonatomic) A4TrackerParam_t startPhase;
@property (nonatomic) NSInteger clockInterpolationFactor;
@property (nonatomic) A4LFOWaveshape shape;
@property (nonatomic, readonly) A4TrackerParam_t lfoValue;
@property (nonatomic) A4TrackerParam_t phase;
- (void)tickWithTime:(double)time trig:(BOOL)trig;
- (void) restart;
@end
