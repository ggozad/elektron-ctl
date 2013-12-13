//
//  A4Settings.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 10/12/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4Settings.h"
#import "MDMath.m"


@implementation A4Settings

- (int8_t)transpose
{
	return _payload[0x15];
}

- (void)setTranspose:(int8_t)transpose
{
	transpose = mdmath_clamp(transpose, -36, 36);
	_payload[0x15] = transpose;
	if(transpose < 0) _payload[0x14] = 0xFF;
}

- (void)setPatternPage:(uint8_t)patternPage
{
	if(patternPage > 3) return;
	_payload[0xB] = patternPage;
}

- (uint8_t)patternPage
{
	return _payload[0xB];
}

- (BOOL)isTrackMuted:(uint8_t)track
{
	if(track > 5) return NO;
	return _payload[0xD] & 1 << track;
}

- (void)setTrack:(uint8_t)track muted:(BOOL)muted
{
	if(track > 5) return;
	
	if(muted)
	{
		_payload[0xD] |= 1 << track;
	}
	else
	{
		_payload[0xD] &= ~ (1 << track);
	}
}

- (uint8_t)selectedTrack
{
	return self.selectedTrackPrimary;
}

- (void)setSelectedTrack:(uint8_t)selectedTrack
{
	self.selectedTrackPrimary = selectedTrack;
	self.selectedTrackSecondary = selectedTrack;
}

- (void)setSelectedTrackPrimary:(uint8_t)selectedTrackPrimary
{
	if(selectedTrackPrimary > 5) return;
	if(selectedTrackPrimary != 4) _payload[0x07] = selectedTrackPrimary;
	_payload[0x06] = selectedTrackPrimary;
}

- (void)setSelectedTrackSecondary:(uint8_t)selectedTrackSecondary
{
	if(selectedTrackSecondary > 5) return;
	if(selectedTrackSecondary != 4) _payload[0x06] = selectedTrackSecondary;
	_payload[0x07] = selectedTrackSecondary;
}

- (uint8_t)selectedTrackPrimary
{
	return _payload[0x06];
}

- (uint8_t)selectedTrackSecondary
{
	return _payload[0x07];
}

- (void)setSequencerMode:(A4SettingsSequencerMode)sequencermode
{
	if(sequencermode > 2) return;
	_payload[0x13] = sequencermode;
}

- (A4SettingsSequencerMode)sequencerMode
{
	return _payload[0x13];
}

- (void)setPatternChangeMode:(A4SettingsPatternChangeMode)patternChangeMode
{
	if(patternChangeMode <= 2)
	{
		_payload[0x16] = patternChangeMode;
	}
}

- (A4SettingsPatternChangeMode)patternChangeMode
{
	return _payload[0x16];
}

- (void)setParamPage:(A4SettingsParamPage)paramPage
{
	if(paramPage <= 8)
	{
		_payload[0x08] = paramPage;
	}
}

- (A4SettingsParamPage)paramPage
{
	return _payload[0x08];
}

- (void)setBpm:(double)bpm
{
	bpm = mdmath_clamp(bpm, 30, 300);
	bpm = round(bpm * 10)/10;
	uint32_t intVal = bpm * 120;
	_payload[0x04] = intVal >> 8;
	_payload[0x05] = intVal & 0xFF;
}

- (double)bpm
{
	uint16_t intVal =  * ((uint16_t *) (_payload + 0x04));
	intVal = intVal >> 8 | intVal << 8;
	return intVal/120.0;
}


@end
