//
//  MDMachinedrumGlobalSettings.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 8/30/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDMachinedrumGlobalSettings.h"

@interface MDMachinedrumGlobalSettings()
{
	uint8_t *outputRoutings;
}
@end

@implementation MDMachinedrumGlobalSettings
@synthesize originalPosition = _originalPosition;
@synthesize midiBaseChannel = _midiBaseChannel;
@synthesize mechanicalSettings = _mechanicalSettings;

- (void)setTempoFromLowByte:(uint8_t)low highByte:(uint8_t)hi
{
	low &= 0x7f;
	hi &= 0x7f;
	self.tempo = (low | (hi << 7)) / 24.0;
}

- (NSData *)tempoBytes
{
	uint8_t bytes[2];
	float tmult = self.tempo * 24;
	
	return [NSData dataWithBytes:bytes length:2];
}

- (MDMachinedrumGlobalSettings_MechanicalSettings)mechanicalSettings
{
	return _mechanicalSettings;
}

- (void)setMechanicalSettings:(MDMachinedrumGlobalSettings_MechanicalSettings)mechanicalSettings
{
	_mechanicalSettings = mechanicalSettings;
}

- (void)setMidiBaseChannel:(uint8_t)midiBaseChannel
{
	_midiBaseChannel = 0;
	if(midiBaseChannel <=5 || midiBaseChannel == 127) _midiBaseChannel = midiBaseChannel;
}

- (uint8_t)midiBaseChannel
{
	return _midiBaseChannel;
}

- (void)setOriginalPosition:(uint8_t)originalPosition
{
	_originalPosition = originalPosition & 0x07;
}

- (uint8_t)originalPosition
{
	return _originalPosition;
}


- (void)setRoutingOfTrack:(uint8_t)track toOutput:(MDMachinedrumGlobalSettings_RoutingOutput)output
{
	if(output > 6) return;
	if(track > 15) return;
	outputRoutings[track] = output;
}

- (uint8_t)routingOfTrack:(uint8_t)track
{
	if(track > 15) return 6;
	return outputRoutings[track];
}

- (id)init
{
	if(self = [super init])
	{
		outputRoutings = malloc(16);
		memset(outputRoutings, 6, 16);
	}
	return self;
}

- (void)dealloc
{
	free(outputRoutings);
}

@end
