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
@property BOOL trig;
@property MDPatternNodePosition *position;


+ (id) nodeWithPosition:(MDPatternNodePosition *)position;
- (void) addLock:(MDParameterLock *)lock;
- (void) clear;

@end
