//
//  A4PerformanceMacroSequencer.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 13/02/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import "A4PerformanceMacroSequencer.h"
#import "PGMidi.h"
#import "MDMIDI.h"
#import "MDConstants.h"
#import "A4ControllerdataHandler.h"

typedef struct SeqCC
{
	MidiControlChange cc;
	BOOL armed;
}
SeqCC;

typedef struct SequencerStep
{
	SeqCC seqCC[10];
	BOOL armed;
	BOOL held;
}
SequencerStep;

typedef struct Sequence
{
	SequencerStep steps[16];
}
Sequence;

uint8_t nextStep()
{
	static uint8_t step = 0;
	uint8_t s = step;
	step++; if(step == 16) step = 0;
	return s;
}

@interface A4PerformanceMacroSequencer() <PGMidiDelegate, MidiInputDelegate, A4ControllerdataHandlerDelegate>
@property (nonatomic) Sequence *sequence;
@property (nonatomic) uint8_t internalStep;
@property (nonatomic) int clock;
@property (nonatomic) BOOL running;
@property (nonatomic, strong) A4ControllerdataHandler *controllerHandler;
@end

@implementation A4PerformanceMacroSequencer

- (void)midiDestinationAdded:(PGMidiDestination *)destination{}
- (void)midiDestinationRemoved:(PGMidiDestination *)destination{}
- (void)midiSourceRemoved:(PGMidiSource *)source{}

- (void)midiSourceAdded:(PGMidiSource *)source
{
	if(source == [[MDMIDI sharedInstance] a4MidiSource])
	{
		source.parser.interpolateClock = YES;
		source.parser.interpolationDivisions = 16;
	}
}


- (void)a4ControllerdataHandler:(A4ControllerdataHandler *)handler performanceKnob:(uint8_t)knob didChangeValue:(uint8_t)value
{
	static uint8_t knobControllerMap[] =
	{ 3, 4, 8, 9,11,
	 64,65,66,67,68};
	
	if(_recording)
	{
		uint8_t controller = knobControllerMap[knob];
		MidiControlChange cc;
		cc.channel = handler.performanceChannel;
		cc.parameter = controller;
		cc.value = value;
		
		uint8_t s = _tracking ? _internalStep : _nonTrackingStep;
		SequencerStep *step = &_sequence->steps[s];
		SeqCC *seqcc = &step->seqCC[knob];
		seqcc->cc = cc;
		seqcc->armed = YES;
	}
	else
	{
		uint8_t controller = knobControllerMap[knob];
		MidiControlChange cc;
		cc.channel = handler.performanceChannel;
		cc.parameter = controller;
		cc.value = value;
		
		for (int i = 0; i < 16; i++)
		{
			SequencerStep *step = &_sequence->steps[i];
			if(step->held)
			{
				SeqCC *seqcc = &step->seqCC[knob];
				seqcc->cc = cc;
				seqcc->armed = YES;
			}
		}
	}
	
	[self.delegate a4PerformanceMacroSequencer:self peformanceKnob:knob changedValue:value];
}

- (id)init
{
	if(self = [super init])
	{
		[[MDMIDI sharedInstance] addObserverForMidiInputParserEvents:self];
		[[MDMIDI sharedInstance] addObserverForMidiConnectionEvents:self];
		
		MidiInputParser *parser = [[[MDMIDI sharedInstance] a4MidiSource] parser];
		parser.interpolateClock = YES;
		parser.interpolationDivisions = 16;
		
		self.controllerHandler = [A4ControllerdataHandler controllerdataHandlerWithDelegate:self];
		self.controllerHandler.enabled = YES;
		self.controllerHandler.performanceChannel = 7;
		self.sequence = calloc(1, sizeof(Sequence));
		
		for (int i = 0; i < 16; i++)
		{
			self.sequence->steps[i].armed = YES;
		}
		
		_tracking = YES;
	}
	return self;
}

- (void)dealloc
{
	free(self.sequence);
}

- (void) reset
{
	_clock = 0;
	_internalStep = 0;
}

- (void)clearAll
{
	memset(self.sequence, 0, sizeof(Sequence));
	for (int i = 0; i < 16; i++)
	{
		self.sequence->steps[i].armed = YES;
	}
}

- (void)setNonTrackingStep:(uint8_t)nonTrackingStep
{
	[self setNonTrackingStep:nonTrackingStep trigger:YES];
}

- (void)setNonTrackingStep:(uint8_t)nonTrackingStep trigger:(BOOL)trigger
{
	nonTrackingStep = MIN(nonTrackingStep, 15);
	_nonTrackingStep = nonTrackingStep;
	if(!_tracking && !_recording && trigger)
	{
		SequencerStep sequencerStep = _sequence->steps[_nonTrackingStep];
		
		printf("-- sending manual scene %d --\n", nonTrackingStep);
		for (int i = 0; i < 10; i++)
		{
			SeqCC seqCC = sequencerStep.seqCC[i];
			if(seqCC.armed)
			{
				MidiControlChange cc = seqCC.cc;
				printf("sending cc %03d val %03d\n", cc.parameter, cc.value);
				[[[MDMIDI sharedInstance] a4MidiDestination] sendControlChange:cc];
			}
		}
	}
}

- (void)setStep:(int)idx active:(BOOL)active
{
	if(idx < 0 || idx > 15) return;
	self.sequence->steps[idx].armed = active;
}

- (BOOL)stepIsActive:(int)idx
{
	if(idx < 0 || idx > 15) return NO;
	return self.sequence->steps[idx].armed;
}

- (BOOL)stepHasArmedControllers:(int)idx
{
	if(idx < 0 || idx > 15) return NO;
	SequencerStep step = _sequence->steps[idx];
	for(int i = 0; i < 10; i++)
	{
		if(step.seqCC[i].armed) return YES;
	}
	return NO;
}

- (uint8_t)trackingStep
{
	return _internalStep;
}

- (void)holdStep:(int)idx
{
	if(idx < 0 || idx > 15) return;
	_sequence->steps[idx].held = YES;
}

- (void)releaseStep:(int)idx
{
	if(idx < 0 || idx > 15) return;
	_sequence->steps[idx].held = NO;
}

- (void)clearStep:(int)idx
{
	if(idx < 0 || idx > 15) return;
	SequencerStep *sequencerStep = &_sequence->steps[idx];
	for (int i = 0; i < 10; i++)
	{
		sequencerStep->seqCC[i].armed = NO;
	}
}

- (void)midiReceivedClockFromSource:(PGMidiSource *)source
{
	[self handleTick];
}

- (void)midiReceivedClockInterpolationFromSource:(PGMidiSource *)source
{
	[self handleTick];
}

- (void) handleTick
{
	if(_running)
	{
		if(_clock % (6*16) == 0)
		{
			if(_tracking)
			{
				[self.delegate a4PerformanceMacroSequencer:self didAdvanceToStep:_internalStep];
				
				if(_clearing)
				{
					[self clearStep:_internalStep];
				}
				
				SequencerStep sequencerStep = _sequence->steps[_internalStep];
				if(sequencerStep.armed)
				{
					for (int i = 0; i < 10; i++)
					{
						SeqCC seqCC = sequencerStep.seqCC[i];
						if(seqCC.armed)
						{
							MidiControlChange cc = seqCC.cc;
							printf("sending cc %03d val %03d\n", cc.parameter, cc.value);
							[[[MDMIDI sharedInstance] a4MidiDestination] sendControlChange:cc];
						}
					}
				}
			}
			
			
			_internalStep++;
			if(_internalStep == 16) _internalStep = 0;
		}
		
		_clock++;
		if(_clock == 16*6*16) _clock = 0;
	}
}

- (void)midiReceivedTransport:(uint8_t)transport fromSource:(PGMidiSource *)source
{
	switch (transport)
	{
		case MD_MIDI_RT_START:
		{
    		[self reset];
			_running = YES;
			[self.delegate a4PerformanceMacroSequencerDidStart:self];
			[self handleTick];
    		break;
		}
		case MD_MIDI_RT_CONTINUE:
		{
    		_running = YES;
			[self.delegate a4PerformanceMacroSequencer:self didContinueAtStep:_internalStep];
			[self handleTick];
    		break;
		}
		case MD_MIDI_RT_STOP:
		{
			[self.delegate a4PerformanceMacroSequencerDidStop:self];
    		_running = NO;
    		break;
		}
		default:
		{
    		break;
		}
	}
}

@end
