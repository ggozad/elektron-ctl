//
//  MDSong.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 9/3/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDSong.h"
#import "MDSongParser.h"
#import "MDSongRow.h"

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

+ (id)song
{
	MDSong *s = [MDSong new];
	[s.rows addObject:[MDSongRow endRow]];
	return s;
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

- (void)addRow:(MDSongRow *)row
{
	[self.rows insertObject:row atIndex:[self.rows indexOfObject:self.rows.lastObject]];
}

- (void)removeRow:(MDSongRow *)row
{
	[self.rows removeObject:row];
}

- (void)splicePattern:(uint8_t)pattern
			  intoRow:(MDSongRow *)row
		  masterStart:(uint8_t)mstart
		   masterStop:(uint8_t)mstop
			fillStart:(uint8_t)fstart
			 fillStop:(uint8_t)fstop
{
	if(row.tempo < 30 || row.tempo > 300)
	{
		DLog(@"row tempo out of bounds: %f", row.tempo);
		return;
	}
	
	int mLen = mstop - mstart;
	int fLen = fstop - fstart;
	float ratio = (float)fLen / (float)mLen;
	float fTempo = row.tempo * ratio;
	if(fTempo < 30 || fTempo > 300)
	{
		DLog(@"fill tempo out of bounds: %f", fTempo);
		return;
	}
	
	MDSongRow *spliceRow = [MDSongRow songRowWithPattern:pattern loop:0 start:fstart stop:fstop tempo:fTempo];
	
	if(mstart > 0 && mstop < row.stop - row.start)
	{
		MDSongRow *headRow = [MDSongRow songRowWithSongRow:row];
		headRow.stop = mstart + row.start;
		
		MDSongRow *tailRow = [MDSongRow songRowWithSongRow:row];
		tailRow.start = mstop + row.start;
		
		int i = [self.rows indexOfObject:row];
		[self.rows removeObject:row];
		[self.rows insertObject:tailRow atIndex:i];
		[self.rows insertObject:spliceRow atIndex:i];
		[self.rows insertObject:headRow atIndex:i];
	}
	else if(mstart == 0 && mstop < row.stop - row.start)
	{
		MDSongRow *tailRow = [MDSongRow songRowWithSongRow:row];
		tailRow.start = mstop + row.start;
		int i = [self.rows indexOfObject:row];
		[self.rows removeObject:row];
		[self.rows insertObject:tailRow atIndex:i];
		[self.rows insertObject:spliceRow atIndex:i];
	}
	else if(mstart > 0 && mstop == row.stop - row.start)
	{
		MDSongRow *headRow = [MDSongRow songRowWithSongRow:row];
		headRow.stop = mstart + row.start;
		int i = [self.rows indexOfObject:row];
		[self.rows removeObject:row];
		[self.rows insertObject:spliceRow atIndex:i];
		[self.rows insertObject:headRow atIndex:i];
	}
	else
	{
		DLog(@"arrrgghh");
	}
}

@end
