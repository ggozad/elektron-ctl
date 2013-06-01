//
//  MDSysexTransaction.m
//  md keys
//
//  Created by Jakob Penca on 8/29/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDSysexTransaction.h"

@implementation MDSysexTransaction

/*
- (void)setCompletionBlock:(void (^)(MDSysexTransaction *))completionBlock
{
	if(_completionBlock == completionBlock) return;
	
	void (^old)(MDSysexTransaction *) = _completionBlock;
	_completionBlock = Block_copy(completionBlock);
	if(old) Block_release(old);
}


- (void)setErrorBlock:(void (^)(MDSysexTransaction *))errorBlock
{
	if(_errorBlock == errorBlock) return;
	
	void (^old)(MDSysexTransaction *) = _errorBlock;
	_errorBlock = Block_copy(errorBlock);
	if(old) Block_release(old);
}

 */

@end
