//
//  A4PatternTrack.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 9/21/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4PatternTrack.h"
#import "A4Pattern.h"
#import "MDMath.h"
#import "NSData+MachinedrumBundle.h"

@implementation A4PatternTrack

+ (A4PatternTrack *)trackWithPayloadAddress:(char *)addr pattern:(A4Pattern *)pattern
{
	A4PatternTrack *track = [self new];
	track.payload = addr;
	track.pattern = pattern;
	return track;
}

- (void)setPayload:(char *)payload
{
	if(_payload && _ownsPayload) free(_payload);
	_payload = payload;
	
	self.flags =		(UInt16 *)	(_payload +  0x00);
	self.notes =		(uint8_t *)	(_payload +  0x80);
	self.velocities =	(uint8_t *)	(_payload +  0xC0);
	self.lengths =		(uint8_t *) (_payload + 0x100);
	self.microtimes =	(uint8_t *)	(_payload + 0x140);
	self.settings =		(A4TrackSettings *)	(_payload + 0x180);
	self.soundLocks =	(uint8_t *)	(_payload + 0x18B);
	self.arp =			(A4Arp *)   (_payload + 0x1CB);
}

- (void)dealloc
{
	if(_ownsPayload && _payload)
	{
		free(_payload);
	}
}

- (void)clearAllTrigs
{
	for (int i = 0; i < 64; i++)
	{
		[self clearTrigAtStep:i];
	}
}

- (void)setTrig:(A4Trig)trig atStep:(uint8_t)step
{
	if(step > 63) return;
	
	int note = 0xFF;
	
	UInt16 doubleFlags = A4TRIGFLAGS.TRIG | A4TRIGFLAGS.TRIGLESS;
	if((trig.flags & 0x03) == doubleFlags)
	{
		trig.flags &= ~A4TRIGFLAGS.TRIGLESS;
	}
	
	if(trig.flags & A4TRIGFLAGS.TRIG)
	{
		trig.flags |= A4TRIGFLAGS.NOTE;
	}
	
	if(trig.flags & A4TRIGFLAGS.NOTE) note = trig.notes[0];
	
	if(!(trig.flags & A4TRIGFLAGS.TRIGLESS ||
		 trig.flags & A4TRIGFLAGS.TRIG))
	{
		if(self.pattern)
		{
			NSUInteger i = [self.pattern.tracks indexOfObject:self];
			if(i != NSNotFound)
			{
				[self.pattern clearAllLocksAtStep:step inTrack:i];
			}
		}
	}
	
	_flags[step]		= CFSwapInt16HostToBig(trig.flags);
	_notes[step]		= note;
	
	for(int i = 1; i < 4; i++)
	{
		uint8_t note = trig.notes[i];
		_arp->noteLocks[i-1][step] = note;
	}
	
	_velocities[step]	= trig.velocity;
	_lengths[step]		= trig.length;
	_soundLocks[step]	= trig.soundLock;
	_microtimes[step]	= trig.microTiming;
}

- (A4Trig)trigAtStep:(uint8_t)step
{
	if(step > 63) return A4TrigMakeEmpty();
	
	A4Trig trig;
	trig.flags		 = CFSwapInt16BigToHost(_flags[step]);
	trig.notes[0]	 = _notes[step];
	trig.velocity	 = _velocities[step];
	trig.length		 = _lengths[step];
	trig.soundLock   = _soundLocks[step];
	trig.microTiming = _microtimes[step];
	
	for(int i = 1; i < 4; i++)
	{
		trig.notes[i] = _arp->noteLocks[i-1][step];
	}
	
	return trig;
}

- (A4Trig)trigAtStepAllFieldsFilled:(uint8_t)step
{
	if(step > 63) return A4TrigMakeEmpty();
	A4Trig trig = [self trigAtStep:step];
	if(trig.notes[0] == A4NULL) trig.notes[0] = _settings->trigNote;
	if(trig.velocity == A4NULL) trig.velocity = _settings->trigVelocity;
	if(trig.length == A4NULL) trig.length = _settings->trigLength;
	return trig;
}

- (void)clearTrigAtStep:(uint8_t)step
{
	if(step > 63) return;
	
	A4Trig trig = A4TrigMakeEmpty();
	[self setTrig:trig atStep:step];
}

- (void)setArpNoteLock:(uint8_t)n forNote:(uint8_t)i atStep:(uint8_t)step
{
	if(step > 63 || i > 2) return;
	
	A4Trig trig = [self trigAtStep:step];
	if(!(trig.flags & A4TRIGFLAGS.TRIGLESS ||
		 trig.flags & A4TRIGFLAGS.TRIG))
	{
		trig = A4TrigMakeDefault();
		[self setTrig:trig atStep:step];
	}
	_arp->noteLocks[i][step] = mdmath_clamp(n, 0, 0x7F);
}

- (uint8_t)arpNoteLockForNote:(uint8_t)i atStep:(uint8_t)step
{
	if(step > 63 || i > 2) return 0xFF;
	return _arp->noteLocks[i][step];
}

- (void)setArpPatternState:(BOOL)state atStep:(uint8_t)step
{
	if(step > 15) return;
	
	UInt16 trig = 1 << step;
	if(state)
	{
		_arp->pattern |= CFSwapInt16HostToBig(trig);
	}
	else
	{
		_arp->pattern &= CFSwapInt16HostToBig(~trig);
	}
}

- (BOOL)arpPatternStateAtStep:(uint8_t)step
{
	if(step > 15) return NO;
	return (CFSwapInt16BigToHost(_arp->pattern) >> step) & 0x1;
}


+ (int) constrainKeyInTrack: (A4PatternTrack *)track note:(int)note
{
	static uint8_t major[] = {0, 2, 4, 5, 7, 9, 11};
	static uint8_t minor[] = {0, 2, 3, 5, 7, 8, 10};
	
	uint8_t scaleIdx = track.settings->keyScale;
	uint8_t *scale;
	if(scaleIdx == 1) scale = major;
	else scale = minor;
	
	uint8_t keyNote = track.settings->keyNote;
	
	int octave =  note/12;
	int noteStrippedOfOctave = note - octave*12;
	int noteStrippedKeyed = noteStrippedOfOctave - keyNote;
	int noteStrippedKeyedWrapped = mdmath_wrap(noteStrippedKeyed, 0, 11);
	int fallDown = noteStrippedKeyed < 0 ? -1 : 0;
	
	BOOL isInKey = NO;
	
	for (int i = 0; i < 8; i++)
	{
		if(noteStrippedKeyed == scale[i])
		{
			isInKey = YES;
			break;
		}
	}
	if(!isInKey)
	{
		if(scaleIdx == 1)
		{
			if(noteStrippedKeyedWrapped == 1) noteStrippedKeyedWrapped = 0;
			else if(noteStrippedKeyedWrapped == 3) noteStrippedKeyedWrapped = 2;
			else if(noteStrippedKeyedWrapped == 6) noteStrippedKeyedWrapped = 5;
			else if(noteStrippedKeyedWrapped == 8) noteStrippedKeyedWrapped = 7;
			else if(noteStrippedKeyedWrapped == 10) noteStrippedKeyedWrapped = 9;
		}
		else if (scaleIdx == 2)
		{
			if(noteStrippedKeyedWrapped == 1) noteStrippedKeyedWrapped = 0;
			else if(noteStrippedKeyedWrapped == 4) noteStrippedKeyedWrapped = 3;
			else if(noteStrippedKeyedWrapped == 6) noteStrippedKeyedWrapped = 5;
			else if(noteStrippedKeyedWrapped == 9) noteStrippedKeyedWrapped = 8;
			else if(noteStrippedKeyedWrapped == 11) noteStrippedKeyedWrapped = 10;
		}
		
		note = mdmath_clamp(octave*12 + keyNote + noteStrippedKeyedWrapped + fallDown*12, 0, 127);
	}
	
	return note;
}


@end
