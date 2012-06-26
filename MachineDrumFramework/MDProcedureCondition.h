//
//  MDProcedureCondition.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 6/26/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum MDProcedureConditionEqualityOperator
{
	MDProcedureConditionEqualityOperator_LESS_THAN,
	MDProcedureConditionEqualityOperator_LESS_THAN_OR_EQUAL,
	MDProcedureConditionEqualityOperator_EQUAL,
	MDProcedureConditionEqualityOperator_GREATER_THAN,
	MDProcedureConditionEqualityOperator_GREATER_THAN_OR_EQUAL,
	MDProcedureConditionEqualityOperator_NOT_EQUAL,
}
MDProcedureConditionEqualityOperator;


@interface MDProcedureCondition : NSObject
@property MDProcedureConditionEqualityOperator equalityOperator;
@property uint8_t leftVal;
@property uint8_t rightVal;

- (BOOL) isTrue;
+ (MDProcedureCondition *) conditionWithLeftVal:(uint8_t) left rightVal:(uint8_t) right op: (MDProcedureConditionEqualityOperator) o;

@end
