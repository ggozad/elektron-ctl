//
//  StandardMidiFileTrackEvent.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 09/02/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGMidi.h"

@interface SMFEvent : NSObject
@property (nonatomic, copy) NSData *data;
@property (nonatomic) NSUInteger delta;
@property (nonatomic) NSUInteger absoluteTick;
@property (nonatomic) NSData *messageData;

+ (instancetype) smfEventWithAbsoluteTick:(NSUInteger)absoluteTick messageData:(NSData *)msg;
+ (instancetype) smfEventWithAbsoluteTick:(NSUInteger)absoluteTick noteOn:(MidiNoteOn)noteOn;
+ (instancetype) smfEventWithAbsoluteTick:(NSUInteger)absoluteTick noteOff:(MidiNoteOff)noteOff;

+ (instancetype) smfEventWithDelta:(NSUInteger)delta messageData:(NSData *)msg;
+ (instancetype) smfEventWithDelta:(NSUInteger)delta noteOn:(MidiNoteOn)noteOn;
+ (instancetype) smfEventWithDelta:(NSUInteger)delta noteOff:(MidiNoteOff)noteOff;
@end
