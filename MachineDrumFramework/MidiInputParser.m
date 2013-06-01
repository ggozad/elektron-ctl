//
//  MidiInputParser.m
//  PGMidiTest
//
//  Created by Jakob Penca on 8/25/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MidiInputParser.h"

#define MD_MIDI_STATUS_SYSEX_BEGIN (0xF0)
#define MD_MIDI_STATUS_SYSEX_END (0xF7)
#define MD_MIDI_STATUS_CLOCK (0xF8)
#define MD_MIDI_STATUS_TICK (0xF9)
#define MD_MIDI_STATUS_START (0xFA)
#define MD_MIDI_STATUS_CONTINUE (0xFB)
#define MD_MIDI_STATUS_STOP (0xFC)
#define MD_MIDI_STATUS_ACTIVESENSE (0xFE)
#define MD_MIDI_STATUS_NOTE_ON (0x90)
#define MD_MIDI_STATUS_NOTE_OFF (0x80)
#define MD_MIDI_STATUS_AFTERTOUCH (0xA0)
#define MD_MIDI_STATUS_CONTROL_CHANGE (0xB0)
#define MD_MIDI_STATUS_PROGRAM_CHANGE (0xC0)

#define MD_MIDI_STATUS_ANY (0x80)


#define sysexBufferSize (1024*1024)
uint8_t sysexBuffer[sysexBufferSize];
NSUInteger sysexBufferIndex = 0;

uint8_t noteOnBuffer[3];
NSUInteger noteOnBufferIndex = 0;

uint8_t noteOffBuffer[3];
NSUInteger noteOffBufferIndex = 0;

uint8_t aftertouchBuffer[3];
NSUInteger aftertouchBufferIndex = 0;

uint8_t ccBuffer[3];
NSUInteger ccBufferIndex = 0;

uint8_t programChangeBuffer[2];
NSUInteger programChangeBufferIndex = 0;


typedef enum receiveState
{
	receiveState_None,
	receiveState_Sysex,
	receiveState_NoteOn,
	receiveState_NoteOff,
	receiveState_Aftertouch,
	receiveState_ControlChange,
	receiveState_ProgramChange,
}
receiveState;

receiveState _receiveState = receiveState_None;

@implementation MidiInputParser

- (void)midiSource:(PGMidiSource *)input midiReceived:(const MIDIPacketList *)list
{	
	//DLog(@"midi received..");
	const MIDIPacket *currentPacket = &list->packet[0];
	
	for (NSUInteger currentPacketIndex = 0; currentPacketIndex < list->numPackets; currentPacketIndex++)
	{
		for (NSUInteger currentByteIndex = 0; currentByteIndex < currentPacket->length; currentByteIndex++)
		{
			if(self.delegate)
			{
				unsigned char byteValue = currentPacket->data[currentByteIndex];
				
				if(byteValue & MD_MIDI_STATUS_ANY) // got status byte
				{
					uint8_t hiNib = byteValue & 0xf0;
					
					if(byteValue == MD_MIDI_STATUS_CLOCK) // check for realtime messages
					{
						//DLog(@"%@ got clock", self.source.name);
						if(self.softThruPassClock && self.softThruDestination)
						{
							//DLog(@"%@ passing clock", self.source.name);
							unsigned char byte = byteValue;
							[self.softThruDestination sendBytes:&byte size:1];
						}
					}
					else if(byteValue == MD_MIDI_STATUS_START) // check for realtime messages
					{
						//DLog(@"%@ got start", self.source.name);
						
						
						if(self.softThruPassStartStop && self.softThruDestination)
						{
							//DLog(@"%@ passing start", self.source.name);
							unsigned char byte = byteValue;
							[self.softThruDestination sendBytes:&byte size:1];
						}
					}
					else if(byteValue == MD_MIDI_STATUS_STOP) // check for realtime messages
					{
						//DLog(@"%@ got stop", self.source.name);
						if(self.softThruPassStartStop && self.softThruDestination)
						{
							//DLog(@"%@ passing stop", self.source.name);
							unsigned char byte = byteValue;
							[self.softThruDestination sendBytes:&byte size:1];
						}
					}
					else if(byteValue == MD_MIDI_STATUS_CONTINUE) // check for realtime messages
					{
						//DLog(@"%@ got continue", self.source.name);
						if(self.softThruPassStartStop && self.softThruDestination)
						{
							//DLog(@"%@ passing continue", self.source.name);
							unsigned char byte = byteValue;
							[self.softThruDestination sendBytes:&byte size:1];
						}
					}
					else if(byteValue == MD_MIDI_STATUS_ACTIVESENSE)
					{
						// handle activesense
					}
					else if(byteValue == MD_MIDI_STATUS_SYSEX_BEGIN)
					{
						//DLog(@"sysex receive begin");
						_receiveState = receiveState_Sysex;
						// discard sysex buffer
						sysexBufferIndex = 0;
						sysexBuffer[sysexBufferIndex++] = byteValue;
					}
					else if (_receiveState == receiveState_Sysex && byteValue == MD_MIDI_STATUS_SYSEX_END) // sysex end (expected)
					{
						_receiveState = receiveState_None;
						sysexBuffer[sysexBufferIndex++] = byteValue;
						NSUInteger sysexDataLength = sysexBufferIndex;
						sysexBufferIndex = 0;	
						if([self.delegate respondsToSelector:@selector(midiReceivedSysexData:fromSource:)])
						{
							@autoreleasepool
							{
								NSData *d = [NSData dataWithBytes:&sysexBuffer length:sysexDataLength];
								[self.delegate midiReceivedSysexData:d fromSource:self.source];
							}
						}
					}
					else if (byteValue == MD_MIDI_STATUS_SYSEX_END) // unexpected sysex end (haven't started sysex receive)
					{
						;
					}
					else if (hiNib == MD_MIDI_STATUS_NOTE_ON)
					{
						_receiveState = receiveState_NoteOn;
						noteOnBufferIndex = 0;
						noteOnBuffer[noteOnBufferIndex++] = byteValue;
					}
					else if (hiNib == MD_MIDI_STATUS_NOTE_OFF)
					{
						_receiveState = receiveState_NoteOff;
						noteOffBufferIndex = 0;
						noteOffBuffer[noteOffBufferIndex++] = byteValue;
					}
					else if (hiNib == MD_MIDI_STATUS_CONTROL_CHANGE)
					{
						_receiveState = receiveState_ControlChange;
						ccBufferIndex = 0;
						ccBuffer[ccBufferIndex++] = byteValue;
					}
					else if (hiNib == MD_MIDI_STATUS_PROGRAM_CHANGE)
					{
						_receiveState = receiveState_ProgramChange;
						programChangeBufferIndex = 0;
						programChangeBuffer[programChangeBufferIndex++] = byteValue;
					}
					else if (hiNib == MD_MIDI_STATUS_AFTERTOUCH)
					{
						_receiveState = receiveState_Aftertouch;
						aftertouchBufferIndex = 0;
						aftertouchBuffer[aftertouchBufferIndex++] = byteValue;
					}
					else
					{
						/*
						NSString *type = @"unknown";
						uint8_t loNib = byteValue & 0x0f;
						if(hiNib == 0xD0) type = [NSString stringWithFormat:@"chan aftertouch @ chan %d", loNib];
						else if(hiNib == 0xE0) type = [NSString stringWithFormat:@"pitch wheel range %d", loNib];
						DLog(@"received unimplemented status byte: 0x%x type: %@", byteValue, type);
						 */
					}
				}
				else
				{
					if(_receiveState == receiveState_Sysex)
					{
						// fill buffer
						sysexBuffer[sysexBufferIndex++] = byteValue;
						if(sysexBufferIndex >= sysexBufferSize)
						{
							DLog(@"overflowing sysex buffer, cancelling sysex receive.");
							sysexBufferIndex = 0;
							_receiveState = receiveState_None;
						}
					}
					else if(_receiveState == receiveState_NoteOn)
					{
						//DLog(@"filling note on buffer..");
						noteOnBuffer[noteOnBufferIndex++] = byteValue;
						if(noteOnBufferIndex == 3)
						{
							_receiveState = receiveState_None;
							noteOnBufferIndex = 0;
							if((noteOnBuffer[2] & 0x7f) == 0 &&
							   [self.delegate respondsToSelector:@selector(midiReceivedNoteOff:fromSource:)]) // zero velocity note off
							{
								@autoreleasepool
								{
									MidiNoteOff *noteOff = [MidiNoteOff new];
									noteOff.channel = noteOnBuffer[0] & 0x0f;
									noteOff.note = noteOnBuffer[1] & 0x7f;
									noteOff.velocity = noteOnBuffer[2] & 0x7f;
									[self.delegate midiReceivedNoteOff:noteOff fromSource:self.source];
								}
							}
							else if([self.delegate respondsToSelector:@selector(midiReceivedNoteOn:fromSource:)])
							{
								@autoreleasepool
								{
									MidiNoteOn *noteOn = [MidiNoteOn new];
									noteOn.channel = noteOnBuffer[0] & 0x0f;
									noteOn.note = noteOnBuffer[1] & 0x7f;
									noteOn.velocity = noteOnBuffer[2] & 0x7f;
									[self.delegate midiReceivedNoteOn:noteOn fromSource:self.source];
								}
							}
						}
					}
					else if(_receiveState == receiveState_NoteOff)
					{
						//DLog(@"filling note on buffer..");
						noteOffBuffer[noteOffBufferIndex++] = byteValue;
						if(noteOffBufferIndex == 3)
						{
							_receiveState = receiveState_None;
							noteOffBufferIndex = 0;
							if([self.delegate respondsToSelector:@selector(midiReceivedNoteOff:fromSource:)])
							{
								@autoreleasepool
								{
									MidiNoteOff *noteOff = [MidiNoteOff new];
									noteOff.channel = noteOffBuffer[0] & 0x0f;
									noteOff.note = noteOffBuffer[1] & 0x7f;
									noteOff.velocity = noteOffBuffer[2] & 0x7f;
									[self.delegate midiReceivedNoteOff:noteOff fromSource:self.source];
								}
							}
						}
					}
					else if(_receiveState == receiveState_ControlChange)
					{
						ccBuffer[ccBufferIndex++] = byteValue;
						if(ccBufferIndex == 3)
						{
							_receiveState = receiveState_None;
							ccBufferIndex = 0;
							if([self.delegate respondsToSelector:@selector(midiReceivedControlChange:fromSource:)])
							{
								@autoreleasepool
								{
									MidiControlChange *cc = [MidiControlChange new];
									cc.channel = ccBuffer[0] & 0x0f;
									cc.parameter = ccBuffer[1] & 0x7f;
									cc.ccValue = ccBuffer[2] & 0x7f;
									[self.delegate midiReceivedControlChange:cc fromSource:self.source];
								}
							}
						}
					}
					else if(_receiveState == receiveState_ProgramChange)
					{
						programChangeBuffer[programChangeBufferIndex++] = byteValue;
						if(programChangeBufferIndex == 2)
						{
							_receiveState = receiveState_None;
							programChangeBufferIndex = 0;
							if([self.delegate respondsToSelector:@selector(midiReceivedProgramChange:fromSource:)])
							{
								@autoreleasepool
								{
									MidiProgramChange *pc = [MidiProgramChange new];
									pc.channel = programChangeBuffer[0] & 0x0f;
									pc.program = programChangeBuffer[1] & 0x7f;
									[self.delegate midiReceivedProgramChange:pc fromSource:self.source];
								}
							}
						}
					}
					else if(_receiveState == receiveState_Aftertouch)
					{
						//DLog(@"filling note on buffer..");
						aftertouchBuffer[aftertouchBufferIndex++] = byteValue;
						if(aftertouchBufferIndex == 3)
						{
							_receiveState = receiveState_None;
							aftertouchBufferIndex = 0;
							if([self.delegate respondsToSelector:@selector(midiReceivedAftertouch:fromSource:)])
							{
								@autoreleasepool
								{
									MidiAftertouch *aftertouch = [MidiAftertouch new];
									aftertouch.channel = aftertouchBuffer[0] & 0x0f;
									aftertouch.note = aftertouchBuffer[1] & 0x7f;
									aftertouch.pressure = aftertouchBuffer[2] & 0x7f;
									[self.delegate midiReceivedAftertouch:aftertouch fromSource:self.source];
								}
							}
						}
					}
				}
			}
		}
		currentPacket = MIDIPacketNext(currentPacket);
	}
}

@end

@implementation MidiNoteOn
@end

@implementation MidiNoteOff
@end

@implementation MidiControlChange
@end

@implementation MidiAftertouch
@end

@implementation MidiProgramChange
@end
