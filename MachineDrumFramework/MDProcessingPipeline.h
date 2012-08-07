//
//  MDProcessingPipeline.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 6/25/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDMachinedrumPublic.h"

@interface MDProcessingPipeline : NSObject
@property (nonatomic, strong) MDPattern *pattern;
@property (nonatomic, strong) MDKit *kit;
@property (nonatomic, strong) NSMutableArray *procedures;

- (void) process;
- (MDPattern *)resultPattern;
- (MDKit *) resultKit;

@end
