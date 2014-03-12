//
//  A4APIPattern.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 09/03/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface A4APIPattern : NSObject

+ (void) executeModeCommandWithModeArg:(NSString *)arg
							  onCompletion:(void (^)(NSString *))completionHandler
								   onError:(void (^)(NSString *))errorHandler;

+ (void) executeLengthCommandWithLengthArg:(NSString *)arg
							  onCompletion:(void (^)(NSString *))completionHandler
								   onError:(void (^)(NSString *))errorHandler;

+ (void) executeScaleCommandWithScaleArg:(NSString *)arg
							onCompletion:(void (^)(NSString *))completionHandler
								 onError:(void (^)(NSString *))errorHandler;

@end
