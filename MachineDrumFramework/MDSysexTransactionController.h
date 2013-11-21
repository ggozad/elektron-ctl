//
//  MDSysexTransactionController.h
//  md keys
//
//  Created by Jakob Penca on 8/29/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDSysexTransaction.h"
#import "MDKitMachine.h"

typedef enum MDSysexTransactionQueuePriority
{
	MDSysexTransactionQueuePriorityHigh,
	MDSysexTransactionQueuePriorityLow
}
MDSysexTransactionQueuePriority;


@interface MDSysexTransactionController : NSObject

- (void) clearQueue;

- (void) request:(MDSysexTransactionContext)context
	   arguments:(NSDictionary *)args
		priority:(MDSysexTransactionQueuePriority)priority
	onCompletion:(void (^)(MDSysexTransaction *t))onCompletion
		 onError:(void (^)(MDSysexTransaction *t))onError;

@end
