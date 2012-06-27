//
//  MDProcedureTrigGenerator.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 6/26/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDProc.h"


typedef enum MDProcedureTrigGeneratorMode
{
	MDProcedureTrigGeneratorMode_ADD,
	MDProcedureTrigGeneratorMode_TOGGLE,
	MDProcedureTrigGeneratorMode_REMOVE
}
MDProcedureTrigGeneratorMode;

@interface MDProcedureTrigGenerator : MDProc
@property MDProcedureTrigGeneratorMode mode;


@end
