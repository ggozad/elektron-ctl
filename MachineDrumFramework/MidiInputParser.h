//
//  MidiInputParser.h
//  PGMidiTest
//
//  Created by Jakob Penca on 8/25/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>
#import "PGMidi.h"

@class MidiInputParser;

@protocol MidiInputDelegate <NSObject>
@optional
- (void) midiReceivedTransport:(uint8_t) transport fromSource:(PGMidiSource *)source;
- (void) midiReceivedClockFromSource:(PGMidiSource *)source;
- (void) midiReceivedClockInterpolationFromSource:(PGMidiSource *)source;
- (void) midiReceivedNoteOn:(MidiNoteOn)noteOn fromSource:(PGMidiSource *)source;
- (void) midiReceivedNoteOff:(MidiNoteOff)noteOff fromSource:(PGMidiSource *)source;
- (void) midiReceivedControlChange:(MidiControlChange)controlChange fromSource:(PGMidiSource *)source;
- (void) midiReceivedProgramChange:(MidiProgramChange)programChange fromSource:(PGMidiSource *)source;
- (void) midiReceivedChannelPressure:(MidiChannelPressure)channelPressure fromSource:(PGMidiSource *)source;
- (void) midiReceivedAftertouch:(MidiAftertouch)aftertouch fromSource:(PGMidiSource *)source;
- (void) midiReceivedPitchWheel:(MidiPitchWheel)pw fromSource:(PGMidiSource *)source;
- (void) midiReceivedSysexData:(NSData *)sysexdata fromSource:(PGMidiSource *)source;
@end

@interface MidiInputParser : NSObject <PGMidiSourceDelegate>
@property BOOL softThruPassClock, softThruPassStartStop;
@property (nonatomic, assign) PGMidiDestination *softThruDestination;
@property (nonatomic, assign) id<MidiInputDelegate>delegate;
@property (assign, nonatomic) PGMidiSource *source;
@property (nonatomic) BOOL interpolateClock;
@property (nonatomic) NSUInteger interpolationDivisions;
@end
