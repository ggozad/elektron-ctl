//
//  MDPatternSelectionNode.h
//  MachineDrumFrameworkOSX
//
//  Created by Jakob Penca on 7/20/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDPatternSelectionNodePosition.h"
#import "MDMachinedrumPublic.h"

@interface MDPatternSelectionNode : NSObject
@property (strong, readonly) NSMutableArray *locks;
@property BOOL trig;
@property MDPatternSelectionNodePosition *position;


+ (id) selectionNodeWithPosition:(MDPatternSelectionNodePosition *)position;
- (void) addLock:(MDParameterLock *)lock;
- (void) clear;

@end
