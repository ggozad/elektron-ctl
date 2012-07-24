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

@interface MDPatternCopiPasta : NSObject
@property  (weak, nonatomic) MDPatternPublicWrapper *sourcePattern, *targetPattern;
@property  (strong, nonatomic) MDPatternRegion *sourceRegion, *targetRegion;

- (void) remapCopySourceToTarget_Transparent;
- (void) remapCopySourceToTarget_Opaque;

- (void) remapMoveSourceToTarget_Transparent;
- (void) remapMoveSourceToTarget_Opaque;

- (void) remapSwapSourceWithTarget;
- (void) clearTargetRegion;

@end
