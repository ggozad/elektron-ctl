//
//  MDSDS.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 10/1/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDMachinedrumPublic.h"
#import <AudioToolbox/AudioToolbox.h>

@class MDSDS;

typedef enum SDSLoopMode
{
	SDSLoopModeForward = 0x00,
	SDSLoopModeBackAndForth = 0x01,
	SDSLoopModeNone = 0x7F,
}
SDSLoopMode;

typedef enum SDSHandshakeMessageID
{
	SDSHandshakeMessageID_ACK = 0x7F,
	SDSHandshakeMessageID_NAK = 0x7E,
	SDSHandshakeMessageID_CANCEL = 0x7D,
	SDSHandshakeMessageID_WAIT = 0x7C,
}
SDSHandshakeMessageID;

@protocol MDSDSDelegate <NSObject>
- (void) sdsDidCancelSendingFile:(MDSDS *)sds;
- (void) sdsDidCancelReceivingFile:(MDSDS *)sds;
- (void) sdsDidFinishSendingFile:(MDSDS *)sds;
- (void) sdsDidFinishReceivingFile:(MDSDS *)sds;
- (void) sdsDidBeginReceiving:(MDSDS *)sds;
- (void) sdsReceiveFileProgressUpdated:(float)progress;
- (void) sdsSendFileProgressUpdated:(float)progress;
- (void) sdsDidReceiveSampleName:(MDSDS *)sds;
@end


@interface MDSDS : NSObject

@property (nonatomic, assign) id<MDSDSDelegate>delegate;
@property (nonatomic, strong) NSString *pathForReceivedAudio;
@property (nonatomic, strong) NSString *sampleNameForReceive;
@property NSUInteger sampleSlotForReceive;


+ (id) sharedInstance;
- (BOOL) armForReceiving;
- (BOOL) disarmForReceiving;

- (void) sendWavFileAtPath:(NSString *)path toSlot:(NSUInteger)slot name:(NSString *)name;
- (void) cancelSend;
- (void) cancelReceive;
- (NSData *)dumpRequestForSampleSlot:(NSUInteger)i sysexChannel:(uint8_t)channel;
- (NSMutableArray *) dataPacketsForAudioData16BitMono:(NSData *)audioData sampleRate:(NSUInteger)sampleRate sysexChannel: (uint8_t)channel;
- (NSData *)dumpHeaderWithBitRate:(uint8_t)bitsPerSample
				   numberOfFrames:(NSUInteger)numSamples
					   sampleRate:(NSUInteger)sampleRate
						loopStart:(NSUInteger)loopStart
						  loopEnd:(NSUInteger)loopEnd
						 loopType:(SDSLoopMode)loopMode
						 saveSlot:(NSUInteger)i
					 sysexChannel:(uint8_t)channel;

@end
