//
//  A4Sound.m
//  A4Sysex
//
//  Created by Jakob Penca on 3/31/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4Sound.h"
#import "A4SysexHelper.h"
#import "MDMath.h"
#import "NSData+MachinedrumBundle.h"

@implementation A4Sound

+ (instancetype)messageWithPayloadAddress:(char *)payload
{
	A4Sound *sound = [super messageWithPayloadAddress:payload];
	[sound initStructs];
	return sound;
}

+ (instancetype)messageWithSysexData:(NSData *)data
{
	A4Sound *instance = [super messageWithSysexData:data];
	if(instance)
	{
		[instance initStructs];
	}
	return instance;
}

+ (instancetype)defaultSound
{
	A4Sound *instance = [self new];
	[instance allocPayload];
	[instance initStructs];
	[instance clear];
	return instance;
}

- (BOOL)isDefaultSound
{
	return [A4SysexHelper soundIsEqualToDefaultSound:self];
}

- (BOOL)isEqualToSound:(A4Sound *)sound
{
	return [A4SysexHelper sound:self isEqualToSound:sound];
}

- (void) initStructs
{
	_settings = (A4SoundSettings *) (_payload + 0xFC);
	_params = (A4SoundParams *) (_payload + 0x1C);
}

- (id)init
{
	if(self = [super init])
	{
		self.type = A4SysexMessageID_Sound;
	}
	return self;
}

- (void)clear
{
	[self setDefaultValuesForPayload];
}

- (void)allocPayload
{
	NSUInteger len = A4MessagePayloadLengthSound;
	self.payloadLength = len;
	if(_payload && self.ownsPayload) free(_payload);
	self.payload = malloc(len);
	self.ownsPayload = YES;
}

- (void)setPayload:(char *)payload
{
	[super setPayload:payload];
	if(_payload)
	{
		[self initStructs];
	}
}

- (void) setDefaultValuesForPayload
{
	if (!_payload) return;
	static dispatch_once_t onceToken;
    static NSData *soundData = nil;
    
	dispatch_once(&onceToken, ^{
        
		soundData = [NSData dataFromMachinedrumBundleResourceWithName:@"defaultSound" ofType:@"payload"];
		
    });
	
	if(soundData != nil)
	{
		memmove(_payload, soundData.bytes, A4MessagePayloadLengthSound);
	}
}

- (void)setParamValue:(A4PVal)value
{
	if(!_payload) return;
	if(value.param == A4NULL) return;
	value = A4PValSanitizeClamp(value);
	
	uint8_t i = A4SoundOffsetForParam(value.param);
	if(i == A4NULL) return;
	
	int16_t intval = value.coarse;
	if(A4ParamIs16Bit(value.param)) intval |= (value.fine << 8);
	_params->param[i] = intval;
}

- (A4PVal)valueForParam:(A4Param)param
{
	if(param == A4NULL) return A4PValMakeInvalid();
	uint8_t offset = A4SoundOffsetForParam(param);
	if(offset == A4NULL) return A4PValMakeInvalid();
	
	int16_t intval = _params->param[offset];
	char coarse = intval & 0xFF;
	char  fine  = (intval<<8) & 0xFF;
	return A4PValMake16(param, coarse, fine);
}

- (void)setName:(NSString *)name
{
	void *bytes = _payload + 0xC;
	[A4SysexHelper setName:name inPayloadLocation:bytes];
}

- (NSString *)name
{
	const void *bytes = _payload + 0xC;
	return [A4SysexHelper nameAtPayloadLocation:bytes];
}

- (void)setTags:(A4SoundTagBitmask)tags
{
	char *bytes = _payload;
	A4SoundTagBitmask *tagsMask = (A4SoundTagBitmask *) (bytes+8);
	*tagsMask = CFSwapInt32HostToBig(tags);
}

- (A4SoundTagBitmask)tags
{
	const char *bytes = _payload;
	A4SoundTagBitmask tagsMask = * (A4SoundTagBitmask *) (bytes+8);
	return CFSwapInt32BigToHost(tagsMask);
}

- (void)addTag:(A4SoundTags)tag
{
	A4SoundTagBitmask mask = self.tags;
	mask |= tag;
	self.tags = mask;
}

- (void)removeTag:(A4SoundTags)tag
{
	A4SoundTagBitmask mask = self.tags;
	mask &= ~tag;
	self.tags = mask;
}

@end
