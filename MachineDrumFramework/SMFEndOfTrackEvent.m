//
//  SMFEndOfTrackEvent.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 12/02/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import "SMFEndOfTrackEvent.h"

@implementation SMFEndOfTrackEvent

+ (instancetype)smfEndOfTrackEventWithAbsoluteTick:(NSUInteger)tick
{
	uint8_t eof[] = {0xFF, 0x2F, 0x00};
	SMFEndOfTrackEvent *event = [self smfEventWithAbsoluteTick:tick bytes:eof length:3];
	return event;
}

+ (instancetype)smfEndOfTrackEventWithDelta:(NSUInteger)tick
{
	uint8_t eof[] = {0xFF, 0x2F, 0x00};
	SMFEndOfTrackEvent *event = [self smfEventWithDelta:tick bytes:eof length:3];
	return event;
}

@end
