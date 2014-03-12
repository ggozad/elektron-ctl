//
//  A4PerformanceMacroHandler.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 21/11/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4ControllerdataHandler.h"
#import "MDMIDI.h"
#import "A4Params.h"

@interface A4ControllerdataHandler ()
{
	uint8_t *NRPNBuf;
	uint8_t lastNRPNChannel;
	uint8_t nextExpectedControllerParam;
	uint8_t performanceCCKnob, performanceCCValue;
}
@end


@implementation A4ControllerdataHandler

- (void) dealWithPerformanceMacroCC
{
	[self.delegate a4ControllerdataHandler:self performanceKnob:performanceCCKnob didChangeValue:performanceCCValue];
}

- (void) dealWithNRPN
{
	if( NRPNBuf[0] == 0 && lastNRPNChannel == _performanceChannel)
	{
		if([_delegate respondsToSelector:@selector(a4ControllerdataHandler:performanceKnob:didChangeValue:)])
			[_delegate a4ControllerdataHandler:self performanceKnob:NRPNBuf[1] didChangeValue:NRPNBuf[2]];
	}
	else if (NRPNBuf[0] == 1 && NRPNBuf[1] == 101)
	{
		if([_delegate respondsToSelector:@selector(a4ControllerdataHandler:track:wasMuted:)])
			[self.delegate a4ControllerdataHandler:self track:lastNRPNChannel wasMuted:NRPNBuf[2]];
	}
	else
	{
		if(NRPNBuf[0] == 1 && lastNRPNChannel < 4)
		{
			uint8_t param = A4ParamForNRPN(NRPNBuf[1]);
			if(param != A4NULL)
			{
				A4PVal pval;
				pval.param = param;
				pval.coarse = NRPNBuf[2];
				pval.fine = NRPNBuf[3];
				
				if([_delegate respondsToSelector:@selector(a4ControllerdataHandler:track:synthParamChanged:)])
					[_delegate a4ControllerdataHandler:self track:lastNRPNChannel synthParamChanged:pval];
			}
		}
		else if (NRPNBuf[0] == 2 && lastNRPNChannel == 4)
		{
			uint8_t param = A4ParamFXForNRPN(NRPNBuf[1]);
			if(param != A4NULL)
			{
				A4PVal pval;
				pval.param = param;
				pval.coarse = NRPNBuf[2];
				pval.fine = NRPNBuf[3];
				
				if([_delegate respondsToSelector:@selector(a4ControllerdataHandler:FXParamChanged:)])
					[_delegate a4ControllerdataHandler:self FXParamChanged:pval];
			}
		}
	}
}

- (void)midiReceivedControlChange:(MidiControlChange)controlChange fromSource:(PGMidiSource *)source
{
	printf("cc chn: %d ctrl: %d val: %d\n", controlChange.channel, controlChange.parameter, controlChange.value);
	
	if(source == [[MDMIDI sharedInstance] a4MidiSource])
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
					lastNRPNChannel = controlChange.channel;
					[self dealWithNRPN];
				}
				break;
			}
			
			default:
				break;
		}
		
		if(controlChange.channel == _performanceChannel)
		{
			switch (controlChange.parameter)
			{
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
					
				default: break;
			}
		}
		else
		{
			if(controlChange.channel < 6 && controlChange.parameter == 94)
			{
				if([_delegate respondsToSelector:@selector(a4ControllerdataHandler:track:wasMuted:)])
					[_delegate a4ControllerdataHandler:self track:controlChange.channel wasMuted:controlChange.value];
			}
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
	[[MDMIDI sharedInstance] removeObserverForMidiInputParserEvents:self];
	free(NRPNBuf);
}

- (void)setPerformanceChannel:(uint8_t)performanceChannel
{
	if(performanceChannel < 16) _performanceChannel = performanceChannel;
}

+ (instancetype)controllerdataHandlerWithDelegate:(id<A4ControllerdataHandlerDelegate>)delegate
{
	A4ControllerdataHandler *handler = [self new];
	[[MDMIDI sharedInstance] addObserverForMidiInputParserEvents:handler];
	handler.delegate = delegate;
	handler.enabled = YES;
	
	return handler;
}

@end
