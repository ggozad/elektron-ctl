//
//  A4SysexHelper.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 9/9/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A4Params.h"
#import "A4PVal.h"

@class A4Sound, A4Kit, A4Pattern;

@interface A4SysexHelper : NSObject
+ (void)setName:(NSString *)name inPayloadLocation:(void *)location;
+ (NSString *)nameAtPayloadLocation:(const void *)location;
+ (NSString *)a4PValDescriptionForPVal:(A4PVal) pVal;
+ (NSString *)patternStorageStringForSlot:(uint8_t)slot;

+ (BOOL) soundIsEqualToDefaultSound:(A4Sound *)sound;
+ (BOOL) sound:(A4Sound *)soundA isEqualToSound:(A4Sound *)soundB;

+ (BOOL) kitIsEqualToDefaultKit:(A4Kit *)kit;
+ (BOOL) kit:(A4Kit *)kitA isEqualToKit:(A4Kit *)kitB;

+ (BOOL) patternIsEqualToDefaultPattern:(A4Pattern *)pattern;
+ (BOOL) pattern:(A4Pattern *)patternA isEqualToPattern:(A4Pattern *)patternB;


@end
