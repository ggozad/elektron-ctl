//
//  MDPatternPublicWrapper.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 6/19/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDPatternPrivate.h"

typedef enum MDPatternScale
{
	MDPatternScale_16,
	MDPatternScale_32,
	MDPatternScale_48,
	MDPatternScale_64
}
MDPatternScale;

@interface MDPattern : NSObject

+ (MDPattern *) pattern;
+ (MDPattern *) patternWithData:(NSData *)sysexData;
+ (MDPattern *) patternWithPattern:(MDPattern *)inPattern;

- (void) setSavePosition:(uint8_t)slot;
- (void) setKitNumber:(uint8_t)kit;
- (void) setLength:(uint8_t)len;
- (void) setScale:(MDPatternScale)scale;
- (void) setTrigAtTrack: (uint8_t) track step: (uint8_t) step toValue: (BOOL) val;
- (void) toggleTrigAtTrack:(uint8_t) track step: (uint8_t) step;
- (BOOL) trigAtTrack: (uint8_t) track step: (uint8_t) step;
- (MDParameterLock *)lockAtTrack:(uint8_t)track step:(uint8_t)step param:(uint8_t)param;
- (BOOL) setLock:(MDParameterLock *)lock setTrigIfNone:(BOOL)setTrig;
- (void) clearLockAtTrack:(uint8_t)t param:(uint8_t)p step:(uint8_t)s clearTrig:(BOOL) clearTrig;
- (void) clearLock:(MDParameterLock *)lock clearTrig:(BOOL) clearTrig;
- (uint8_t) numberOfUniqueLocks;


- (NSData *)sysexData;

@end
