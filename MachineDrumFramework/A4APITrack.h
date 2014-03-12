//
//  A4APITrack.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 09/03/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A4APIStringNumericIterator.h"

@interface A4APITrack : NSObject

+ (void) executeArpCommandWithTrackIterator:(A4APIStringNumericIterator *)trackIt
									   args:(NSArray *)args
							   onCompletion:(void (^)(NSString *))completionHandler
									onError:(void (^)(NSString *))errorHandler;


+ (void) executeTrackSettingsCommandWithTrackIterator:(A4APIStringNumericIterator *)trackIt
												 args:(NSArray *)args
										 onCompletion:(void (^)(NSString *))completionHandler
											  onError:(void (^)(NSString *))errorHandler;

+ (void) executeTrackLengthCommandWithTrackIterator:(A4APIStringNumericIterator *)trackIt
											   args:(NSArray *)args
									   onCompletion:(void (^)(NSString *))completionHandler
											onError:(void (^)(NSString *))errorHandler;


+ (void) executeLevelCommandWithTrackIterator:(A4APIStringNumericIterator *)trackIt
										 args:(NSArray *)args
								 onCompletion:(void (^)(NSString *))completionHandler
									  onError:(void (^)(NSString *))errorHandler;


+ (void) executeShiftCommandWithTrackIterator:(A4APIStringNumericIterator *)trackIt
										 args:(NSString *)arg
								 onCompletion:(void (^)(NSString *))completionHandler
									  onError:(void (^)(NSString *))errorHandler;

@end
