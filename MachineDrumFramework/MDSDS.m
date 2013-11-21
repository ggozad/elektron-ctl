//
//  MDSDS.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 10/1/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDSDS.h"
#import "WaveEditor.h"

#define kMDSDSDurationForSentPacketACKTimeout (0.2)



typedef enum MDSDStransmissionState
{
	MDSDStransmissionState_IDLE,
	MDSDStransmissionState_SENT_HEADER_WILL_SEND_PACKET_WAITING_FOR_ACK,
	MDSDStransmissionState_SENT_HEADER_WILL_SEND_PACKET,
	MDSDStransmissionState_SENT_PACKET_WILL_SEND_PACKET_WAITING_FOR_ACK,
	MDSDStransmissionState_SENT_PACKET_WILL_SEND_PACKET,
	MDSDStransmissionState_SENT_PACKET_WILL_IDLE_WAITING_FOR_ACK,
	MDSDStransmissionState_SENT_PACKET_WILL_IDLE,
	MDSDStransmissionState_WAIT_WILL_SEND_PACKET,
	
	MDSDStransmissionState_ARMED_FOR_RECEIVE,
	MDSDStransmissionState_RECEIVING_GOT_HEADER_WAITING_FOR_PACKETS,
	MDSDStransmissionState_RECEIVING_GOT_HEADER_WAITING_FOR_USER_INPUT,
}
MDSDStransmissionState;

@interface MDSDS()
- (NSMutableArray *) dataPacketsForAudioData16BitMono:(NSData *)audioData sampleRate:(NSUInteger)sampleRate sysexChannel: (uint8_t)channel;
@property (nonatomic, strong) NSData *headerForSend;
@property (nonatomic, strong) NSArray *packetsForSend;
@property (nonatomic, assign) NSTimer *timerForSend;
@property MDSDStransmissionState transmissionState;
@property NSUInteger currentPacketIndexForSend;
@property (nonatomic, strong) NSString *sampleNameForSend;
@property NSUInteger sampleSlotForSend;

@property (nonatomic, strong) NSData *headerForReceive;
@property (nonatomic, strong) NSMutableArray *packetsForReceive;
@property (nonatomic, strong) NSData *sampleNameMessageForReceive;
@property NSUInteger currentPacketIndexForReceive;
@property NSUInteger sampleRateForReceive;
@property NSUInteger numberOfSamplesForReceive;
@property NSUInteger totalSamplesWritten;
@property NSUInteger numberOfSamplesPerPacketForReceive;
@property NSUInteger numberOfPacketsForReceive;
@property NSUInteger bitsPerSampleForReceive;
@property NSUInteger bytesPerSampleForReceive;
@property NSUInteger loopStartForReceive;
@property NSUInteger loopEndForReceive;
@property SDSLoopMode loopModeForReceive;
@property (getter = isRegisteredForSDSNotifications) BOOL registeredForSDSNotifications;

@end

@implementation MDSDS

static MDSDS *_default = nil;

+ (id)sharedInstance
{
	if(_default != nil) return _default;
	static dispatch_once_t safer;
	dispatch_once(&safer, ^(void)
				  {
					  _default = [[self alloc] init];
				  });
	return _default;
}

- (void) reset
{
	self.currentPacketIndexForSend = 0;
	self.transmissionState = MDSDStransmissionState_IDLE;
//	[self unRegisterForSDSNotifications];
	[self.timerForSend invalidate];
	
	self.totalSamplesWritten = 0;
}

- (id)init
{
	if(_default)return _default;
	if(self = [super init])
	{
		[self registerForSDSNotifications];
	}
	return self;
}

- (void)dealloc
{
	[self unRegisterForSDSNotifications];
}

- (BOOL)armForReceiving
{
//	[self registerForSDSNotifications];
	if(self.transmissionState == MDSDStransmissionState_IDLE)
	{
		self.transmissionState = MDSDStransmissionState_ARMED_FOR_RECEIVE;
		DLog(@"armed!");
		return YES;
	}
	else if(self.transmissionState == MDSDStransmissionState_ARMED_FOR_RECEIVE)
	{
		return YES;
	}
	else
	{
		DLog(@"don't arm when not idle!");
		return NO;
	}
	return NO;
}

- (BOOL)disarmForReceiving
{
//	[self unRegisterForSDSNotifications];
	if(self.transmissionState == MDSDStransmissionState_ARMED_FOR_RECEIVE)
	{
		DLog(@"disarmed!");
		self.transmissionState = MDSDStransmissionState_IDLE;
		return YES;
	}
	else if(self.transmissionState == MDSDStransmissionState_RECEIVING_GOT_HEADER_WAITING_FOR_PACKETS ||
			self.transmissionState == MDSDStransmissionState_RECEIVING_GOT_HEADER_WAITING_FOR_USER_INPUT)
	{
		DLog(@"cancelling receive..");
		NSData *cancelMessage = [self handShakeMessageWithID:SDSHandshakeMessageID_CANCEL packetNumber:0 channel:0];
//		[[[MDMIDI sharedInstance] machinedrumMidiDestination] sendSysexBytes:cancelMessage.bytes size:cancelMessage.length];
		
		[[[MDMIDI sharedInstance] machinedrumMidiDestination] sendSysexData:cancelMessage];
		
		self.transmissionState = MDSDStransmissionState_IDLE;
		{
			DLog(@"disarmed!");
			self.transmissionState = MDSDStransmissionState_IDLE;
			return YES;
		}
	}
	return YES;
}

- (void)sendWavFileAtPath:(NSString *)path toSlot:(NSUInteger)slot name:(NSString *)name
{
	PGMidiDestination *dst = [[MDMIDI sharedInstance] machinedrumMidiDestination];
	
	if(self.transmissionState != MDSDStransmissionState_IDLE || dst == nil)
	{
		[self.delegate sdsDidCancelSendingFile:self];
		return;
	}
	
	[self reset];
	
	self.sampleNameForSend = name;
	self.sampleSlotForSend = slot;
	self.currentPacketIndexForSend = 0;
		
	WaveEditor *editor = [WaveEditor waveEditorWithFileAtPath:path];
	AudioStreamBasicDescription asbd = editor.asbd;
	NSData *data = editor.data;
	
	float sampleRate = asbd.mSampleRate;
	NSUInteger numSamples = data.length / asbd.mBytesPerFrame;
	
	self.headerForSend = [self  dumpHeaderWithBitRate: asbd.mBytesPerFrame * 8
								numberOfFrames: data.length / asbd.mBytesPerFrame
									sampleRate: sampleRate
									 loopStart: 0
									   loopEnd: numSamples-1
									  loopType: SDSLoopModeNone
									  saveSlot: slot
								  sysexChannel: 0];
	
	self.packetsForSend = [self dataPacketsForAudioData16BitMono:data
											   sampleRate:sampleRate
											 sysexChannel:0];
	
	
//	[self registerForSDSNotifications];
	
//	[[[MDMIDI sharedInstance] machinedrumMidiDestination] sendSysexBytes:self.headerForSend.bytes size:(UInt32)self.headerForSend.length];
	[[[MDMIDI sharedInstance] machinedrumMidiDestination] sendSysexData:self.headerForSend];
	
	[self sendSampleName];
	
	self.transmissionState = MDSDStransmissionState_SENT_HEADER_WILL_SEND_PACKET_WAITING_FOR_ACK;
	NSString *s = @"header ACK timeout";
	[self startTimer:2.5 info:s];
}


- (void)cancelSend
{
	[self reset];
	if([self.delegate respondsToSelector:@selector(sdsDidFinishSendingFile:)])
	{
		[self.delegate sdsDidFinishSendingFile:self];
	}
}

- (void)cancelReceive
{
	[self disarmForReceiving];
	[self reset];
}

- (void) unRegisterForSDSNotifications
{
	NSNotificationCenter *c = [NSNotificationCenter defaultCenter];
	[c removeObserver:self name:kMDSysexSDSdumpHeaderNotification object:nil];
	[c removeObserver:self name:kMDSysexSDSdumpRequestNotification object:nil];
	[c removeObserver:self name:kMDSysexSDSdumpPacketNotification object:nil];
	[c removeObserver:self name:kMDSysexSDSdumpACKNotification object:nil];
	[c removeObserver:self name:kMDSysexSDSdumpNAKNotification object:nil];
	[c removeObserver:self name:kMDSysexSDSdumpCANCELNotification object:nil];
	[c removeObserver:self name:kMDSysexSDSdumpWAITNotification object:nil];
	[c removeObserver:self name:kMDSysexSetSampleNameNotification object:nil];
	
	self.registeredForSDSNotifications = NO;
}

- (void) registerForSDSNotifications
{
	if(self.isRegisteredForSDSNotifications) return;
	NSNotificationCenter *c = [NSNotificationCenter defaultCenter];
	[c addObserver:self selector:@selector(handleDumpHeader:) name:kMDSysexSDSdumpHeaderNotification object:nil];
	[c addObserver:self selector:@selector(handleDumpPacket:) name:kMDSysexSDSdumpPacketNotification object:nil];
	[c addObserver:self selector:@selector(handleDumpRequest:) name:kMDSysexSDSdumpRequestNotification object:nil];
	[c addObserver:self selector:@selector(handleACK:) name:kMDSysexSDSdumpACKNotification object:nil];
	[c addObserver:self selector:@selector(handleNAK:) name:kMDSysexSDSdumpNAKNotification object:nil];
	[c addObserver:self selector:@selector(handleWAIT:) name:kMDSysexSDSdumpWAITNotification object:nil];
	[c addObserver:self selector:@selector(handleCANCEL:) name:kMDSysexSDSdumpCANCELNotification object:nil];
	[c addObserver:self selector:@selector(handleSetSampleName:) name:kMDSysexSetSampleNameNotification object:nil];
	self.registeredForSDSNotifications = YES;
}

- (void) handleSetSampleName:(NSNotification *)n
{
	if(self.transmissionState != MDSDStransmissionState_RECEIVING_GOT_HEADER_WAITING_FOR_PACKETS)
	{
		DLog(@"got message, but ignoring.");
		return;
	}
	
	NSData *d = n.object;
	const char *bytes = d.bytes;
	
	NSUInteger num = bytes[7] & 0x3F;
	const char *nameStr = &bytes[8];
	NSString *name = [NSString stringWithCString:nameStr encoding:NSASCIIStringEncoding];
	if([name length] > 4)
	{
		NSRange r = NSMakeRange(4, [name length] - 4);
		name = [name stringByReplacingCharactersInRange:r withString:@""];
	}
	self.sampleNameForReceive = name;
	self.sampleNameMessageForReceive = d;
	DLog(@"sample number: %ld name: %@", num, name);
	
	[self.delegate sdsDidReceiveSampleName:self];
}

- (void) handleACK:(NSNotification *)n
{
	DLog(@"ACK!");
	if(self.transmissionState == MDSDStransmissionState_SENT_HEADER_WILL_SEND_PACKET_WAITING_FOR_ACK)
		self.transmissionState = MDSDStransmissionState_SENT_HEADER_WILL_SEND_PACKET;
	else if(self.transmissionState == MDSDStransmissionState_SENT_PACKET_WILL_SEND_PACKET_WAITING_FOR_ACK)
		self.transmissionState = MDSDStransmissionState_SENT_PACKET_WILL_SEND_PACKET;
	else if(self.transmissionState == MDSDStransmissionState_SENT_PACKET_WILL_IDLE_WAITING_FOR_ACK)
	{
		self.transmissionState = MDSDStransmissionState_IDLE;
//		[self unRegisterForSDSNotifications];
	}
	[self killTimerForSend];
	[self proceedWithSend];
}

- (void) handleNAK:(NSNotification *)n
{
	DLog(@"NAK!");
	if(self.transmissionState == MDSDStransmissionState_SENT_PACKET_WILL_IDLE_WAITING_FOR_ACK ||
	   self.transmissionState == MDSDStransmissionState_SENT_PACKET_WILL_SEND_PACKET_WAITING_FOR_ACK)
	{
		NSData *d = n.object;
		const char *bytes = d.bytes;
		uint8_t packetNum = bytes[3];
		NSUInteger n = self.currentPacketIndexForSend;
		
		while (n % 128 > packetNum)
		{
			n--;
		}
		self.currentPacketIndexForSend = n;
		
		[self killTimerForSend];
		[self proceedWithSend];
	}
	else
	{
		[self killTimerForSend];
		self.transmissionState = MDSDStransmissionState_IDLE;
	}
}

- (void) handleCANCEL:(NSNotification *)n
{
	DLog(@"CANCEL");
	[self killTimerForSend];
	self.transmissionState = MDSDStransmissionState_IDLE;
	[self.delegate sdsDidCancelSendingFile:self];
	//[self cancel];
}

- (void) handleWAIT:(NSNotification *)n
{
	DLog(@"WAIT!");
	[self killTimerForSend];
	//[self proceed];
	//[self wait];
}

- (void) handleDumpHeader:(NSNotification *)n
{
	if(self.transmissionState != MDSDStransmissionState_ARMED_FOR_RECEIVE)
	{
		DLog(@"got header, ignoring..");
		NSData *cancelMessage = [self handShakeMessageWithID:SDSHandshakeMessageID_CANCEL packetNumber:0 channel:0];
//		[[[MDMIDI sharedInstance] machinedrumMidiDestination] sendSysexBytes:cancelMessage.bytes size:cancelMessage.length];
		[[[MDMIDI sharedInstance] machinedrumMidiDestination] sendSysexData:cancelMessage];
		return;
	}
	
	DLog(@"got header: %@", n.object);
	const char *bytes = [n.object bytes];
	DLog(@"bits per sample: %d", bytes[6]);
	NSUInteger bytesPerSample = bytes[6] / 8;
	if(bytes[6]%8) bytesPerSample += 1;
	DLog(@"bytes per sample: %ld", bytesPerSample);
	
	NSUInteger samplePeriod = (bytes[7] | bytes[8] << 7 | bytes[9] << 14);
	NSUInteger sampleRate = 1000000000 / samplePeriod;
	DLog(@"sample rate: %ld", sampleRate);
	
	NSUInteger numSamples = (bytes[10] | bytes[11] << 7 | bytes[12] << 14);
	DLog(@"number of samples: %ld", numSamples);
	
	NSUInteger loopStart = (bytes[13] | bytes[14] << 7 | bytes[15] << 14);
	NSUInteger loopEnd = (bytes[16] | bytes[17] << 7 | bytes[18] << 14);
	DLog(@"loop start: %ld, end: %ld", loopStart, loopEnd);
	
	NSUInteger sampleSlot = (bytes[4] | bytes[5] << 7);
	
	NSString *loopMode = @"[forward]";
	if(bytes[18] == SDSLoopModeBackAndForth) loopMode = @"[back & forth]";
	else if(bytes[18] == SDSLoopModeNone) loopMode = @"[none]";
	
	DLog(@"loop mode: %@", loopMode);
	
	
	
	NSUInteger bitsPerSample = bytes[6];
	NSUInteger packetBytesPerSample = 1;
	if(bitsPerSample > 8 && bitsPerSample <= 14) packetBytesPerSample = 2;
	if(bitsPerSample > 14 && bitsPerSample <= 21) packetBytesPerSample = 3;
	if(bitsPerSample > 21 && bitsPerSample <= 28) packetBytesPerSample = 4;
	
	NSUInteger samplesPerPacket = 120 / packetBytesPerSample;
	NSUInteger numPackets = numSamples / samplesPerPacket;
	if (numSamples % samplesPerPacket) numPackets += 1;
	
	self.headerForReceive = n.object;
	self.packetsForReceive = [NSMutableArray array];
	self.sampleRateForReceive = sampleRate;
	self.bitsPerSampleForReceive = bytes[6];
	self.bytesPerSampleForReceive = bytesPerSample;
	self.loopStartForReceive = loopStart;
	self.loopEndForReceive = loopEnd;
	self.loopModeForReceive = bytes[18];
	self.currentPacketIndexForReceive = 0;
	self.sampleSlotForReceive = sampleSlot;
	
	self.numberOfPacketsForReceive = numPackets;
	self.numberOfSamplesPerPacketForReceive = samplesPerPacket;
	self.numberOfSamplesForReceive = numSamples;
	self.totalSamplesWritten = 0;
	
#warning todo: check format
	
	NSData *ackMessage = [self handShakeMessageWithID:SDSHandshakeMessageID_ACK packetNumber:0 channel:bytes[2]];
//	[[[MDMIDI sharedInstance] machinedrumMidiDestination] sendSysexBytes:ackMessage.bytes size:ackMessage.length];
	[[[MDMIDI sharedInstance] machinedrumMidiDestination] sendSysexData:ackMessage];
	self.transmissionState = MDSDStransmissionState_RECEIVING_GOT_HEADER_WAITING_FOR_PACKETS;
	
	if([self.delegate respondsToSelector:@selector(sdsDidBeginReceiving:)])
	{
		[self.delegate sdsDidBeginReceiving:self];
	}
}

- (void) handleDumpPacket:(NSNotification *)n
{
	if(self.transmissionState != MDSDStransmissionState_RECEIVING_GOT_HEADER_WAITING_FOR_PACKETS)
	{
		DLog(@"got packet but ignoring..");
		return;
	}
	
	NSData *data = n.object;
	const char *bytes = data.bytes;
	uint8_t packetNum = bytes[4];
	uint8_t channel = bytes[2];
	
	BOOL checksumOK = NO;
	char checksum = bytes[1];
	for (int i = 2; i < 125; i++)
		checksum ^= bytes[i];
	
	if(checksum == bytes[125])
		checksumOK = YES;
	
	DLog(@"packet num: %d(%ld)/%ld %@", packetNum, self.currentPacketIndexForReceive, self.numberOfPacketsForReceive, checksumOK ? @"OK" : @"ERR");

	
	NSData *handShakeMessage = nil;
	SDSHandshakeMessageID handShakeID = SDSHandshakeMessageID_ACK;
	if(!checksumOK)	handShakeID = SDSHandshakeMessageID_NAK;
	handShakeMessage = [self handShakeMessageWithID:handShakeID packetNumber:packetNum channel:channel];
//	[[[MDMIDI sharedInstance] machinedrumMidiDestination] sendBytes:handShakeMessage.bytes size:handShakeMessage.length];
	[[[MDMIDI sharedInstance] machinedrumMidiDestination] sendSysexData:handShakeMessage];
	
	if(checksumOK)
	{
		[self.packetsForReceive addObject:data];
		self.currentPacketIndexForReceive++;
		
		if([self.delegate respondsToSelector:@selector(sdsReceiveFileProgressUpdated:)])
		{
			float progress = self.currentPacketIndexForReceive / (float) self.numberOfPacketsForReceive;
			[self.delegate sdsReceiveFileProgressUpdated:progress];
		}
		
		if(self.currentPacketIndexForReceive == self.numberOfPacketsForReceive)
		{
			self.transmissionState = MDSDStransmissionState_IDLE;
			DLog(@"received last packet..");
			[self armForReceiving];
			[self parsePackets];
			if([self.delegate respondsToSelector:@selector(sdsDidFinishReceivingFile:)])
			{
				[self.delegate sdsDidFinishReceivingFile:self];
			}
		}
	}
}

- (void)parsePackets
{
	NSMutableData *audioData = [NSMutableData data];
	int i = 0;
	for (NSData *packet in self.packetsForReceive)
	{
		DLog(@"parsing packet %d", i);
		NSData *parsedPacket = [self parseDumpPacket:packet];
		[audioData appendData:parsedPacket];
		i++;
	}
	
	[audioData setLength:self.numberOfSamplesForReceive * self.bytesPerSampleForReceive];
	
	
	/*
	
	NSURL *url = [[MDDataDump sharedInstance] currentSnapshotDirectory];
	url = [url URLByAppendingPathComponent:@"samples"];
	url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%02ld_%@", self.sampleSlotForReceive, self.sampleNameForReceive]];
	*/
	
	NSURL *url = [NSURL fileURLWithPath:self.pathForReceivedAudio];
	DLog(@"writing files to url: %@", url);
	[self writeAudioData: audioData toURL:url];
//	[self writeSyxFileToURL:[url URLByAppendingPathExtension:@"syx"]];
}


- (void) writeSyxFileToURL:(NSURL *)url
{
	NSMutableData *syx = [NSMutableData data];
	[syx appendData:self.headerForReceive];
	[syx appendData:self.sampleNameMessageForReceive];
	for (NSData *packet in self.packetsForReceive)
		[syx appendData:packet];
	
	DLog(@"writing syx file.. size: %ld", syx.length);
	
	NSError *err = nil;
	[syx writeToFile:[url path] options:NSDataWritingAtomic error:&err];
	if(err)
	{
		DLog(@"error: %@", [err localizedDescription]);
	}
	else
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:kMDSDSDidWriteSyxFileNotification object: url];
	}
}

- (void) writeAudioData:(NSData *)data toURL:(NSURL *)url
{
	AudioStreamBasicDescription asbd;
	memset(&asbd, 0, sizeof(AudioStreamBasicDescription));
	AudioFileID fileID = NULL;
	
	asbd.mSampleRate = self.sampleRateForReceive;
	asbd.mFormatID = kAudioFormatLinearPCM;
	asbd.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
	asbd.mFramesPerPacket = 1;
	asbd.mBytesPerFrame = 2;
	asbd.mChannelsPerFrame = 1;
	asbd.mBitsPerChannel = 16;
	asbd.mBytesPerPacket = 2;
	asbd.mBytesPerFrame = 2;
	
	OSStatus err = AudioFileCreateWithURL((__bridge CFURLRef)url, kAudioFileWAVEType, &asbd, kAudioFileFlags_EraseFile | kAudioFileFlags_DontPageAlignAudioData, &fileID);
	
	if(err)
	{
		DLog(@"failed to create file with err: %d at url: %@", err, url);
		return;
	}

	UInt32 numBytes = data.length;
	err = AudioFileWriteBytes(fileID, FALSE, 0, &numBytes, data.bytes);
	if(err)
	{
		DLog(@"failed to write bytes..");
		return;
	}
	
	AudioFileClose(fileID);
	if(err)
	{
		DLog(@"failed to close file..");
		return;
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kMDSDSDidWriteAudioFileNotification object: url];
}

int16_t unpack3(const uint8_t *ptr)
{
    int16_t num = ((uint16_t)(*ptr) << 9) | ((uint16_t)(*(ptr+1)) << 2) | (*(ptr+2) >> 5);
    return num - 0x8000;
}

- (NSData *)parseDumpPacket:(NSData *)packetData
{
	const uint8_t *bytes = packetData.bytes;
	bytes += 5;
	
	NSUInteger len = self.numberOfSamplesPerPacketForReceive * self.bytesPerSampleForReceive;
	if((self.numberOfSamplesForReceive - self.totalSamplesWritten) * self.bytesPerSampleForReceive < len)
		len = (self.numberOfSamplesForReceive - self.totalSamplesWritten) * self.bytesPerSampleForReceive;
	
	int16_t *samples = malloc(len);
	
	for (NSUInteger i = 0; i < len / self.bytesPerSampleForReceive; i++)
	{
		samples[i] = unpack3(bytes);
		bytes += 3;
	}

	return [NSData dataWithBytesNoCopy:samples length:len freeWhenDone:YES];
}

- (void) handleDumpRequest:(NSNotification *)n
{
	DLog(@"got dump request..");
#warning unimplemented
}

- (void) startTimer:(float)seconds info:(NSString *)str
{
	//DLog(@"seconds: %f", seconds);
	[self killTimerForSend];
	self.timerForSend = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(timeOut:) userInfo:str repeats:NO];
}

- (void) killTimerForSend
{
	if(self.timerForSend)
	{
		[self.timerForSend invalidate];
		self.timerForSend = nil;
	}
}

- (void) timeOut:(NSTimer *)timer
{
	DLog(@"%@", timer.userInfo);
	if(self.transmissionState == MDSDStransmissionState_SENT_HEADER_WILL_SEND_PACKET_WAITING_FOR_ACK)
	{
		self.transmissionState = MDSDStransmissionState_SENT_HEADER_WILL_SEND_PACKET;
		[self proceedWithSend];
	}
	else if(self.transmissionState == MDSDStransmissionState_SENT_PACKET_WILL_SEND_PACKET_WAITING_FOR_ACK)
	{
		self.transmissionState = MDSDStransmissionState_SENT_PACKET_WILL_SEND_PACKET;
		[self proceedWithSend];
	}
}

- (void) proceedWithSend
{
	if(self.transmissionState == MDSDStransmissionState_IDLE)
	{
		if([self.delegate respondsToSelector:@selector(sdsDidFinishSendingFile:)])
		{
			[self.delegate sdsDidFinishSendingFile:self];
		}
		DLog(@"nothing to do.."); return;
	}
	if(self.transmissionState == MDSDStransmissionState_SENT_HEADER_WILL_SEND_PACKET ||
	   self.transmissionState == MDSDStransmissionState_SENT_PACKET_WILL_SEND_PACKET)
	{
		
		NSData *packet = [self.packetsForSend objectAtIndex:self.currentPacketIndexForSend++];
//		[[[MDMIDI sharedInstance] machinedrumMidiDestination] sendSysexBytes:packet.bytes size:packet.length];
		[[[MDMIDI sharedInstance] machinedrumMidiDestination] sendSysexData:packet];
		
		if (self.currentPacketIndexForSend < [self.packetsForSend count])
			self.transmissionState = MDSDStransmissionState_SENT_PACKET_WILL_SEND_PACKET_WAITING_FOR_ACK;
		else
			self.transmissionState = MDSDStransmissionState_SENT_PACKET_WILL_IDLE_WAITING_FOR_ACK;
		
		DLog(@"sending packet %ld/%ld", self.currentPacketIndexForSend, [self.packetsForSend count]);
		
		
		
		if([self.delegate respondsToSelector:@selector(sdsSendFileProgressUpdated:)])
		{
			float progress = self.currentPacketIndexForSend / (float) self.packetsForSend.count;
			[self.delegate sdsSendFileProgressUpdated:progress];
		}
		
		NSString *s = @"packet ACK timeout";
		[self startTimer:kMDSDSDurationForSentPacketACKTimeout info:s];
	}
}

- (void) sendSampleName
{
	if(self.sampleNameForSend)
	{
		if(self.sampleNameForSend.length > 4)
			self.sampleNameForSend = [self.sampleNameForSend substringToIndex:4];
		
		[[[MDMIDI sharedInstance] machinedrum] setSampleName:self.sampleNameForSend atSlot:self.sampleSlotForSend];
	}
}

- (NSData *)dumpRequestForSampleSlot:(NSUInteger)i sysexChannel:(uint8_t)channel
{
	channel &= 0x7F;
	i &= 0x3FFF;
	
	uint8_t sampleSlotHigherBits = (i >> 7) & 0x7F;
	uint8_t sampleSlotLowerBits = i & 0x7F;
	
	char bytes[] = {0xF0, 0x7E, channel, 0x03, sampleSlotLowerBits, sampleSlotHigherBits, 0xF7};
	return [NSData dataWithBytes:bytes length:7];
}

- (NSData *)dumpHeaderWithBitRate:(uint8_t)bitsPerSample
				   numberOfFrames:(NSUInteger)numSamples
					   sampleRate:(NSUInteger)sampleRate
						loopStart:(NSUInteger)loopStart
						  loopEnd:(NSUInteger)loopEnd
						 loopType:(SDSLoopMode)loopMode
						 saveSlot:(NSUInteger)i
					 sysexChannel:(uint8_t)channel
{
	DLog(@"header w/ samprate: %d", sampleRate);
	NSAssert(sampleRate > 0, @"sampleRate must be higher than 0");
	NSAssert(bitsPerSample >=8 && bitsPerSample <= 24, @"bitRate must be between 8 and 24");
	
	channel &= 0x7F;
	i &= 0x3FFF;
	
	if(loopMode == SDSLoopModeNone)
		loopStart = loopEnd = numSamples;
	
	uint8_t sampleSlotHigherBits = (i >> 7) & 0x7F;
	uint8_t sampleSlotLowerBits = i & 0x7F;
	
	NSUInteger samplePeriod = 1000000000 / sampleRate;
	uint8_t samplePeriodLowBits =  samplePeriod & 0x7F;
	uint8_t samplePeriodMiddleBits = (samplePeriod >> 7) & 0x7F;
	uint8_t samplePeriodHighBits = (samplePeriod >> 14) & 0x7F;
	
	uint8_t waveformLengthLowBits = numSamples & 0x7F;
	uint8_t waveformLengthMiddleBits = (numSamples >> 7) & 0x7F;
	uint8_t waveformLengthHighBits = (numSamples >> 14) & 0x7F;
	
	uint8_t sustainLoopStartLowBits = loopStart & 0x7F;
	uint8_t sustainLoopStartMiddleBits = (loopStart >> 7) & 0x7F;
	uint8_t sustainLoopStartHighBits = (loopStart >> 14) & 0x7F;
	
	uint8_t sustainLoopEndLowBits = loopEnd & 0x7F;
	uint8_t sustainLoopEndMiddleBits = (loopEnd >> 7) & 0x7F;
	uint8_t sustainLoopEndHighBits = (loopEnd >> 14) & 0x7F;
	
	loopMode &= 0x7F;
	
	char bytes[] =
	{
		0xF0,
		0x7E,
		channel,
		0x01,
		sampleSlotLowerBits,
		sampleSlotHigherBits,
		bitsPerSample,
		samplePeriodLowBits,
		samplePeriodMiddleBits,
		samplePeriodHighBits,
		waveformLengthLowBits,
		waveformLengthMiddleBits,
		waveformLengthHighBits,
		sustainLoopStartLowBits,
		sustainLoopStartMiddleBits,
		sustainLoopStartHighBits,
		sustainLoopEndLowBits,
		sustainLoopEndMiddleBits,
		sustainLoopEndHighBits,
		loopMode,
		0xF7
	};
	
	return [NSData dataWithBytes:bytes length:21];
}

- (NSData *) dataPacketForAudioData:(NSData *)audioData index:(NSUInteger)packetIndex sysexChannel:(uint8_t)channel
{
	char *bytes = calloc(127, 1);
	bytes[0] = 0xF0;
	bytes[1] = 0x7E;
	bytes[2] = channel & 0x7F;
	bytes[3] = 0x02;
	bytes[4] = packetIndex % 128;
	
	const int16_t *samples = audioData.bytes;
	NSUInteger numSamples = audioData.length / 2;
	NSUInteger offset = packetIndex*(120/3);
	NSUInteger indexInPacket = 5;
	uint8_t packetBytesPerSample = 3;
	
	for (int j = 0; j < 120/packetBytesPerSample; j++)
	{
		int16_t currentSample = 0;
		if(offset + j < numSamples)
		{
			currentSample = samples[offset + j];
			currentSample += 0x8000;
			//currentSample &= 0xFFF0; 12 bit sampling
		}
		
		bytes[indexInPacket++] = (currentSample >> 9) & 0x7F; // hi bits
		bytes[indexInPacket++] = (currentSample >> 2) & 0x7F; // mid bits
		bytes[indexInPacket++] = (currentSample & 0x03) << 5; // lo bits
	}
	
	char checksum = bytes[1];
	for (int i = 2; i < 125; i++)
		checksum ^= bytes[i];
	
	bytes[125] = checksum;
	bytes[126] = 0xF7;
	
	return [NSData dataWithBytes:bytes length:127];
	free(bytes);
}

- (NSMutableArray *)dataPacketsForAudioData16BitMono:(NSData *)audioData sampleRate:(NSUInteger)sampleRate sysexChannel:(uint8_t)channel
{
	NSUInteger numberOfSamples = audioData.length / 2;
	NSUInteger numberOfPackets = ceilf(numberOfSamples * 3.0 / 120);
	NSMutableArray *packets = [NSMutableArray array];
	
	for (NSUInteger i = 0; i < numberOfPackets; i++)
	{
		@autoreleasepool
		{
			NSData *packet = [self dataPacketForAudioData:audioData index:i sysexChannel:channel];
			[packets addObject:packet];
		}
	}
	return packets;
}

- (NSData *)handShakeMessageWithID:(SDSHandshakeMessageID)handshakeID packetNumber:(uint8_t)packetNumber channel:(uint8_t)channel
{
	const char bytes[] =
	{
		0xF0,
		0x7E,
		channel & 0x7F,
		handshakeID,
		packetNumber & 0x7F,
		0xF7
	};
	return [NSData dataWithBytes:bytes length:6];
}


@end
