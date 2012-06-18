//
//  MDSysexRouter.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 6/18/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDSysexRouter.h"
#define kKitDumpMessageID 0x52
#define kPatternDumpMessageID 0x67


@interface MDSysexRouter()
+ (BOOL) dataStartsWithMachineDrumHeader:(NSData *)data;
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
		
		//TODO: version & revision handling
		
		/*
		 if(bytes[0x07] != 0x04)
		 {
		 DLog(@"unsupported version");
		 return;
		 }
		 if(bytes[0x08] != 0x01)
		 {
		 DLog(@"unsupported revision");
		 return;
		 }
		 */
		
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
	else
	{
		DLog(@"invalid header. ignoring.");
	}
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
