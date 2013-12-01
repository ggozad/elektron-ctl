//
//  A4TrackingMidiSequencer.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 10/11/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A4MidiSequencer.h"
#import "A4Kit.h"
#import "A4Project.h"
#import "A4TrackerTrack.h"
#import "A4PerformanceMacroHandler.h"
#import "A4VoiceAllocator.h"


typedef enum A4TrackingMidiSequencerTrackingMode
{
	A4TrackingMidiSequencerTrackingModeRealtime,
	A4TrackingMidiSequencerTrackingModeOffline
}
A4TrackingMidiSequencerTrackingMode;

@class A4TrackingMidiSequencer;

@protocol A4TrackingMidiSequencerDelegate <A4MidiSequencerDelegate>
- (void) a4TrackingMidiSequencerDidUpdateContinuousValues:(A4TrackingMidiSequencer *)sequencer;
@end

@interface A4TrackingMidiSequencer : A4MidiSequencer <A4PerformanceMacroHandlerDelegate, A4VoiceAllocatorDelegate>
@property (nonatomic, strong) A4VoiceAllocator *voiceAllocator;
@property (nonatomic, weak) id<A4TrackingMidiSequencerDelegate> delegate;
@property (nonatomic) A4TrackingMidiSequencerTrackingMode trackingMode;
@property (nonatomic, strong) A4Kit *sourceKit;
@property (nonatomic) A4TrackerParam_t **targetParams;
@property (nonatomic, strong) A4Project *project;
@property (nonatomic, strong) A4PerformanceMacroHandler *performanceMacroHandler;
@property (nonatomic) double time;
+ (instancetype)trackingSequencerWithDelegate:(id<A4TrackingMidiSequencerDelegate>)delegate outputDevice:(PGMidiDestination *)dst inputDevice:(PGMidiSource *)src;
- (void) updateContinuousValues;
@end
