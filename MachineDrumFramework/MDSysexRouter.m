//
//  MDSysexRouter.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 6/18/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDSysexRouter.h"
#import "MDMachinedrumPublic.h"

#define kKitDumpMessageID 0x52
#define kPatternDumpMessageID 0x67

#define kTurboMIDISpeedRequestID 0x10
#define kTurboMIDISpeedAnswerID 0x11





@interface MDSysexRouter()
+ (BOOL) dataStartsWithMachineDrumHeader:(NSData *)data;
+ (BOOL) dataStartsWithTurboMIDIHeader:(NSData *)data;
+ (BOOL) dataStartsWithAssumedTM1Header:(NSData *)data;
@end

@implementation MDSysexRouter

+ (void)routeSysexData:(NSData *)data
{
	if(data.length < 8)
	{
		DLog(@"data too short. ignoring.");
		return;
	}
	
	if([self dataStartsWithMachineDrumHeader:data])
	{
		const uint8_t *bytes = data.bytes;
		uint8_t messageID = bytes[0x06];
		
		 
		
		switch (messageID)
		{
			case kKitDumpMessageID:
			{
				[[NSNotificationCenter defaultCenter]
				 postNotificationName:kMDSysexKitDumpNotification
				 object:data];
				
				break;
			}
			case kPatternDumpMessageID:
			{
				DLog(@"forwarding pattern version 0x%x revision 0x%x", bytes[0x07], bytes[0x08]);
				[[NSNotificationCenter defaultCenter]
				 postNotificationName:kMDSysexPatternDumpNotification
				 object:data];
				
				break;
			}
			default:
			{
				DLog(@"unimplemented machinedrum message ID: 0x%X", messageID);
				break;
			}
		}
	}
	else if([self dataStartsWithTurboMIDIHeader:data])
	{
		DLog(@"got turboMIDI message");
		
		const uint8_t *bytes = data.bytes;
		uint8_t messageID = bytes[0x06];
		
		switch (messageID)
		{
			case kTurboMIDISpeedAnswerID:
			{
				DLog(@"forwarding speed answer.");
				[[NSNotificationCenter defaultCenter] postNotificationName:kMDturboMIDISpeedAnswer
																	object:data];
				break;
			}
			default:
				break;
		}
	}
	else if([self dataStartsWithAssumedTM1Header:data])
	{
		DLog(@"got message from TM-1(?), ignoring.");
	}
	else
	{
		DLog(@"unknown header, ignoring.");
	}
}

+ (BOOL)dataStartsWithAssumedTM1Header:(NSData *)data
{
	const uint8_t *bytes = data.bytes;
	const uint8_t header[] = {0xf0, 0x00, 0x20, 0x3c, 0x04, 0x00};
	for (int i = 0; i < 6; i++)
		if(bytes[i] != header[i]) return NO;
	
	return YES;
}

+ (BOOL)dataStartsWithTurboMIDIHeader:(NSData *)data
{
	const uint8_t *bytes = data.bytes;
	const uint8_t header[] = {0xf0, 0x00, 0x20, 0x3c, 0x00, 0x00};
	for (int i = 0; i < 6; i++)
		if(bytes[i] != header[i]) return NO;
	
	return YES;
}


+ (BOOL)dataStartsWithMachineDrumHeader:(NSData *)data
{
	const uint8_t *bytes = data.bytes;
	const uint8_t mdHeader[] = {0xf0, 0x00, 0x20, 0x3c, 0x02, 0x00};
	for (int i = 0; i < 6; i++)
		if(bytes[i] != mdHeader[i]) return NO;
	
	return YES;
}

@end
