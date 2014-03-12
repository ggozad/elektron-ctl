//
//  MDMarkovChain.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 02/03/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDMarkovChain : NSObject
@property (nonatomic, copy) NSArray *inputSequence;
- (NSArray *)outputSequenceWithLength:(NSUInteger)len order:(NSUInteger)order;
@end
