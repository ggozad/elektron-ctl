//
//  StandardMidiFileTrackEvent.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 09/02/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import "SMFEvent.h"
#import "MDMachinedrumPublic.h"

@interface SMFEvent()
{
	NSUInteger _delta;
}
@property (nonatomic, strong) NSData *deltaData;
@end

@implementation SMFEvent

+ (instancetype) smfEventWithAbsoluteTick:(NSUInteger)absouluteTicks messageData:(NSData *)msg
{
	SMFEvent *event = [self new];
	event.absoluteTick = absouluteTicks;
	event.messageData = msg;
	return event;
}


+ (instancetype) smfEventWithAbsoluteTick:(NSUInteger)absouluteTicks noteOn:(MidiNoteOn)noteOn
{
	uint8_t bytes[3];
	bytes[0] = MD_MIDI_STATUS_NOTE_ON | noteOn.channel;
	bytes[1] = noteOn.note;
	bytes[2] = noteOn.velocity;
	NSData *data = [NSData dataWithBytes:bytes length:3];
	return [self smfEventWithAbsoluteTick:absouluteTicks messageData:data];
}


+ (instancetype) smfEventWithAbsoluteTick:(NSUInteger)absouluteTicks noteOff:(MidiNoteOff)noteOff
{
	uint8_t bytes[3];
	bytes[0] = MD_MIDI_STATUS_NOTE_OFF | noteOff.channel;
	bytes[1] = noteOff.note;
	bytes[2] = noteOff.velocity;
	NSData *data = [NSData dataWithBytes:bytes length:3];
	return [self smfEventWithAbsoluteTick:absouluteTicks messageData:data];
}


+ (instancetype)smfEventWithDelta:(NSUInteger)delta messageData:(NSData *)msg
{
	SMFEvent *event = [self new];
	event.delta = delta;
	event.messageData = msg;
	return event;
}

+ (instancetype)smfEventWithDelta:(NSUInteger)delta noteOn:(MidiNoteOn)noteOn
{
	uint8_t bytes[3];
	bytes[0] = MD_MIDI_STATUS_NOTE_ON | noteOn.channel;
	bytes[1] = noteOn.note;
	bytes[2] = noteOn.velocity;
	NSData *data = [NSData dataWithBytes:bytes length:3];
	return [self smfEventWithDelta:delta messageData:data];
}

+(instancetype)smfEventWithDelta:(NSUInteger)delta noteOff:(MidiNoteOff)noteOff
{
	uint8_t bytes[3];
	bytes[0] = MD_MIDI_STATUS_NOTE_OFF | noteOff.channel;
	bytes[1] = noteOff.note;
	bytes[2] = noteOff.velocity;
	NSData *data = [NSData dataWithBytes:bytes length:3];
	return [self smfEventWithDelta:delta messageData:data];
}

- (NSData *)data
{
	NSAssert(self.deltaData && self.messageData, @"there must be data");
	NSMutableData *d = [self.deltaData mutableCopy];
	[d appendData:self.messageData];
	return d;
}

- (void)setDelta:(NSUInteger)delta
{
	NSUInteger len = 0;
	uint8_t deltaBytes[4] = {};
	for (int i = 3; i >= 0; i--)
	{
		uint8_t byte = delta & 0x7F;
		deltaBytes[len++] = byte;
		delta >>= 7;
	}
	
	len = 4;
	for (int i = 3; i >= 0; i--)
	{
		if (deltaBytes[i]) break;
		len--;
	}
	
	for (int i = 1; i < len; i++)
	{
		deltaBytes[i] |= 0x80;
	}
	
	if(len == 0)
	{
		uint8_t byte = 0;
		self.deltaData = [NSData dataWithBytes:&byte length:1];
	}
	else
	{
		uint8_t rev[len];
		for(int i = 0; i < len; i++)
		{
			rev[len - 1 - i] = deltaBytes[i];
		}
		self.deltaData = [NSData dataWithBytes:rev length:len];
	}
	
	_delta = delta;
}

- (NSUInteger)delta
{
	/*
	if(!self.deltaData) return 0;
	const uint8_t *bytes = self.deltaData.bytes;
	NSUInteger len = self.deltaData.length;
	NSUInteger retVal = 0;
	int i = 0;
	while (i < len && i < 4)
	{
		uint8_t byteVal = bytes[i++];
		retVal |= (byteVal & 0x7F);
		
		if(byteVal & 0x80)
		{
			retVal <<= 7;
		}
		else
		{
			break;
		}
	}
	
	return retVal;
	 */
	return _delta;
}

@end
