//
//  A4MidiSequencer.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 09/11/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4MidiSequencer.h"
#import "MDConstants.h"
#import "A4Timepiece.h"

@interface A4MidiSequencer()
@property (nonatomic) uint8_t *outputChannels;
@property (nonatomic) BOOL *holdingNote;
@property (nonatomic) MidiNoteOn *noteOn;
@end

@implementation A4MidiSequencer

- (void)midiDestinationAdded:(PGMidiDestination *)destination
{
	
}

- (void)midiSourceAdded:(PGMidiSource *)source
{
	
}

- (void)midiDestinationRemoved:(PGMidiDestination *)destination
{
	
}

- (void)midiSourceRemoved:(PGMidiSource *)source
{
	
}

- (void)midiReceivedProgramChange:(MidiProgramChange)programChange fromSource:(PGMidiSource *)source
{
//	DLog(@"lul?");
	if(source == _inputDevice)
	{
//		DLog(@"lul! %d", programChange.program);
		A4SequencerMode mode = A4SequencerModeQueue;
		if(!self.playing) mode = A4SequencerModeJump;
		[self setPattern:[self.project patternAtPosition:programChange.program] mode:mode];
		[self.delegate a4MidiSequencer:self didReceiveProgramChange:programChange];
	}
}

- (void)midiReceivedTransport:(uint8_t)transport fromSource:(PGMidiSource *)source
{
	if(source != _inputDevice) return;
	
	switch (transport)
	{
		case MD_MIDI_RT_CONTINUE:
		{
			[self continue];
			break;
		}
		case MD_MIDI_RT_START:
		{
			[self start];
			break;
		}
		case MD_MIDI_RT_STOP:
		{
			[self stop];
			break;
		}
		default:
			break;
	}
}


- (void)midiReceivedClockFromSource:(PGMidiSource *)source
{
	if(source != _inputDevice) return;
	[self handleClock];
}

- (void) midiReceivedClockInterpolationFromSource:(PGMidiSource *)source
{
	if(source != _inputDevice) return;
	[self handleClock];
}

- (void) handleClock
{
	@synchronized(self)
	{
		[self clockTick];
	}
}

/*
- (void)a4SequencerTrack:(A4SequencerTrack *)sequencerTrack didOpenGateWithTrig:(A4Trig)trig step:(uint8_t)step context:(TrigContext)ctxt
{
	if(_outputDevice)
	{
		
		uint8_t trackIdx = sequencerTrack.trackIdx;
		if(_holdingNote[trackIdx])
		{
			MidiNoteOn on = _noteOn[trackIdx];
			on.velocity = 0;
			[_outputDevice sendNoteOn:on];
		}
		
		_noteOn[trackIdx].channel = _outputChannels[trackIdx];
		_noteOn[trackIdx].note = trig.note;
		_noteOn[trackIdx].velocity = trig.velocity;
		_holdingNote[trackIdx] = YES;
		MidiNoteOn on = _noteOn[trackIdx];
		[_outputDevice sendNoteOn:on];
	}

//	[super a4SequencerTrack:sequencerTrack didOpenGateWithTrig:trig step:step context:ctxt];
}

- (void)a4SequencerTrack:(A4SequencerTrack *)sequencerTrack didCloseGateWithTrig:(A4Trig)trig step:(uint8_t)step context:(TrigContext)ctxt
{	
	if(_outputDevice)
	{
		
		uint8_t trackIdx = sequencerTrack.trackIdx;
		_holdingNote[trackIdx] = NO;
		
		MidiNoteOn on;
		on.channel = _outputChannels[trackIdx];
		on.note = trig.note;
		on.velocity = 0;
		
		[_outputDevice sendNoteOn:on];
	}
	
//	[super a4SequencerTrack:sequencerTrack didCloseGateWithTrig:trig step:step context:ctxt];
}
 */

- (void)setOutputDevice:(PGMidiDestination *)outputDevice
{
	if(outputDevice != _outputDevice)
	{
		if(_outputDevice && self.playing)
		{
			for(int i = 0; i < 6; i++)
			{
				if(_holdingNote[i])
				{
					_noteOn[i].velocity = 0;
					[_outputDevice sendNoteOn:_noteOn[i]];
					_holdingNote[i] = NO;
				}
				i++;
			}
		}
		_outputDevice = outputDevice;
	}
}

- (void)setInputDevice:(PGMidiSource *)inputDevice
{
	if(inputDevice != _inputDevice)
	{
		if(inputDevice == nil && self.playing)
		{
			[self stop];
		}
		_inputDevice = inputDevice;
		self.clockInterpolationFactor = _inputDevice.parser.interpolationDivisions;
	}
}

+ (instancetype)sequencerWithDelegate:(id<A4MidiSequencerDelegate>)delegate
						 outputDevice:(PGMidiDestination *)dst
						  inputDevice:(PGMidiSource *)src
{
	A4MidiSequencer *sequencer = [self sequencerWithDelegate:delegate];
	sequencer.outputDevice = dst;
	sequencer.inputDevice = src;
	
	for(int i = 0; i < 6; i++)
	{
		sequencer.outputChannels[i] = i;
	}
	
	[[MDMIDI sharedInstance] addObserverForMidiConnectionEvents:sequencer];
	[[MDMIDI sharedInstance] addObserverForMidiInputParserEvents:sequencer];
	return sequencer;
}

- (void)setOutputChannel:(uint8_t)channel forTrack:(uint8_t)track
{
	if(track > 5 || channel > 15) return;
	
	if(_holdingNote[track])
	{
		MidiNoteOn on = _noteOn[track];
		on.velocity = 0;
		[_outputDevice sendNoteOn:on];
		_holdingNote[track] = NO;
	}
	
	_outputChannels[channel] = track;
}

- (uint8_t)outputChannelForTrack:(uint8_t)track
{
	if(track > 5) return A4NULL;
	return _outputChannels[track];
}

- (id)init
{
	if(self = [super init])
	{
		_outputChannels = calloc(6, sizeof(uint8_t));
		_noteOn = calloc(6, sizeof(MidiNoteOn));
		_holdingNote = calloc(6, sizeof(BOOL));
	}
	return self;
}

- (void)dealloc
{
	[[MDMIDI sharedInstance] removeObserverForMidiConnectionEvents:self];
	[[MDMIDI sharedInstance] removeObserverForMidiInputParserEvents:self];
	free(_outputChannels);
	free(_holdingNote);
	free(_noteOn);
}

@end
