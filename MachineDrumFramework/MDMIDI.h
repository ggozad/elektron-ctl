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

@interface MDMIDI : NSObject <PGMidiDelegate, MidiInputDelegate, MDMachineDrumDelegate>
@property (strong, nonatomic) MDMachineDrum *machinedrum;
@property (strong, nonatomic) PGMidiSource *externalInputSource;
@property (strong, nonatomic) PGMidiSource *machinedrumMidiSource;
@property (strong, nonatomic) PGMidiDestination *machinedrumMidiDestination;
@property (strong, nonatomic) MDSysexTransactionController *sysex;
+ (MDMIDI *) sharedInstance;
+ (MDSysexTransactionController *) sysex;

- (void) addObserverForMidiConnectionEvents:(id<PGMidiDelegate>)observer;
- (void) removeObserverForMidiConnectionEvents:(id<PGMidiDelegate>)observer;
- (void) addObserverForMidiInputParserEvents:(id<MidiInputDelegate>)observer;
- (void) removeObserverForMidiInputParserEvents:(id<MidiInputDelegate>)observer;

- (void) foo;

@end
