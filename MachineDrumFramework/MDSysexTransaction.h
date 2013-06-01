//
//  MDSysexTransaction.h
//  md keys
//
//  Created by Jakob Penca on 8/29/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>


#define MDSysexTransactionArgumentKeyKitNumber @"MDSysexTransactionArgumentKeyKitNumber"
#define MDSysexTransactionArgumentKeyPatternNumber @"MDSysexTransactionArgumentKeyPatternNumber"
#define MDSysexTransactionArgumentKeyStatusID @"MDSysexTransactionArgumentKeyStatusID"

@class MDSysexTransaction;

typedef enum MDSysexTransactionContext
{
	MDSysexTransactionContextStatus,
	MDSysexTransactionContextCurrentPatternNumber,
	MDSysexTransactionContextCurrentPattern,
	MDSysexTransactionContextCurrentKitNumber,
	MDSysexTransactionContextCurrentKit,
//	MDSysexTransactionContextCurrentGlobalNumber,
//	MDSysexTransactionContextCurrentGlobal,
//	MDSysexTransactionContextCurrentPatternAndKit,
	MDSysexTransactionContextKit,
	MDSysexTransactionContextPattern,
//	MDSysexTransactionContextGlobal,
}
MDSysexTransactionContext;

typedef enum MDSysexStatusID
{
	MDSysexStatusIDCurrentGlobalSlot		= 0x01,
	MDSysexStatusIDCurrentKitNumber			= 0x02,
	MDSysexStatusIDCurrentPatternNumber		= 0x04,
	MDSysexStatusIDCurrentSongNumber		= 0x08,
	MDSysexStatusIDCurrentSequencerMode		= 0x10,
	MDSysexStatusIDCurrentLockMode			= 0x20,
	MDSysexStatusIDCurrentTrack				= 0x22,
}
MDSysexStatusID;


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
	MDSysexTransactionError_No_Connection,
}
MDSysexTransactionError;

@protocol MDSysexTransactionDelegate <NSObject>
- (void) sysexTransactionSucceded: (MDSysexTransaction *) transaction;
- (void) sysexTransactionFailed: (MDSysexTransaction *) transaction;
@end

@interface MDSysexTransaction : NSObject
@property (weak, nonatomic) id<MDSysexTransactionDelegate> delegate;
@property (strong, nonatomic) NSDictionary *args;
@property MDSysexTransactionContext context;
@property MDSysexTransactionType type;
@property MDSysexTransactionError error;
@property (strong, nonatomic) NSData *sentData;
@property (strong, nonatomic) id returnedObject;
@property (strong, nonatomic) NSString *tag;
@property (copy) void (^completionBlock)(MDSysexTransaction *);
@property (copy) void (^errorBlock)(MDSysexTransaction *);
@end
