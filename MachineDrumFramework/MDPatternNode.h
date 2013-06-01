//
//  MDPatternSelectionNode.h
//  MachineDrumFrameworkOSX
//
//  Created by Jakob Penca on 7/20/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDPatternNodePosition.h"
#import "MDMachinedrumPublic.h"

@interface MDPatternNode : NSObject
@property (strong, readonly) NSMutableArray *locks;
@property BOOL trig, accent, slide, swing;
@property MDPatternNodePosition *position;


+ (id) nodeWithPosition:(MDPatternNodePosition *)position;
+ (id) nodeAtTrack:(uint8_t)track step:(uint8_t)step;
- (void) addLock:(MDParameterLock *)lock;
- (void)removeLockForParam:(uint8_t)param;
- (void) clear;

@end
