//
//  A4Randomizer.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 9/16/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4Randomizer.h"
#import "MDMath.h"
#import "A4RandomizerPreset.h"

@implementation A4Randomizer

static inline void nextIdx(UInt32 *currentIdx, UInt32 threshold, UInt32 idxMax)
{
	if(arc4random_uniform(UINT32_MAX) > threshold) *currentIdx = arc4random_uniform(idxMax);
}

+ (NSArray *)soundsWithRange:(NSRange)range processedFromSoundPool:(NSArray *)pool usingPreset:(A4RandomizerPreset *)preset
{
	NSMutableArray *outArray = @[].mutableCopy;
	NSArray *inArray = pool.copy;
	
	UInt32 paramThreshold = mdmath_map(preset.geneMixGranularity, 1, 0, 0, UINT32_MAX);
	A4RandomizerMode randMode = preset.randomizerMode;
	double deviation = preset.deviation;
	
	UInt32 idx = arc4random_uniform(inArray.count);
	nextIdx(&idx, paramThreshold, inArray.count);
	
	A4Sound *sound = [A4Sound messageWithSysexData:[(A4Sound *)inArray[0] sysexData]];
	
	for (NSUInteger slot = range.location; slot < range.location + range.length; slot++)
	{
		char *name = sound.payload + 0xC;
		for (NSUInteger character = 0 ; character < 16; character ++)
		{
			nextIdx(&idx, paramThreshold, inArray.count);
			A4Sound *s = inArray[idx];
			char *nameBuf = s.payload + 0xC;
			name[character] = nameBuf[character];
		}
		
		for (uint8_t paramIdx = 0; paramIdx < A4ParamLockableCount; paramIdx++)
		{
			A4Param param = A4ParamLockableByIndex(paramIdx);
			nextIdx(&idx, paramThreshold, inArray.count);
			A4Sound *s = inArray[idx];
			[sound setParamValue:[self randomizedValueForValue:[s valueForParam:param]
														   min:A4ParamMin(param)
														   max:A4ParamMax(param)
													 deviation:deviation
														  mode:randMode]];
		}
		
	
		/*
		for (A4SoundModulatorType modulatorType = A4SoundModulatorTypeVelocity; modulatorType < 5; modulatorType++)
		{
			for (int i = 0; i < 5; i++)
			{
				nextIdx(&idx, paramThreshold, inArray.count);
				A4Sound *s = inArray[idx];
				
				A4SoundModulatorTarget target = [s modulatorTargetForType:modulatorType index:i];
				[sound setModulator:modulatorType index:i target:target];
				
				int8_t depth = [s modulatorDepthForType:modulatorType index:i];
				[sound setModulator:modulatorType index:i depth:depth];
			}
		}
		 */
		 
		
		nextIdx(&idx, paramThreshold, inArray.count);
		sound.settings->legatoMode = [(A4Sound *)inArray[idx] settings]->legatoMode;
		nextIdx(&idx, paramThreshold, inArray.count);
		sound.settings->portamento = [(A4Sound *)inArray[idx] settings]->portamento;
		nextIdx(&idx, paramThreshold, inArray.count);
		sound.settings->oscillatorDrift = [(A4Sound *)inArray[idx] settings]->oscillatorDrift;
		nextIdx(&idx, paramThreshold, inArray.count);
		sound.settings->velocityMode = [(A4Sound *)inArray[idx] settings]->velocityMode;
		
		sound.position = slot;
		sound.tags = 0;
		
		[outArray addObject:[A4Sound messageWithSysexData:sound.sysexData]];
	}
	
	return outArray;
}


+ (A4PVal)randomizedValueForValue:(A4PVal)value min:(NSInteger)min max:(NSInteger)max deviation:(double)deviation mode:(A4RandomizerMode)mode
{
	switch (mode)
	{
		case A4RandomizerModeGauss:
		{
			double gauss = mdmath_gaussRand();
			gauss *= deviation;
			gauss += A4PValDoubleVal(value);
			value  = A4PValMake(value.param, gauss);
			return value;
			break;
		}
		case A4RandomizerModeUniform:
		{
			if(min > max)
			{
				NSInteger t =  min; min = max; max = t;
			}

			
			return value;
			break;
		}
		default:
			return value;
			break;
	}
}
 

@end
