//
//  A4Kit.m
//  A4Sysex
//
//  Created by Jakob Penca on 3/28/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4Kit.h"
#import "A4SysexHelper.h"
#import "NSData+MachinedrumBundle.h"

@interface A4Kit()
@property (strong, nonatomic) NSMutableArray *sounds;
@end

@implementation A4Kit

+ (instancetype)messageWithPayloadAddress:(char *)payload
{
	A4Kit *kit = [super messageWithPayloadAddress:payload];
	[kit initSounds];
	[kit initMacros];
	[kit initPolyphony];
	return kit;
}

+ (instancetype)messageWithSysexData:(NSData *)data
{
	A4Kit *instance = [super messageWithSysexData:data];
	[instance initSounds];
	[instance initMacros];
	[instance initPolyphony];
	[instance convertParamsToHost];
	return instance;
}

+ (instancetype)defaultKit
{
	A4Kit *kit = [self new];
	[kit allocPayload];
	[kit initSounds];
	[kit initMacros];
	[kit initPolyphony];
	[kit convertParamsToHost];
	[kit clear];
	return kit;
}


- (void) convertParamsToHost
{
	for(A4Sound *s in _sounds)
	{
		[s convertParamsToHost];
	}
	
	// TODO: FX params
}

- (void) convertParamsToBigEndian
{
	for(A4Sound *s in _sounds)
	{
		[s convertParamsToBigEndian];
	}
	
	// TODO: FX params
}

- (BOOL)isDefaultKit
{
	return [A4SysexHelper kitIsEqualToDefaultKit:self];
}

- (BOOL)isEqualToKit:(A4Kit *)kit
{
	return [A4SysexHelper kit:self isEqualToKit:kit];
}

- (instancetype)init
{
	if(self = [super init])
	{
		self.type = A4SysexMessageID_Kit;
	}
	return self;
}

- (void)allocPayload
{
	if(_payload && self.ownsPayload) free(_payload);
	NSUInteger len = A4MessagePayloadLengthKit;
	char *bytes = malloc(len);
	memset(bytes, 0, len);
	self.payload = bytes;
	self.ownsPayload = YES;
}

- (void)setPayload:(char *)payload
{
	[super setPayload:payload];
	if(_payload)
	{
		[self initSounds];
		[self initMacros];
		[self initPolyphony];
	}
}

- (void)clear
{
	[self setDefaultValuesForPayload];
}

- (void) setDefaultValuesForPayload
{
	if (!_payload) return;
	static dispatch_once_t onceToken;
    static NSData *kitData = nil;
    
	dispatch_once(&onceToken, ^{
        
		kitData = [NSData dataFromMachinedrumBundleResourceWithName:@"defaultKit" ofType:@"payload"];
		
    });
	
	if(kitData != nil)
	{
		memmove(_payload, kitData.bytes, A4MessagePayloadLengthKit);
	}
}

- (void)initSounds
{
	self.sounds = [@[]mutableCopy];
		
	for (int track = 0; track < 4; track++)
	{
		NSUInteger offset = 0x20 + A4MessagePayloadLengthSound * track;
		A4Sound *s = [A4Sound messageWithPayloadAddress:self.payload + offset];
		[self.sounds addObject:s];
	}
}

- (void) initMacros
{
	self.macros = (A4PerformanceMacro *)(_payload + 0x7B0);
}

- (void) initPolyphony
{
	self.polyphony = (A4PolySettings *)(_payload + 0x92C);
}

- (A4Sound *)copySound:(A4Sound *)sound toTrack:(uint8_t)track
{
	if (track > 3) return nil;

	const char *soundPayloadBytes = sound.payload;
	A4Sound *targetSound = (A4Sound *)_sounds[track];
	char *targetBytes = [targetSound payload];
	
	if(targetBytes != soundPayloadBytes)
	{
		memmove(targetBytes, soundPayloadBytes, A4MessagePayloadLengthSound);
	}
	
	return targetSound;
}

- (A4Sound *)soundAtTrack:(uint8_t)track copy:(BOOL)copy
{
	if(track > 3)return nil;
	if(copy)
	{
		A4Sound *originalSound = self.sounds[track];
		char *payload = malloc(A4MessagePayloadLengthSound);
		memmove(payload, originalSound.payload, A4MessagePayloadLengthSound);
		A4Sound *copiedSound = [A4Sound messageWithPayloadAddress:payload];
		copiedSound.ownsPayload = YES;
		return copiedSound;
	}
	return self.sounds[track];
}

- (void)setName:(NSString *)name
{
	void *bytes = self.payload + 0x4;
	[A4SysexHelper setName:name inPayloadLocation:bytes];
}

- (NSString *)name
{
	const void *bytes = self.payload + 0x4;
	return [A4SysexHelper nameAtPayloadLocation:bytes];
}

/*
- (void) setFxParamValue:(A4PVal)value
{
	if(!_payload) return;
	if(! A4ParamFxIsLockable(value.param)) return;
	value = A4PValFxSanitizeClamp(value);
	
	_payload[A4KitOffsetForFxParam(value.param)] = value.coarse;
	if(A4ParamFxIs16Bit(value.param))
		_payload[A4KitOffsetForFxParam(value.param) + 1] = value.fine;
}

- (A4PVal) valueForFxParam:(A4Param)param
{
	if(! A4ParamFxIsLockable(param)) return A4PValMakeInvalid();
	
	UInt16 offset = A4KitOffsetForFxParam(param);
	uint8_t coarse = _payload[offset];
	uint8_t  fine  = _payload[offset+1];
	return A4PValFxMake16(param, coarse, fine);
}
*/

- (uint8_t)levelForTrack:(uint8_t)t
{
	if(t > 5) return 0;
	return _payload[0x14 + t*2];
}

- (void)setLevel:(uint8_t)level forTrack:(uint8_t)t
{
	if(t > 5) return;
	if(level > 127) level = 127;
	_payload[0x14 + t*2] = level;
}


- (NSData *)sysexData
{
	for(A4Sound *s in _sounds)
	{
		[s convertParamsToBigEndian];
	}
	NSData *d = [super sysexData];
	for(A4Sound *s in _sounds)
	{
		[s convertParamsToHost];
	}
	return d;
}

@end
