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

- (void) requestCurrentGlobalSlot:(id<MDSysexTransactionDelegate>)delegate tag:(NSString *)tag;
- (void) requestCurrentKitNumber:(id<MDSysexTransactionDelegate>)delegate tag:(NSString *)tag;
- (void) requestCurrentPatternNumber:(id<MDSysexTransactionDelegate>)delegate tag:(NSString *)tag;
- (void) requestCurrentSongNumber:(id<MDSysexTransactionDelegate>)delegate tag:(NSString *)tag;
- (void) requestCurrentSequencerMode:(id<MDSysexTransactionDelegate>)delegate tag:(NSString *)tag;
- (void) requestCurrentLockMode:(id<MDSysexTransactionDelegate>)delegate tag:(NSString *)tag;

- (void) requestCurrentKit:(id<MDSysexTransactionDelegate>)delegate tag:(NSString *)tag;
- (void) requestCurrentPattern:(id<MDSysexTransactionDelegate>)delegate tag:(NSString *)tag;
- (void) requestCurrentGlobalSettings:(id<MDSysexTransactionDelegate>)delegate tag:(NSString *)tag;

@end
