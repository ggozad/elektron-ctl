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
@property (nonatomic, strong) NSMutableArray *midiConnectionObservers;
@property (nonatomic, strong) NSMutableArray *midiInputObservers;
@end

@implementation MDMIDI

- (void)foo
{
	DLog(@"lol");
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

- (void)midiReceivedSysexData:(NSData *)sysexdata fromSource:(PGMidiSource *)source
{
	[MDSysexRouter routeSysexData:sysexdata];
}

- (void)machineDrum:(MDMachineDrum *)md wantsToSendSysExData:(NSData *)data
{
	if(self.machinedrumMidiDestination)
		[self.machinedrumMidiDestination sendSysexBytes:data.bytes size:data.length];
}

- (void)setExternalInputSource:(PGMidiSource *)externalInputSource
{
	if(_externalInputSource) _externalInputSource.parser.delegate = nil;
	_externalInputSource = externalInputSource;
	if(_externalInputSource)
		_externalInputSource.parser.delegate = self;
	
	[[NSUserDefaults standardUserDefaults] setValue:_externalInputSource.name forKey:@"externalInputSourceName"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	DLog(@"set ext source to %@", _externalInputSource.name);
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
		self.midiConnectionObservers = [NSMutableArray array];
		self.midiInputObservers = [NSMutableArray array];
		self.machinedrum = [MDMachineDrum new];
		self.machinedrum.delegate = self;
		self.sysex = [MDSysexTransactionController new];
		[[PGMidi sharedInstance] setDelegate:self];
		[self reconnectToKnownMidiEndpoints];
	}
	return self;
}

- (void) reconnectToKnownMidiEndpoints
{
	NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
	[d synchronize];
	
	NSString *s = [d valueForKey:@"externalInputSourceName"];
	if(s)
	{
		for (PGMidiSource *source in [[PGMidi sharedInstance] sources])
		{
			if([s isEqualToString:source.name])
				[self setExternalInputSource:source];
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
