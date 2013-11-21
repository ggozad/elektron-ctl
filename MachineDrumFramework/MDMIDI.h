//
//  MainLogic.h
//  md keys
//
//  Created by Jakob Penca on 8/27/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MDSysexTransactionController;
#import "PGMidi.h"
#import "MidiInputParser.h"
#import "MDMachineDrum.h"
@class A4PolyMapper;

@interface MDMIDI : NSObject <PGMidiDelegate, MidiInputDelegate, MDMachineDrumDelegate>
@property (strong, nonatomic) MDMachineDrum *machinedrum;
@property (strong, nonatomic) PGMidiSource *externalInputSource;
@property (strong, nonatomic) PGMidiDestination *externalInputDestination;
@property (strong, nonatomic) PGMidiSource *machinedrumMidiSource;
@property (strong, nonatomic) PGMidiDestination *machinedrumMidiDestination;
@property (strong, nonatomic) PGMidiSource *a4MidiSource;
@property (strong, nonatomic) PGMidiDestination *a4MidiDestination;
@property (strong, nonatomic) A4PolyMapper *a4PolyMapper;

@property (strong, nonatomic) MDSysexTransactionController *sysex;
+ (MDMIDI *) sharedInstance;
+ (MDSysexTransactionController *) sysex;

- (void) addObserverForMidiConnectionEvents:(id<PGMidiDelegate>)observer;
- (void) removeObserverForMidiConnectionEvents:(id<PGMidiDelegate>)observer;
- (void) addObserverForMidiInputParserEvents:(id<MidiInputDelegate>)observer;
- (void) removeObserverForMidiInputParserEvents:(id<MidiInputDelegate>)observer;

- (void) setTurboMidiFactor:(float)turboMidiFactor forMIDIDestination:(PGMidiDestination *)destination;
- (float)turboMidiFactorForDestination:(PGMidiDestination *)destination;

- (void) refreshSoftThruSettings;
- (void) setSoftMIDIThruMDIsMaster:(BOOL)master clock:(BOOL)clock startStop:(BOOL) startStop;

@end
