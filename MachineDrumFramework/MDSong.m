//
//  MDSong.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 9/3/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDSong.h"
#import "MDSongParser.h"

@implementation MDSong

- (id)init
{
	if(self = [super init])
	{
		self.rows = [NSMutableArray array];
		self.name = @"";
	}
	return self;
}

+ (id)songWithSysexData:(NSData *)data
{
	return [MDSongParser songFromSysexData:data];
}

+ (id)songWithSong:(MDSong *)song
{
	return [MDSongParser songFromSysexData:song.sysexData];
}

- (NSData *)sysexData
{
	return [MDSongParser sysexDataFromSong:self];
}

@end
