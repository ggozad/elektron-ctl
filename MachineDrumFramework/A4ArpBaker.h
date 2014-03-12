//
//  A4ArpBaker.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 27/02/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A4Pattern.h"

@interface A4ArpBaker : NSObject

- (A4Pattern *) bakeArpInPattern:(A4Pattern *)pattern track:(uint8_t)trackIdx;

@end
