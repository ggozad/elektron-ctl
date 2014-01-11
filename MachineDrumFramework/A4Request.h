//
//  A4Request.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 09/12/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum A4RequestOptions
{
	A4RequestOptionsPatternsWithKits					= 1 << 0,
	A4RequestOptionsPatternsWithLockedSounds			= 1 << 1,
	A4RequestOptionsAllPatterns							= 1 << 2,
	A4RequestOptionsAllSounds							= 1 << 3,
	A4RequestOptionsAllKits								= 1 << 4,
	A4RequestOptionsAllGlobals							= 1 << 5,
	A4RequestOptionsAllSettings							= 1 << 6,
	A4RequestOptionsAllSongs							= 1 << 7,
	A4RequestOptionsSongsWithPatterns					= 1 << 8,
	A4RequestOptions_SAFER_								= 1 << 9,
}
A4RequestOptions;

typedef enum A4SysexRequestID
{
	A4SysexRequestID_NULL		= 0,
	A4SysexRequestID_Kit		= 0x62,
	A4SysexRequestID_Sound		= 0x63,
	A4SysexRequestID_Pattern	= 0x64,
	A4SysexRequestID_Song		= 0x65,
	A4SysexRequestID_Settings	= 0x66,
	A4SysexRequestID_Global		= 0x67,
	
	A4SysexRequestID_Kit_X		= 0x68,
	A4SysexRequestID_Sound_X	= 0x69,
	A4SysexRequestID_Pattern_X	= 0x6A,
	A4SysexRequestID_Song_X		= 0x6B,
	A4SysexRequestID_Settings_X	= 0x6C,
	A4SysexRequestID_Global_X	= 0x6D,
}
A4SysexRequestID;


typedef enum A4RequestPriority
{
	A4RequestPriorityDefault
}
A4RequestPriority;


#define A4RequestHandle NSInteger

@protocol A4RequestDelegate <NSObject>
@optional
- (void) a4requestDidBeginRequestWithHandle:(A4RequestHandle) handle;
- (void) a4requestWithHandle:(A4RequestHandle) handle didUpdateProgress:(double)progress;
@end

@interface A4Request : NSObject

+ (instancetype) sharedInstance;
+ (void) cancelAllRequests;
+ (BOOL) cancelRequest:(NSInteger)handle;

+ (A4RequestHandle)requestWithKeys:(NSArray *)keys
						   options:(A4RequestOptions)optionsBitmask
						  priority:(A4RequestPriority)priority
						  delegate:(id<A4RequestDelegate>)delegate
				   completionQueue:(dispatch_queue_t)queue
				 completionHandler:(void (^)(NSDictionary *dict)) completionHandler
					  errorHandler:(void (^)(NSError *err)) errorHandler;

+ (A4RequestHandle)requestWithKeys:(NSArray *)keys
						   options:(A4RequestOptions)optionsBitmask
						  delegate:(id<A4RequestDelegate>)delegate
				 completionHandler:(void (^)(NSDictionary *dict))completionHandler
					  errorHandler:(void (^)(NSError *err))errorHandler;

+ (A4RequestHandle)requestWithKeys:(NSArray *)keys
				 completionHandler:(void (^)(NSDictionary *dict))completionHandler
					  errorHandler:(void (^)(NSError *err))errorHandler;


@end
