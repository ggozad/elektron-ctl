//
//  MDProcedureTrigGenerator.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 6/26/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDProcedure.h"

typedef enum MDProcedureTrigGeneratorMode
{
	MDProcedureTrigGeneratorMode_ADD,
	MDProcedureTrigGeneratorMode_TOGGLE,
	MDProcedureTrigGeneratorMode_REMOVE
}
MDProcedureTrigGeneratorMode;

@interface MDProcedureTrigGenerator : MDProcedure
@property MDProcedureTrigGeneratorMode mode;
@property uint8_t track;
@property uint8_t startTrig;
@property uint8_t endTrig;
@property uint8_t stride;
@end
