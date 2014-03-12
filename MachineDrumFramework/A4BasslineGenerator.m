//
//  A4BasslineGenerator.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 22/02/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import "A4BasslineGenerator.h"
#import "MDMath.h"

typedef struct Phrase
{
	uint8_t stepIntervals[64];
	uint8_t stepIntervalsLen;
	uint8_t notes[64];
	uint8_t notesLen;
	uint8_t noteLengths[64];
	uint8_t noteLengthsLen;
	uint8_t noteVelocities[64];
	uint8_t noteVelocitiesLen;
	 int8_t octaveOffsets[64];
	uint8_t octaveOffsetsLen;
	
	uint8_t baseOctave;
	uint8_t root;
	uint8_t phraseLength;
	uint8_t idx, stepOffset;
}
Phrase;

typedef struct PhraseTrig
{
	A4Trig trig;
	uint8_t stepOffset;
}
PhraseTrig;

PhraseTrig trigForPhraseIdx(Phrase *p, uint8_t idx)
{
	PhraseTrig trig;
	trig.trig = A4TrigMakeDefault();
	trig.trig.notes[0] =
	mdmath_clamp(p->baseOctave * 12 + p->root + 12 * p->octaveOffsets[idx % p->octaveOffsetsLen] + p->notes[idx % p->notesLen], 0, 127);
	trig.trig.length = p->noteLengths[idx % p->noteLengthsLen];
	trig.trig.velocity = p->noteVelocities[idx % p->noteVelocitiesLen];
	p->stepOffset = trig.stepOffset = p->stepOffset + p->stepIntervals[idx % p->stepIntervalsLen];
	return trig;
}

@interface A4BasslineGenerator()
@property (nonatomic) Phrase *phrases;
@property (nonatomic) uint8_t phraseCount;
@end

@implementation A4BasslineGenerator


- (id)init
{
	if(self = [super init])
	{
		self.project = [A4Project defaultProject];
		self.project.autoReceiveEnabled = NO;
		self.phrases = malloc(sizeof(Phrase) * 16);
	}
	return self;
}

- (void)dealloc
{
	free(self.phrases);
}

- (Phrase) genPhrase
{
	Phrase p;
	p.root = _currentPreset.scale.rootNote;
	p.baseOctave = _currentPreset.scale.octave;
	p.idx = 0;
	p.phraseLength = _currentPreset.phraseLength * 64;
	
	p.stepIntervalsLen = mdmath_map(_currentPreset.rhythmAmount, 0, 1, 1, 8);
	
	for (int i = 0; i < p.stepIntervalsLen; i++)
	{
		p.stepIntervals[i] = mdmath_randi(1, 1 + (1-_currentPreset.density) * 7);
	}
	p.stepIntervals[0] = 0;
	
	uint8_t possibleNoteLengths[] = {0, 8, 16, 32, 64};
	p.noteLengthsLen = mdmath_randi(1, 4);
	for (int i = 0; i < p.noteLengthsLen; i++)
	{
		p.noteLengths[i] = possibleNoteLengths[mdmath_randi(0, 4)];
	}
	
	uint8_t possibleVelocities[] = {127, 100, 80, 60};
	p.noteVelocitiesLen = 1 + mdmath_map(_currentPreset.dynamics, 0, 1, 0, 6);
	
	for (int i = 0; i < p.noteVelocitiesLen; i++)
	{
		p.noteVelocities[i] = possibleVelocities[mdmath_randi(0, 3)];
	}
	
	p.notesLen = mdmath_map(_currentPreset.notesAmount, 0, 1, 1, p.phraseLength);
	int n = mdmath_randi(0, 11);
	for (int i = 0; i < p.notesLen; i++)
	{
		while (mdmath_rand(0, 1) > _currentPreset.scale.noteProbability[n])
		{
			int incr = mdmath_randi(-1, 1);
			n+=incr;
			n = mdmath_wrap(n, 0, 11);
		}
		
		p.notes[i] = n;
	}
	p.octaveOffsetsLen = mdmath_map(_currentPreset.phraseLength, 0, 1, 1, p.phraseLength);
	for(int i = 0; i < p.octaveOffsetsLen; i++)
	{
		p.octaveOffsets[i] = mdmath_clamp(mdmath_gaussRandf() * 2 * _currentPreset.octaveJumps, -2, 2);
	}
	
	p.stepOffset = 0;
	
	return p;
}

- (void)generateBasslineInPattern:(A4Pattern *)pattern track:(uint8_t)trkIdx
{
	if(!pattern || trkIdx > 5) return;
	
	
	int trackLen = pattern.masterLength;
	
	A4PatternTrack *track = [pattern track:trkIdx];
	A4Kit *kit = [self.project kitAtPosition:pattern.kit];
	
	if (pattern.timeMode == A4PatternTimeModeAdvanced)
	{
		trackLen = track.settings->trackLength;
	}
	
	for(int stepIdx = 0; stepIdx < 64; stepIdx ++)
	{
		A4Trig t = [pattern trigAtStep:stepIdx inTrack:trkIdx];
		if(t.flags & A4TRIGFLAGS.TRIG || t.flags & A4TRIGFLAGS.TRIGLESS)
		{
			if(t.soundLock != A4NULL && ! _currentPreset.keepSoundLocks)
			{
				continue;
			}
			
			[pattern clearTrigAtStep:stepIdx inTrack:trkIdx];
		}
	}
	
	uint8_t kicks[64] = {};
	int numKicks = 0;
	BOOL kicksInTrackSounds[4] = {};
	for(int i = 0; i < 4; i++)
	{
		A4Sound *sound = [kit soundAtTrack:i copy:NO];
		kicksInTrackSounds[i] = [sound tagMatchesAnyTag:A4SoundTagKick];
	}
	
	for (int stepIdx = 0; stepIdx < trackLen; stepIdx++)
	{
		BOOL hasKickAtThisStep = NO;
		for (int trk = 0; trk < 4; trk++)
		{
			if(hasKickAtThisStep) continue;
			
			A4Trig t = [pattern trigAtStep:stepIdx inTrack:trk];
			if(t.flags & A4TRIGFLAGS.TRIG)
			{
				if(t.soundLock != A4NULL)
				{
					A4Sound *sound = [self.project soundAtPosition:t.soundLock];
					if ([sound tagMatchesAnyTag:A4SoundTagKick])
					{
						hasKickAtThisStep = YES;
						kicks[numKicks++] = stepIdx;
					}
				}
				else if(kicksInTrackSounds[trk])
				{
					hasKickAtThisStep = YES;
					kicks[numKicks++] = stepIdx;
				}
			}
		}
	}
	
	if(numKicks)
	{
		self.phraseCount = mdmath_map(_currentPreset.phraseCount, 0, 1, 1, 16);
		for(int i = 0; i < self.phraseCount; i++)
		{
			self.phrases[i] = [self genPhrase];
		}
		

		uint8_t currentStepIdx = 0;
		int currentPhraseIdx = 0;
		int phraseInternalIdx = 0;
		
		
		for (int kickIdx = 0; kickIdx < numKicks; kickIdx++)
		{
			int phraseIdx = mdmath_randi(0, _phraseCount-1);
			if(mdmath_rand(0, 1) > .5) phraseInternalIdx = 0;
			
			int stop;
			if (kickIdx > numKicks-2) stop = trackLen;
			else stop = kicks[kickIdx+1];
			
			currentStepIdx = kicks[kickIdx];
			currentPhraseIdx = 0;

			_phrases[phraseIdx].stepOffset = 0;
			PhraseTrig phraseTrig;
			phraseTrig.stepOffset = 0;
			
			while(currentStepIdx + phraseTrig.stepOffset < stop)
			{
				phraseTrig = trigForPhraseIdx(&_phrases[phraseIdx], phraseInternalIdx++);
				A4Trig trig = phraseTrig.trig;
				if(mdmath_rand(0, 1) > .7) trig.flags |= A4TRIGFLAGS.ACCENT;
				if(mdmath_rand(0, 1) > .7) trig.flags |= A4TRIGFLAGS.NOTESLIDE;
				
				[pattern setTrig:trig atStep:currentStepIdx + phraseTrig.stepOffset inTrack:trkIdx];
			}
		}
	}
}

@end
