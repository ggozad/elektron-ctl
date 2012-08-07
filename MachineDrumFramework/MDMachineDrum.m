//
//  MachineDrum.m
//  sysexingApp
//
//  Created by Jakob Penca on 5/19/12.
//
//

#import "MDMachineDrum.h"
#import "MDMIDIFoundation.h"
#import "MDSysexUtil.h"
#import "MDKit.h"

#define kTempoChanged @"tempoChanged"
#define kSetCurrentKitName @"setCurrentKitName"
#define kSysexMDPrefix @"f000203c0200"
#define kSysexEnd @"f7"

@interface MDMachineDrum()
- (NSData *)tempoMessageData;
- (NSData *)currentKitMessageData;
- (NSData *)saveKitMessageDataWithSlot:(NSUInteger) num;
- (NSData *)loadPatternMessageDataWithSlot:(NSUInteger)num;
- (NSData *)loadKitMessageDataWithSlot:(NSUInteger)num;
@end

@implementation MDMachineDrum

- (id) init
{
	if(self = [super init])
	{
		[self addObserver:self forKeyPath:@"tempo" options:0 context:kTempoChanged];
		[self addObserver:self forKeyPath:@"currentKitName" options:0 context:kSetCurrentKitName];
		
		
		
		
	}
	return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"tempo"] && [(__bridge NSString *)context isEqualToString:kTempoChanged])
	{
		NSLog(@"midi tempo changed to %d", self.tempo);
		if (self.delegate)
		{
			[self.delegate machineDrum:self wantsToSendSysExData: [self tempoMessageData]];
		}
	}
	else if([keyPath isEqualToString:@"currentKitName"] && [(__bridge NSString *)context isEqualToString:kSetCurrentKitName])
	{
		NSLog(@"kit name changed to %@", self.currentKitName);
		if (self.delegate)
		{
			[self.delegate machineDrum:self wantsToSendSysExData: [self currentKitMessageData]];
		}
	}
}


- (NSData *)currentKitMessageData
{
	char nameBytes[16] = {};
	NSUInteger len = self.currentKitName.length;
	
	for (int i = 0; i < len; i++)
	{
		nameBytes[i] = [self.currentKitName characterAtIndex:i] & 0x7f;
	}
	
	NSMutableData *data = [[NSMutableData alloc] init];
	
	[data appendData:[MDSysexUtil dataFromHexString:kSysexMDPrefix]];
	[data appendData:[MDSysexUtil dataFromHexString:@"55"]];
	[data appendData: [NSData dataWithBytes:nameBytes length:16]];
	[data appendData:[MDSysexUtil dataFromHexString:kSysexEnd]];
	
	return data;
}


- (NSData *)tempoMessageData
{
	NSString *tempoID = @"61";
	
	int tempoMultiplied = self.tempo * 24;
	
	char tempoBytes[2] = {};
	tempoBytes[0] = (tempoMultiplied >> 7) & 0x7f;
	tempoBytes[1] = tempoMultiplied & 0x7f;
	
	NSData *tempoData = [NSData dataWithBytes:&tempoBytes length:2];
	NSMutableData *data = [[NSMutableData alloc] init];
	
	[data appendData:[MDSysexUtil dataFromHexString:kSysexMDPrefix]];
	[data appendData:[MDSysexUtil dataFromHexString:tempoID]];
	[data appendData: tempoData];
	[data appendData:[MDSysexUtil dataFromHexString:kSysexEnd]];
	
	return data;
}

- (NSData *)saveKitMessageDataWithSlot:(NSUInteger)num
{
	if(num > 63) num = 63;
	
	NSString *saveKitID = @"59";
	char slotByte = num & 0x6f;
	
	NSData *slotData = [NSData dataWithBytes:&slotByte length:1];
	
	NSMutableData *msgData = [NSMutableData new];
	
	
	[msgData appendData:[MDSysexUtil dataFromHexString:kSysexMDPrefix]];
	[msgData appendData:[MDSysexUtil dataFromHexString:saveKitID]];
	[msgData appendData:slotData];
	[msgData appendData:[MDSysexUtil dataFromHexString:kSysexEnd]];
	
	return msgData;
}

- (NSData *)loadPatternMessageDataWithSlot:(NSUInteger)num
{
	if(num > 127) num = 127;
	
	NSString *loadPatternID = @"57";
	char slotByte = num & 0x7f;
	
	NSData *slotData = [NSData dataWithBytes:&slotByte length:1];
	
	NSMutableData *msgData = [NSMutableData new];
	
	
	[msgData appendData:[MDSysexUtil dataFromHexString:kSysexMDPrefix]];
	[msgData appendData:[MDSysexUtil dataFromHexString:loadPatternID]];
	[msgData appendData:slotData];
	[msgData appendData:[MDSysexUtil dataFromHexString:kSysexEnd]];
	
	return msgData;

}

- (NSData *)loadKitMessageDataWithSlot:(NSUInteger)num
{
	if(num > 63) num = 63;
	
	NSString *loadKitID = @"58";
	char slotByte = num & 0x6f;
	
	NSData *slotData = [NSData dataWithBytes:&slotByte length:1];
	
	NSMutableData *msgData = [NSMutableData new];
	
	
	[msgData appendData:[MDSysexUtil dataFromHexString:kSysexMDPrefix]];
	[msgData appendData:[MDSysexUtil dataFromHexString:loadKitID]];
	[msgData appendData:slotData];
	[msgData appendData:[MDSysexUtil dataFromHexString:kSysexEnd]];
	
	return msgData;

}



- (void)saveCurrentKitToSlot:(NSUInteger)num
{
	if(self.delegate)
		[self.delegate machineDrum:self
			  wantsToSendSysExData:[self saveKitMessageDataWithSlot:num]];
}

- (void)loadPattern:(NSUInteger)num
{
	if(self.delegate)
		[self.delegate machineDrum:self
			  wantsToSendSysExData:[self loadPatternMessageDataWithSlot:num]];

}

- (void)loadKit:(NSUInteger)num
{
	if(self.delegate)
		[self.delegate machineDrum:self
			  wantsToSendSysExData:[self loadKitMessageDataWithSlot:num]];
}

- (void)requestKitDumpForSlot:(uint8_t)num
{
	if(num > 63) num = 63;
	
	char slotByte = num & 0x6f;
	NSData *slotData = [NSData dataWithBytes:&slotByte length:1];
	NSMutableData *data = [NSMutableData new];
	
	[data appendData:[MDSysexUtil dataFromHexString:kSysexMDPrefix]];
	[data appendData:[MDSysexUtil dataFromHexString:@"53"]];
	[data appendData:slotData];
	[data appendData:[MDSysexUtil dataFromHexString:kSysexEnd]];
	
	if(self.delegate)
		[self.delegate machineDrum:self wantsToSendSysExData:data];
}

- (void)requestPatternDumpForSlot:(uint8_t)num
{
	if(num > 127) num = 127;
	
	char slotByte = num & 0x7f;
	NSData *slotData = [NSData dataWithBytes:&slotByte length:1];
	NSMutableData *data = [NSMutableData new];
	
	[data appendData:[MDSysexUtil dataFromHexString:kSysexMDPrefix]];
	[data appendData:[MDSysexUtil dataFromHexString:@"68"]];
	[data appendData:slotData];
	[data appendData:[MDSysexUtil dataFromHexString:kSysexEnd]];
	
	if(self.delegate)
		[self.delegate machineDrum:self wantsToSendSysExData:data];
}

- (void)requestCurrentKitNumber
{
	char slotByte = 0x02;
	NSData *slotData = [NSData dataWithBytes:&slotByte length:1];
	NSMutableData *data = [NSMutableData new];
	
	[data appendData:[MDSysexUtil dataFromHexString:kSysexMDPrefix]];
	[data appendData:[MDSysexUtil dataFromHexString:@"70"]];
	[data appendData:slotData];
	[data appendData:[MDSysexUtil dataFromHexString:kSysexEnd]];
	
	if(self.delegate)
		[self.delegate machineDrum:self wantsToSendSysExData:data];
}

- (void)sendRandomPatternToSlot:(NSUInteger)slot
{
	MDKit *kit = [MDKit kitWithRandomParametersAndDrumModels];
	kit.originalPosition = slot;
	NSData *sysexData = [kit sysexData];
	if(self.delegate)
		[self.delegate machineDrum:self wantsToSendSysExData:sysexData];
}

- (void)sendPattern:(MDPattern *)pattern
{
	DLog(@"preparing to send pattern.");
	NSData *d = [pattern sysexData];
	if(d)
	{
		DLog(@"sending.");
		[self.delegate machineDrum:self wantsToSendSysExData:d];
	}
}


@end
