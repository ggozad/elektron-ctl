//
//  MDParameterLockRow.h
//  sysexingApp
//
//  Created by Jakob Penca on 6/14/12.
//
//

#import <Foundation/Foundation.h>
#import "MDParameterLock.h"
@interface MDParameterLockRow : NSObject
@property uint8_t track;
@property uint8_t param;
@property NSData *valueStepData;

+ (MDParameterLockRow *)parameterLockRowForLock:(MDParameterLock *)lock;
+ (MDParameterLockRow *)parameterLockRowForTrack:(uint8_t)track param: (uint8_t) param withValueStepData:(NSData *)data;
- (void) setStep:(uint8_t) step toValue: (int8_t) value;
- (BOOL) isEmpty;

@end
