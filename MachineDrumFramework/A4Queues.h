//
//  A4Queues.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 09/12/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface A4Queues : NSObject
+ (dispatch_queue_t) sysexQueue;
+ (dispatch_queue_t) realtimeQueue;
+ (dispatch_queue_t) voiceQueue;
@end
