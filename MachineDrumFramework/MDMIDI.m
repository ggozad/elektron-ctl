//
//  MainLogic.m
//  md keys
//
//  Created by Jakob Penca on 8/27/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDMIDI.h"
#import "MDSysexTransactionController.h"
#import "MDMachinedrumPublic.h"

@interface MDMIDI()
{
	PGMidiSource *_externalInputSource;
}
@property (nonatomic, strong) NSMutableArray *midiConnectionObservers;
@property (nonatomic, strong) NSMutableArray *midiInputObservers;
@property (strong, nonatomic) NSArray *deviceNamesForAutoConnect;
@end

@implementation MDMIDI

void SetMIDISysExSpeed(MIDIEndpointRef ep, SInt32 speed)
{
	SInt32 speed2 = 0;
	MIDIObjectGetIntegerProperty(ep, kMIDIPropertyMaxSysExSpeed, &speed2);
	printf("old speed: %d\n", speed2);
	MIDIObjectSetIntegerProperty(ep, kMIDIPropertyMaxSysExSpeed, speed);
	speed2 = 0;
	MIDIObjectGetIntegerProperty(ep, kMIDIPropertyMaxSysExSpeed, &speed2);
	printf("%d -> %d\n", (int)speed, (int)speed2);
}

- (void) refreshSoftThruSettings
{
	NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
	[d synchronize];
	
	NSNumber *master = [d valueForKey:kMDSoftMIDIThruMasterOrSlaveKey];
	NSNumber *clock = [d valueForKey:kMDSoftMIDIThruClockEnabledKey];
	NSNumber *startStop = [d valueForKey:kMDSoftMIDIThruStartStopEnabledKey];
	
	[self setSoftMIDIThruMDIsMaster:master.boolValue clock:clock.boolValue startStop:startStop.boolValue];
}

- (void)setSoftMIDIThruMDIsMaster:(BOOL)master clock:(BOOL)clock startStop:(BOOL)startStop
{
	if(!master)
	{
		self.externalInputSource.parser.softThruDestination = self.machinedrumMidiDestination;
		self.externalInputSource.parser.softThruPassClock = clock;
		self.externalInputSource.parser.softThruPassStartStop = startStop;
		
		self.machinedrumMidiSource.parser.softThruDestination = nil;
		self.machinedrumMidiSource.parser.softThruPassClock = NO;
		self.machinedrumMidiSource.parser.softThruPassStartStop = NO;
	}
	else
	{
		self.externalInputSource.parser.softThruDestination = nil;
		self.externalInputSource.parser.softThruPassClock = NO;
		self.externalInputSource.parser.softThruPassStartStop = NO;
		
		self.machinedrumMidiSource.parser.softThruDestination = self.externalInputDestination;
		self.machinedrumMidiSource.parser.softThruPassClock = clock;
		self.machinedrumMidiSource.parser.softThruPassStartStop = startStop;
	}
}

- (void)setTurboMidiFactor:(float)turboMidiFactor forMIDIDestination:(PGMidiDestination *)destination
{
	if(turboMidiFactor > 10) turboMidiFactor = 10;
	if(turboMidiFactor < 1) turboMidiFactor = 1;
	SInt32 speed = 3125 * turboMidiFactor;
	SetMIDISysExSpeed(destination.endpoint, speed);
}

- (float)turboMidiFactorForDestination:(PGMidiDestination *)destination
{
	SInt32 speed;
	MIDIObjectGetIntegerProperty(destination.endpoint, kMIDIPropertyMaxSysExSpeed, &speed);
	return speed / 3125.0;
}

- (void) addObserverForMidiInputParserEvents:(id<MidiInputDelegate>)observer
{
	DLog(@"adding observer..");
	if(![self.midiInputObservers containsObject:observer])
		[self.midiInputObservers addObject:observer];
}

- (void) removeObserverForMidiInputParserEvents:(id<MidiInputDelegate>)observer
{
	if([self.midiInputObservers containsObject:observer])
		[self.midiInputObservers removeObject:observer];
}

- (void)addObserverForMidiConnectionEvents:(id<PGMidiDelegate>)observer
{
	DLog(@"adding observer..");
	if(![self.midiConnectionObservers containsObject:observer])
		[self.midiConnectionObservers addObject:observer];
}

- (void)removeObserverForMidiConnectionEvents:(id<PGMidiDelegate>)observer
{
	if([self.midiConnectionObservers containsObject:observer])
		[self.midiConnectionObservers removeObject:observer];
}

- (void)midiDestinationAdded:(PGMidiDestination *)destination
{
	[self performSelectorOnMainThread:@selector(reconnectToKnownMidiEndpoints) withObject:nil waitUntilDone:NO];
	for (NSObject *observer in self.midiConnectionObservers)
		[observer performSelectorOnMainThread:@selector(midiDestinationAdded:) withObject:destination waitUntilDone:NO];
}

- (void)midiDestinationRemoved:(PGMidiDestination *)destination
{
	[self performSelectorOnMainThread:@selector(reconnectToKnownMidiEndpoints) withObject:nil waitUntilDone:NO];
	
	if(destination == self.a4MidiDestination) self.a4MidiDestination = nil;
	if(destination == self.machinedrumMidiDestination) self.machinedrumMidiDestination = nil;
	if(destination == self.externalInputDestination) self.externalInputDestination = nil;
	
	for (NSObject *observer in self.midiConnectionObservers)
		[observer performSelectorOnMainThread:@selector(midiDestinationRemoved:) withObject:destination waitUntilDone:NO];
}
- (void)midiSourceAdded:(PGMidiSource *)source
{
	[self performSelectorOnMainThread:@selector(reconnectToKnownMidiEndpoints) withObject:nil waitUntilDone:NO];
	for (NSObject *observer in self.midiConnectionObservers)
		[observer performSelectorOnMainThread:@selector(midiSourceAdded:) withObject:source waitUntilDone:NO];
}
- (void)midiSourceRemoved:(PGMidiSource *)source
{
	[self performSelectorOnMainThread:@selector(reconnectToKnownMidiEndpoints) withObject:nil waitUntilDone:NO];
	
	if(source == self.a4MidiSource) self.a4MidiSource = nil;
	if(source == self.machinedrumMidiSource) self.machinedrumMidiSource = nil;
	if(source == self.externalInputSource) self.externalInputSource = nil;
	
	for (NSObject *observer in self.midiConnectionObservers)
		[observer performSelectorOnMainThread:@selector(midiSourceRemoved:) withObject:source waitUntilDone:NO];
}

- (void)midiReceivedNoteOn:(MidiNoteOn *)noteOn fromSource:(PGMidiSource *)source
{
	for (id<MidiInputDelegate> i in self.midiInputObservers)
	{
		if([i respondsToSelector:@selector(midiReceivedNoteOn:fromSource:)])
			[i midiReceivedNoteOn:noteOn fromSource:source];
	}
	
	//DLog(@"note on from %@, channel: %d, note: %d, velocity: %d", source.name, noteOn.channel, noteOn.note, noteOn.velocity);
}

- (void)midiReceivedControlChange:(MidiControlChange *)controlChange fromSource:(PGMidiSource *)source
{
	for (id<MidiInputDelegate> i in self.midiInputObservers)
	{
		if([i respondsToSelector:@selector(midiReceivedControlChange:fromSource:)])
			[i midiReceivedControlChange:controlChange fromSource:source];
	}
}

- (void)midiReceivedSysexData:(NSData *)sysexdata fromSource:(PGMidiSource *)source
{
	if(source == self.machinedrumMidiSource || source == self.a4MidiSource)
	{
		[MDSysexRouter routeSysexData:sysexdata];
	}
}

- (void)machineDrum:(MDMachineDrum *)md wantsToSendSysExData:(NSData *)data
{
	if(self.machinedrumMidiDestination)
		[self.machinedrumMidiDestination sendSysexBytes:data.bytes size:data.length];
}

- (void)setExternalInputSource:(PGMidiSource *)externalInputSource
{
	if(_externalInputSource)
	{
		_externalInputSource.parser.delegate = nil;
	}
	_externalInputSource = externalInputSource;
	
	if(_externalInputSource)
	{
		_externalInputSource.parser.delegate = self;
	}
			
	[[NSUserDefaults standardUserDefaults] setValue:_externalInputSource.name forKey:@"externalInputSourceName"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	
	PGMidiDestination *dst = nil;
	if(_externalInputSource)
	{
		for (PGMidiDestination *d in [[PGMidi sharedInstance] destinations])
		{
			if([d.name isEqualToString:_externalInputSource.name])
			{
				dst = d;
				break;
			}
		}
	}
	
	[self setExternalInputDestination:dst];
	DLog(@"set ext source to %@", _externalInputSource.name);
}

- (void)setExternalInputDestination:(PGMidiDestination *)externalInputDestination
{
	_externalInputDestination = externalInputDestination;
}

- (PGMidiSource *)externalInputSource
{
	return _externalInputSource;
}

- (void)setMachinedrumMidiSource:(PGMidiSource *)mdSource
{
	if(_machinedrumMidiSource) _machinedrumMidiSource.parser.delegate = nil;
	_machinedrumMidiSource = mdSource;
	if(_machinedrumMidiSource)
		_machinedrumMidiSource.parser.delegate = self;
	
	[[NSUserDefaults standardUserDefaults] setValue:_machinedrumMidiSource.name forKey:@"mdSourceName"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	DLog(@"set md source to %@", _machinedrumMidiSource.name);
}

- (void)setMachinedrumMidiDestination:(PGMidiDestination *)mdDestination
{
	_machinedrumMidiDestination = mdDestination;
	[[NSUserDefaults standardUserDefaults] setValue:_machinedrumMidiDestination.name forKey:@"mdDestinationName"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	DLog(@"set md dest to %@", _machinedrumMidiDestination.name);
}

- (void)setA4MidiSource:(PGMidiSource *)a4MidiSource
{
	if(_a4MidiSource) _a4MidiSource.parser.delegate = nil;
	_a4MidiSource = a4MidiSource;
	if(_a4MidiSource)
		_a4MidiSource.parser.delegate = self;
}

static MDMIDI *_default = nil;

+ (MDMIDI *)sharedInstance
{
	if(_default != nil) return _default;
	
	static dispatch_once_t safer;
	dispatch_once(&safer, ^(void)
				  {
					  _default = [[self alloc] init];
				  });
	
	return _default;
}

+ (MDSysexTransactionController *)sysex
{
	return [[self sharedInstance] sysex];
}

- (id)init
{
	if(self = [super init])
	{
		self.deviceNamesForAutoConnect = @[
									 @"Elektron Analog Four",
									 @"Elektron TM-1"];
		
		
		
		DLog(@"init");
		self.midiConnectionObservers = [NSMutableArray array];
		self.midiInputObservers = [NSMutableArray array];
		self.machinedrum = [MDMachineDrum new];
		self.machinedrum.delegate = self;
		self.sysex = [MDSysexTransactionController new];
		[[PGMidi sharedInstance] setDelegate:self];
	
		
		[self reconnectToKnownMidiEndpoints];
		[self refreshSoftThruSettings];
		
		
		
		
		[MDStorage sharedInstance];
		[MDSDS sharedInstance];
		
		
		DLog(@"done..");
		
	}
	return self;
}

- (void) midiEndpointDisconnect
{
	
}

- (void) reconnectToKnownMidiEndpoints
{
	DLog(@"trying to reconnect to previous midi endpoints..");
	
	for (PGMidiSource *source in [[PGMidi sharedInstance] sources])
	{
		DLog(@"src: %@", source.name);
		
		for (NSString *autoConnectName in self.deviceNamesForAutoConnect)
		{
			if([autoConnectName isEqualToString:source.name])
			{
				if([source.name isEqualToString:@"Elektron TM-1"])
				{
					DLog(@"src success! connecting to %@", source.name);
					[self setMachinedrumMidiSource:source];
					break;
				}
				else if([source.name isEqualToString:@"Elektron Analog Four"])
				{
					DLog(@"src success! connecting to %@", source.name);
					[self setA4MidiSource:source];
					break;
				}
			}
		}
	}
	for (PGMidiDestination *destination in [[PGMidi sharedInstance] destinations])
	{
		DLog(@"dst: %@", destination.name);
		
		for (NSString *autoConnectName in self.deviceNamesForAutoConnect)
		{
			if([autoConnectName isEqualToString:destination.name])
			{
				if([destination.name isEqualToString:@"Elektron TM-1"])
				{
					DLog(@"dst success! connecting to %@", destination.name);
					[self setMachinedrumMidiDestination:destination];
					break;
				}
				else if([destination.name isEqualToString:@"Elektron Analog Four"])
				{
					DLog(@"dst success! connecting to %@", destination.name);
					[self setA4MidiDestination:destination];
					break;
				}
			}
		}
	}
	
	/*
	if(self.machinedrumMidiDestination && self.machinedrumMidiSource)
		return;
	*/
	
	NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
	//[d synchronize];
	
	NSString *s = [d valueForKey:@"externalInputSourceName"];
	if(s)
	{
		for (PGMidiSource *source in [[PGMidi sharedInstance] sources])
		{
			if([s isEqualToString:source.name])
			{
				DLog(@"ext in success, connecting to: %@", source.name);
				[self setExternalInputSource:source];
			}
		}
		for (PGMidiDestination *dest in [[PGMidi sharedInstance] destinations])
		{
			if([s isEqualToString:dest.name])
			{
				DLog(@"ext out success, connecting to: %@", dest.name);
				[self setExternalInputDestination:dest];
			}
		}
	}
	
	s = [d valueForKey:@"mdSourceName"];
	if(s)
	{
		for (PGMidiSource *source in [[PGMidi sharedInstance] sources])
		{
			if([s isEqualToString:source.name])
				[self setMachinedrumMidiSource:source];
		}
	}
	
	s = [d valueForKey:@"mdDestinationName"];
	if(s)
	{
		for (PGMidiDestination *destination in [[PGMidi sharedInstance] destinations])
		{
			if([s isEqualToString:destination.name])
				[self setMachinedrumMidiDestination:destination];
		}
	}
}

@end
