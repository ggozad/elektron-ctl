//
//  MDMarkovChain.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 02/03/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import "MDMarkovChain.h"
#import "MDMath.h"


@interface MDMarkovChain()
@property (nonatomic, strong) NSMutableArray *uniqueOccurences;
@end

@implementation MDMarkovChain


- (void)setInputSequence:(NSArray *)inputSequence
{
	_inputSequence = [inputSequence copy];
	_uniqueOccurences = [NSMutableArray array];
	
	
	for(id obj in _inputSequence)
	{
		BOOL isAlreadyInUniqueArray = NO;
		for(id uniqueObj in _uniqueOccurences)
		{
			if([obj isEqual:uniqueObj])
			{
				isAlreadyInUniqueArray = YES;
			}
		}
		
		if(!isAlreadyInUniqueArray)
		{
			[_uniqueOccurences addObject:obj];
		}
	}
	
}

- (NSArray *)outputSequenceWithLength:(NSUInteger)len order:(NSUInteger)order
{
	if(len < 1 ||
	   !_inputSequence ||
	   !_inputSequence.count ||
	   order > 32)
	{
		 return nil;
	}
	
	NSMutableArray *outputSequence = [NSMutableArray array];
	NSUInteger inputLength = _inputSequence.count;
	NSUInteger initialIdx = mdmath_randi(0, _inputSequence.count-1);
	
	for(int i = 0; i < order+1; i++)
	{
		NSUInteger idx = mdmath_wrap(initialIdx + i, 0, inputLength-1);
		id obj = _inputSequence[idx];
		[outputSequence addObject:obj];
	}
	
	if(outputSequence.count < len)
	{
		NSMutableArray *target = [NSMutableArray arrayWithArray:outputSequence];
		NSMutableArray *matchCount = [NSMutableArray array];
		NSUInteger num = len - outputSequence.count;
		for(NSUInteger i = 0; i < num; i++)
		{
			if(order == 0)
			{
				[outputSequence addObject:_inputSequence[mdmath_randi(0, inputLength-1)]];
			}
			else
			{
				[matchCount removeAllObjects];
				for(NSUInteger i = 0; i < _uniqueOccurences.count; i++)
				{
					[matchCount addObject:@(0)];
				}
				
				NSUInteger maxMatch = 0;
				NSUInteger inputCnt = 0;
				for(id obj in _inputSequence)
				{
					if([obj isEqual:target[0]])
					{
						BOOL matchesTarget = YES;
						NSUInteger idxInTargtSequence = 0;
						NSUInteger idxInInputSequence = inputCnt;
						
						for(NSUInteger matchIdx = 0; matchIdx < order+1; matchIdx++)
						{
							id objInInputSequence = _inputSequence[mdmath_wrap(idxInInputSequence, 0, inputLength-1)];
							id objInTargetSequence = target[idxInTargtSequence];
															
							if(![objInInputSequence isEqualTo:objInTargetSequence])
							{
								matchesTarget = NO; break;
							}
							
							idxInTargtSequence++;
							idxInInputSequence++;
						}
						
						if(matchesTarget)
						{
							NSUInteger nextObjIdx = mdmath_wrap(idxInInputSequence, 0, inputLength-1);
							id nextObj = _inputSequence[nextObjIdx];
							for(id uniqueObj in _uniqueOccurences)
							{
								if([uniqueObj isEqual:nextObj])
								{
									NSUInteger idxOfUniqueMatchingObject = [_uniqueOccurences indexOfObject:uniqueObj];
									NSNumber *n = matchCount[idxOfUniqueMatchingObject];
									n = @(n.intValue + 1);
									[matchCount replaceObjectAtIndex:idxOfUniqueMatchingObject withObject:n];
									maxMatch = MAX(maxMatch, n.intValue);
								}
								
							}
						}
					}
					inputCnt++;
				}
				
				while(1)
				{
					id nextObject = nil;
					NSUInteger randMatch = mdmath_rand(0, 1) * maxMatch;
					maxMatch = 0;
					NSUInteger strtIdx = mdmath_randi(0, _uniqueOccurences.count-1);
					
					for(NSUInteger i = 0; i < _uniqueOccurences.count; i++)
					{
						NSUInteger iWrapped = mdmath_wrap(i+strtIdx, 0, _uniqueOccurences.count-1);
						NSUInteger cnt = [matchCount[iWrapped] intValue];
						if(cnt > randMatch)
						{
							nextObject = _uniqueOccurences[iWrapped];
							break;
						}
					}
					
					if(nextObject != nil)
					{
						[outputSequence addObject:nextObject];
						[target removeAllObjects];
						for(NSUInteger tgtIdx = outputSequence.count - order - 1; tgtIdx < outputSequence.count; tgtIdx++)
						{
							[target addObject:outputSequence[tgtIdx]];
						}
						
						break;
					}
				}
			}
		}
	}
	return outputSequence;
}


@end
