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

@interface MidiNoteOn : NSObject
@property UInt8 channel;
@property UInt8 note;
@property UInt8 velocity;
@end

@interface MidiNoteOff : NSObject
@property UInt8 channel;
@property UInt8 note;
@property UInt8 velocity;
@end

@interface MidiControlChange : NSObject
@property UInt8 channel;
@property UInt8 parameter;
@property UInt8 ccValue;
@end

@interface MidiProgramChange : NSObject
@property UInt8 channel;
@property UInt8 program;
@end

@interface MidiAftertouch : NSObject
@property UInt8 channel;
@property UInt8 note;
@property UInt8 pressure;
@end

@class MidiInputParser;

@protocol MidiInputDelegate <NSObject>
@optional
- (void) midiReceivedNoteOn:(MidiNoteOn *)noteOn fromSource:(PGMidiSource *)source;
- (void) midiReceivedNoteOff:(MidiNoteOff *)noteOff fromSource:(PGMidiSource *)source;
- (void) midiReceivedControlChange:(MidiControlChange *)controlChange fromSource:(PGMidiSource *)source;
- (void) midiReceivedProgramChange:(MidiProgramChange *)controlChange fromSource:(PGMidiSource *)source;
- (void) midiReceivedAftertouch:(MidiAftertouch *)aftertouch fromSource:(PGMidiSource *)source;
- (void) midiReceivedSysexData:(NSData *)sysexdata fromSource:(PGMidiSource *)source;
@end

@interface MidiInputParser : NSObject <PGMidiSourceDelegate>
@property (nonatomic, assign) id<MidiInputDelegate>delegate;
@property (assign, nonatomic) PGMidiSource *source;
@end
