//
//  MDPatternSelection.h
//  MachineDrumFrameworkOSX
//
//  Created by Jakob Penca on 7/20/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MDMachinedrumPublic.h>
#import "MDPatternRegion.h"

@interface MDPatternSelection : NSObject
@property  (weak, nonatomic) MDPatternPublicWrapper *sourcePattern, *targetPattern;
@property  (strong, nonatomic) MDPatternRegion *sourceRegion, *targetRegion;

- (void) remapCopySourceToTarget;
- (void) remapMoveSourceToTarget;
- (void) remapSwapSourceWithTarget;
- (void) clearTargetRegion;

@end
