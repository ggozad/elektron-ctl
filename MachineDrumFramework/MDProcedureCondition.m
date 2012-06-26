//
//  MDProcedureCondition.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 6/26/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDProcedureCondition.h"

@implementation MDProcedureCondition

- (BOOL)isTrue
{
	if(self.equalityOperator == MDProcedureConditionEqualityOperator_EQUAL)
	{
		if(self.leftVal == self.rightVal) return YES;
		return NO;
	}
	if(self.equalityOperator == MDProcedureConditionEqualityOperator_NOT_EQUAL)
	{
		if(self.leftVal != self.rightVal) return YES;
		return NO;
	}
	if(self.equalityOperator == MDProcedureConditionEqualityOperator_LESS_THAN)
	{
		if(self.leftVal < self.rightVal) return YES;
		return NO;
	}
	if(self.equalityOperator == MDProcedureConditionEqualityOperator_LESS_THAN_OR_EQUAL)
	{
		if(self.leftVal <= self.rightVal) return YES;
		return NO;
	}
	if(self.equalityOperator == MDProcedureConditionEqualityOperator_GREATER_THAN)
	{
		if(self.leftVal > self.rightVal) return YES;
		return NO;
	}
	if(self.equalityOperator == MDProcedureConditionEqualityOperator_GREATER_THAN_OR_EQUAL)
	{
		if(self.leftVal >= self.rightVal) return YES;
		return NO;
	}
	return NO;
}

+ (MDProcedureCondition *)conditionWithLeftVal:(uint8_t)left rightVal:(uint8_t)right op:(MDProcedureConditionEqualityOperator)o
{
	MDProcedureCondition *c = [MDProcedureCondition new];
	c.leftVal = left;
	c.rightVal = right;
	if(o <= 5 ) c.equalityOperator = o;
	return c;
}

@end
