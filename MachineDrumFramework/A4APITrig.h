//
//  A4APITrig.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 08/03/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>

@class A4APIStringNumericIterator;

@interface A4APITrig : NSObject

+ (void) executePutTrigCommandWithTrackIterator:(A4APIStringNumericIterator *)trackIt
								   stepIterator:(A4APIStringNumericIterator *)stepIt
										   args:(NSArray *)argTokens
								   onCompletion:(void (^)(NSString *))completionHandler
										onError:(void (^)(NSString *))errorHandler;

+ (void) executeClearTrigCommandWithTrackIterator:(A4APIStringNumericIterator *)trackIt
									 stepIterator:(A4APIStringNumericIterator *)stepIt
									 onCompletion:(void (^)(NSString *))completionHandler
										  onError:(void (^)(NSString *))errorHandler;
@end
