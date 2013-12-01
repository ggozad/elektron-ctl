//
//  A4VoiceAllocator.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 30/11/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4VoiceAllocator.h"
#import "MDMath.h"

#define kNumAllowedVoices 4

A4TrackVoicePair A4TrackVoicePairMake(uint8_t track, uint8_t voice)
{
	A4TrackVoicePair pair;
	pair.track = track;
	pair.voice = voice;
	return pair;
}

@interface NSValue(A4TrackVoicePair)
+ (instancetype) valueWithTrackVoicePair:(A4TrackVoicePair)trackVoicePair;
- (A4TrackVoicePair) trackVoicePairValue;
@end

@implementation NSValue(TrackVoicePair)
+ (instancetype)valueWithTrackVoicePair:(A4TrackVoicePair)trackVoicePair
{
	return [NSValue valueWithBytes:&trackVoicePair objCType:@encode(A4TrackVoicePair)];
}

- (A4TrackVoicePair)trackVoicePairValue
{
	A4TrackVoicePair pair; [self getValue:&pair]; return pair;
}
@end


@interface A4VoiceAllocator()
@property (nonatomic) NSMutableArray *heldVoices, *discardBin;
@end

@implementation A4VoiceAllocator

- (id)init
{
	if(self = [super init])
	{
		_oldestVoice = A4TrackVoicePairMake(-1, -1);
		_freeVoices = 0x0F;
		_heldVoices = @[].mutableCopy;
		_discardBin = @[].mutableCopy;
	}
	return self;
}

- (void) pushVoice:(A4TrackVoicePair)newPair
{
	[_discardBin removeAllObjects];
	
	for (NSValue *value in _heldVoices)
	{
		A4TrackVoicePair oldPair = value.trackVoicePairValue;
		if(oldPair.voice == newPair.voice)
		{
			[_discardBin addObject:value];
			break;
		}
	}
	
	[_heldVoices removeObjectsInArray:_discardBin];
	[_heldVoices addObject:[NSValue valueWithTrackVoicePair:newPair]];
}

- (A4TrackVoicePair) popOldestVoice
{
	if(!_heldVoices.count) return A4TrackVoicePairMake(-1, -1);
	NSValue *value  = _heldVoices[0];
	A4TrackVoicePair pair = value.trackVoicePairValue;
	[_heldVoices removeObject:value];
	return pair;
}

- (int8_t) nextFreePolyVoiceStartingFrom:(uint8_t)strt
{
	if(strt > 3) return -1;
	for (uint8_t i = strt; i < strt + 4; i++)
	{
		uint8_t wrapped = mdmath_wrap(i, 0, 3);
		if([self isVoicePolyphonic:wrapped] && [self isVoiceFree:wrapped]) return wrapped;
	}
	return -1;
}

- (int8_t) allocateNextVoiceNormalTrigFromTrack:(uint8_t)trackIdx withTrig:(A4Trig)trig
{
	if(![self isVoicePolyphonic:trackIdx]) return trackIdx;
	int8_t voice = -1;
	
	switch (_mode)
	{
		case A4VoiceAllocationModeReset:
		{
			voice = [self nextFreePolyVoiceStartingFrom:trackIdx];
			
			if(voice == -1)
			{
				A4TrackVoicePair pair = [self popOldestVoice];
				if(pair.track != -1 && pair.voice != -1)
				{
					[self.delegate a4VoiceAllocator:self willStealVoice:pair];
					voice = pair.voice;
				}
			}
			
			NSAssert(voice != -1, @"voice shouldn't be -1 here!");
			
			[self setVoice:voice free:NO];
			[self pushVoice:A4TrackVoicePairMake(trackIdx, voice)];
			return voice;
		}
			
		default:
			break;
	}
	
	
	return -1;
}


- (int8_t) allocateNextVoiceTriglessTrigFromTrack:(uint8_t)trackIdx withTrig:(A4Trig)trig
{
	if(![self isVoicePolyphonic:trackIdx]) return trackIdx;
	return -1;
}



- (void)setVoice:(uint8_t)voiceIdx polyphonic:(BOOL)active
{
	if(voiceIdx > kNumAllowedVoices-1) return;
	uint8_t mask = (uint8_t) 1 << voiceIdx;
	if(active) _polyphonicVoices |= mask;
	else _polyphonicVoices &= ~mask;
}

- (BOOL)isVoicePolyphonic:(uint8_t)voiceIdx
{
	if(voiceIdx > kNumAllowedVoices-1) return NO;
	return _polyphonicVoices & 1 << voiceIdx;
}

- (void) setVoice:(uint8_t)voiceIdx free:(BOOL)free
{
	if(voiceIdx > kNumAllowedVoices-1) return;
	uint8_t mask = (uint8_t) 1 << voiceIdx;
	if(free) _freeVoices |= mask;
	else _freeVoices &= ~mask;
}

- (BOOL)isVoiceFree:(uint8_t)voiceIdx
{
	if(voiceIdx > kNumAllowedVoices-1) return NO;
	return _freeVoices & (1<<voiceIdx);
}


- (int8_t)openGateAtTrack:(uint8_t)trackIdx withTrig:(A4Trig)trig
{
	if(trackIdx > kNumAllowedVoices-1) return -1;
	return [self allocateNextVoiceNormalTrigFromTrack:trackIdx withTrig:(A4Trig)trig];
}

- (void)closeGateAtTrack:(uint8_t)trackIdx
{
	if(trackIdx > kNumAllowedVoices-1) return;
}

- (int8_t)openTriglessGateAtTrack:(uint8_t)trackIdx withTrig:(A4Trig)trig
{
	if(trackIdx > kNumAllowedVoices-1) return -1;
	return [self allocateNextVoiceTriglessTrigFromTrack:trackIdx withTrig:(A4Trig)trig];
}

- (void)closeTriglessGateAtTrack:(uint8_t)trackIdx
{
	if(trackIdx > kNumAllowedVoices-1) return;
}

@end
