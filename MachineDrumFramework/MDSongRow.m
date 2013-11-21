//
//  MDSongRow.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 6/30/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "MDSongRow.h"
#import "MDSysexUtil.h"

@implementation MDSongRow

- (id)init
{
	if(self = [super init])
	{
		self.stop = 16;
		self.tempo = INT16_MAX / 24.0;
	}
	return self;
}

- (BOOL)isTrackMuted:(uint8_t)track
{
	return self.mutes & (1 << track) ? 1 : 0;
}

- (void)setTrack:(uint8_t)track muted:(BOOL)mute
{
	uint16_t m =  1 << track;
	if(mute)
	{
		self.mutes |= m;
	}
	else
	{
		self.mutes &= ~m;
	}
}

+ (MDSongRow *)songRowWithSongRow:(MDSongRow *)songRow
{
	MDSongRow *row = [MDSongRow new];
	row.pattern = songRow.pattern;
	row.kit = songRow.kit;
	row.loopCount = songRow.loopCount;
	row.rowJump = songRow.rowJump;
	row.mutes = songRow.mutes;
	row.tempo = songRow.tempo;
	row.start = songRow.start;
	row.stop = songRow.stop;
	return row;
}

+ (MDSongRow *)songRowWithPattern:(uint8_t)pattern loop:(uint8_t)loopCount start:(uint8_t)strt stop:(uint8_t)stop tempo:(float)tempo
{
	MDSongRow *row = [MDSongRow new];
	row.pattern = pattern;
	row.loopCount = loopCount;
	row.start = strt;
	row.stop = stop;
	row.tempo = tempo;
	return row;
}

+ (MDSongRow *)endRow
{
	MDSongRow *row = [MDSongRow new];
	row.pattern = MDSongRowPatternPositionEnd;
	return row;
}

- (NSString *)description
{
	NSString *str = [super description];
	str = [str stringByAppendingFormat:@"\npattern: %03d", self.pattern];
	str = [str stringByAppendingFormat:@"\nkit:     %03d", self.kit];
	str = [str stringByAppendingFormat:@"\nloop:    %03d", self.loopCount];
	str = [str stringByAppendingFormat:@"\njump:    %03d", self.rowJump];
	str = [str stringByAppendingFormat:@"\nmutes:   %@", [MDSysexUtil getBitStringForInt:self.mutes]];
	str = [str stringByAppendingFormat:@"\ntempo:   %3.3f", self.tempo];
	str = [str stringByAppendingFormat:@"\nstart:   %03d", self.start];
	str = [str stringByAppendingFormat:@"\nstop:    %03d", self.stop];
	return str;
}

@end
