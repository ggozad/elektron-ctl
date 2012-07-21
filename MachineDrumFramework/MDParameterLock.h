//
//  MDParameterLock.h
//  sysexingApp
//
//  Created by Jakob Penca on 6/14/12.
//
//

#import <Foundation/Foundation.h>

@interface MDParameterLock : NSObject
@property NSUInteger track;
@property NSUInteger param;
@property NSUInteger step;
@property NSInteger lockValue;

+ (MDParameterLock*) lockForTrack:(NSUInteger)track param:(NSUInteger)p step:(NSUInteger)s value: (NSInteger) v;
- (id)copy;

@end
