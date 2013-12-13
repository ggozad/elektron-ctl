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
	A4SysexMessageID_Settings	= 0x56,
	A4SysexMessageID_Global		= 0x57,
	
	A4SysexMessageID_Kit_X		= 0x58,
	A4SysexMessageID_Sound_X	= 0x59,
	A4SysexMessageID_Pattern_X	= 0x5A,
	A4SysexMessageID_Song_X		= 0x5B,
	A4SysexMessageID_Settings_X	= 0x5C,
	A4SysexMessageID_Global_X	= 0x5D,
}
A4SysexMessageID;

typedef enum A4MessagePayloadLength
{
	A4MessagePayloadLengthSound		= 0x16E,
	A4MessagePayloadLengthKit		= 0x933,
	A4MessagePayloadLengthPattern	= 0x30FE,
	A4MessagePayloadLengthTrack		= 0x2A7,
	A4MessagePayloadLengthSettings	= 0x3C,
	A4MessagePayloadLengthGlobal	= 0x8DE,
	A4MessagePayloadLengthSong		= 0x518,
	A4MessagePayloadLengthProject	= 0x1DCF80
}
A4MessagePayloadLength;

typedef enum A4Sendmode
{
	A4SendSave,
	A4SendTemp,
}
A4Sendmode;

@interface A4SysexMessage : NSObject
{
	NSMutableData *_sysexData;
	char *_payload;
}

@property (nonatomic) char *payload;
@property (nonatomic) BOOL ownsPayload;
@property (nonatomic) NSUInteger payloadLength;
@property (nonatomic, copy) NSData *sysexData;
@property (nonatomic) uint8_t type, version, revision, position;
@property (nonatomic, readonly, copy) NSData *payloadData;

+ (instancetype) messageWithSysexData:(NSData *)data;
+ (instancetype) messageWithPayloadAddress:(char *)payload;
+ (BOOL) checksumIsValidInSysexData:(NSData *)data;
+ (void) updateChecksumInSysexData:(NSMutableData *)data;
+ (BOOL) messageLengthIsValidInSysexData:(NSData *)data;
+ (void) updateMessageLengthInSysexData:(NSMutableData *)data;
- (void) clear;
- (void) setByteValue:(char)byte inPayloadAtIndex:(NSUInteger)i;
- (char) byteValueInPayloadAtIndex:(NSUInteger)i;
- (void) send;
- (void) sendWithMode:(A4Sendmode)mode;
@end
