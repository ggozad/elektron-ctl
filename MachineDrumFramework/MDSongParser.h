//
//  MDSongParser.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 6/30/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MDSong;

@interface MDSongParser : NSObject
+ (NSData *) sysexDataFromSong:(MDSong *)song;
+ (MDSong *) songFromSysexData:(NSData *)data;
@end
