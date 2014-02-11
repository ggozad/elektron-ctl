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
		self.events = [NSMutableArray array];
	}
	return self;
}

- (NSData *)data
{
	uint8_t trackHeader[] = {'M', 'T', 'r', 'k', 0, 0, 0, 0};
	UInt32 *eventByteCount = (UInt32 *)&trackHeader[7];
	NSMutableData *eventsData = [NSMutableData data];
	for (SMFEvent *event in self.events)
	{
		NSData *d = event.data;
		*eventByteCount += d.length;
		[eventsData appendData:d];
	}
	
	*eventByteCount += 4;
	
	NSMutableData *trackData = [NSMutableData dataWithBytes:trackHeader length:8];
	[trackData appendData:eventsData];
	
	static uint8_t eof[] = {0x00, 0xFF, 0x2F, 0x00};
	[trackData appendBytes:eof length:4];
	
	return trackData;
}

- (void)insertEvent:(SMFEvent *)event
{
	if(!self.events.count)
	{
		event.delta = event.absoluteTick;
		[self.events addObject:event];
	}
	else if(self.events.count == 1)
	{
		SMFEvent *existingEvent =  self.events[0];
		if(existingEvent.absoluteTick <= event.absoluteTick)
		{
			NSUInteger delta = event.absoluteTick - existingEvent.absoluteTick;
			event.delta = delta;
			[self.events addObject:event];
		}
		else
		{
			NSUInteger delta = existingEvent.absoluteTick - event.absoluteTick;
			existingEvent.delta = delta;
			event.delta = event.absoluteTick;
			[self.events insertObject:event atIndex:0];
		}
	}
	else
	{
		SMFEvent *prevEvent = nil, *nextEvent = nil;
		for(SMFEvent *e in self.events)
		{
			if(e.absoluteTick > event.absoluteTick)
			{
				nextEvent = e; break;
			}
		}
		
		NSUInteger idx = nextEvent ? [self.events indexOfObject:nextEvent] : 0;
		if(nextEvent && idx)
		{
			prevEvent = self.events[idx-1];
		}
		else
		{
			prevEvent = [self.events lastObject];
		}
		
		
		if(prevEvent)
		{
			event.delta = event.absoluteTick - prevEvent.absoluteTick;
		}
		else
		{
			event.delta = event.absoluteTick;
		}
		
		if(nextEvent)
		{
			nextEvent.delta = nextEvent.absoluteTick - event.absoluteTick;
			[self.events insertObject:event atIndex:idx];
		}
		else
		{
			[self.events addObject:event];
		}
	}
}


@end
