//
//  A4Queues.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 09/12/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4Queues.h"

@implementation A4Queues

static dispatch_queue_t sysexQueue, realtimeQueue, voiceQueue;

static dispatch_queue_t getSysexQueue()
{
	if(sysexQueue == NULL)
	{
		sysexQueue = dispatch_queue_create("sysex", NULL);
	}
	return sysexQueue;
}

static dispatch_queue_t getRealtimeQueue()
{
	if(realtimeQueue == NULL)
	{
		realtimeQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
	}
	return realtimeQueue;
}

static dispatch_queue_t getVoiceQueue()
{
	if(voiceQueue == NULL)
	{
		voiceQueue = dispatch_queue_create("voice", NULL);
	}
	return voiceQueue;
}

+ (dispatch_queue_t)sysexQueue
{
	return getSysexQueue();
}

+ (dispatch_queue_t)voiceQueue
{
	return getVoiceQueue();
}

+ (dispatch_queue_t)realtimeQueue
{
	return getRealtimeQueue();
}

@end
