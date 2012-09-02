//
//  MDSysexTransactionController.h
//  md keys
//
//  Created by Jakob Penca on 8/29/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDSysexTransaction.h"


@interface MDSysexTransactionController : NSObject
@property (readonly) BOOL canProcessTransaction;

- (void) requestCurrentGlobalSlot:(id<MDSysexTransactionDelegate>)delegate;
- (void) requestCurrentKitNumber:(id<MDSysexTransactionDelegate>)delegate;
- (void) requestCurrentPatternNumber:(id<MDSysexTransactionDelegate>)delegate;
- (void) requestCurrentSongNumber:(id<MDSysexTransactionDelegate>)delegate;
- (void) requestCurrentSequencerMode:(id<MDSysexTransactionDelegate>)delegate;
- (void) requestCurrentLockMode:(id<MDSysexTransactionDelegate>)delegate;

- (void) requestCurrentKit:(id<MDSysexTransactionDelegate>)delegate;
- (void) requestCurrentPattern:(id<MDSysexTransactionDelegate>)delegate;
- (void) requestCurrentGlobalSettings:(id<MDSysexTransactionDelegate>)delegate;

@end
