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

- (void) machinedrumKitDumpReceived:(NSNotification *)n
{
	if(!self.currentTransaction) return;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kMDSysexKitDumpNotification object:self];
	NSData *d = n.object;
	self.currentTransaction.returnedData = d;
	[self.currentTransaction.delegate sysexTransactionSucceded:self.currentTransaction];
	self.currentTransaction = nil;
	_canProcessTransaction = YES;
}

- (void) machinedrumStatusReceived:(NSNotification *)n
{
	if(!self.currentTransaction) return;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kMDSysexStatusResponseNotification object:nil];
	
	NSData *d = n.object;
	const uint8_t *bytes = d.bytes;
	
	if(bytes[6] == 0x72 && bytes[7] == 0x02) // kit num status
	{
		[self.timeoutTimer invalidate];
		uint8_t kitNum = bytes[8] & 0x3F;
		[[[MDMIDI sharedInstance] machinedrum] requestKitDumpForSlot:kitNum];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(machinedrumKitDumpReceived:) name:kMDSysexKitDumpNotification object:nil];
		
		self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeOut:) userInfo:self.currentTransaction repeats:NO];
	}
}

- (void)requestCurrentKit:(id<MDSysexTransactionDelegate>)delegate
{
	if(!_canProcessTransaction)
	{
		MDSysexTransaction *failed = [MDSysexTransaction new];
		failed.error = MDSysexTransactionError_Busy;
		failed.delegate = delegate;
		[failed.delegate sysexTransactionFailed:failed];
	}
	_canProcessTransaction = NO;
	MDSysexTransaction *kitTransaction = [MDSysexTransaction new];
	kitTransaction.error = MDSysexTransactionError_No_Error;
	kitTransaction.type = MDSysexTransactionType_Request_Response;
	kitTransaction.delegate = delegate;
	self.currentTransaction = kitTransaction;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(machinedrumStatusReceived:) name:kMDSysexStatusResponseNotification object:nil];
	
	[[[MDMIDI sharedInstance] machinedrum] requestCurrentKitNumber];
	self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeOut:) userInfo:kitTransaction repeats:NO];
}

- (void)requestCurrentPattern:(id<MDSysexTransactionDelegate>)delegate
{
	return;
}

- (void) timeOut:(id)userInfo
{
	self.timeoutTimer = nil;
	if(self.currentTransaction && self.currentTransaction == userInfo)
	{
		self.currentTransaction.error = MDSysexTransactionError_Response_Timed_Out;
		self.currentTransaction.returnedData = nil;
		[self.currentTransaction.delegate sysexTransactionFailed:self.currentTransaction];
		self.currentTransaction = nil;
	}
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
