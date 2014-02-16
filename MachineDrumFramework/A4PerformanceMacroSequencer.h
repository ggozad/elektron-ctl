//
//  A4PerformanceMacroSequencer.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 13/02/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>

@class A4PerformanceMacroSequencer;
@protocol A4PerformanceMacroSequencerDelegate <NSObject>
- (void) a4PerformanceMacroSequencer:(A4PerformanceMacroSequencer *)sequencer didAdvanceToStep:(uint8_t)step;
- (void) a4PerformanceMacroSequencerDidStart:(A4PerformanceMacroSequencer *)sequencer;
- (void) a4PerformanceMacroSequencer:(A4PerformanceMacroSequencer *)sequencer didContinueAtStep:(uint8_t)step;
- (void) a4PerformanceMacroSequencerDidStop:(A4PerformanceMacroSequencer *)sequencer;
- (void) a4PerformanceMacroSequencer:(A4PerformanceMacroSequencer *)sequencer peformanceKnob:(uint8_t)knob changedValue:(uint8_t)value;
@end

@interface A4PerformanceMacroSequencer : NSObject
@property (nonatomic) BOOL recording, clearing, tracking;
@property (nonatomic) id<A4PerformanceMacroSequencerDelegate>delegate;
@property (nonatomic) uint8_t nonTrackingStep;
@property (nonatomic, readonly) uint8_t trackingStep;
- (void) setNonTrackingStep:(uint8_t)nonTrackingStep trigger:(BOOL)trigger;
- (void) clearAll;
- (BOOL) stepIsActive:(int)idx;
- (BOOL) stepHasArmedControllers:(int)idx;
- (void) setStep:(int)idx active:(BOOL)active;
- (void) holdStep:(int)idx;
- (void) releaseStep:(int)idx;
- (void) clearStep:(int)idx;
@end
