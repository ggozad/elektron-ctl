//
//  A4MidiSequencer.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 09/11/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A4Sequencer.h"
#import "PGMidi.h"
#import "MDMIDI.h"

@class A4MidiSequencer;

@protocol A4MidiSequencerDelegate <A4SequencerDelegate>
- (void) a4MidiSequencer:(A4MidiSequencer *)sequencer didReceiveProgramChange:(MidiProgramChange)programChange;
@end

@interface A4MidiSequencer : A4Sequencer <MidiInputDelegate, PGMidiDelegate>
@property (nonatomic, weak) PGMidiSource *inputDevice;
@property (nonatomic, weak) PGMidiDestination *outputDevice;
@property (nonatomic, weak) id<A4MidiSequencerDelegate>delegate;
+ (instancetype)sequencerWithDelegate:(id<A4MidiSequencerDelegate>)delegate outputDevice:(PGMidiDestination *)dst inputDevice:(PGMidiSource *)src;
- (void) setOutputChannel:(uint8_t)channel forTrack:(uint8_t)track;
- (uint8_t) outputChannelForTrack:(uint8_t)track;
- (void) handleClock;
@end
