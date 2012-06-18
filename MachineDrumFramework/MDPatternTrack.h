//
//  MDPatternTrack.h
//  sysexingApp
//
//  Created by Jakob Penca on 6/14/12.
//
//

#import <Foundation/Foundation.h>

@interface MDPatternTrack : NSObject

@property int32_t trigPattern_00_31;
@property int32_t trigPattern_32_63;

@property int32_t slidePattern_00_31;
@property int32_t slidePattern_32_63;

@property int32_t accentPattern_00_31;
@property int32_t accentPattern_32_63;

@property int32_t swingPattern_00_31;
@property int32_t swingPattern_32_63;

- (BOOL) hasTrigAtStep:(NSUInteger) step;
- (void) setTrigAtStep:(NSUInteger) step to:(BOOL) active;
@end
