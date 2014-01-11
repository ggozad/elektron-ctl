//
//  NSArray+Reverse.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 01/01/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import "NSArray+Reverse.h"

@implementation NSArray (Reverse)

- (NSArray *)reversedArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}

@end
