//
//  A4PerformanceMacroHandler.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 21/11/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4ControllerdataHandler.h"
#import "MDMIDI.h"

@interface A4ControllerdataHandler ()
{
	uint8_t *NRPNBuf;
	uint8_t nextExpectedControllerParam;
	uint8_t performanceCCKnob, performanceCCValue;
}
@end


@implementation A4ControllerdataHandler

- (void) dealWithPerformanceMacroCC
{
	[self.delegate a4ControllerdataHandler:self knob:performanceCCKnob didChangeValue:performanceCCValue];
}

- (void) dealWithPerformanceMacroNRPN
{
	[self.delegate a4ControllerdataHandler:self knob:NRPNBuf[1] didChangeValue:NRPNBuf[2]];
}

- (void)midiReceivedControlChange:(MidiControlChange)controlChange fromSource:(PGMidiSource *)source
{
	if(source == self.inputSource && controlChange.channel == 0x07)
	{
		switch (controlChange.parameter)
		{
			case 0x63:
			{
				NRPNBuf[0] = controlChange.value;
				nextExpectedControllerParam = 0x62;
				break;
			}
			case 0x62:
			{
				if(nextExpectedControllerParam == 0x62)
				{
					NRPNBuf[1] = controlChange.value;
					nextExpectedControllerParam = 0x06;
				}
				break;
			}
			case 0x06:
			{
				if(nextExpectedControllerParam == 0x06)
				{
					NRPNBuf[2] = controlChange.value;
					nextExpectedControllerParam = 0x26;
				}
				break;
			}
			case 0x26:
			{
				if(nextExpectedControllerParam == 0x26)
				{
					NRPNBuf[3] = controlChange.value;
					[self dealWithPerformanceMacroNRPN];
				}
				break;
			}
			case 0x03:
			{
				performanceCCKnob = 0;
				performanceCCValue = controlChange.value;
				[self dealWithPerformanceMacroCC];
				break;
			}
			case 0x04:
			{
				performanceCCKnob = 1;
				performanceCCValue = controlChange.value;
				[self dealWithPerformanceMacroCC];
				break;
			}
			case 0x08:
			{
				performanceCCKnob = 2;
				performanceCCValue = controlChange.value;
				[self dealWithPerformanceMacroCC];
				break;
			}
			case 0x09:
			{
				performanceCCKnob = 3;
				performanceCCValue = controlChange.value;
				[self dealWithPerformanceMacroCC];
				break;
			}
			case 0x0B:
			{
				performanceCCKnob = 4;
				performanceCCValue = controlChange.value;
				[self dealWithPerformanceMacroCC];
				break;
			}
			case 0x40:
			{
				performanceCCKnob = 5;
				performanceCCValue = controlChange.value;
				[self dealWithPerformanceMacroCC];
				break;
			}
			case 0x41:
			{
				performanceCCKnob = 6;
				performanceCCValue = controlChange.value;
				[self dealWithPerformanceMacroCC];
				break;
			}
			case 0x42:
			{
				performanceCCKnob = 7;
				performanceCCValue = controlChange.value;
				[self dealWithPerformanceMacroCC];
				break;
			}
			case 0x43:
			{
				performanceCCKnob = 8;
				performanceCCValue = controlChange.value;
				[self dealWithPerformanceMacroCC];
				break;
			}
			case 0x44:
			{
				performanceCCKnob = 9;
				performanceCCValue = controlChange.value;
				[self dealWithPerformanceMacroCC];
				break;
			}
				
				
			default:
				break;
		}
	}
}

- (id)init
{
	if(self = [super init])
	{
		NRPNBuf = malloc(sizeof(uint8_t) * 4);
	}
	return self;
}

- (void)dealloc
{
	free(NRPNBuf);
}

- (void)setChannel:(uint8_t)channel
{
	if(channel < 16) _channel = channel;
}

- (void)setInputSource:(PGMidiSource *)inputSource
{
	if(inputSource != _inputSource)
	{
		if(_inputSource && inputSource == nil)
		{
			[[MDMIDI sharedInstance] removeObserverForMidiInputParserEvents:self];
		}
		else if (_inputSource == nil && inputSource)
		{
			[[MDMIDI sharedInstance] addObserverForMidiInputParserEvents:self];
		}
	}
	
	_inputSource = inputSource;
}

+ (instancetype)controllerdataHandlerWithDelegate:(id<A4ControllerdataHandlerDelegate>)delegate
									  inputSource:(PGMidiSource *)source channel:(uint8_t)channel
{
	A4ControllerdataHandler *handler = [self new];
	
	handler.delegate = delegate;
	handler.channel = channel;
	handler.inputSource = source;
	handler.enabled = YES;
	
	return handler;
}

@end
