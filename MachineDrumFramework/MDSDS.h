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


@interface MDSDS : NSObject
+ (id) sharedInstance;
- (BOOL) armForReceiving;
- (BOOL) disarmForReceiving;

- (void) sendWavData:(NSData *)wavData toSlot:(NSUInteger)slot name:(NSString *)name;
- (NSData *)dumpRequestForSampleSlot:(NSUInteger)i sysexChannel:(uint8_t)channel;
- (NSData *)rawAudioDataFor16BitMonoWavFileData:(NSData *)d;
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
