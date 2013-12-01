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
		[instance convertParamsToHost];
	}
	return instance;
}

+ (instancetype)defaultSound
{
	A4Sound *instance = [self new];
	[instance allocPayload];
	[instance initStructs];
	[instance convertParamsToHost];
	[instance clear];
	return instance;
}

- (void)convertParamsToBigEndian
{
	for(int i = 0; i < A4ParamLayoutCount; i++)
	{
		_params->param[i] = CFSwapInt16HostToBig(_params->param[i]);
	}
}

- (void)convertParamsToHost
{
	for(int i = 0; i < A4ParamLayoutCount; i++)
	{
		_params->param[i] = CFSwapInt16BigToHost(_params->param[i]);
	}
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

- (void)setParamValue:(A4PVal)lock
{
	if(!_payload) return;
	if(lock.param == A4NULL) return;
	uint8_t i = A4SoundOffsetForParam(lock.param);
	if(i == A4NULL) return;
	_params->param[i] = lock.value;
}

- (A4PVal)valueForParam:(A4Param)param
{
	if(param == A4NULL) return A4PValMakeInvalid();
	uint8_t offset = A4SoundOffsetForParam(param);
	if(offset == A4NULL) return A4PValMakeInvalid();
	
	int16_t intval = _params->param[offset];
	return A4PValMakeI(param, intval);
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

- (NSData *)sysexData
{
	[self convertParamsToBigEndian];
	NSData *d = [super sysexData];
	[self convertParamsToHost];
	return d;
}

@end
