//
//  MDProcedure.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 6/26/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "MDMachinedrumPublic.h"
#import "MDPatternPublicWrapper.h"
#import "MDKit.h"

@class MDProcedureCondition;

typedef enum MDProcedureConditionsMode
{
	MDProcedureConditionsMode_ANY,
	MDProcedureConditionsMode_ALL,
	MDProcedureConditionsMode_NONE,
}
MDProcedureConditionsMode;


@interface MDProc : NSObject
@property MDProcedureConditionsMode conditionsMode;
@property uint8_t track;
@property uint8_t startTrig;
@property uint8_t endTrig;
@property uint8_t stride;

+ (MDProc *) procedureWithMode:(MDProcedureConditionsMode)m;
- (BOOL) evaluateConditions;
- (void) processPattern:(MDPatternPublicWrapper *) pattern kit: (MDKit *)kit;
- (void) addCondition:(MDProcedureCondition *)c;
- (void) removeConditionAtIndex:(NSUInteger)i;
- (void) removeFirstCondition;
- (void) removeLastCondition;
- (void) clearConditions;

+ (id) procedureForWithMode:(MDProcedureConditionsMode)m
				   forTrack:(uint8_t)track
			  withStartTrig:(uint8_t)startTrig
					endTrig:(uint8_t)endTrig
					 stride:(uint8_t)stride;

@end
