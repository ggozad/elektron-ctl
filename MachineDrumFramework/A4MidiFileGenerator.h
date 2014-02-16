//
//  A4MidiFileGenerator.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 11/02/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>

@class A4Pattern;

@interface A4MidiFileGenerator : NSObject

+ (NSData *)smfDataForPattern:(A4Pattern *)pattern;

@end
