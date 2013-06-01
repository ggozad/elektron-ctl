//
//  MDSysexRouter.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 6/18/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDSysexRouter.h"
#import "MDMachinedrumPublic.h"

#define kStatusResponseID 0x72
#define kKitDumpMessageID 0x52
#define kPatternDumpMessageID 0x67
#define kGlobalSettingsDumpMessageID 0x50
#define kSetSampleNameMessageID 0x73

#define kTurboMIDISpeedRequestID 0x10
#define kTurboMIDISpeedAnswerID 0x11
#define kTurboMIDISpeedNegotiationID 0x12
#define kTurboMIDISpeedAcknowledgementID 0x13
#define kTurboMIDISpeedTestID 0x14
#define kTurboMIDISpeedTestResultID 0x15

@interface MDSysexRouter()
+ (BOOL) dataStartsWithA4Header:(NSData *)data;
+ (BOOL) dataStartsWithMachineDrumHeader:(NSData *)data;
+ (BOOL) dataStartsWithTurboMIDIHeader:(NSData *)data;
+ (BOOL) dataStartsWithAssumedTM1Header:(NSData *)data;
@end

@implementation MDSysexRouter

+ (void)routeSysexData:(NSData *)data
{
	if(data.length < 4)
	{
		DLog(@"data too short. ignoring.");
		return;
	}
	
	NSString *notificationName;
	
	if([self dataStartsWithMachineDrumHeader:data])
	{
		//DLog(@"got md message...");
		const uint8_t *bytes = data.bytes;
		uint8_t messageID = bytes[0x06];
		
		switch (messageID)
		{
			case kKitDumpMessageID:
			{
				notificationName = kMDSysexKitDumpNotification;
				break;
			}
			case kPatternDumpMessageID:
			{
				notificationName = kMDSysexPatternDumpNotification;
				break;
			}
			case kStatusResponseID:
			{
				notificationName = kMDSysexStatusResponseNotification;
				break;
			}
			case kGlobalSettingsDumpMessageID:
			{
				notificationName = kMDSysexGlobalSettingsDumpNotification;
				break;
			}
			case kSetSampleNameMessageID:
			{
				notificationName = kMDSysexSetSampleNameNotification;
				break;
			}
			default:
			{
				DLog(@"unimplemented machinedrum message ID: 0x%X", messageID);
				if(messageID == 0x62)
				{
					DLog(@"%@", data);
				}
				break;
			}
		}
	}
	else if([self dataStartsWithTurboMIDIHeader:data])
	{
		//DLog(@"got turboMIDI message");
		
		const uint8_t *bytes = data.bytes;
		uint8_t messageID = bytes[0x06];
		
		switch (messageID)
		{
			case kTurboMIDISpeedAnswerID:
			{
				notificationName = kMDturboMIDISpeedAnswer;
				break;
			}
			case kTurboMIDISpeedRequestID:
			{
				notificationName = kMDturboMIDISpeedRequest;
				break;
			}
			case kTurboMIDISpeedNegotiationID:
			{
				notificationName = kMDturboMIDISpeedNegotiation;
				break;
			}
			case kTurboMIDISpeedAcknowledgementID:
			{
				notificationName = kMDturboMIDISpeedAcknowledgement;
				break;
			}
			case kTurboMIDISpeedTestID:
			{
				notificationName = kMDturboMIDISpeedTest;
				break;
			}
			case kTurboMIDISpeedTestResultID:
			{
				notificationName = kMDturboMIDISpeedTestResult;
				break;
			}
			default:
				break;
		}
	}
	else if([self dataStartsWithA4Header:data])
	{
		notificationName = kA4SysexNotification;
	}
	else if([self dataStartsWithAssumedTM1Header:data])
	{
		DLog(@"got message from TM-1, ignoring.");
	}
	else if([self messageIsUniversalRealtimeMessage:data])
	{
		const uint8_t *bytes = data.bytes;
		const uint8_t subID = bytes[3];
		switch (subID)
		{
			case 0x01:
			{
				notificationName = kMDSysexSDSdumpHeaderNotification;
				break;
			}
			case 0x02:
			{
				notificationName = kMDSysexSDSdumpPacketNotification;
				break;
			}
			case 0x03:
			{
				notificationName = kMDSysexSDSdumpRequestNotification;
				break;
			}
			case 0x7F:
			{
				notificationName = kMDSysexSDSdumpACKNotification;
				break;
			}
			case 0x7E:
			{
				notificationName = kMDSysexSDSdumpNAKNotification;
				break;
			}
			case 0x7D:
			{
				notificationName = kMDSysexSDSdumpCANCELNotification;
				break;
			}
			case 0x7C:
			{
				notificationName = kMDSysexSDSdumpWAITNotification;
				break;
			}
			default:
				break;
		}
	}
	else
	{
		DLog(@"unknown header, ignoring.");
	}
	
	if(notificationName)
	{
		NSNotification *n = [NSNotification notificationWithName:notificationName object:data];
		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:n waitUntilDone:NO];
	}
}

+ (BOOL) messageIsUniversalRealtimeMessage:(NSData *)data
{
	const uint8_t *bytes = data.bytes;
	if(bytes[1] == 0x7E) return YES;
	return NO;
}

const uint8_t tm1header[] = {0xf0, 0x00, 0x20, 0x3c, 0x04, 0x00};
+ (BOOL)dataStartsWithAssumedTM1Header:(NSData *)data
{
	const uint8_t *bytes = data.bytes;
	
	for (int i = 0; i < 6; i++)
		if(bytes[i] != tm1header[i]) return NO;
	
	return YES;
}

const uint8_t tmheader[] = {0xf0, 0x00, 0x20, 0x3c, 0x00, 0x00};
+ (BOOL)dataStartsWithTurboMIDIHeader:(NSData *)data
{
	const uint8_t *bytes = data.bytes;
	for (int i = 0; i < 6; i++)
		if(bytes[i] != tmheader[i]) return NO;
	
	return YES;
}

const uint8_t mdHeader[] = {0xf0, 0x00, 0x20, 0x3c, 0x02, 0x00};
+ (BOOL)dataStartsWithMachineDrumHeader:(NSData *)data
{
	const uint8_t *bytes = data.bytes;
	for (int i = 0; i < 6; i++)
		if(bytes[i] != mdHeader[i]) return NO;
	
	return YES;
}

const uint8_t a4Header[] = {0xf0, 0x00, 0x20, 0x3c, 0x06, 0x00};
+ (BOOL)dataStartsWithA4Header:(NSData *)data
{
	const uint8_t *bytes = data.bytes;
	for (int i = 0; i < 6; i++)
		if(bytes[i] != a4Header[i]) return NO;
	
	return YES;
}

@end
