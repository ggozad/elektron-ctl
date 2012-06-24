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
@property (readonly) uint8_t rowCount;
@property (readonly) uint8_t totalCount;
@property (weak, nonatomic) MDPattern *pattern;
@property (strong, nonatomic, readonly) NSMutableArray *lockRows;

- (void) clearLock:(MDParameterLock *)lock;
- (void) clearLocksAtTrack:(uint8_t)t step:(uint8_t)s;
- (BOOL) setLock:(MDParameterLock *)lock;
- (void) printRows;

@end
