//
//  MDValueMap.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 9/3/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDValueMap.h"
#import "MDValuePair.h"
#import "MDMath.h"

@interface MDValueMap()
@property uint8_t *mapping;
@end

@implementation MDValueMap

- (void) sortValuePairs
{
	[self.valuePairs sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
	 {
		 MDValuePair *p1 = obj1;
		 MDValuePair *p2 = obj2;
		 if(p1.x > p2.x) return NSOrderedDescending;
		 else if(p1.x == p2.x) return NSOrderedSame;
		 return NSOrderedAscending;
	 }];
}

- (void) updateMapping
{
	for (MDValuePair *p in self.valuePairs)
	{
		if(p.y > 1) p.y = 1;
		if(p.y < 0) p.y = 0;
		if(p.x < 0) p.x = 0;
		if(p.x > 1) p.x = 1;
	}
	
	[self sortValuePairs];
	if([self.valuePairs count] < 2) return;
	
	for(int x = 0; x < 127; x++)
    {
		float fx = mdmath_map(x, 0, 127, 0, 1);
		
		MDValuePair *a = [self.valuePairs objectAtIndex:0];
		for (MDValuePair *v in self.valuePairs)
		{
			if (v.x < fx) a = v;
			else break;
		}
		
		int i = [self.valuePairs indexOfObject:a];
		MDValuePair *b = a;
		if(i < [self.valuePairs count])
			b = [self.valuePairs objectAtIndex:i+1];
		
		float deltaBetweenPoints = b.x - a.x;
		float biasOfFX = mdmath_map(b.x - fx, 0, deltaBetweenPoints, 0, 1);
		uint8_t y = roundf(a.y*127.0*biasOfFX + b.y*127.0*(1.0-biasOfFX));
		//DLog(@"%d - %d", );
		//uint8_t x = y;
		//if(x > 127) x = 127;
		self.mapping[x] = y;
    }
}

- (id)init
{
	if(self = [super init])
	{
		self.mapping = malloc(128);
		memset(self.mapping, 0, 128);
		self.valuePairs = [NSMutableArray array];
		MDValuePair *v0 = [MDValuePair new];
		MDValuePair *v1 = [MDValuePair new];
		v1.x = 1;
		v1.y = 1;
		[self.valuePairs addObject:v0];
		[self.valuePairs addObject:v1];
		[self updateMapping];
	}
	return self;
}

- (uint8_t)valueAtIndex:(uint8_t)index
{
	if(index > 127) index = 127;
	DLog(@"returning mapping at %d: %d", index, self.mapping[index]);
	return self.mapping[index];
}

- (void)dealloc
{
	free(self.mapping);
}

@end
