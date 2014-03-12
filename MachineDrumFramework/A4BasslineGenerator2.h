//
//  A4BasslineGenerator2.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 01/03/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A4Pattern.h"

@interface A4BasslineGenerator2 : NSObject

@property (nonatomic) float rhythmVariation;
@property (nonatomic) float maxPhrases;
@property (nonatomic) uint8_t offset;
@property (nonatomic) uint8_t phraseLength;
@property (nonatomic) float density;
@property (nonatomic) A4KeyScale scale;

@property (nonatomic) float octaveJump;
@property (nonatomic) float noteProgress;
@property (nonatomic) float noteLengthVariations;
@property (nonatomic) float velocityVariations;
@property (nonatomic) float slides;
@property (nonatomic) float accents;

- (void) generateBasslineInPattern:(A4Pattern *)pattern track:(uint8_t)trackIdx;

@end
