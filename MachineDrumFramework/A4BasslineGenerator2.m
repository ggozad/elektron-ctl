//
//  A4BasslineGenerator2.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 01/03/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import "A4BasslineGenerator2.h"
#import "MDMath.h"

typedef struct PhraseTrig
{
	A4Trig trig;
	BOOL active;
}
PhraseTrig;

typedef struct Phrase
{
	PhraseTrig trigs[64];
	uint8_t length;
	uint8_t offset;
}
Phrase;

@interface A4BasslineGenerator2()
@property (nonatomic, strong) A4Pattern *pattern;
@property (nonatomic) uint8_t trackIdx;
@end


@implementation A4BasslineGenerator2

- (Phrase) genPhrase
{
	Phrase phrase;
	phrase.length = _phraseLength;
	phrase.offset = 0;
	A4PatternTrack *track = [_pattern track:_trackIdx];
	A4Trig trig = A4TrigMakeDefault();
	trig.notes[0] = track.settings->trigNote;
	trig.velocity = track.settings->trigVelocity;
	trig.length = track.settings->trigLength;
	
	if(_density == 0)_density = .01;
	float div = 1/_density;
	
	for (int i = 0; i < phrase.length; i++)
	{
		phrase.trigs[i].trig = trig;
		phrase.trigs[i].active = NO;
	}
	
	float current = 0;
	for (int i = 0; i < phrase.length; )
	{
		phrase.trigs[i].active = YES;
		current+=div;
		current += mdmath_gaussRandf() * _rhythmVariation;
		i = round(current);
		if(i >= phrase.length) break;
		if(i <= 0) break;
	}
	
	phrase.trigs[0].active = YES;
	
	int numActiveSteps = 0;
	for(int i = 0; i < phrase.length; i++)
	{
		if(phrase.trigs[i].active) numActiveSteps++;
	}
	
	
	static float majorScale[] = {.5, .0, .4, .0, .5, .5, .0, .5, .0, .5, .0, .3};
	static float minorScale[] = {.5, .0, .4, .5, .0, .4, .0, .5, .0, .4, .3, .0};
	float *scale = minorScale;
	if(_scale == A4KeyScaleMaj) scale = majorScale;
	
	int n = mdmath_randi(0, 11);
	float noteRandMax = mdmath_map(_noteProgress, 0, 1, .5, 1);
	int root = 0;
	while (mdmath_rand(.1, noteRandMax) > scale[root])
	{
		root = mdmath_randi(0, 11);
	}
	
	for (int i = 0; i < phrase.length; i++)
	{

		if(phrase.trigs[i].active)
		{
			if(mdmath_rand(0, 1) > .7)
			{
				n = root;
			}
			else
			{
				while (mdmath_rand(.1, noteRandMax) > scale[n])
				{
					int incr = mdmath_gaussRandf() * 4;
					n+=incr;
					n = mdmath_wrap(n, 0, 11);
				}
			}
			
			phrase.trigs[i].trig.notes[0] += n;
			int octaveOffset = mdmath_clamp(mdmath_gaussRandf() * 2 * _octaveJump, -2, 2);
			octaveOffset *= 12;
			phrase.trigs[i].trig.notes[0] = mdmath_clamp(phrase.trigs[i].trig.notes[0] + octaveOffset, 0, 127);
			
			if(mdmath_rand(0, 1) < _accents)
				phrase.trigs[i].trig.flags |= A4TRIGFLAGS.ACCENT;
			
			if(mdmath_rand(0, 1) < _slides)
				phrase.trigs[i].trig.flags |= A4TRIGFLAGS.NOTESLIDE;
			
			if(mdmath_rand(0, 1) < _noteLengthVariations)
				phrase.trigs[i].trig.length = mdmath_clamp(phrase.trigs[i].trig.length + mdmath_gaussRandf() * 16, 0, 127);
			
			if(mdmath_rand(0, 1) < _velocityVariations)
				phrase.trigs[i].trig.velocity = mdmath_clamp(phrase.trigs[i].trig.velocity + mdmath_gaussRandf() * 16, 0, 127);
			
		}
	}
	
	return phrase;
}

- (void)generateBasslineInPattern:(A4Pattern *)pattern track:(uint8_t)trackIdx
{
	if(trackIdx > 5) return;
	self.pattern = pattern;
	self.trackIdx = trackIdx;
	
	[pattern clearTrack:trackIdx];
	A4PatternTrack *track = [pattern track:trackIdx];
	
	int numPhrases = mdmath_map(_maxPhrases, 0, 1, 1, 8);
	Phrase phrases[numPhrases];
	
	for (int i = 0; i < numPhrases; i++)
	{
		phrases[i] = [self genPhrase];
	}
	
	Phrase phrase = phrases[0];
	
	int trackLen = pattern.masterLength;
	if(pattern.timeMode == A4PatternTimeModeAdvanced) trackLen = track.settings->trackLength;
	
	uint8_t currentStep = phrase.offset, startStep = phrase.offset;
	uint8_t currentPhrase = 0;
	
	while (1)
	{
		if(currentStep >= trackLen-1) break;
		
		phrase = phrases[currentPhrase++ % numPhrases];
		
		for(int phraseIdx = 0; phraseIdx < phrase.length; phraseIdx++)
		{
			if(phrase.trigs[phraseIdx].active)
			{
				int i = phraseIdx;
				if(mdmath_rand(0, 1) < _accents)
					phrase.trigs[i].trig.flags |= A4TRIGFLAGS.ACCENT;
				
				if(mdmath_rand(0, 1) < _slides)
					phrase.trigs[i].trig.flags |= A4TRIGFLAGS.NOTESLIDE;
				
				if(mdmath_rand(0, 1) < _noteLengthVariations)
					phrase.trigs[i].trig.length = mdmath_clamp(phrase.trigs[i].trig.length + mdmath_gaussRandf() * 16, 0, 127);
				
				if(mdmath_rand(0, 1) < _velocityVariations)
					phrase.trigs[i].trig.velocity = mdmath_clamp(phrase.trigs[i].trig.velocity + mdmath_gaussRandf() * 16, 0, 127);
				
				
				currentStep = startStep + phraseIdx;
				[pattern setTrig:phrase.trigs[phraseIdx].trig atStep:currentStep inTrack:trackIdx];
				if(currentStep >= trackLen-1) break;
			}
		}
		
		startStep+=phrase.length;
	}
}

@end



















