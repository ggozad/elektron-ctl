//
//  MDPatternSelectionRectangle.h
//  MachineDrumFrameworkOSX
//
//  Created by Jakob Penca on 7/20/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDPatternRegion : NSObject
@property uint8_t track;
@property uint8_t step;
@property int8_t numSteps;
@property int8_t numTracks;

+ (id) regionAtTrack:(uint8_t)t step:(uint8_t)s numberOfTracks:(int8_t)nt numberOfSteps:(int8_t)ns;
- (void) translateStep: (int8_t)s track: (int8_t)t;
- (void) changeNumSteps: (int8_t)s numTracks: (int8_t)t;

@end
