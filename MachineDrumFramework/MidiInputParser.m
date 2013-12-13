//
//  MidiInputParser.m
//  PGMidiTest
//
//  Created by Jakob Penca on 8/25/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MidiInputParser.h"
#import "MDConstants.h"
#import <mach/mach_time.h>
#import <QuartzCore/QuartzCore.h>
#import "A4Queues.h"


#define kMidiInputParserBufferSize (1024*1024)

@interface MidiInputParser()
{
	uint8_t *_buffer;
	NSUInteger _idx;
	uint8_t _status;
	dispatch_source_t interpolationTimer;
	uint64_t lastNanos;
	double lastTime;
	NSUInteger interpolationDivisionCount;
	NSUInteger clockCount;
	BOOL interpolationTimerIsSuspended;
}
@end


@implementation MidiInputParser

- (id)init
{
	if(self = [super init])
	{
		_buffer = calloc(kMidiInputParserBufferSize, 1);
		_interpolationDivisions = 16;
	}
	return self;
}

- (void)dealloc
{
	free(_buffer);
	if(interpolationTimer != NULL)
	{
		if(!interpolationTimerIsSuspended) dispatch_suspend(interpolationTimer);
		dispatch_source_cancel(interpolationTimer);
		dispatch_release(interpolationTimer);
	}
}

static inline uint64_t convertTimestampToNanoseconds(uint64_t time)
{
    static mach_timebase_info_data_t s_timebase_info;
	
    if (s_timebase_info.denom == 0)
    {
        (void) mach_timebase_info(&s_timebase_info);
    }

    return (uint64_t)((time * s_timebase_info.numer) / (s_timebase_info.denom));
}

dispatch_source_t CreateDispatchTimer(uint64_t interval,
									  uint64_t leeway,
									  dispatch_queue_t queue,
									  dispatch_block_t block)
{
	dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                                     0, 0, queue);
	if (timer)
	{
		dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval), interval, leeway);
		dispatch_source_set_event_handler(timer, block);
		dispatch_resume(timer);
		dispatch_retain(timer);
	}
	return timer;
}


- (void)setInterpolateClock:(BOOL)interpolateClock
{
	_interpolateClock = interpolateClock;
	if(!_interpolateClock && interpolationTimer)
	{
		dispatch_source_cancel(interpolationTimer);
		interpolationTimer = NULL;
	}
}

- (void) handleClockWithTimestamp:(MIDITimeStamp)timestamp
{
	if(interpolationTimer && !interpolationTimerIsSuspended)
	{
		dispatch_source_cancel(interpolationTimer);
		dispatch_suspend(interpolationTimer);
		interpolationTimerIsSuspended = YES;
	}
	
	if(! _interpolateClock && interpolationTimer != NULL)
	{
		interpolationTimer = NULL;
	}
	
	if(_interpolateClock && _interpolationDivisions > 1)
	{
		int numberOfMissedClocks = _interpolationDivisions - interpolationDivisionCount-1;
		
		if(numberOfMissedClocks)
		{
			for (int i = 0; i < numberOfMissedClocks; i++)
			{
				if(interpolationDivisionCount >= _interpolationDivisions) break;
				interpolationDivisionCount++;
				/*
				double nanos = convertTimestampToNanoseconds(mach_absolute_time());
				double delta = nanos - lastNanosInterpolated;
				lastNanosInterpolated = nanos;
				 */
//				printf("inter: %d\n", interpolationDivisionCount);
				if([_delegate respondsToSelector:@selector(midiReceivedClockInterpolationFromSource:)])[ _delegate midiReceivedClockInterpolationFromSource:_source];
			}
		}
		
		uint64_t nanos = convertTimestampToNanoseconds(timestamp);
		
		if(lastNanos != 0)
		{
			uint64_t delta = nanos - lastNanos;
			delta /= _interpolationDivisions;
			
			if(interpolationTimer == NULL)
			{
				dispatch_source_t timer = CreateDispatchTimer(delta, 0, [A4Queues realtimeQueue], ^{
					
					[self handleInterpolationTimer];
					
				});
				
				if(timer) interpolationTimer = timer;
			}
			else
			{
				if(interpolationTimerIsSuspended) dispatch_resume(interpolationTimer);
				interpolationTimerIsSuspended = NO;
				dispatch_source_set_timer(interpolationTimer, dispatch_time(DISPATCH_TIME_NOW, delta), delta, 0);
			}
		}
		
		lastNanos = nanos;
		interpolationDivisionCount = 0;
	}

	if(_delegate)[ _delegate midiReceivedClockFromSource:_source];
}

- (void)setInterpolationDivisions:(NSUInteger)interpolationDivisions
{
	if(interpolationDivisions < 1) return;
	_interpolationDivisions = interpolationDivisions;
}

- (void) handleInterpolationTimer
{
	if(interpolationTimerIsSuspended) return;
	interpolationDivisionCount++;
	if(interpolationDivisionCount >= _interpolationDivisions) return;
	if([_delegate respondsToSelector:@selector(midiReceivedClockInterpolationFromSource:)])[ _delegate midiReceivedClockInterpolationFromSource:_source];
	
	/*
	double nanos = convertTimestampToNanoseconds(mach_absolute_time());
	double delta = nanos - lastNanosInterpolated;
	lastNanosInterpolated = nanos;
	 */
//	printf("inter: %d\n", interpolationDivisionCount);
}

- (void)midiSource:(PGMidiSource *)input midiReceived:(const MIDIPacketList *)list
{
	if(_delegate)
	{
		const MIDIPacket *currentPacket = &list->packet[0];
		
		for (NSUInteger currentPacketIndex = 0; currentPacketIndex < list->numPackets; currentPacketIndex++)
		{
			for (NSUInteger currentByteIndex = 0; currentByteIndex < currentPacket->length; currentByteIndex++)
			{
				uint8_t byteValue = currentPacket->data[currentByteIndex];
				
				if(byteValue & MD_MIDI_STATUS_ANY) // got status byte
				{
					if(byteValue >= (uint8_t) MD_MIDI_RT_CLOCK) // realtime status
					{
						if(byteValue == MD_MIDI_RT_CLOCK) // check for realtime messages
						{
							if(_softThruPassClock && _softThruDestination)
							{
								unsigned char byte = byteValue;
								[_softThruDestination sendBytes:&byte size:1];
							}
							
							MIDITimeStamp timeStamp = currentPacket->timeStamp;
							dispatch_async([A4Queues realtimeQueue], ^{
								
								@synchronized(self)
								{
									if([_delegate respondsToSelector:@selector(midiReceivedClockFromSource:)])
									{
										[self handleClockWithTimestamp:timeStamp];
									}
								}
								
							});
							
						}
						else if(byteValue == MD_MIDI_RT_START) // check for realtime messages
						{
//							DLog(@"%@ got start", self.source.name);
							
							if(_softThruPassStartStop && _softThruDestination)
							{
								//DLog(@"%@ passing start", self.source.name);
								unsigned char byte = byteValue;
								[_softThruDestination sendBytes:&byte size:1];
							}
							
							dispatch_async([A4Queues realtimeQueue], ^{
								
								if([_delegate respondsToSelector:@selector(midiReceivedTransport:fromSource:)])
								{
									[_delegate midiReceivedTransport:byteValue fromSource:_source];
								}
							});
						}
						else if(byteValue == MD_MIDI_RT_STOP) // check for realtime messages
						{
//							DLog(@"%@ got stop", self.source.name);
							if(_softThruPassStartStop && _softThruDestination)
							{
								//DLog(@"%@ passing stop", self.source.name);
								unsigned char byte = byteValue;
								[_softThruDestination sendBytes:&byte size:1];
							}
							
							dispatch_async([A4Queues realtimeQueue], ^{
								
								if([_delegate respondsToSelector:@selector(midiReceivedTransport:fromSource:)])
								{
									[_delegate midiReceivedTransport:byteValue fromSource:_source];
								}
								
							});
							
							
						}
						else if(byteValue == MD_MIDI_RT_CONTINUE) // check for realtime messages
						{
//							DLog(@"%@ got continue", self.source.name);
							if(_softThruPassStartStop && _softThruDestination)
							{
								//DLog(@"%@ passing continue", self.source.name);
								unsigned char byte = byteValue;
								[_softThruDestination sendBytes:&byte size:1];
							}
							
							dispatch_async([A4Queues realtimeQueue], ^{
								
								if([_delegate respondsToSelector:@selector(midiReceivedTransport:fromSource:)])
								{
									[_delegate midiReceivedTransport:byteValue fromSource:_source];
								}
								
							});
						}
						else if(byteValue == MD_MIDI_RT_ACTIVESENSE)
						{
							// handle activesense
						}
					}
					else
					{
						if(byteValue != MD_MIDI_STATUS_SYSEX_END){ _idx = 0; _status = byteValue & 0xF0;}
						_buffer[_idx++] = byteValue;
						
						if (_status == MD_MIDI_STATUS_SYSEX_BEGIN && byteValue == MD_MIDI_STATUS_SYSEX_END) // sysex end (expected)
						{
							_status = MD_MIDI_STATUS_SYSEX_END;
							NSUInteger sysexDataLength = _idx;
							
							@autoreleasepool
							{
								NSData *d = [NSData dataWithBytes:_buffer length:sysexDataLength];
								dispatch_async([A4Queues sysexQueue], ^{
									
									if([_delegate respondsToSelector:@selector(midiReceivedSysexData:fromSource:)])
									{
										[self.delegate midiReceivedSysexData:d fromSource:self.source];
									}
											   
								});
							}
						}
					}
				}
				else
				{
					_buffer[_idx++] = byteValue;
					
					if(_status != MD_MIDI_STATUS_SYSEX_BEGIN)
					{
						if(_idx == 2)
						{
							switch(_status)
							{
								case MD_MIDI_STATUS_PROGRAM_CHANGE:
								{
									MidiProgramChange pc;
									pc.channel = _buffer[0] & 0x0f;
									pc.program = _buffer[1] & 0x7f;
									
									dispatch_async([A4Queues voiceQueue], ^{
										
										if([_delegate respondsToSelector:@selector(midiReceivedProgramChange:fromSource:)])
										{
											[_delegate midiReceivedProgramChange:pc fromSource:self.source];
										}
										
									});
									break;
								}
								case MD_MIDI_STATUS_CHANNEL_PRESSURE:
								{
									MidiChannelPressure pressure;
									pressure.channel =	_buffer[0] & 0x0f;
									pressure.pressure = _buffer[1] & 0x7f;
									
									dispatch_async([A4Queues voiceQueue], ^{
										
										if([_delegate respondsToSelector:@selector(midiReceivedChannelPressure:fromSource:)])
										{
											[_delegate midiReceivedChannelPressure: pressure fromSource:self.source];
										}
										
									});
									break;
								}
								default: break;
							}
						}
						else if (_idx == 3)
						{
							switch(_status)
							{
								case MD_MIDI_STATUS_NOTE_ON:
								{
									
									MidiNoteOn noteOn;
									noteOn.channel = _buffer[0] & 0x0f;
									noteOn.note = _buffer[1] & 0x7f;
									noteOn.velocity = _buffer[2] & 0x7f;
									
									
									dispatch_async([A4Queues voiceQueue], ^{
										
										if([_delegate respondsToSelector:@selector(midiReceivedNoteOn:fromSource:)])
										{
											
											[_delegate midiReceivedNoteOn:noteOn fromSource:self.source];
										}
										
									});
									break;
								}
								case MD_MIDI_STATUS_NOTE_OFF:
								{
									MidiNoteOff noteOff;
									noteOff.channel =	_buffer[0] & 0x0f;
									noteOff.note =		_buffer[1] & 0x7f;
									noteOff.velocity =	_buffer[2] & 0x7f;
									
									dispatch_async([A4Queues voiceQueue], ^{
										
										if([_delegate respondsToSelector:@selector(midiReceivedNoteOff:fromSource:)])
										{
											
											[_delegate midiReceivedNoteOff:noteOff fromSource:self.source];
										}
				
									});
									break;
								}
								case MD_MIDI_STATUS_CONTROL_CHANGE:
								{
									MidiControlChange cc;
									cc.channel =	_buffer[0] & 0x0f;
									cc.parameter =	_buffer[1] & 0x7f;
									cc.value =		_buffer[2] & 0x7f;
									
									dispatch_async([A4Queues voiceQueue], ^{
										
										if([_delegate respondsToSelector:@selector(midiReceivedControlChange:fromSource:)])
										{
											
											[_delegate midiReceivedControlChange:cc fromSource:self.source];
										}
										
									});
									break;
								}
								case MD_MIDI_STATUS_AFTERTOUCH:
								{
									MidiAftertouch aftertouch;
									aftertouch.channel =	_buffer[0] & 0x0f;
									aftertouch.note =		_buffer[1] & 0x7f;
									aftertouch.pressure =	_buffer[2] & 0x7f;
									
									dispatch_async([A4Queues voiceQueue], ^{
										
										if([_delegate respondsToSelector:@selector(midiReceivedAftertouch:fromSource:)])
										{
											
											[_delegate midiReceivedAftertouch:aftertouch fromSource:self.source];
										}
										
									});
									break;
								}
								case MD_MIDI_STATUS_PITCH_WHEEL:
								{
									MidiPitchWheel pw;
									pw.channel = _buffer[0] & 0x0f;
									UInt16 pitch = (_buffer[2] & 0x7F) << 7 | (_buffer[1] & 0x7F);
									pw.pitch = pitch;
									
									dispatch_async([A4Queues voiceQueue], ^{
										
										if([_delegate respondsToSelector:@selector(midiReceivedPitchWheel:fromSource:)])
										{
											[_delegate midiReceivedPitchWheel:pw fromSource:self.source];
										}
										
									});
									break;
								}
								default: break;
							}
						}
					}
					if (_idx == kMidiInputParserBufferSize)
					{
						_status = 0;
						_idx = 0;
					}
				}
			}
			currentPacket = MIDIPacketNext(currentPacket);
		}
		
	}
}

@end
