//
//  MDPatternTrack.h
//  sysexingApp
//
//  Created by Jakob Penca on 6/14/12.
//
//

#import <Foundation/Foundation.h>

@interface MDPatternTrack : NSObject
{
	@public
	int32_t trigPattern_00_31;
	int32_t trigPattern_32_63;

	int32_t slidePattern_00_31;
	int32_t slidePattern_32_63;

	int32_t accentPattern_00_31;
	int32_t accentPattern_32_63;

	int32_t swingPattern_00_31;
	int32_t swingPattern_32_63;
}

- (BOOL) trigAtStep:(NSUInteger) step;
- (BOOL) slideTrigAtStep:(NSUInteger) step;
- (BOOL) accentTrigAtStep:(NSUInteger) step;
- (BOOL) swingTrigAtStep:(NSUInteger) step;

- (void) setTrigAtStep:(NSUInteger) step to:(BOOL) active;
- (void) setSlideTrigAtStep:(NSUInteger) step to:(BOOL) active;
- (void) setAccentTrigAtStep:(NSUInteger) step to:(BOOL) active;
- (void) setswingTrigAtStep:(NSUInteger) step to:(BOOL) active;


@end
