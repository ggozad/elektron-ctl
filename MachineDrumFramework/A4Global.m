//
//  A4Global.m
//  A4Sysex
//
//  Created by Jakob Penca on 3/31/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4Global.h"
#import "MDMath.h"

@implementation A4Global


- (void)setQuantizeLiveRecording:(BOOL)quantizeLiveRecording
{
	_payload[0xCA] = quantizeLiveRecording ? 1 : 0;
}

- (BOOL)quantizeLiveRecording
{
	return _payload[0xCA];
}

- (void)setKitReloadOnChange:(BOOL)kitReloadOnChange
{
	_payload[0xC9] = kitReloadOnChange ? 1 : 0;
}

- (BOOL)kitReloadOnChange
{
	return _payload[0xC9];
}

- (void)setMidiClockReceive:(BOOL)midiClockReceive
{
	_payload[0x1A] = midiClockReceive ? 1 : 0;
}

- (BOOL)midiClockReceive
{
	return _payload[0x1A];
}

- (void)setMidiClockSend:(BOOL)midiClockSend
{
	_payload[0x1B] = midiClockSend ? 1 : 0;
}

- (BOOL)midiClockSend
{
	return _payload[0x1B];
}

- (void)setMasterTune:(double)masterTune
{
	masterTune = masterTune * 10 - 4400;
	masterTune = mdmath_clamp(round(masterTune), -2200, 4400);
	int16_t tune = masterTune;
	DLog(@"tune: %d", tune);
	_payload[0x28] = tune & 0xFF;
	_payload[0x27] = (tune >> 8) & 0xFF;
}

- (double)masterTune
{
	uint8_t tunLSB = _payload[0x28];
	uint8_t tunMSB = _payload[0x27];
	int16_t tune = tunLSB | tunMSB << 8;
	DLog(@"tune: %d", tune);
	return 440 + tune/10.0;
}


@end
