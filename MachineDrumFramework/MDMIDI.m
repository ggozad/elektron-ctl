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
	[self performSelector:@selector(reconnectToKnownMidiEndpoints) withObject:nil];
	for (id<PGMidiDelegate> observer in self.midiConnectionObservers)
	{
		[observer performSelector:@selector(midiDestinationAdded:) withObject:destination];
	}
}

- (void)midiDestinationRemoved:(PGMidiDestination *)destination
{
	[self performSelector:@selector(reconnectToKnownMidiEndpoints) withObject:nil];
	
	if(destination == self.a4MidiDestination) self.a4MidiDestination = nil;
	if(destination == self.machinedrumMidiDestination) self.machinedrumMidiDestination = nil;
	if(destination == self.externalInputDestination) self.externalInputDestination = nil;
	
	for (id<PGMidiDelegate> observer in self.midiConnectionObservers)
	{
		if([observer respondsToSelector:@selector(midiDestinationRemoved:)])
			[observer performSelector:@selector(midiDestinationRemoved:) withObject:destination];
	}
}
- (void)midiSourceAdded:(PGMidiSource *)source
{
	DLog(@"source added: %@", source.name);
	[self performSelector:@selector(reconnectToKnownMidiEndpoints) withObject:nil];
	for (id<PGMidiDelegate> observer in self.midiConnectionObservers)
	{
		if([observer respondsToSelector:@selector(midiSourceAdded:)])
			[observer performSelector:@selector(midiSourceAdded:) withObject:source];
	}
}
- (void)midiSourceRemoved:(PGMidiSource *)source
{
	DLog(@"source removed: %@", source.name);
	
	
	for (id<PGMidiDelegate> observer in self.midiConnectionObservers)
	{
		if([observer respondsToSelector:@selector(midiSourceRemoved:)])
			[observer performSelector:@selector(midiSourceRemoved:) withObject:source];
	}
	
	[self performSelector:@selector(reconnectToKnownMidiEndpoints) withObject:nil];
	
	if(source == self.a4MidiSource) self.a4MidiSource = nil;
	if(source == self.machinedrumMidiSource) self.machinedrumMidiSource = nil;
	if(source == self.externalInputSource) self.externalInputSource = nil;
}


- (void)midiReceivedClockFromSource:(PGMidiSource *)source
{
	for (id<MidiInputDelegate> i in self.midiInputObservers)
	{
		if([i respondsToSelector:@selector(midiReceivedClockFromSource:)])
			[i midiReceivedClockFromSource:source];
	}
}

- (void)midiReceivedClockInterpolationFromSource:(PGMidiSource *)source
{
	for (id<MidiInputDelegate> i in self.midiInputObservers)
	{
		if([i respondsToSelector:@selector(midiReceivedClockInterpolationFromSource:)])
			[i midiReceivedClockInterpolationFromSource:source];
	}
}

- (void)midiReceivedTransport:(uint8_t)transport fromSource:(PGMidiSource *)source
{
	for (id<MidiInputDelegate> i in self.midiInputObservers)
	{
		if([i respondsToSelector:@selector(midiReceivedTransport:fromSource:)])
			[i midiReceivedTransport:transport fromSource:source];
	}
}

- (void)midiReceivedNoteOn:(MidiNoteOn)noteOn fromSource:(PGMidiSource *)source
{
	for (id<MidiInputDelegate> i in self.midiInputObservers)
	{
		if([i respondsToSelector:@selector(midiReceivedNoteOn:fromSource:)])
			[i midiReceivedNoteOn:noteOn fromSource:source];
	}
}

- (void)midiReceivedNoteOff:(MidiNoteOff)noteOff fromSource:(PGMidiSource *)source
{
	for (id<MidiInputDelegate> i in self.midiInputObservers)
	{
		if([i respondsToSelector:@selector(midiReceivedNoteOff:fromSource:)])
			[i midiReceivedNoteOff:noteOff fromSource:source];
	}
}

- (void)midiReceivedControlChange:(MidiControlChange)controlChange fromSource:(PGMidiSource *)source
{
	for (id<MidiInputDelegate> i in self.midiInputObservers)
	{
		if([i respondsToSelector:@selector(midiReceivedControlChange:fromSource:)])
			[i midiReceivedControlChange:controlChange fromSource:source];
	}
}

- (void)midiReceivedProgramChange:(MidiProgramChange)programChange fromSource:(PGMidiSource *)source
{
	for (id<MidiInputDelegate> i in self.midiInputObservers)
	{
		if([i respondsToSelector:@selector(midiReceivedProgramChange:fromSource:)])
			[i midiReceivedProgramChange:programChange fromSource:source];
	}
}

- (void)midiReceivedAftertouch:(MidiAftertouch)aftertouch fromSource:(PGMidiSource *)source
{
	for (id<MidiInputDelegate> i in self.midiInputObservers)
	{
		if([i respondsToSelector:@selector(midiReceivedAftertouch:fromSource:)])
			[i midiReceivedAftertouch:aftertouch fromSource:source];
	}
}

- (void)midiReceivedPitchWheel:(MidiPitchWheel)pw fromSource:(PGMidiSource *)source
{
	for (id<MidiInputDelegate> i in self.midiInputObservers)
	{
		if([i respondsToSelector:@selector(midiReceivedPitchWheel:fromSource:)])
			[i midiReceivedPitchWheel:pw fromSource:source];
	}
}

- (void)midiReceivedSysexData:(NSData *)sysexdata fromSource:(PGMidiSource *)source
{
	if(source == self.machinedrumMidiSource || source == self.a4MidiSource)
	{
		[MDSysexRouter routeSysexData:sysexdata.copy];
	}
}

- (void)machineDrum:(MDMachineDrum *)md wantsToSendSysExData:(NSData *)data
{
	if(self.machinedrumMidiDestination)
		[self.machinedrumMidiDestination sendSysexData:data];
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
	
	NSString *name = @"";
	if(_a4MidiSource) name = _a4MidiSource.name;
	
	[[NSUserDefaults standardUserDefaults] setValue:name forKey:@"a4SourceName"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	DLog(@"set a4 source to %@", _a4MidiSource.name);
}

- (void)setA4MidiDestination:(PGMidiDestination *)a4MidiDestination
{
	_a4MidiDestination = a4MidiDestination;
	NSString *name = @"";
	if(_a4MidiDestination) name = _a4MidiDestination.name;
	
	[[NSUserDefaults standardUserDefaults] setValue:name forKey:@"a4DestinationName"];
	[[NSUserDefaults standardUserDefaults] synchronize];
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
	NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
	[d synchronize];
	
	NSString *s = [d valueForKey:@"a4SourceName"];
	if(s)
	{
		for (PGMidiSource *source in [[PGMidi sharedInstance] sources])
		{
			if([source.name isEqualToString:s])
			{
				self.a4MidiSource = source;
			}
		}
	}
	
	s = [d valueForKey:@"externalInputSourceName"];
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
	
	for (PGMidiSource *source in [[PGMidi sharedInstance] sources])
	{
		DLog(@"src: %@", source.name);
		
		for (NSString *autoConnectName in self.deviceNamesForAutoConnect)
		{
			if([autoConnectName isEqualToString:source.name])
			{
				if([source.name isEqualToString:@"Elektron TM-1"] && !self.machinedrumMidiSource)
				{
					DLog(@"src success! connecting to %@", source.name);
					[self setMachinedrumMidiSource:source];
					break;
				}
				else if([source.name isEqualToString:@"Elektron Analog Four"] && !self.a4MidiSource)
				{
					DLog(@"src success! connecting to %@", source.name);
					[self setA4MidiSource:source];
					break;
				}
				/*
				else if([source.name isEqualToString:@"Network Session 1"])
				{
					DLog(@"src success! connecting to %@", source.name);
					[self setA4MidiSource:source];
					break;
				}
				 */
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
				if([destination.name isEqualToString:@"Elektron TM-1"] && !self.machinedrumMidiDestination)
				{
					DLog(@"dst success! connecting to %@", destination.name);
					[self setMachinedrumMidiDestination:destination];
					break;
				}
				else if([destination.name isEqualToString:@"Elektron Analog Four"] && !self.a4MidiDestination)
				{
					DLog(@"dst success! connecting to %@", destination.name);
					[self setA4MidiDestination:destination];
					break;
				}
				/*
				else if([destination.name isEqualToString:@"Network Session 1"])
				{
					DLog(@"dst success! connecting to %@", destination.name);
					[self setA4MidiDestination:destination];
					break;
				}
				 */
			}
		}
	}
	
	/*
	if(self.machinedrumMidiDestination && self.machinedrumMidiSource)
		return;
	*/
	
	
}

@end
