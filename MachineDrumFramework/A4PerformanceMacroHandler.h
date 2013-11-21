//
//  A4PerformanceMacroHandler.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 21/11/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MidiInputParser.h"
#import "PGMidi.h"

@class A4PerformanceMacroHandler;


@protocol A4PerformanceMacroHandlerDelegate <NSObject>
- (void) a4PerformanceMacroHandler:(A4PerformanceMacroHandler *)handler knob:(uint8_t)knob didChangeValue:(uint8_t)value;
@end

@interface A4PerformanceMacroHandler : NSObject <MidiInputDelegate, PGMidiDelegate>
@property (nonatomic, weak) id<A4PerformanceMacroHandlerDelegate> delegate;
@property (nonatomic, weak) PGMidiSource *inputSource;
@property (nonatomic) uint8_t channel;
@property (nonatomic) BOOL enabled;
+ (instancetype) performanceMacroHandlerWithDelegate:(id<A4PerformanceMacroHandlerDelegate>)delegate inputSource:(PGMidiSource *)source channel:(uint8_t)channel;
@end
