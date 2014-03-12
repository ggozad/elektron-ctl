//
//  A4API.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 06/03/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface A4API : NSObject

+ (instancetype) sharedInstance;
- (void) executeCommand:(NSArray *)commandTokens
		   onCompletion:(void(^)(NSString *str))completionHandler
				onError:(void(^)(NSString *str))errorHandler;
@end
