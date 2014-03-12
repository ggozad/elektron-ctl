//
//  A4APIParams.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 09/03/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A4Params.h"
#import "A4APIStringNumericIterator.h"

@interface A4APIParams : NSObject

+ (A4Param) synthParamWithArgs:(NSArray *)args;
+ (void) executeSetTrackSoundParamWithTrackIterator:(A4APIStringNumericIterator *) trackIt
											   args:(NSArray *)args
									   onCompletion:(void (^)(NSString *))completionHandler
											onError:(void (^)(NSString *))errorHandler;
@end
