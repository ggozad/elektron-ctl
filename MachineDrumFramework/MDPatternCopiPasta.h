//
//  MDPatternSelection.h
//  MachineDrumFrameworkOSX
//
//  Created by Jakob Penca on 7/20/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDMachinedrumPublic.h"
#import "MDPatternRegion.h"

typedef enum MDPatternCopiPastaShiftDirection
{
	MDPatternCopiPastaShiftDirectionRight,
	MDPatternCopiPastaShiftDirectionDown,
	MDPatternCopiPastaShiftDirectionLeft,
	MDPatternCopiPastaShiftDirectionUp
}
MDPatternCopiPastaShiftDirection;

typedef enum MDPatternCopiPastaRemapMode
{
	MDPatternCopiPastaRemapModeScale
}
MDPatternCopiPastaRemapMode;

@interface MDPatternCopiPasta : NSObject
@property  (strong, nonatomic) MDPattern *sourcePattern, *targetPattern;
@property  (strong, nonatomic) MDPatternRegion *sourceRegion, *targetRegion;

- (void) swapRegions;
- (void) shiftSourceInDirection:(MDPatternCopiPastaShiftDirection)dir;
- (void) shiftTargetInDirection:(MDPatternCopiPastaShiftDirection)dir;

- (void) remapCopySourceToTarget_Transparent_WithMode: (MDPatternCopiPastaRemapMode)mode;
- (void) remapCopySourceToTarget_Opaque_WithMode: (MDPatternCopiPastaRemapMode)mode;

- (void) remapMoveSourceToTarget_Transparent_WithMode: (MDPatternCopiPastaRemapMode)mode;
- (void) remapMoveSourceToTarget_Opaque_WithMode: (MDPatternCopiPastaRemapMode)mode;

- (void) remapSwapSourceWithTarget_WithMode: (MDPatternCopiPastaRemapMode)mode;

- (void) clearTargetRegion;
- (void) clearSourceRegion;

@end
