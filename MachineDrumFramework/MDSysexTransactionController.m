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

static uint8_t statusRequestMessage[] = {0xf0, 0x00, 0x20, 0x3c, 0x02, 0x00, 0x70, 0x00, 0xf7};

typedef enum TransactionReturnType
{
	TransactionReturnType_Void,
	TransactionReturnType_Kit,
	TransactionReturnType_Pattern,
	TransactionReturnType_PatternAndKit,
	TransactionReturnType_GlobalSettings,
	TransactionReturnType_Status
}
TransactionReturnType;

@interface MDSysexTransactionController() <MDSysexTransactionDelegate>
@property (strong, nonatomic) NSMutableArray *transactionQueue;
@property (strong, nonatomic) MDSysexTransaction *currentTransaction;
@property (strong, nonatomic) NSTimer *timeoutTimer;
@property TransactionReturnType transactionReturnType; // used internally!
@property (readonly) BOOL canProcessTransaction;
@end

@implementation MDSysexTransactionController

- (void)sysexTransactionSucceded:(MDSysexTransaction *)transaction
{
	MDSysexTransaction *tNew = [MDSysexTransaction new];
	tNew.returnedObject = transaction.returnedObject;
	_canProcessTransaction = YES;
	self.currentTransaction = nil;
	transaction.completionBlock(tNew);
	[self dequeue];
}

- (void)sysexTransactionFailed:(MDSysexTransaction *)transaction
{
	DLog(@"FAILX %d", transaction.context);
	MDSysexTransaction *tNew = [MDSysexTransaction new];
	tNew.returnedObject = transaction.returnedObject;
	transaction.errorBlock(tNew);
	_canProcessTransaction = YES;
	self.currentTransaction = nil;
	[self dequeue];
}

- (void) machinedrumDumpReceived:(NSNotification *)n
{
	DLog(@"received md dump..");
	
	if(!self.currentTransaction) return;
	[self.timeoutTimer invalidate];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:n.name object:nil];
	NSData *d = n.object;
	id obj = nil;
	
	if ([n.name isEqualToString:kMDSysexKitDumpNotification] && self.transactionReturnType == TransactionReturnType_Kit)
	{
		obj = [MDKit kitWithData:d];
	}
	else if([n.name  isEqualToString: kMDSysexPatternDumpNotification] && self.transactionReturnType == TransactionReturnType_Pattern)
	{
		obj = [MDPattern patternWithData:d];
	}
	else if([n.name isEqualToString: kMDSysexGlobalSettingsDumpNotification] && self.transactionReturnType == TransactionReturnType_GlobalSettings)
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
		else if(bytes[7] == 0x08)
		{
			uint8_t songNum = bytes[8] & 0x7f;
			if(self.transactionReturnType == TransactionReturnType_Status)
			{
				[self sendSuccessfulTransactionWithObject:@(songNum)];
				return;
			}
		}
		else if(bytes[7] == 0x10 || bytes[7] == 0x20 || bytes[7] == 0x22)
		{
			uint8_t status = bytes[8];
			if(self.transactionReturnType == TransactionReturnType_Status)
			{
				[self sendSuccessfulTransactionWithObject:@(status)];
				return;
			}
		}
		
		if(notificationName)
		{
			[self.timeoutTimer invalidate];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(machinedrumDumpReceived:) name:notificationName object:nil];
			self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(timeOut:) userInfo:self.currentTransaction repeats:NO];
		}
	}
}

- (void) sendSuccessfulTransactionWithObject:(id)obj
{
	self.currentTransaction.returnedObject = obj;
	[self.timeoutTimer invalidate];
	_canProcessTransaction = YES;
	MDSysexTransaction *t = self.currentTransaction;
	self.currentTransaction = nil;
	[t.delegate sysexTransactionSucceded:t];
}

- (void)requestCurrentKitNumber:(id<MDSysexTransactionDelegate>)delegate tag:(NSString *)tag
{
	MDSysexTransaction *failed = [self connectionFailedTransactionWithTag:tag];
	if(failed)
	{
		failed.delegate = delegate;
		[delegate sysexTransactionFailed:failed];
	}
	_canProcessTransaction = NO;
	[self beginTransaction:self.currentTransaction];
	self.transactionReturnType = TransactionReturnType_Status;
	[[[MDMIDI sharedInstance] machinedrum] requestCurrentKitNumber];
}


- (void)requestCurrentKit:(id<MDSysexTransactionDelegate>)delegate tag:(NSString *)tag
{
	MDSysexTransaction *failed = [self connectionFailedTransactionWithTag:tag];
	if(failed)
	{
		failed.delegate = delegate;
		[delegate sysexTransactionFailed:failed];
	}
	_canProcessTransaction = NO;
	[self beginTransaction:self.currentTransaction];
	self.transactionReturnType = TransactionReturnType_Kit;
	[[[MDMIDI sharedInstance] machinedrum] requestCurrentKitNumber];
	
}

- (void) requestKitNumber:(uint8_t)kitNum delegate:(id<MDSysexTransactionDelegate>)delegate tag:(NSString *)tag
{
	DLog(@"requesting kit %d", kitNum);
	MDSysexTransaction *failed = [self connectionFailedTransactionWithTag:tag];
	if(failed)
	{
		failed.delegate = delegate;
		[delegate sysexTransactionFailed:failed];
		return;
	}
	
	self.currentTransaction.error = MDSysexTransactionError_No_Error;
	self.currentTransaction.type = MDSysexTransactionType_Dump;
	self.currentTransaction.delegate = delegate;
	self.currentTransaction.tag = [tag copy];
	self.transactionReturnType = TransactionReturnType_Kit;
	_canProcessTransaction = NO;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(machinedrumDumpReceived:) name:kMDSysexKitDumpNotification object:nil];
	self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(timeOut:) userInfo:self.currentTransaction repeats:NO];
	[[[MDMIDI sharedInstance] machinedrum] requestKitDumpForSlot:kitNum];
}

- (void) requestPatternNumber:(uint8_t)slot delegate:(id<MDSysexTransactionDelegate>)delegate tag:(NSString *)tag
{
	DLog(@"requesting pattern %d", slot);
	MDSysexTransaction *failed = [self connectionFailedTransactionWithTag:tag];
	if(failed)
	{
		failed.delegate = delegate;
		[delegate sysexTransactionFailed:failed];
		return;
	}
	
	self.currentTransaction.error = MDSysexTransactionError_No_Error;
	self.currentTransaction.type = MDSysexTransactionType_Dump;
	self.currentTransaction.delegate = delegate;
	self.currentTransaction.tag = [tag copy];
	self.transactionReturnType = TransactionReturnType_Pattern;
	_canProcessTransaction = NO;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(machinedrumDumpReceived:) name:kMDSysexPatternDumpNotification object:nil];
	self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(timeOut:) userInfo:self.currentTransaction repeats:NO];
	
	[[[MDMIDI sharedInstance] machinedrum] requestPatternDumpForSlot:slot];
}

- (void)requestCurrentGlobalSlot:(id<MDSysexTransactionDelegate>)delegate tag:(NSString *)tag
{
	MDSysexTransaction *failed = [self connectionFailedTransactionWithTag:tag];
	if(failed)
	{
		failed.delegate = delegate;
		[delegate sysexTransactionFailed:failed];
		return;
	}
	_canProcessTransaction = NO;
	[self beginTransaction:self.currentTransaction];
	self.transactionReturnType = TransactionReturnType_Status;
	[[[MDMIDI sharedInstance] machinedrum] requestCurrentGlobalSettingsSlot];
}


- (void)requestCurrentGlobalSettings:(id<MDSysexTransactionDelegate>)delegate tag:(NSString *)tag
{
	MDSysexTransaction *failed = [self connectionFailedTransactionWithTag:tag];
	if(failed)
	{
		failed.delegate = delegate;
		[delegate sysexTransactionFailed:failed];
		return;
	}
	_canProcessTransaction = NO;
	[self beginTransaction:self.currentTransaction];
	self.transactionReturnType = TransactionReturnType_GlobalSettings;
	[[[MDMIDI sharedInstance] machinedrum] requestCurrentGlobalSettingsSlot];
}

- (void)requestCurrentPatternNumber:(id<MDSysexTransactionDelegate>)delegate tag:(NSString *)tag
{
	MDSysexTransaction *failed = [self connectionFailedTransactionWithTag:tag];
	if(failed)
	{
		failed.delegate = delegate;
		[delegate sysexTransactionFailed:failed];
		return;
	}
	_canProcessTransaction = NO;
	[self beginTransaction:self.currentTransaction];
	self.transactionReturnType = TransactionReturnType_Status;
	[[[MDMIDI sharedInstance] machinedrum] requestCurrentPatternNumber];
}

- (void)requestCurrentPattern:(id<MDSysexTransactionDelegate>)delegate tag:(NSString *)tag
{
	MDSysexTransaction *failed = [self connectionFailedTransactionWithTag:tag];
	if(failed)
	{
		failed.delegate = delegate;
		[delegate sysexTransactionFailed:failed];
		return;
	}

	_canProcessTransaction = NO;
	[self beginTransaction:self.currentTransaction];
	self.transactionReturnType = TransactionReturnType_Pattern;
	[[[MDMIDI sharedInstance] machinedrum] requestCurrentPatternNumber];
}



- (void) requestStatus:(uint8_t) statusID withDelegate:(id<MDSysexTransactionDelegate>)delegate tag:(NSString *)tag
{
	MDSysexTransaction *failed = [self connectionFailedTransactionWithTag:tag];
	if(failed)
	{
		failed.delegate = delegate;
		[delegate sysexTransactionFailed:failed];
		return;
	}
	
	_canProcessTransaction = NO;
	[self beginTransaction:self.currentTransaction];
	self.transactionReturnType = TransactionReturnType_Status;
	statusRequestMessage[7] = statusID;
	NSData *data = [NSData dataWithBytes:statusRequestMessage length:9];
	[[[MDMIDI sharedInstance] machinedrumMidiDestination] sendSysexData:data];
}

- (void) timeOut:(id)userInfo
{
	DLog(@"timeout!");
	self.timeoutTimer = nil;
	
	DLog(@"notifying delegate of fail...");
	self.currentTransaction.error = MDSysexTransactionError_Response_Timed_Out;
	self.currentTransaction.returnedObject = nil;
	[self.currentTransaction.delegate sysexTransactionFailed:self.currentTransaction];
	self.currentTransaction = nil;
	_canProcessTransaction = YES;
}

- (MDSysexTransaction *) connectionFailedTransactionWithTag:(NSString *)tag
{
	MDSysexTransaction *failed = nil;
	
	if(![[MDMIDI sharedInstance] machinedrumMidiDestination] ||
	   ![[MDMIDI sharedInstance] machinedrumMidiSource])
	{
		DLog(@"NO CONNECTION");
		failed = [MDSysexTransaction new];
		failed.tag = tag;
		failed.error = MDSysexTransactionError_No_Connection;
	}
	return failed;
}

- (MDSysexTransaction *) transactionForDelegate:(id<MDSysexTransactionDelegate>)delegate tag:(NSString *)tag
{
	MDSysexTransaction *t = [MDSysexTransaction new];
	t.error = MDSysexTransactionError_No_Error;
	t.type = MDSysexTransactionType_Request_Response;
	t.delegate = delegate;
	t.tag = [tag copy];
	return t;
}

- (void) beginTransaction:(MDSysexTransaction *)t
{
	self.currentTransaction = t;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(machinedrumStatusReceived:) name:kMDSysexStatusResponseNotification object:nil];
	self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(timeOut:) userInfo:self.currentTransaction repeats:NO];
}

- (id)init
{
	if (self = [super init])
	{
		_canProcessTransaction = YES;
		self.transactionQueue = [NSMutableArray array];
	}
	return self;
}

- (void)request:(MDSysexTransactionContext)context
	  arguments:(NSDictionary *)args
	   priority:(MDSysexTransactionQueuePriority)priority
   onCompletion:(void (^)(MDSysexTransaction *))onCompletion
		onError:(void (^)(MDSysexTransaction *))onError
{
	MDSysexTransaction *failed = [self connectionFailedTransactionWithTag:@""];
	if(failed)
	{
		onError(failed);
		return;
	}

	MDSysexTransaction *t = nil;

	if(context == MDSysexTransactionContextCurrentKit)
	{
		t = [self transactionForDelegate:self tag:@"current kit"];
	}
	else if(context == MDSysexTransactionContextKit)
	{
		t = [self transactionForDelegate:self tag:@"specific kit"];
	}
	else if (context == MDSysexTransactionContextCurrentKitNumber)
	{
		t = [self transactionForDelegate:self tag:@"current kit number"];
	}
	else if (context == MDSysexTransactionContextCurrentPattern)
	{
		t = [self transactionForDelegate:self tag:@"current pattern"];
	}
	else if (context == MDSysexTransactionContextPattern)
	{
		t = [self transactionForDelegate:self tag:@"specific pattern"];
	}
	else if (context == MDSysexTransactionContextCurrentPatternNumber)
	{
		t = [self transactionForDelegate:self tag:@"current pattern number"];
	}
	else if (context == MDSysexTransactionContextStatus)
	{
		t = [self transactionForDelegate:self tag:@"status"];
	}


	if(!onCompletion || !onError)
	{
		DLog(@"no completion or error block...");
		return;
	}
	if(t)
	{
		t.args = args;
		t.completionBlock = onCompletion;
		t.errorBlock = onError;
		t.context = context;
		[self enqueueTransaction:t withPriority:priority];
	}

	[self dequeue];
}

- (void) dequeue
{
	if(self.currentTransaction) return;
	if(!self.canProcessTransaction) return;
	
	if(self.transactionQueue.count)
	{
		self.currentTransaction = [self.transactionQueue objectAtIndex:0];
		[self.transactionQueue removeObjectAtIndex:0];
		
		NSDictionary *args = self.currentTransaction.args;
		MDSysexTransactionContext context = self.currentTransaction.context;
		
		if(context == MDSysexTransactionContextCurrentKit)
		{
			[self requestCurrentKit:self tag:self.currentTransaction.tag];
		}
		else if(context == MDSysexTransactionContextCurrentKitNumber)
		{
			[self requestCurrentKitNumber:self tag:self.currentTransaction.tag];
		}
		else if(context == MDSysexTransactionContextKit)
		{
			NSNumber *i = [args valueForKey:MDSysexTransactionArgumentKeyKitNumber];
			
			if(!i || !args)
			{
				self.currentTransaction.errorBlock(self.currentTransaction);
				self.currentTransaction = nil;
				[self dequeue];
				return;
			}
			else
			{
				[self requestKitNumber:[i charValue] delegate:self tag:self.currentTransaction.tag];
			}
		}
		else if(context == MDSysexTransactionContextCurrentPattern)
		{
			[self requestCurrentPattern:self tag:self.currentTransaction.tag];
		}
		else if(context == MDSysexTransactionContextCurrentPatternNumber)
		{
			[self requestCurrentPatternNumber:self tag:self.currentTransaction.tag];
		}
		else if(context == MDSysexTransactionContextPattern)
		{
			NSNumber *i = [args valueForKey:MDSysexTransactionArgumentKeyPatternNumber];
			
			if(!i || !args)
			{
				self.currentTransaction.errorBlock(self.currentTransaction);
				self.currentTransaction = nil;
				[self dequeue];
				return;
			}
			else
			{
				[self requestPatternNumber:[i charValue] delegate:self tag:self.currentTransaction.tag];
			}
		}
		else if(context == MDSysexTransactionContextStatus)
		{
			NSNumber *i = [args valueForKey:MDSysexTransactionArgumentKeyStatusID];
			
			if(!i || !args)
			{
				self.currentTransaction.errorBlock(self.currentTransaction);
				self.currentTransaction = nil;
				[self dequeue];
				return;
			}
			else
			{
				[self requestStatus:[i charValue] withDelegate:self tag:self.currentTransaction.tag];
			}
			
		}
	}
}

- (void) enqueueTransaction:(MDSysexTransaction *)t withPriority:(MDSysexTransactionQueuePriority)priority
{
	if(priority == MDSysexTransactionQueuePriorityLow)
		[self.transactionQueue addObject:t];
	else if(priority == MDSysexTransactionQueuePriorityHigh)
		[self.transactionQueue insertObject:t atIndex:0];
}



@end
