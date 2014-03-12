//
//  A4BasslineGenerator.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 22/02/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A4Pattern.h"
#import "A4PatternTrack.h"
#import "A4Project.h"

typedef struct A4BasslineScale
{
	uint8_t octave;
	A4NoteValue rootNote;
	float noteProbability[12];
}
A4BasslineScale;

typedef struct A4BasslineGeneratorPreset
{
	A4BasslineScale scale;
	float density;
	float phraseLength;
	float rhythmAmount;
	float notesAmount;
	float dynamics;
	float noteSlides;
	float paramSlides;
	float accents;
	float octaveJumps;
	float phraseCount;
	BOOL keepSoundLocks;
}
A4BasslineGeneratorPreset;

@interface A4BasslineGenerator : NSObject
@property (nonatomic, strong) A4Project *project;
@property (nonatomic) A4BasslineGeneratorPreset currentPreset;
- (void) generateBasslineInPattern:(A4Pattern *)pattern track:(uint8_t)track;
@end
