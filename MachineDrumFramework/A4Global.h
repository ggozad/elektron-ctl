//
//  A4Global.h
//  A4Sysex
//
//  Created by Jakob Penca on 3/31/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4SysexMessage.h"

typedef struct A4MultimapEntry
{
	uint8_t bytes[16];
}
A4MultimapEntry;

typedef struct A4Multimap
{
	A4MultimapEntry entries[128];
}
A4Multimap;

@interface A4Global : A4SysexMessage
@property (nonatomic) A4Multimap *multimap;
@property (nonatomic) double masterTune;
@property (nonatomic) BOOL quantizeLiveRecording;
@property (nonatomic) BOOL kitReloadOnChange;

@property (nonatomic) BOOL midiClockReceive, midiClockSend;
@end
