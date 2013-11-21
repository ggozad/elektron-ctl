//
//  A4Timepiece.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 13/11/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface A4Timepiece : NSObject
+ (double) secondsBetweenClockTicks;
+ (void) tickWithTime:(double)time;
@end
