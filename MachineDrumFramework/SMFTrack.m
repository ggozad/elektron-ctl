//
//  StandardMidiFileTrack.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 09/02/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import "SMFTrack.h"

@implementation SMFTrack


- (id)init
{
	if (self = [super init])
	{
		self.trackEvents = [NSMutableArray array];
	}
	return self;
}

- (NSData *)data
{
	NSMutableData *data = [NSMutableData data];
	NSUInteger eventByteCount = 0;
	for (SMFEvent *event in self.trackEvents)
	{
		NSData *eventData = event.data;
		eventByteCount += eventData.length;
		[data appendData:eventData];
	}
}

@end
