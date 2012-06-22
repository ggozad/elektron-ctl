//
//  MDParameterLock.h
//  sysexingApp
//
//  Created by Jakob Penca on 6/14/12.
//
//

#import <Foundation/Foundation.h>

@interface MDParameterLock : NSObject
@property (readonly) NSUInteger track;
@property (readonly) NSUInteger param;
@property (readonly) NSUInteger step;
@property (readonly) NSInteger lockValue;

+ (MDParameterLock*) lockForTrack:(NSUInteger)track param:(NSUInteger)p step:(NSUInteger)s value: (NSInteger) v;

@end
