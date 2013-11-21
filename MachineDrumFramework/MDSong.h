//
//  MDSong.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 9/3/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MDSongRow;

@interface MDSong : NSObject
@property (nonatomic) uint8_t position;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray *rows;

+ (id) song;
+ (id) songWithSong:(MDSong *)song;
+ (id) songWithSysexData:(NSData *)data;
- (NSData *)sysexData;

- (void) addRow:(MDSongRow *)row;
- (void) removeRow:(MDSongRow *)row;

- (void) splicePattern:(uint8_t)pattern
			   intoRow:(MDSongRow *)row
		   masterStart:(uint8_t)mstart
			masterStop:(uint8_t)mstop
			 fillStart:(uint8_t)fstart
			  fillStop:(uint8_t)fstop;

@end
