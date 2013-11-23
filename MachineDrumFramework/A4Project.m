//
//  A4Project.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 9/28/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4Project.h"
#import "MDSysexUtil.h"
#import "MDMachinedrumPublic.h"

@interface A4Project()
@property (nonatomic, strong) NSMutableArray *sounds, *kits, *patterns;
@end

@implementation A4Project

static NSInteger payloadOffsetForSoundPosition(uint8_t i)
{
	if(i > 127) return -1;
	return A4MessagePayloadLengthSound * i;
}

static NSInteger payloadOffsetForKitPosition(uint8_t i)
{
	if(i > 127) return -1;
	return A4MessagePayloadLengthSound*128 + A4MessagePayloadLengthKit * i;
}

static NSInteger payloadOffsetForPatternPosition(uint8_t i)
{
	if(i > 127) return -1;
	return A4MessagePayloadLengthSound*128 + A4MessagePayloadLengthKit*128 + A4MessagePayloadLengthPattern*i;
}

+ (instancetype)defaultProject
{
	A4Project *project = [self new];
	[project allocPayload];
	[project setupContent];
	[project clear];
	project.autoReceiveEnabled = YES;
	return project;
}

- (void)setAutoReceiveEnabled:(BOOL)autoReceiveEnabled
{
	if(autoReceiveEnabled == _autoReceiveEnabled) return;
	if(autoReceiveEnabled)
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleA4SysEx:) name:kA4SysexNotification
												   object:nil];
	}
	else
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self name:kA4SysexNotification object:nil];
	}
}

- (void) handleA4SysEx:(NSNotification *)n
{
	NSData *d = [n.object copy];
	const uint8_t *bytes = d.bytes;
	switch (bytes[0x06])
	{
		case A4SysexMessageID_Pattern:
		{
			A4Pattern *p = [A4Pattern messageWithSysexData:d];
			if(p && [_delegate a4Project:self shouldStoreReceivedPattern:p])
				[self copyPattern:p toPosition:p.position];
			break;
		}
		case A4SysexMessageID_Kit:
		{
			A4Kit *k = [A4Kit messageWithSysexData:d];
			if(k && [_delegate a4Project:self shouldStoreReceivedKit:k])
				[self copyKit:k toPosition:k.position];
			break;
		}
		case A4SysexMessageID_Sound:
		{
			A4Sound *s = [A4Sound messageWithSysexData:d];
			if(s && [_delegate a4Project:self shouldStoreReceivedSound:s])
				[self copySound:s toPosition:s.position];
			break;
		}
		default:
			break;
	}
}

- (void) allocPayload
{
	if(_payload && self.ownsPayload) free(_payload);
	NSUInteger len = A4MessagePayloadLengthProject;
	char *bytes = malloc(len);
	memset(bytes, 0, len);
	_payload = bytes;
	self.ownsPayload = YES;
}

- (void) setupContent
{
	self.sounds = @[].mutableCopy;
	self.kits = @[].mutableCopy;
	self.patterns = @[].mutableCopy;
	
	char *addr = _payload;
	
	for (uint8_t i = 0; i < 128; i++)
	{
		A4Sound *sound = [A4Sound messageWithPayloadAddress:addr];
		[sound clear];
		sound.position = i;
		[self.sounds addObject:sound];
		addr += A4MessagePayloadLengthSound;
	}
	for (uint8_t i = 0; i < 128; i++)
	{
		A4Kit *kit = [A4Kit messageWithPayloadAddress:addr];
		[kit clear];
		kit.position = i;
		[self.kits addObject:kit];
		addr += A4MessagePayloadLengthKit;
	}
	for (uint8_t i = 0; i < 128; i++)
	{
		A4Pattern *pattern = [A4Pattern messageWithPayloadAddress:addr];
		[pattern clear];
		pattern.position = i;
		[self.patterns addObject:pattern];
		addr += A4MessagePayloadLengthPattern;
	}
}

- (void)clear
{
	[super clear];
	
	for (A4Sound *sound in self.sounds)
	{
		[sound clear];
	}
	
	for (A4Kit *kit in self.kits)
	{
		[kit clear];
	}
	
	for (A4Pattern *pattern in self.patterns)
	{
		[pattern clear];
	}
}

- (id)init
{
	if(self = [super init])
	{
		self.payloadLength = A4MessagePayloadLengthProject;
	}
	return self;
}

- (void)setSysexData:(NSData *)sysexData
{
	[self clear];
	
	NSArray *splits = [MDSysexUtil splitDataFromData:sysexData];
	for (NSData *d in splits)
	{
		const char *bytes = d.bytes;
		if(d.length >= 0x06)
		{
			A4SysexMessage *message;
			char ident = bytes[0x06];
			
			switch (ident)
			{
				case A4SysexMessageID_Sound:
				{
					message = [A4Sound messageWithSysexData:d];
					if(message) [self copySound:(A4Sound *)message toPosition:message.position];
					break;
				}
				case A4SysexMessageID_Kit:
				{
					message = [A4Kit messageWithSysexData:d];
					if(message) [self copyKit:(A4Kit *)message toPosition:message.position];
					break;
				}
				case A4SysexMessageID_Pattern:
				{
					message = [A4Pattern messageWithSysexData:d];
					if(message) [self copyPattern:(A4Pattern *)message toPosition: message.position];
					break;
				}
				default:
					break;
			}
		}
	}
}

- (NSData *)sysexData
{
	NSMutableData *data = [NSMutableData data];
	
	int i = 0;
	for (A4Sound *sound in self.sounds)
	{
		sound.position = i;
		[data appendData:sound.sysexData];
		i++;
	}
	
	i = 0;
	for (A4Kit *kit in self.kits)
	{
		kit.position = i;
		[data appendData:kit.sysexData];
		i++;
	}
	
	i = 0;
	for (A4Pattern *pattern in self.patterns)
	{
		pattern.position = i;
		[data appendData:pattern.sysexData];
		i++;
	}
	return data;
}


- (A4Sound *)copySound:(A4Sound *)sound toPosition:(uint8_t)i
{
	NSInteger offset = payloadOffsetForSoundPosition(i);
	if(offset != -1) memmove(_payload + offset, sound.payload, A4MessagePayloadLengthSound);
	DLog(@"%d",i);
	return [self soundAtPosition:i];
}

- (A4Sound *)copySoundToFirstUnusedPosition:(A4Sound *)sound
{
	for (int i = 0; i < 128; i++)
	{
		if([[self soundAtPosition:i] isDefaultSound])
			return [self copySound:sound toPosition:i];
	}
	return nil;
}

- (A4Kit *)copyKit:(A4Kit *)kit toPosition:(uint8_t)i
{
	NSInteger offset = payloadOffsetForKitPosition(i);
	if(offset != -1) memmove(_payload + offset, kit.payload, A4MessagePayloadLengthKit);
	DLog(@"%d",i);
	return [self kitAtPosition:i];
}

- (A4Kit *)copyKitToFirstUnusedPosition:(A4Kit *)kit
{
	for (int i = 0; i < 128; i++)
	{
		if([[self kitAtPosition:i] isDefaultKit])
			return [self copyKit:kit toPosition:i];
	}
	return nil;
}

- (A4Pattern *)copyPattern:(A4Pattern *)pattern toPosition:(uint8_t)i
{
	NSInteger offset = payloadOffsetForPatternPosition(i);
	if(offset != -1) memmove(_payload + offset, pattern.payload, A4MessagePayloadLengthPattern);
	DLog(@"%d",i);
	return [self patternAtPosition:i];
}

- (A4Pattern *)copyPatternToFirstUnusedPosition:(A4Pattern *)pattern
{
	for (int i = 0; i < 128; i++)
	{
		if([[self patternAtPosition:i] isDefaultPattern])
			return [self copyPattern:pattern toPosition:i];
	}
	return nil;
}

- (A4Sound *)soundAsCopyAtStep:(uint8_t)step inTrack:(uint8_t)track forPattern:(uint8_t)i
{
	if(step > 63 || track > 3 || i > 127) return nil;
	
	A4Pattern *pattern = [self patternAtPosition:i];
	A4Sound *sound = nil;
	A4Trig trig = [pattern trigAtStep:step inTrack:track];
	if(trig.soundLock != (uint8_t)A4NULL) sound = [self soundAtPosition:trig.soundLock copy:YES];
	else sound = [[self kitAtPosition:pattern.kit] soundAtTrack:track copy:YES];
	
	A4PVal *locks = NULL;
	uint8_t len = 0;
	
	if(A4LocksCreateForTrackAndStep(pattern, step, track, &locks, &len))
	{
		for (int i = 0; i < len; i++)
		{
			[sound setParamValue:locks[i]];
		}
		A4LocksRelease(&locks);
	}
	
	return sound;
}

- (int8_t)indexOfFirstDefaultSound
{
	for (int i = 0; i < 128; i++)
	{
		if([[self soundAtPosition:i] isDefaultSound]) return i;
	}
	return A4NULL;
}

- (A4Sound *)soundAtPosition:(uint8_t)i
{
	return self.sounds[i];
}

- (A4Sound *)soundAtPosition:(uint8_t)i copy:(BOOL)copy
{
	if(!copy) return self.sounds[i];
	return [A4Sound messageWithSysexData:[self.sounds[i] sysexData]];
}

- (BOOL)soundAtIndexIsLockedFromAnyPattern:(uint8_t)i
{
	for (A4Pattern *pattern in self.patterns)
	{
		for (int trackIdx = 0; trackIdx < 6; trackIdx++)
		{
			A4PatternTrack *track = [pattern track:trackIdx];
			for (int step = 0; step < 64; step++)
			{
				if(track.soundLocks[step] == i) return YES;
			}
		}
	}
	return NO;
}

- (NSArray *)patternIndicesLockingSoundAtIndex:(uint8_t)i
{
	NSMutableArray *array = @[].mutableCopy;
	
	for (A4Pattern *pattern in self.patterns)
	{
		BOOL thisPatternGotTheSound = NO;
		for (int trackIdx = 0; trackIdx < 6; trackIdx++)
		{
			BOOL thisTrackGotTheSound = NO;
			A4PatternTrack *track = [pattern track:trackIdx];
			for (int step = 0; step < 64; step++)
			{
				if(track.soundLocks[step] == i)
				{
					[array addObject:@(pattern.position)];
					thisPatternGotTheSound = YES;
					thisTrackGotTheSound = YES;
					break;
				}
			}
			if(thisTrackGotTheSound) break;
		}
		if(thisPatternGotTheSound) continue;
	}
	return array;
}

- (int8_t)indexOfFirstDefaultKit
{
	for (int i = 0; i < 128; i++)
	{
		if([[self kitAtPosition:i] isDefaultKit]) return i;
	}
	return A4NULL;
}

- (A4Kit *)kitAtPosition:(uint8_t)i
{
	return self.kits[i];
}

- (A4Kit *)kitAtPosition:(uint8_t)i copy:(BOOL)copy
{
	if(!copy) return self.kits[i];
	return [A4Kit messageWithSysexData:[self.kits[i] sysexData]];
}

- (BOOL)kitAtIndexIsLinkedFromAnyPattern:(uint8_t)i
{
	for (A4Pattern *pattern in self.patterns)
	{
		if(pattern.kit == i) return YES;
	}
	return NO;
}

- (NSArray *)patternIndicesLinkingToKitAtIndex:(uint8_t)i
{
	NSMutableArray *array = @[].mutableCopy;
	
	for (A4Pattern *pattern in self.patterns)
	{
		if(![pattern isDefaultPattern] && pattern.kit == i)
			[array addObject:@(pattern.position)];
	}
	
	return array;
}

- (int8_t)indexOfFirstDefaultPattern
{
	for (int i = 0; i < 128; i++)
	{
		if([[self patternAtPosition:i] isDefaultPattern]) return i;
	}
	return 0xFF;
}

- (A4Pattern *)patternAtPosition:(uint8_t)i
{
	return self.patterns[i];
}

- (A4Pattern *)patternAtPosition:(uint8_t)i copy:(BOOL)copy
{
	if(!copy) return self.patterns[i];
	return [A4Pattern messageWithSysexData:[self.patterns[i] sysexData]];
}

@end
