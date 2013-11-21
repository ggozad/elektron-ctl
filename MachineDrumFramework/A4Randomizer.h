//
//  A4Randomizer.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 9/16/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A4Sound.h"

@class A4RandomizerPreset;

typedef enum A4RandomizerMode
{
	A4RandomizerModeUniform,
	A4RandomizerModeGauss,
}
A4RandomizerMode;

@interface A4Randomizer : NSObject

+ (NSArray *)soundsWithRange:(NSRange)range processedFromSoundPool:(NSArray *)pool usingPreset:(A4RandomizerPreset *)preset;
+ (A4PVal)randomizedValueForValue:(A4PVal)value min:(NSInteger)min max:(NSInteger)max deviation:(double)deviation mode:(A4RandomizerMode)mode;

@end
