//
//  A4SysexMessage.h
//  A4Sysex
//
//  Created by Jakob Penca on 3/28/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum A4SysexMessageID
{
	A4SysexMessageID_Kit		= 0x52,
	A4SysexMessageID_Sound		= 0x53,
	A4SysexMessageID_Pattern	= 0x54,
	A4SysexMessageID_Song		= 0x55,
	A4SysexMessageID_Global		= 0x57,
}
A4SysexMessageID;

@interface A4SysexMessage : NSObject

@property (strong, nonatomic) NSMutableData *data;
@property uint8_t position;

+ (id) messageWithData:(NSData *)data;
- (void) updateChecksum;
- (BOOL) checksumIsValid;
- (BOOL) messageLengthIsValid;
@end
