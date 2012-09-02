//
//  MDSysexTransaction.h
//  md keys
//
//  Created by Jakob Penca on 8/29/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MDSysexTransaction;

typedef enum MDSysexTransactionType
{
	MDSysexTransactionType_Request_Response,
	MDSysexTransactionType_Dump,
	MDSysexTransactionType_Receive
}
MDSysexTransactionType;

typedef enum MDSysexTransactionError
{
	MDSysexTransactionError_No_Error,
	MDSysexTransactionError_Response_Timed_Out,
	MDSysexTransactionError_Data_Corrupted,
	MDSysexTransactionError_Busy,
}
MDSysexTransactionError;

@protocol MDSysexTransactionDelegate <NSObject>
- (void) sysexTransactionSucceded: (MDSysexTransaction *) transaction;
- (void) sysexTransactionFailed: (MDSysexTransaction *) transaction;
@end


@interface MDSysexTransaction : NSObject
@property (weak, nonatomic) id<MDSysexTransactionDelegate> delegate;
@property MDSysexTransactionType type;
@property MDSysexTransactionError error;
@property (strong, nonatomic) NSData *sentData;
@property (strong, nonatomic) NSData *returnedData;
@end
