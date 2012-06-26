//
//  MDProcedure.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 6/26/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDMachinedrumPublic.h"

typedef enum MDProcedureConditionsMode
{
	MDProcedureConditionsMode_ANY,
	MDProcedureConditionsMode_ALL,
	MDProcedureConditionsMode_NONE,
}
MDProcedureConditionsMode;


@interface MDProcedure : NSObject
@property MDProcedureConditionsMode conditionsMode;

+ (MDProcedure *) procedureWithMode:(MDProcedureConditionsMode)m;
- (BOOL) evaluateConditions;
- (void) processPattern:(MDPatternPublicWrapper *) pattern kit: (MDKit *)kit;
- (void) addCondition:(MDProcedureCondition *)c;
- (void) removeConditionAtIndex:(NSUInteger)i;
- (void) removeFirstCondition;
- (void) removeLastCondition;
- (void) clearConditions;
@end
