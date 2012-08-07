//
//  MDPatternParser.h
//  sysexingApp
//
//  Created by Jakob Penca on 6/14/12.
//
//

#import <Foundation/Foundation.h>
#import "MDPatternPrivate.h"

@interface MDPatternParser : NSObject

+ (MDPatternPrivate *)patternFromSysexData:(NSData *)data;
+ (NSData *) sysexDataFromPattern:(MDPatternPrivate *) pattern;

@end
