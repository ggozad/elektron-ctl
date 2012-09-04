//
//  MDValueMap.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 9/3/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MDValuePair;

@interface MDValueMap : NSObject
@property (strong, nonatomic) NSMutableArray *valuePairs;
- (void) updateMapping;
- (uint8_t) valueAtIndex:(uint8_t)index;
@end
