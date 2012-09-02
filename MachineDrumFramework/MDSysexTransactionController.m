//
//  MDSysexTransactionController.m
//  md keys
//
//  Created by Jakob Penca on 8/29/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDSysexTransactionController.h"
#import "MDMachinedrumPublic.h"
#import "MDMIDI.h"

@interface MDSysexTransactionController()
@property (strong, nonatomic) MDSysexTransaction *currentTransaction;
@property (strong, nonatomic) NSTimer *timeoutTimer;
@end

@implementation MDSysexTransactionController

- (void) machinedrumDumpReceived:(NSNotification *)n
{
	if(!self.currentTransaction) return;
	[self.timeoutTimer invalidate];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:n.name object:self];
	NSData *d = n.object;
	
	if (n.name == kMDSysexKitDumpNotification)
	{
		MDKit *kit = [MDKit kitWithData:d];
		self.currentTransaction.returnedObject = kit;
	}
	else if(n.name == kMDSysexPatternDumpNotification)
	{
		MDPattern *p = [MDPattern patternWithData:d];
		self.currentTransaction.returnedObject = p;
	}
	else if(n.name == kMDSysexGlobalSettingsDumpNotification)
	{
		MDMachinedrumGlobalSettings *g = [MDMachinedrumGlobalSettings globalSettingsWithData:d];
		self.currentTransaction.returnedObject = g;
	}

	[self.currentTransaction.delegate sysexTransactionSucceded:self.currentTransaction];
	self.currentTransaction = nil;
	_canProcessTransaction = YES;
}

- (void) machinedrumStatusReceived:(NSNotification *)n
{
	if(!self.currentTransaction) return;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:n.name object:nil];
	
	NSData *d = n.object;
	const uint8_t *bytes = d.bytes;
	
	if(bytes[6] == 0x72)
	{
		//DLog(@"md status received..");
		[self.timeoutTimer invalidate];
		NSString *notificationName = nil;
		
		if(bytes[7] == 0x02) // kit num
		{
			//DLog(@"requesting kit dump..");
			uint8_t kitNum = bytes[8] & 0x7F;
			notificationName = kMDSysexKitDumpNotification;
			[[[MDMIDI sharedInstance] machinedrum] requestKitDumpForSlot:kitNum];
		}
		else if(bytes[7] == 0x01) // global settings slot num
		{
			//DLog(@"requesting global dump..");
			uint8_t globalSlot = bytes[8] & 0x3F;
			notificationName = kMDSysexGlobalSettingsDumpNotification;
			[[[MDMIDI sharedInstance] machinedrum] requestGlobalSettingsDumpForSlot:globalSlot];
		}
		else if(bytes[7] == 0x04) // pattern num
		{
			//DLog(@"requesting pattern dump..");
			uint8_t patternNum = bytes[8] & 0x7F;
			notificationName = kMDSysexPatternDumpNotification;
			[[[MDMIDI sharedInstance] machinedrum] requestPatternDumpForSlot:patternNum];
		}
		
		if(notificationName)
		{
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(machinedrumDumpReceived:) name:notificationName object:nil];
			self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeOut:) userInfo:self.currentTransaction repeats:NO];
		}
	}
}

- (void)requestCurrentKit:(id<MDSysexTransactionDelegate>)delegate
{
	MDSysexTransaction *failed = [self busyFailedTransaction];
	if(failed)
	{
		failed.delegate = delegate;
		[delegate sysexTransactionFailed:failed];
	}
	_canProcessTransaction = NO;
	[self createStatusRequestTransactionForDelegate:delegate];
	[[[MDMIDI sharedInstance] machinedrum] requestCurrentKitNumber];
	
}

- (void)requestCurrentGlobalSettings:(id<MDSysexTransactionDelegate>)delegate
{
	MDSysexTransaction *failed = [self busyFailedTransaction];
	if(failed)
	{
		failed.delegate = delegate;
		[delegate sysexTransactionFailed:failed];
	}
	_canProcessTransaction = NO;
	[self createStatusRequestTransactionForDelegate:delegate];
	[[[MDMIDI sharedInstance] machinedrum] requestCurrentGlobalSettingsSlot];
}

- (void)requestCurrentPattern:(id<MDSysexTransactionDelegate>)delegate
{
	MDSysexTransaction *failed = [self busyFailedTransaction];
	if(failed)
	{
		failed.delegate = delegate;
		[delegate sysexTransactionFailed:failed];
	}
	_canProcessTransaction = NO;
	[self createStatusRequestTransactionForDelegate:delegate];
	[[[MDMIDI sharedInstance] machinedrum] requestCurrentPatternNumber];
}

- (void) timeOut:(id)userInfo
{
	DLog(@"timeout!");
	self.timeoutTimer = nil;
	if(self.currentTransaction && self.currentTransaction == userInfo)
	{
		DLog(@"notifying delegate of fail...");
		self.currentTransaction.error = MDSysexTransactionError_Response_Timed_Out;
		self.currentTransaction.returnedObject = nil;
		[self.currentTransaction.delegate sysexTransactionFailed:self.currentTransaction];
		self.currentTransaction = nil;
	}
}

- (MDSysexTransaction *) busyFailedTransaction
{
	MDSysexTransaction *failed = nil;
	
	if(!_canProcessTransaction || ![[MDMIDI sharedInstance] machinedrumMidiDestination] ||
	   ![[MDMIDI sharedInstance] machinedrumMidiSource])
	{
		failed = [MDSysexTransaction new];
		failed.error = MDSysexTransactionError_Busy;
	}
	return failed;
}

- (void) createStatusRequestTransactionForDelegate:(id<MDSysexTransactionDelegate>)delegate
{
	MDSysexTransaction *t = [MDSysexTransaction new];
	t.error = MDSysexTransactionError_No_Error;
	t.type = MDSysexTransactionType_Request_Response;
	t.delegate = delegate;
	self.currentTransaction = t;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(machinedrumStatusReceived:) name:kMDSysexStatusResponseNotification object:nil];
	self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeOut:) userInfo:self.currentTransaction repeats:NO];
}

- (id)init
{
	if (self = [super init])
	{
		_canProcessTransaction = YES;
	}
	return self;
}


@end
