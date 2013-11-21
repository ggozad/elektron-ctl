//
//  A4PolyMapper.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 7/10/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4PolyMapper.h"
#import "MDMachinedrumPublic.h"


static MidiNoteOn heldNotes[6];
static uint8_t heldNotesLen;
static const uint8_t heldNotesLenMax = 6;

static BOOL freeChannels[6];
static const uint8_t freeChannelsLen = 6;

@interface A4PolyMapper()
@property (nonatomic) int lastUsedChannelIndex;
@end


@implementation A4PolyMapper

- (void)setChannels:(NSArray *)channels
{
	[self clearAllHeldNotes];
	_channels = channels;
	_lastUsedChannelIndex = 0;
}

- (void)setMode:(A4PolyMapperMappingMode)mode
{
	[self clearAllHeldNotes];
	_lastUsedChannelIndex = 0;
	_mode = mode;
}

- (void)clearAllHeldNotes
{
	for (uint8_t i = 0; i < heldNotesLen; i++)
	{
		MidiNoteOn n = heldNotes[i];
		n.velocity = 0;
		[[[MDMIDI sharedInstance] a4MidiDestination] sendNoteOn:n];
		[self.delegate polyMapperDidSendNoteOn:n];
	}
	
	heldNotesLen = 0;
	
	for (uint8_t i = 0; i < 6; i++)
	{
		freeChannels[i] = YES;
	}
}

- (int) nextFreeChannel
{	
	int cnt = self.channels.count;
	DLog(@"num channels: %d", cnt);
	if(!cnt) return -1;
	int iter = 0;
	
//	if(_lastUsedChannelIndex == 5) _lastUsedChannelIndex = 0;
	
	while (iter < cnt)
	{
		DLog(@"loggins");
		iter++;
		int chnIndex = (_lastUsedChannelIndex++) % cnt;
		NSNumber *n = self.channels[chnIndex];
		int i = n.integerValue;
		if(freeChannels[i])
		{
			freeChannels[i] = NO;
			return i;
		}
		
	}
	
	return -1;
}

- (void)midiDestinationAdded:(PGMidiDestination *)destination{}
- (void)midiDestinationRemoved:(PGMidiDestination *)destination{}

- (void)midiSourceAdded:(PGMidiSource *)source
{
	[self clearAllHeldNotes];
}

- (void)midiSourceRemoved:(PGMidiSource *)source
{
	[self clearAllHeldNotes];
}

- (void)midiReceivedPitchWheel:(MidiPitchWheel)pw fromSource:(PGMidiSource *)source
{
	if(source == [[MDMIDI sharedInstance] externalInputSource] ||
	   source == [[MDMIDI sharedInstance] machinedrumMidiSource])
	{
		if(self.mode == A4PolyMapperMappingModeUnison ||
		   self.mode == A4PolyMapperMappingModePoly)
		{

			for (NSNumber *channel in self.channels)
			{
				pw.channel = [channel charValue];
				[[[MDMIDI sharedInstance] a4MidiDestination] sendPitchWheel:pw];
			}
		}
		else
		{
			[[[MDMIDI sharedInstance] a4MidiDestination] sendPitchWheel:pw];
		}
	}
}

- (void)midiReceivedNoteOn:(MidiNoteOn)noteOn fromSource:(PGMidiSource *)source
{
	if(source == [[MDMIDI sharedInstance] externalInputSource])
	{
		if(self.mode == A4PolyMapperMappingModeUnison)
		{
			for (NSNumber *n in self.channels)
			{
				noteOn.channel = [n charValue];
//				[self.heldNotes addObject:noteOn];
				[[[MDMIDI sharedInstance] a4MidiDestination] sendNoteOn:noteOn];
				[self.delegate polyMapperDidSendNoteOn:noteOn];
			}
		}
		else if(self.mode == A4PolyMapperMappingModeThru)
		{
			[[[MDMIDI sharedInstance] a4MidiDestination] sendNoteOn:noteOn];
			[self.delegate polyMapperDidSendNoteOn:noteOn];
		}
		else if(self.mode == A4PolyMapperMappingModePoly)
		{
			if(noteOn.velocity > 0) // it's a note on
			{
				if(!self.channels.count) return;
				
				DLog(@"got note on");
				int chan = [self nextFreeChannel]; // see if there's a free channel
				if(chan >= 0 && heldNotesLen < heldNotesLenMax) // there is a free channel
				{
					noteOn.channel = chan; // set the channel
					heldNotes[heldNotesLen++] = noteOn;
					[[[MDMIDI sharedInstance] a4MidiDestination] sendNoteOn:noteOn]; // pass it to a4
					[self.delegate polyMapperDidSendNoteOn:noteOn];
				}
				else // if there was no free channel, choke the oldest note that's being held
				{
					if(heldNotesLen > 0) // there is a note
					{
						
						MidiNoteOn oldest = heldNotes[0];
						// choke, it, mark its channel as free:
						
						oldest.velocity = 0;
						[[[MDMIDI sharedInstance] a4MidiDestination] sendNoteOn:oldest];
						[self.delegate polyMapperDidSendNoteOn:oldest];
				
						
						for (int i = heldNotesLen-1; i > 0; i--)
						{
							heldNotes[i-1] = heldNotes[i];
						}
						
						heldNotesLen--;
						freeChannels[oldest.channel] = YES;
						
						// same as above, see if there's a free channel now and send the note to it:
						if(chan >= 0 && heldNotesLen < heldNotesLenMax) // there is a free channel
						{
							noteOn.channel = chan; // set the channel
							heldNotes[heldNotesLen++] = noteOn;
							[[[MDMIDI sharedInstance] a4MidiDestination] sendNoteOn:noteOn]; // pass it to a4
							[self.delegate polyMapperDidSendNoteOn:noteOn];
						}
					}
				}
			}
			else // it's a note off
			{
				// remove the held note from being tracked.
				// send the note off to the correct channel
				
				
				for (int i = 0; i < heldNotesLen; i++)
				{
					MidiNoteOn n = heldNotes[i];
					if(n.note == noteOn.note)
					{
						noteOn.channel = n.channel;
						freeChannels[n.channel] = YES;
						
						for (int j = heldNotesLen-1; j > i; j--)
						{
							heldNotes[j-1] = heldNotes[j];
						}
						
						heldNotesLen--;
						
						
						[[[MDMIDI sharedInstance] a4MidiDestination] sendNoteOn:noteOn];
						[self.delegate polyMapperDidSendNoteOn:noteOn];
					}
				}
			}
		}
	}
}

- (void)midiReceivedNoteOff:(MidiNoteOff)noteOff fromSource:(PGMidiSource *)source
{
	if(source == [[MDMIDI sharedInstance] externalInputSource] ||
	   source == [[MDMIDI sharedInstance] machinedrumMidiSource])
	{
		if(self.mode == A4PolyMapperMappingModeUnison)
		{
			for (NSNumber *n in self.channels)
			{
				noteOff.channel = [n charValue];
				[[[MDMIDI sharedInstance] a4MidiDestination] sendNoteOff:noteOff];
				[self.delegate polyMapperDidSendNoteOff:noteOff];
			}
		}
		else if(self.mode == A4PolyMapperMappingModeThru)
		{
			[[[MDMIDI sharedInstance] a4MidiDestination] sendNoteOff:noteOff];
			[self.delegate polyMapperDidSendNoteOff:noteOff];
		}
		else if(self.mode == A4PolyMapperMappingModePoly)
		{
			for (int i = 0; i < heldNotesLen; i++)
			{
				MidiNoteOn n = heldNotes[i];
				if(n.note == noteOff.note)
				{
					noteOff.channel = n.channel;
					freeChannels[n.channel] = YES;
					
					for (int j = heldNotesLen-1; j > i; j--)
					{
						heldNotes[j-1] = heldNotes[j];
					}
					
					heldNotesLen--;
					
					[[[MDMIDI sharedInstance] a4MidiDestination] sendNoteOff:noteOff];
					[self.delegate polyMapperDidSendNoteOff:noteOff];
				}
			}
		}
	}
}

- (void)midiReceivedControlChange:(MidiControlChange)controlChange fromSource:(PGMidiSource *)source
{
	if(source == [[MDMIDI sharedInstance] a4MidiSource])
	{
		//		DLog(@"got cc chan: %d", controlChange.channel);
		//		printf("\nchn: %02d prm: %02d val: %02d", controlChange.channel, controlChange.parameter, controlChange.ccValue);
		
		if(self.ccMirroringEnabled)
		{
			int skip = controlChange.channel;
			BOOL isPoly = NO;
			for (NSNumber *n in self.channels)
			{
				if(n.charValue == controlChange.channel)
				{
					isPoly = YES;
				}
			}
			
			for (NSNumber *n in self.channels)
			{
				//				DLog(@"chn: %d", n.charValue);
				if(isPoly && n.charValue != skip)
				{
					//					DLog(@"mirroring!");
					controlChange.channel = n.charValue;
					[[[MDMIDI sharedInstance] a4MidiDestination] sendControlChange:controlChange];
				}
			}
		}
	}
	else if(source == [[MDMIDI sharedInstance] externalInputSource] ||
	   source == [[MDMIDI sharedInstance] machinedrumMidiSource])
	{
		if(self.mode == A4PolyMapperMappingModeUnison ||
		   self.mode == A4PolyMapperMappingModePoly)
		{
//			DLog(@"mirroring cc from ext source..");
			for (NSNumber *channel in self.channels)
			{
				controlChange.channel = [channel charValue];
				[[[MDMIDI sharedInstance] a4MidiDestination] sendControlChange:controlChange];
			}
		}
		else
		{
			[[[MDMIDI sharedInstance] a4MidiDestination] sendControlChange:controlChange];
		}
	}
}

- (instancetype)init
{
	if(self = [super init])
	{
		[[MDMIDI sharedInstance] addObserverForMidiConnectionEvents:self];
		[[MDMIDI sharedInstance] addObserverForMidiInputParserEvents:self];
		
		for (int i = 0; i < 6; i++)
		{
			freeChannels[i] = YES;
		}
		
		self.channels = [@[@(0), @(1), @(2), @(3)] mutableCopy];
		self.mode = A4PolyMapperMappingModePoly;
		self.ccMirroringEnabled = YES;
	}
	return self;
}

static A4PolyMapper *mapper = nil;

+ (instancetype)sharedInstance
{
	if(mapper == nil)
	{
		mapper = [self new];
	}
	return mapper;
}

@end
