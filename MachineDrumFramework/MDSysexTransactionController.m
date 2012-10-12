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

typedef enum TransactionReturnType
{
	TransactionReturnType_Void,
	TransactionReturnType_Kit,
	TransactionReturnType_Pattern,
	TransactionReturnType_GlobalSettings,
	TransactionReturnType_Status
}
TransactionReturnType;




@interface MDSysexTransactionController()
@property (strong, nonatomic) MDSysexTransaction *currentTransaction;
@property (strong, nonatomic) NSTimer *timeoutTimer;
@property TransactionReturnType transactionReturnType;
@end

@implementation MDSysexTransactionController

- (void) machinedrumDumpReceived:(NSNotification *)n
{
	if(!self.currentTransaction) return;
	[self.timeoutTimer invalidate];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:n.name object:self];
	NSData *d = n.object;
	id obj = nil;
	
	if (n.name == kMDSysexKitDumpNotification && self.transactionReturnType == TransactionReturnType_Kit)
	{
		obj = [MDKit kitWithData:d];
	}
	else if(n.name == kMDSysexPatternDumpNotification && self.transactionReturnType == TransactionReturnType_Pattern)
	{
		obj = [MDPattern patternWithData:d];
	}
	else if(n.name == kMDSysexGlobalSettingsDumpNotification && self.transactionReturnType == TransactionReturnType_GlobalSettings)
	{
		obj = [MDMachinedrumGlobalSettings globalSettingsWithData:d];
	}
	
	if(obj)
		[self sendSuccessfulTransactionWithObject:obj];
	
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
		NSString *notificationName = nil;
		
		if(bytes[7] == 0x02) // kit num
		{
			//DLog(@"requesting kit dump..");
			uint8_t kitNum = bytes[8] & 0x7F;
			if(self.transactionReturnType == TransactionReturnType_Status)
			{
				[self sendSuccessfulTransactionWithObject:[NSNumber numberWithInt:kitNum]];
				return;
			}
			else if(self.transactionReturnType == TransactionReturnType_Kit)
			{
				notificationName = kMDSysexKitDumpNotification;
				[[[MDMIDI sharedInstance] machinedrum] requestKitDumpForSlot:kitNum];
			}
		}
		else if(bytes[7] == 0x01) // global settings slot num
		{
			//DLog(@"requesting global dump..");
			uint8_t globalSlot = bytes[8] & 0x3F;
			
			if(self.transactionReturnType == TransactionReturnType_Status)
			{
				[self sendSuccessfulTransactionWithObject:[NSNumber numberWithInt:globalSlot]];
				return;
			}
			else if(self.transactionReturnType == TransactionReturnType_GlobalSettings)
			{
				notificationName = kMDSysexGlobalSettingsDumpNotification;
				[[[MDMIDI sharedInstance] machinedrum] requestGlobalSettingsDumpForSlot:globalSlot];
			}
		}
		else if(bytes[7] == 0x04) // pattern num
		{
			//DLog(@"requesting pattern dump..");
			uint8_t patternNum = bytes[8] & 0x7F;
			
			if(self.transactionReturnType == TransactionReturnType_Status)
			{
				[self sendSuccessfulTransactionWithObject:[NSNumber numberWithInt:patternNum]];
				return;
			}
			else if(self.transactionReturnType == TransactionReturnType_Pattern)
			{
				notificationName = kMDSysexPatternDumpNotification;
				[[[MDMIDI sharedInstance] machinedrum] requestPatternDumpForSlot:patternNum];
			}
		}
		
		if(notificationName)
		{
			[self.timeoutTimer invalidate];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(machinedrumDumpReceived:) name:notificationName object:nil];
			self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeOut:) userInfo:self.currentTransaction repeats:NO];
		}
	}
}

- (void) sendSuccessfulTransactionWithObject:(id)obj
{
	self.currentTransaction.returnedObject = obj;
	[self.timeoutTimer invalidate];
	[self.currentTransaction.delegate sysexTransactionSucceded:self.currentTransaction];
	self.currentTransaction = nil;
	_canProcessTransaction = YES;
}

- (void)requestCurrentKitNumber:(id<MDSysexTransactionDelegate>)delegate tag:(NSString *)tag
{
	MDSysexTransaction *failed = [self busyFailedTransactionWithTag:tag];
	if(failed)
	{
		failed.delegate = delegate;
		[delegate sysexTransactionFailed:failed];
	}
	_canProcessTransaction = NO;
	[self createStatusRequestTransactionForDelegate:delegate tag:tag];
	self.transactionReturnType = TransactionReturnType_Status;
	[[[MDMIDI sharedInstance] machinedrum] requestCurrentKitNumber];
}


- (void)requestCurrentKit:(id<MDSysexTransactionDelegate>)delegate tag:(NSString *)tag
{
	MDSysexTransaction *failed = [self busyFailedTransactionWithTag:tag];
	if(failed)
	{
		failed.delegate = delegate;
		[delegate sysexTransactionFailed:failed];
	}
	_canProcessTransaction = NO;
	[self createStatusRequestTransactionForDelegate:delegate tag:tag];
	self.transactionReturnType = TransactionReturnType_Kit;
	[[[MDMIDI sharedInstance] machinedrum] requestCurrentKitNumber];
	
}

- (void)requestCurrentGlobalSlot:(id<MDSysexTransactionDelegate>)delegate tag:(NSString *)tag
{
	MDSysexTransaction *failed = [self busyFailedTransactionWithTag:tag];
	if(failed)
	{
		failed.delegate = delegate;
		[delegate sysexTransactionFailed:failed];
		return;
	}
	_canProcessTransaction = NO;
	[self createStatusRequestTransactionForDelegate:delegate tag:tag];
	self.transactionReturnType = TransactionReturnType_Status;
	[[[MDMIDI sharedInstance] machinedrum] requestCurrentGlobalSettingsSlot];
}


- (void)requestCurrentGlobalSettings:(id<MDSysexTransactionDelegate>)delegate tag:(NSString *)tag
{
	MDSysexTransaction *failed = [self busyFailedTransactionWithTag:tag];
	if(failed)
	{
		failed.delegate = delegate;
		[delegate sysexTransactionFailed:failed];
		return;
	}
	_canProcessTransaction = NO;
	[self createStatusRequestTransactionForDelegate:delegate tag:tag];
	self.transactionReturnType = TransactionReturnType_GlobalSettings;
	[[[MDMIDI sharedInstance] machinedrum] requestCurrentGlobalSettingsSlot];
}

- (void)requestCurrentPatternNumber:(id<MDSysexTransactionDelegate>)delegate tag:(NSString *)tag
{
	MDSysexTransaction *failed = [self busyFailedTransactionWithTag:tag];
	if(failed)
	{
		failed.delegate = delegate;
		[delegate sysexTransactionFailed:failed];
		return;
	}
	_canProcessTransaction = NO;
	[self createStatusRequestTransactionForDelegate:delegate tag:tag];
	self.transactionReturnType = TransactionReturnType_Status;
	[[[MDMIDI sharedInstance] machinedrum] requestCurrentPatternNumber];
}

- (void)requestCurrentPattern:(id<MDSysexTransactionDelegate>)delegate tag:(NSString *)tag
{
	MDSysexTransaction *failed = [self busyFailedTransactionWithTag:tag];
	if(failed)
	{
		failed.delegate = delegate;
		[delegate sysexTransactionFailed:failed];
		return;
	}
	_canProcessTransaction = NO;
	[self createStatusRequestTransactionForDelegate:delegate tag:tag];
	self.transactionReturnType = TransactionReturnType_Pattern;
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
		_canProcessTransaction = YES;
	}
}

- (MDSysexTransaction *) busyFailedTransactionWithTag:(NSString *)tag
{
	MDSysexTransaction *failed = nil;
	
	if(!_canProcessTransaction || ![[MDMIDI sharedInstance] machinedrumMidiDestination] ||
	   ![[MDMIDI sharedInstance] machinedrumMidiSource])
	{
		DLog(@"yea");
		failed = [MDSysexTransaction new];
		failed.tag = tag;
		failed.error = MDSysexTransactionError_Busy;
	}
	return failed;
}

- (void) createStatusRequestTransactionForDelegate:(id<MDSysexTransactionDelegate>)delegate tag:(NSString *)tag
{
	MDSysexTransaction *t = [MDSysexTransaction new];
	t.error = MDSysexTransactionError_No_Error;
	t.type = MDSysexTransactionType_Request_Response;
	t.delegate = delegate;
	t.tag = [tag copy];
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
