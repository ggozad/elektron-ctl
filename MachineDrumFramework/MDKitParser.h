//
//  MDKitParser.h
//  sysexingApp
//
//  Created by Jakob Penca on 6/11/12.
//
//

#import <Foundation/Foundation.h>
#import "MDKit.h"

@interface MDKitParser : NSObject


+ (MDKit *) kitFromSysexData: (NSData *)data;
+ (NSData *) sysexDataFromKit: (MDKit *) kit;


@end
