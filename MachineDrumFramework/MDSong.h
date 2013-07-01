//
//  MDSong.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 9/3/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDSong : NSObject
@property (nonatomic) uint8_t position;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray *rows;

+ (id) songWithSong:(MDSong *)song;
+ (id) songWithSysexData:(NSData *)data;
- (NSData *)sysexData;

@end
