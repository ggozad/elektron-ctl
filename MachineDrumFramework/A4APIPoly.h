//
//  A4APIPoly.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 12/03/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface A4APIPoly : NSObject

+ (void) executePolyCommandWithArgs:(NSArray *)args
					   onCompletion:(void (^)(NSString *))completionHandler
							onError:(void (^)(NSString *))errorHandler;


@end
