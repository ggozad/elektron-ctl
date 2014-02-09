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
#define kNumMaxGates 128


@interface A4VoiceAllocator()
@property (nonatomic) GateEvent *gates;
@property (nonatomic) NSUInteger gatesLen;
@property (nonatomic) uint8_t *usedVoices;
@property (nonatomic) uint8_t lastUsedVoice;
@property (nonatomic) uint8_t usedVoicesLen;
@end

@implementation A4VoiceAllocator

- (void)reset
{
	_lastUsedVoice = A4NULL;
	self.freeVoices = 0xF;
	_usedVoicesLen = 0;
	_gatesLen = 0;
}

- (void) addGate:(GateEvent)gate
{
	printf("adding gate with voices:\n%d\n%d\n%d\n%d\n",
		   gate.voices[0],
		   gate.voices[1],
		   gate.voices[2],
		   gate.voices[3]);
	
	
	if(_gatesLen == kNumMaxGates) return;
	for(int i = 0; i < _gatesLen; i++)
	{
		if(gate.id == _gates[i].id) return;
	}
	_gates[_gatesLen++] = gate;
}

- (void) removeGate:(GateEvent)gate
{
	for(int i = 0; i < _gatesLen; i++)
	{
		if(gate.id == _gates[i].id)
		{
			for(int j = 0; j < 4; j++)
			{
				uint8_t voice = _gates[i].voices[j];
				
				[self freeVoice:voice];
			}
			
			if(_gatesLen > i+1)
			{
				for(int j = i; j < _gatesLen; j++)
				{
					_gates[j] = _gates[j+1];
				}
			}
			_gatesLen--;
			return;
		}
	}
}

- (BOOL) registerVoice:(uint8_t) voice
{
	if(voice == A4NULL) return NO;
	if(voice > kNumAllowedVoices-1) return NO;
	if(_usedVoicesLen == kNumAllowedVoices) return NO;
	
	for(int i = 0; i < _usedVoicesLen; i++)
	{
		if(_usedVoices[i] == voice) return NO;
	}
	
	[self setVoice:voice free:NO];
	_usedVoices[_usedVoicesLen++] = voice;
	_lastUsedVoice = voice;
	return YES;
}

- (uint8_t) oldestVoice
{
	if(_usedVoicesLen) return _usedVoices[0];
	return A4NULL;
}

- (BOOL) freeVoice:(uint8_t)voice
{
	printf("freeing voice %d\n", voice);
	if(voice == A4NULL) return NO;
	
	for(uint8_t i = 0; i < _usedVoicesLen; i++)
	{
		if(_usedVoices[i] == voice)
		{
			if(_usedVoicesLen > i+1)
			{
				for(int j = i; j < _usedVoicesLen-1; j++)
				{
					_usedVoices[j] = _usedVoices[j+1];
				}
			}
			[self setVoice:voice free:YES];
			_usedVoicesLen--;
			return YES;
		}
	}
	
	return NO;
}

- (uint8_t) stealOldestVoice
{
	uint8_t voice = [self oldestVoice];
	if(voice == A4NULL) return A4NULL;
	
//	DLog(@"stealing: %d", voice);
	
	BOOL didFreeVoice = [self freeVoice:voice];
	if(didFreeVoice)
	{
		for(int i = 0; i < _gatesLen; i++)
		{
			for(int j = 0; j < 4; j++)
			{
				
				if(_gates[i].voices[j] == voice)
				{
					_gates[i].voices[j] = A4NULL;
					BOOL hasVoices = NO;
					for(int k = 0; k < 4; k++)
					{
						if(_gates[i].voices[k] != A4NULL)
						{
							hasVoices = YES; break;
						}
					}
					
					if(!hasVoices)
					{
//						DLog(@"closing a gate");
						GateEvent event = _gates[i];
						[self removeGate:event];
						[self.delegate a4VoiceAllocator:self didNullifyGate:event];
					}
					else
					{
						[self.delegate a4VoiceAllocator:self didStealVoice:voice noteIdx:j gate:_gates[i]];
					}
				}
			}
		}
	}
	
	return voice;
}

- (id)init
{
	if(self = [super init])
	{
		_lastUsedVoice = A4NULL;
		_freeVoices = 0x0F;
		_usedVoices = malloc(sizeof(uint8_t) * kNumAllowedVoices);
		_gates = malloc(sizeof(GateEvent) * kNumMaxGates);
	}
	return self;
}

- (void)dealloc
{
	free(_usedVoices);
	free(_gates);
}

- (uint8_t) nextFreePolyVoiceStartingFrom:(uint8_t)strt
{
	if(strt > 3) return -1;
	for (uint8_t i = strt; i < strt + 4; i++)
	{
		uint8_t wrapped = mdmath_wrap(i, 0, 3);
		if([self isVoicePolyphonic:wrapped] && [self isVoiceFree:wrapped]) return wrapped;
	}
	return A4NULL;
}

- (uint8_t) nextPolyVoiceRotate
{
	uint8_t start = _lastUsedVoice+1;
	if(_lastUsedVoice == A4NULL) start = 0;
	for (uint8_t i = start; i < start + 4; i++)
	{
		uint8_t wrapped = mdmath_wrap(i, 0, 3);
		if([self isVoicePolyphonic:wrapped]  && [self isVoiceFree:wrapped])
		{
			return wrapped;
		}
	}
	return A4NULL;
}

- (int8_t) allocateSingleVoiceForGate:(GateEvent) event
{
	uint8_t voice = A4NULL;
	switch (_mode)
	{
		case A4VoiceAllocationModeReset:
		{
			voice = [self nextFreePolyVoiceStartingFrom:event.track];
			
			if(voice == A4NULL)
			{
				voice = [self stealOldestVoice];
			}
			
			NSAssert(voice != A4NULL, @"voice shouldn't be NULL here!");
			
			[self registerVoice:voice];
			return voice;
		}
		case A4VoiceAllocationModeRotate:
		{
			voice = [self nextPolyVoiceRotate];
			if(voice == A4NULL)
			{
				voice = [self stealOldestVoice];
			}
			
			NSAssert(voice != A4NULL, @"voice shouldn't be NULL here!");
			[self registerVoice:voice];
			return voice;
		}
			
		default:
		{
			return A4NULL;
			break;
		}
	}
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


- (void)handleOnRequests:(GateEvent *)gates len:(NSUInteger)len
{
	int num = [self totalRequestedVoicesInGates:gates len:len];
	if(num > 4) num = 4;
	
//	DLog(@"handle on requests: %d", num);
	
	int allocatedVoices = 0;
	for(int noteIdx = 0; noteIdx < 4; noteIdx++)
	{
		for(int gateIdx = 0; gateIdx < len; gateIdx++)
		{
			if([self isVoicePolyphonic:gates[gateIdx].track])
			{
				if(gates[gateIdx].trig.notes[noteIdx] != A4NULL)
				{
					uint8_t voice = [self allocateSingleVoiceForGate:gates[gateIdx]];
					
					
					printf("allocating voice %d to track %d note %d\n",
						   voice, gates[gateIdx].track, noteIdx);
	
					gates[gateIdx].voices[noteIdx] = voice;
					
					allocatedVoices++;
					if(allocatedVoices == num || noteIdx == 3) [self addGate:gates[gateIdx]];
					if(allocatedVoices == num) break;
				}
			}
			else
			{
				if(noteIdx == 0)
				{
					gates[gateIdx].voices[noteIdx] = gates[gateIdx].track;
				}
			}
		}
		if(allocatedVoices == num) break;
	}
	
//	printf("gates len: %d\n", _gatesLen);
}

- (void)handleOffRequests:(GateEvent *)gates len:(NSUInteger)len
{
//	DLog(@"num: %d", num);
	
	for(int i = 0; i < len; i++)
	{
		[self removeGate:gates[i]];
	}
	
//	printf("gates len: %d\n", _gatesLen);
}

- (int) totalRequestedVoicesInGates:(GateEvent *)gates len:(NSUInteger)len
{
	int num = 0;
	for(int i = 0; i < len; i++)
	{
		for(int j = 0; j < 4; j++)
		{
			if(gates[i].trig.notes[j] != A4NULL) num++;
		}
	}
	return num;
}

@end
