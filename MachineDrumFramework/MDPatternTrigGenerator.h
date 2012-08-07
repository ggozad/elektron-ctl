//
//  MDPatternTrigGenerator.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 8/7/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDMachinedrumPublic.h"
#import "MDPatternRegion.h"

@interface MDPatternTrigGenerator : NSObject
@property (strong, nonatomic) MDPatternRegion *region;
@property (strong, nonatomic) MDPattern *pattern;

- (void) generateTrigsWithStartStride:(uint8_t)startStride endStride:(uint8_t)endStride;

@end
