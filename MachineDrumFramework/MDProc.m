//
//  MDProcedure.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 6/26/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDProc.h"
#import "MDProcedureCondition.h"

@interface MDProc()
@property (strong, nonatomic) NSMutableArray *conditions;
@end


@implementation MDProc

- (id)init
{
	if(self = [super init])
	{
		self.conditions = [NSMutableArray array];
	}
	return self;
}

- (void)processPattern:(MDPatternPublicWrapper *)pattern kit :(MDKit *)kit
{
	return;
}

+ (MDProc *)procedureWithMode:(MDProcedureConditionsMode)m
{
	MDProc *p = [self new];
	if(m < 2)
		p.conditionsMode = m;
	return p;
}

- (void)addCondition:(MDProcedureCondition *)c
{
	[self.conditions addObject:c];
}

- (BOOL)evaluateConditions
{
	if(![self.conditions count]) return YES;
	
	if(self.conditionsMode == MDProcedureConditionsMode_ALL)
	{
		for (MDProcedureCondition *c in self.conditions)
			if(![c isTrue]) return NO;
		return YES;
	}
	if(self.conditionsMode == MDProcedureConditionsMode_ANY)
	{
		for (MDProcedureCondition *c in self.conditions)
			if([c isTrue]) return YES;
		return NO;
	}
	if(self.conditionsMode == MDProcedureConditionsMode_NONE)
	{
		for (MDProcedureCondition *c in self.conditions)
			if([c isTrue]) return NO;
		return YES;
	}
	else return YES;
}

- (void)clearConditions
{
	[self.conditions removeAllObjects];
}

- (void)removeConditionAtIndex:(NSUInteger)i
{
	if(i < [self.conditions count]) [self.conditions removeObjectAtIndex:i];
}

- (void)removeFirstCondition
{
	if([self.conditions count]) [self.conditions removeObjectAtIndex:0];
}

- (void)removeLastCondition
{
	if([self.conditions count]) [self.conditions removeLastObject];
}

@end
