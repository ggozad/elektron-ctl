//
//  MDPattern.h
//  sysexingApp
//
//  Created by Jakob Penca on 6/14/12.
//
//

#import <Foundation/Foundation.h>
#import "MDPatternTrack.h"
#import "MDPatternParameterLocks.h"
#import "MDPatternPrivate.h"

@interface MDPatternPrivate : NSObject
{
	@public
		int32_t accentPattern_00_31;
		int32_t accentPattern_32_63;
		
		int32_t swingPattern_00_31;
		int32_t swingPattern_32_63;
		
		int32_t slidePattern_00_31;
		int32_t slidePattern_32_63;
}
@property uint8_t originalPosition;
@property uint8_t accentAmount;
@property uint8_t length;
@property uint8_t tempoMultiplier;
@property uint8_t scale;
@property uint8_t kitNumber;
@property uint8_t numberOfLockedRows_UNUSED;
@property int32_t swingAmount;
@property BOOL accentEditAllFlag;
@property BOOL slideEditAllFlag;
@property BOOL swingEditAllFlag;


@property (strong, nonatomic) NSArray *tracks;
@property (strong, nonatomic) MDPatternParameterLocks *locks;

+ (id) patternWithData:(NSData *)data;
- (NSData *) sysexData;

- (BOOL) slideTrigAtStep:(NSUInteger) step;
- (BOOL) accentTrigAtStep:(NSUInteger) step;
- (BOOL) swingTrigAtStep:(NSUInteger) step;

- (void) setSlideTrigAtStep:(NSUInteger) step to:(BOOL) active;
- (void) setAccentTrigAtStep:(NSUInteger) step to:(BOOL) active;
- (void) setswingTrigAtStep:(NSUInteger) step to:(BOOL) active;

@end
