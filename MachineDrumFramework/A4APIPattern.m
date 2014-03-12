//
//  A4APIPattern.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 09/03/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import "A4APIPattern.h"
#import "A4APIStringNumericIterator.h"
#import "A4Pattern.h"
#import "A4Request.h"
#import "MDMath.h"

@implementation A4APIPattern

+ (void)executeModeCommandWithModeArg:(NSString *)arg
						 onCompletion:(void (^)(NSString *))completionHandler
							  onError:(void (^)(NSString *))errorHandler
{
	int mode = -1;
	
	if([arg isEqualToString:@"NORMAL"]) mode = A4PatternTimeModeNormal;
	if([arg isEqualToString:@"ADVANCED"]) mode = A4PatternTimeModeAdvanced;
	
	if(mode == -1)
	{
		errorHandler([NSString stringWithFormat:@"INVALID MODE %@", arg]);
		return;
	}
	
	[A4Request requestWithKeys:@[@"pat.x"]
			 completionHandler:^(NSDictionary *dict) {
				
				 A4Pattern *pattern = dict[@"pat.x"];
				 pattern.timeMode = mode;
				 [pattern sendTemp];
				 completionHandler([NSString stringWithFormat:@"PATTERN MODE %@", arg]);
				 
			 } errorHandler:^(NSError *err) {
				 
			 }];
	
	
	
	
	
}

+ (void)executeScaleCommandWithScaleArg:(NSString *)arg
						   onCompletion:(void (^)(NSString *))completionHandler
								onError:(void (^)(NSString *))errorHandler
{
	int scale = -1;
	
	if([arg isEqualToString:@"1/8"]) scale = A4PatternTimeScale_1_8;
	else if([arg isEqualToString:@"1/4"]) scale = A4PatternTimeScale_1_4;
	else if([arg isEqualToString:@"1/2"]) scale = A4PatternTimeScale_1_2;
	else if([arg isEqualToString:@"3/4"]) scale = A4PatternTimeScale_3_4;
	else if([arg isEqualToString:@"1"] || [arg isEqualToString:@"1/1"]) scale = A4PatternTimeScale_1_1;
	else if([arg isEqualToString:@"3/2"]) scale = A4PatternTimeScale_3_2;
	else if([arg isEqualToString:@"2/1"] ||[arg isEqualToString:@"2"]) scale = A4PatternTimeScale_2_1;
	
	if(scale == -1)
	{
		errorHandler([NSString stringWithFormat:@"INVALID SCALE %@", arg]);
		return;
	}
	
	
	[A4Request requestWithKeys:@[@"pat.x"]
			 completionHandler:^(NSDictionary *dict) {
				 A4Pattern *pattern = dict[@"pat.x"];
				 pattern.timeScale = scale;
				 [pattern sendTemp];
				 completionHandler([NSString stringWithFormat:@"PATTERN SCALE %@", arg]);
			 } errorHandler:^(NSError *err) {
				 errorHandler(err.description);
			 }];
	
	
}

+ (void) executeLengthCommandWithLengthArg:(NSString *)arg
							  onCompletion:(void (^)(NSString *))completionHandler
								   onError:(void (^)(NSString *))errorHandler
{
	int length = -1;
	if([arg isEqualToString:@"INF"])
	{
		 length = A4PatternMasterLengthInfinite;
	}
	else
	{
		A4APIStringNumericIterator *it = [A4APIStringNumericIterator iteratorWithStringToken:arg
																					   range:A4ApiIteratorRangeMake(2, 1024)
																						mode:A4ApiIteratorRangeModeBreak
																					   inVal:A4ApiIteratorInputValInt
																					  retVal:A4ApiIteratorReturnValInt];
		if(it.isValid) length = [it currentValue];
	}
	
	if(length == -1)
	{
		errorHandler(@"INAVLID PATTERN LENGTH");
		return;
	}
	
	[A4Request requestWithKeys:@[@"pat.x"]
			 completionHandler:^(NSDictionary *dict) {
				 
				 A4Pattern *pattern = dict[@"pat.x"];
				 if(pattern.timeMode == A4PatternTimeModeNormal && (length > 64 || length == A4PatternMasterLengthInfinite))
				 {
					 errorHandler(@"INVALID LENGTH FOR NORMAL PATTERN MODE. SET MODE TO ADVANCED FIRST.");
					 return;
				 }
				 
				 
				 if(pattern.timeMode == A4PatternTimeModeNormal)
				 {
					 for(int trk = 0; trk < 6; trk++)
					 {
						 {
							 uint8_t oldLength = [pattern track:trk].settings->trackLength;
							 
							 if(length > oldLength)
							 {
								 A4PVal locksBuf[128];
								 uint8_t locksLen = 0;
								 
								 for(int i = oldLength; i < length; i++)
								 {
									 [pattern clearTrigAtStep:i inTrack:trk];
									 int stepToCopyFrom = mdmath_wrap(i-oldLength, 0, oldLength-1);
									 
									 A4Trig trig = [pattern trigAtStep:stepToCopyFrom inTrack:trk];
									 [pattern setTrig:trig atStep:i inTrack:trk];
									 
									 if(A4LocksForTrackAndStep(pattern, stepToCopyFrom, trk, locksBuf, &locksLen))
									 {
										 for(int j = 0; j < locksLen; j++)
										 {
											 [pattern setLock:locksBuf[j] atStep:i inTrack:trk];
										 }
									 }
								 }
							 }
						 }
					 }
				 }
				 
				 
				 pattern.masterLength = length;
				 [pattern sendTemp];
				 
				 NSString *completionString =
				 [NSString stringWithFormat:@"PATTERN LENGTH %@",
				  length != A4PatternMasterLengthInfinite ? [NSString stringWithFormat:@"%d", length] : @"INF"];
				 
				 completionHandler(completionString);
				 
			 } errorHandler:^(NSError *err) {
				 errorHandler(err.description);
			 }];
	
	
	
	
	
}


@end
