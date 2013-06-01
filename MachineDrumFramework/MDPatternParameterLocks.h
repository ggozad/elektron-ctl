//
//  MDPatternParameterLocks.h
//  sysexingApp
//
//  Created by Jakob Penca on 6/14/12.
//
//

#import <Foundation/Foundation.h>
#import "MDParameterLock.h"
@class MDPatternPrivate;

@interface MDPatternParameterLocks : NSObject
@property (readonly) uint8_t rowCount;
@property (readonly) uint8_t totalCount;
@property (weak, nonatomic) MDPatternPrivate *pattern;
@property (strong, nonatomic, readonly) NSMutableArray *lockRows;

- (void) clearLock:(MDParameterLock *)lock;
- (void) clearLocksAtTrack:(uint8_t)t step:(uint8_t)s;
- (BOOL) setLock:(MDParameterLock *)lock;
- (MDParameterLock *)lockAtTrack:(uint8_t)track step:(uint8_t)step param:(uint8_t)param;
- (BOOL) hasLockAtTrack:(uint8_t)track step:(uint8_t) step;
- (void) printRows;

@end
