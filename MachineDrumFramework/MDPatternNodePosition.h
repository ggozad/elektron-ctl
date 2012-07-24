//
//  MDPatternSelectionNodePosition.h
//  MachineDrumFrameworkOSX
//
//  Created by Jakob Penca on 7/20/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDPatternNodePosition : NSObject

@property uint8_t step;
@property uint8_t track;

+ (MDPatternNodePosition *) nodePositionAtTrack: (uint8_t) t step: (uint8_t) s;
- (void) setTrack:(uint8_t)track step: (uint8_t) step;

@end
