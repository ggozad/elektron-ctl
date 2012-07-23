//
//  MDPatternSelectionRectangle.h
//  MachineDrumFrameworkOSX
//
//  Created by Jakob Penca on 7/20/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDPatternSelectionRectangle : NSObject
@property uint8_t track;
@property uint8_t step;
@property uint8_t numSteps;
@property uint8_t numTracks;

+ (id) selectionRectangleAtTrack:(uint8_t)t step:(uint8_t)s numTracks:(uint8_t)nt numSteps:(uint8_t)ns;


@end
