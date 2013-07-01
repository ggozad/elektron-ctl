//
//  MDPatternPublicWrapper.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 6/19/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MDPatternPrivate;
@class MDParameterLock;

typedef enum MDPatternScale
{
	MDPatternScale_16,
	MDPatternScale_32,
	MDPatternScale_48,
	MDPatternScale_64
}
MDPatternScale;

@interface MDPattern : NSObject

@property MDPatternScale scale;
@property uint8_t length;
@property uint8_t tempoMultiplier;
@property (nonatomic) uint8_t swingAmount;
@property (nonatomic) uint8_t accentAmount;
@property (nonatomic) BOOL accentEditAllFlag;
@property (nonatomic) BOOL slideEditAllFlag;
@property (nonatomic) BOOL swingEditAllFlag;

+ (MDPattern *) pattern;
+ (MDPattern *) patternWithData:(NSData *)sysexData;
+ (MDPattern *) patternWithPattern:(MDPattern *)inPattern;

- (void) setSavePosition:(uint8_t)slot;
- (uint8_t)savePosition;

- (BOOL) isEmpty;
- (void) setKitNumber:(uint8_t)kit;
- (uint8_t)kitNumber;
- (void) setTrigAtTrack: (uint8_t) track step: (uint8_t) step toValue: (BOOL) val;
- (void) toggleTrigAtTrack:(uint8_t) track step: (uint8_t) step;
- (BOOL) trigAtTrack: (uint8_t) track step: (uint8_t) step;
- (BOOL) hasLockAtTrack:(uint8_t) track step: (uint8_t) step;
- (MDParameterLock *)lockAtTrack:(uint8_t)track step:(uint8_t)step param:(uint8_t)param;
- (BOOL) setLock:(MDParameterLock *)lock setTrigIfNone:(BOOL)setTrig;
- (void) clearLockAtTrack:(uint8_t)t param:(uint8_t)p step:(uint8_t)s clearTrig:(BOOL) clearTrig;
- (void) clearLock:(MDParameterLock *)lock clearTrig:(BOOL) clearTrig;
- (uint8_t) numberOfUniqueLocks;

- (BOOL) globalSlideTrigAtStep:(NSUInteger) step;
- (BOOL) globalAccentTrigAtStep:(NSUInteger) step;
- (BOOL) globalSwingTrigAtStep:(NSUInteger) step;

- (void) setGlobalSlideTrigAtStep:(NSUInteger) step to:(BOOL) active;
- (void) setGlobalAccentTrigAtStep:(NSUInteger) step to:(BOOL) active;
- (void) setGlobalSwingTrigAtStep:(NSUInteger) step to:(BOOL) active;

- (BOOL) slideTrigAtTrack:(NSUInteger)track step:(NSUInteger) step;
- (BOOL) accentTrigAtTrack:(NSUInteger)track step:(NSUInteger) step;
- (BOOL) swingTrigAtTrack:(NSUInteger)track step:(NSUInteger) step;

- (void) setSlideTrigAtTrack:(NSUInteger)track step:(NSUInteger) step to:(BOOL) active;
- (void) setAccentTrigAtTrack:(NSUInteger)track step:(NSUInteger) step to:(BOOL) active;
- (void) setswingTrigAtTrack:(NSUInteger)track step:(NSUInteger) step to:(BOOL) active;

- (NSData *)sysexData;

@end
