//
//  StandardMidiFile.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 09/02/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import "SMF.h"
#define kHeaderSize 14

@interface SMF()
@property (nonatomic) uint8_t *header;
@end

@implementation SMF

- (id)init
{
	if(self = [super init])
	{
		self.tracks = [NSMutableArray array];
		_header = malloc(kHeaderSize);
		uint8_t bytes[] =
		{
			'M', 'T', 'h', 'd',
			0, 0, 0, 6,
			0, 1,
			0, 0,
			0, 24
		};
		memmove(_header, bytes, 14);
	}
	return self;
}

- (NSData *)data
{
	_header[0x0B] = self.tracks.count;
	NSMutableData *d = [NSMutableData dataWithBytes:_header length:kHeaderSize];
	for(SMFTrack *trk in self.tracks)
	{
		[d appendData:trk.data];
	}
	return d;
}

- (void)setData:(NSData *)data
{
	NSAssert(data.length == kHeaderSize, @"invalid header length. must be %d bytes", kHeaderSize);
	const uint8_t *bytes = data.bytes;
	memmove(_header, bytes, kHeaderSize);
}

- (void)dealloc
{
	free(_header);
}

- (void)setFormat:(SMFFormat)format
{
	_header[0x09] = format;
}

- (SMFFormat)format
{
	return _header[0x09];
}

- (void)setTicksPerBeat:(uint16_t)ticksPerBeat
{
	ticksPerBeat &= 0x7FFF;
	uint16_t *ptr = (uint16_t *)(_header + 0xC);
	*ptr = CFSwapInt16(ticksPerBeat);
}

- (uint16_t)ticksPerBeat
{
	uint16_t *ptr = (uint16_t *)(_header + 0xC);
	return CFSwapInt16(*ptr);
}

@end
