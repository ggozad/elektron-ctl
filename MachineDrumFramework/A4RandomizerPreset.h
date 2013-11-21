//
//  A4RandomizerPreset.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 9/17/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A4Randomizer.h"

@interface A4RandomizerPreset : NSObject
@property double geneMixGranularity;
@property A4RandomizerMode randomizerMode;
@property double deviation;
@end
