//
//  MDProcedure.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 6/25/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDMachinedrumPublic.h"


@interface MDProcedure : NSObject

- (void) processPattern:(MDPatternPublicWrapper *) pattern kit: (MDKit *)kit;

@end
