//
//  MDPatternParameterLocks.h
//  sysexingApp
//
//  Created by Jakob Penca on 6/14/12.
//
//

#import <Foundation/Foundation.h>
#import "MDParameterLock.h"
@class MDPattern;

@interface MDPatternParameterLocks : NSObject
@property uint8_t rowCount;
@property uint8_t totalCount;
@property (weak, nonatomic) MDPattern *pattern;
@property (strong, nonatomic) NSMutableArray *lockRows;


- (BOOL) setLock:(MDParameterLock *)lock;
- (void) printRows;

@end
