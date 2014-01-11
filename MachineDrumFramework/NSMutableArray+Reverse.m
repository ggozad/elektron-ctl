//
//  NSMutableArray+Reverse.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 01/01/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import "NSMutableArray+Reverse.h"

@implementation NSMutableArray (Reverse)

- (void)reverse {
    if ([self count] == 0)
        return;
    NSUInteger i = 0;
    NSUInteger j = [self count] - 1;
    while (i < j) {
        [self exchangeObjectAtIndex:i
                  withObjectAtIndex:j];
		
        i++;
        j--;
    }
}

@end
