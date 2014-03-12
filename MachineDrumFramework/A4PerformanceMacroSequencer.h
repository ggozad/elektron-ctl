//
//  A4PerformanceMacroSequencer.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 13/02/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum A4MacroSequencerPulsesPerStep
{
	A4MacroSequencerPulsesPerStep_3 = 0x00, // 2
	A4MacroSequencerPulsesPerStep_4 = 0x01, // 3/2
	A4MacroSequencerPulsesPerStep_6 = 0x02,  // 1
	A4MacroSequencerPulsesPerStep_8 = 0x03,  // 3/4
	A4MacroSequencerPulsesPerStep_12 = 0x04,  // 1/2
	A4MacroSequencerPulsesPerStep_24 = 0x05,  // 1/4
	A4MacroSequencerPulsesPerStep_48 = 0x06,  // 1/8
	A4MacroSequencerPulsesPerStep_96 = 0x07   // 1/16
}
A4MacroSequencerPulsesPerStep;

typedef enum A4macroSequencerTimeScale
{
	A4macroSequencerTimeScale_2_1 = 0x00,  // 2
	A4macroSequencerTimeScale_3_2 = 0x01,  // 3/2
	A4macroSequencerTimeScale_1_1 = 0x02,  // 1
	A4macroSequencerTimeScale_3_4 = 0x03,  // 3/4
	A4macroSequencerTimeScale_1_2 = 0x04,  // 1/2
	A4macroSequencerTimeScale_1_4 = 0x05,  // 1/4
	A4macroSequencerTimeScale_1_8 = 0x06,   // 1/8
	A4macroSequencerTimeScale_1_16 = 0x07   // 1/16
}
A4macroSequencerTimeScale;

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
@property (nonatomic) uint16_t skippedSteps;
@property (nonatomic, readonly) BOOL running;
@property (nonatomic) A4macroSequencerTimeScale timeScale;
- (void) setNonTrackingStep:(uint8_t)nonTrackingStep trigger:(BOOL)trigger;
- (void) clearAll;
- (void) setStep:(int)idx skipped:(BOOL)skip;
- (BOOL) stepIsSkipped:(int)idx;
- (BOOL) stepIsActive:(int)idx;
- (void) setStep:(int)idx active:(BOOL)active;
- (BOOL) stepHasArmedControllers:(int)idx;
- (void) holdStep:(int)idx;
- (void) releaseStep:(int)idx;
- (void) clearStep:(int)idx;
@end
