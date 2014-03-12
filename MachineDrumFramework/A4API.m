//
//  A4API.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 06/03/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import "A4API.h"
#import "MDMachinedrumPublic.h"
#import "A4APITrig.h"
#import "A4APITrack.h"
#import "A4APIPattern.h"
#import "A4APIParams.h"
#import "A4APIStringNumericIterator.h"

@implementation A4API


+ (instancetype)sharedInstance
{
	static A4API *instance = nil;
	static dispatch_once_t token;
	dispatch_once(&token, ^{
		instance = [self new];
	});
	return instance;
}

- (void)executeCommand:(NSArray *)commandTokens
		  onCompletion:(void (^)(NSString *))completionHandler
			   onError:(void (^)(NSString *))errorHandler
{
	NSMutableArray *t = [NSMutableArray array];
	
	for(NSString *token in commandTokens)
	{
		if(token.length)
		{
			NSString *stripped =
			[[token uppercaseString]
			 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			if(stripped.length)
			[t addObject:stripped];
		}
	}
	
	NSString *errStr = @"";
	for(NSString *token in t)
	{
		errStr = [errStr stringByAppendingString:token];
		errStr = [errStr stringByAppendingString:@" "];
	}
	
	errStr = [NSString stringWithFormat:@"invalid command: %@", errStr];
	
	if(!t.count)
	{
		errorHandler(errStr);
	}
	
	if([t[0] isEqualToString:@"START"] && t.count == 1)
	{
		[self executeTransportCommandWithTransportCode:MD_MIDI_RT_START
										  onCompletion:completionHandler
											   onError:errorHandler];
	}
	else if ([t[0] isEqualToString:@"STOP"] && t.count == 1)
	{
		[self executeTransportCommandWithTransportCode:MD_MIDI_RT_STOP
										  onCompletion:completionHandler
											   onError:errorHandler];
	}
	else if ([t[0] isEqualToString:@"CONTINUE"])
	{
		[self executeTransportCommandWithTransportCode:MD_MIDI_RT_CONTINUE
										  onCompletion:completionHandler
											   onError:errorHandler];
	}
	else if([t[0] isEqualToString:@"BPM"] && t.count == 2)
	{
		A4APIStringNumericIterator *it = [A4APIStringNumericIterator
										  iteratorWithStringToken:t[1]
										  range:A4ApiIteratorRangeMake(30, 300)
										  mode:A4ApiIteratorRangeModeBreak
										  inVal:A4ApiIteratorInputValFloat
										  retVal:A4ApiIteratorReturnValFloat];
		
		[self executeSetBPMCommandWithBPMIterator:it onCompletion:completionHandler onError:errorHandler];
	}
	else if ([t[0] isEqualToString:@"BPM"] && t.count == 1)
	{
		[self executeGetBPMonCompletion:completionHandler onError:errorHandler];
	}
	else if ([t[0] isEqualToString:@"PATTERN"] && t.count == 3)
	{
		if([t[1] isEqualToString:@"LENGTH"])
		{
			[A4APIPattern executeLengthCommandWithLengthArg:t[2]
											   onCompletion:completionHandler
													onError:errorHandler];
		}
		else if([t[1] isEqualToString:@"SCALE"])
		{
			[A4APIPattern executeScaleCommandWithScaleArg:t[2]
											 onCompletion:completionHandler
												  onError:errorHandler];
		}
		else if([t[1] isEqualToString:@"MODE"])
		{
			[A4APIPattern executeModeCommandWithModeArg:t[2]
											 onCompletion:completionHandler
												  onError:errorHandler];
		}
	}
	else if ([t[0] isEqualToString:@"TRACK"] && t.count > 1)
	{
		A4APIStringNumericIterator *trackIt =
		[A4APIStringNumericIterator iteratorWithStringToken:t[1]
													  range:A4ApiIteratorRangeMake(1, 6)
													   mode:A4ApiIteratorRangeModeBreak
													  inVal:A4ApiIteratorInputValInt
													 retVal:A4ApiIteratorReturnValInt];
		
		if(trackIt.isValid && t.count == 4 && [t[2] isEqualToString:@"SHIFT"])
		{
			NSString *arg = t[3];
			[A4APITrack executeShiftCommandWithTrackIterator:trackIt
														args:arg
												onCompletion:completionHandler
													 onError:errorHandler];
		}
		else if(trackIt.isValid && t.count == 4 && [t[2] isEqualToString:@"LENGTH"])
		{
			NSArray *args = [t subarrayWithRange:NSMakeRange(3, t.count-3)];
			[A4APITrack executeTrackLengthCommandWithTrackIterator:trackIt
															  args:args
													  onCompletion:completionHandler
														   onError:errorHandler];
		}
		else if(trackIt.isValid && t.count >= 4 && [t[2] isEqualToString:@"SETUP"])
		{
			NSArray *args = [t subarrayWithRange:NSMakeRange(3, t.count-3)];
			
			[A4APITrack executeTrackSettingsCommandWithTrackIterator:trackIt
																args:args
														onCompletion:completionHandler
															 onError:errorHandler];
		}
		else if(trackIt.isValid && t.count >= 4 && [t[2] isEqualToString:@"ARP"])
		{
			NSArray *args = [t subarrayWithRange:NSMakeRange(3, t.count-3)];
			
			[A4APITrack executeArpCommandWithTrackIterator:trackIt
													  args:args
											  onCompletion:completionHandler
												   onError:errorHandler];
		}
		else if(trackIt.isValid && t.count == 3)
		{
			if([t[2] isEqualToString:@"MUTE"])
			{
				[self executeSetMutedCommandWithTrackIterator:trackIt
														muted:YES
												 onCompletion:completionHandler
													  onError:errorHandler];
			}
			else if([t[2] isEqualToString:@"UNMUTE"])
			{
				[self executeSetMutedCommandWithTrackIterator:trackIt
														muted:NO
												 onCompletion:completionHandler
													  onError:errorHandler];
			}
			else if([t[2] isEqualToString:@"CLEAR"])
			{
				[self executeClearTrackCommandWithTrackIterator:trackIt
												   onCompletion:completionHandler
														onError:errorHandler];
			}
			else
			{
				errorHandler(errStr);
			}
		}
		else if (trackIt.isValid && t.count == 4)
		{
			if([t[2] isEqualToString:@"SOUND"])
			{
				A4APIStringNumericIterator *soundIt =
				[A4APIStringNumericIterator iteratorWithStringToken:t[3]
															  range:A4ApiIteratorRangeMake(1, 128)
															   mode:A4ApiIteratorRangeModeBreak
															  inVal:A4ApiIteratorInputValInt
															 retVal:A4ApiIteratorReturnValInt];
				
				if(soundIt.isValid)
				{
					[self executeTrackSoundCommandWithTrackIterator:trackIt
													  soundIterator:soundIt
													   onCompletion:completionHandler
															onError:errorHandler];
				}
				else
				{
					errorHandler(@"INVALID COMMAND");
				}
			}
		}
		else if(trackIt.isValid && t.count >= 5)
		{
			if([t[2] isEqualToString:@"PARAM"] && t.count >= 6)
			{
				NSArray *args = [t subarrayWithRange:NSMakeRange(3, t.count-3)];
				
				[A4APIParams executeSetTrackSoundParamWithTrackIterator:trackIt
																   args:args
														   onCompletion:completionHandler
																onError:errorHandler];
			}
			else if([t[2] isEqualToString:@"STEP"])
			{
				A4APIStringNumericIterator *stepIt =
				[A4APIStringNumericIterator iteratorWithStringToken:t[3]
															  range:A4ApiIteratorRangeMake(.5, 64.5)
															   mode:A4ApiIteratorRangeModeBreak
															  inVal:A4ApiIteratorInputValFloat
															 retVal:A4ApiIteratorReturnValFloat];
				
				NSArray *args = [t subarrayWithRange:NSMakeRange(4, t.count-4)];
				
				if(stepIt.isValid)
				{
					[A4APITrig executePutTrigCommandWithTrackIterator:trackIt
														 stepIterator:stepIt
																 args:args
														 onCompletion:completionHandler
															  onError:errorHandler];
				}
				else
				{
					errorHandler(errStr);
				}
			}
			else
			{
				errorHandler(errStr);
			}
		}
		else
		{
			errorHandler(errStr);
		}
	}
	else
	{
		errorHandler(errStr);
	}
}


- (BOOL) isIntVal:(NSString *)str
{
	if(!str) return NO;
	NSScanner *scanner = [NSScanner scannerWithString:str];
	return [scanner scanInt:nil];
}



- (void) executeTransportCommandWithTransportCode:(uint8_t)transportStatus
									 onCompletion:(void (^)(NSString *))completionHandler
										  onError:(void (^)(NSString *))errorHandler
{
	if(transportStatus == MD_MIDI_RT_START)
	{
		[[[MDMIDI sharedInstance] a4MidiDestination] sendBytes:&transportStatus size:1];
		completionHandler(@"START");
	}
	else if(transportStatus == MD_MIDI_RT_STOP)
	{
		[[[MDMIDI sharedInstance] a4MidiDestination] sendBytes:&transportStatus size:1];
		completionHandler(@"STOP");
	}
	if(transportStatus == MD_MIDI_RT_CONTINUE)
	{
		[[[MDMIDI sharedInstance] a4MidiDestination] sendBytes:&transportStatus size:1];
		completionHandler(@"CONTINUE");
	}
}


- (void) executeTrackSoundCommandWithTrackIterator:(A4APIStringNumericIterator *)trackIt
									 soundIterator:(A4APIStringNumericIterator *)soundIt
									  onCompletion:(void (^)(NSString *))completionHandler
										   onError:(void (^)(NSString *))errorHandler
{
	if(!trackIt.isValid || !soundIt.isValid)
	{
		errorHandler(@"INVALID COMMAND");
		return;
	}
	
	int soundIdx = [soundIt currentValue] - 1;
	int trackIdx = [trackIt currentValue] - 1;
	NSString *soundKey = [NSString stringWithFormat:@"snd.%d", soundIdx];
	[A4Request requestWithKeys:@[@"kit.x", soundKey]
			 completionHandler:^(NSDictionary *dict) {
				 A4Kit *kit = dict[@"kit.x"];
				 A4Sound *sound = dict[soundKey];
				 [kit copySound:sound toTrack:trackIdx];
				 [kit sendTemp];
				 NSString *completionString = [NSString stringWithFormat:@"TRACK %d SOUND %d \"%@\"",
											   trackIdx+1,
											   soundIdx+1,
											   [kit soundAtTrack:trackIdx copy:NO].name];
				 
				 completionHandler(completionString);
				 
			 } errorHandler:^(NSError *err) {
				 errorHandler(err.description);
			 }];
}

- (void) executeClearTrackCommandWithTrackIterator:(A4APIStringNumericIterator *)it
									  onCompletion:(void (^)(NSString *))completionHandler
										   onError:(void (^)(NSString *))errorHandler
{
	[A4Request requestWithKeys:@[@"pat.x"]
			 completionHandler:^(NSDictionary *dict) {
				 
				 A4Pattern *pattern = dict[@"pat.x"];
				 NSString *str = @"";
				 int cnt = 0;
				 if(it.isValid)
				 {
					 int trk = [it currentValue];
					 [pattern clearTrack:trk-1];
					 str = [str stringByAppendingString:[NSString stringWithFormat:@"%d ", trk]];
					 cnt++;
				 }
				 
				 [pattern sendTemp];
				 completionHandler([NSString
									stringWithFormat:@"%@ %@CLEARED",
									cnt > 1 ? @"TRACKS" : @"TRACK",
									str]);
				 
			 } errorHandler:^(NSError *err) {
				 
				 errorHandler(err.description);
				 
			 }];
}

- (void) executeSetMutedCommandWithTrackIterator:(A4APIStringNumericIterator *)it
										   muted:(BOOL)muted
									onCompletion:(void (^)(NSString *))completionHandler
										 onError:(void (^)(NSString *))errorHandler
{
	[A4Request requestWithKeys:@[@"set.x"]
			 completionHandler:^(NSDictionary *dict) {
				 
				 A4Settings *settings = dict[@"set.x"];
				 NSString *str = @"";
				 int cnt = 0;
				 if(it.isValid)
				 {
					 int trk = [it currentValue];
					 [settings setTrack:trk-1 muted:muted];
					 str = [str stringByAppendingString:[NSString stringWithFormat:@"%d ", trk]];
					 cnt++;
				 }
				 
				 
				 [settings sendTemp];
				 completionHandler([NSString
									stringWithFormat:@"%@ %@%@",
									cnt > 1 ? @"TRACKS" : @"TRACK",
									str,
									muted ? @"MUTED" : @"UNMUTED"]);
				 
			 } errorHandler:^(NSError *err) {
				 
				 errorHandler(err.description);
				 
			 }];
	
	
	
}

- (void) executeSetBPMCommandWithBPMIterator:(A4APIStringNumericIterator *)it
								onCompletion:(void (^)(NSString *))completionHandler
									 onError:(void (^)(NSString *))errorHandler
{
	double bpm = 0;
	if(it.isValid) bpm = [it currentValue];
	
	if(bpm < 30 || bpm > 300)
	{
		errorHandler(@"invalid tempo value. must be a number from 30.0 to 300.0");
		return;
	}
	
	[A4Request requestWithKeys:@[@"set.x"]
			 completionHandler:^(NSDictionary *dict) {
				
				 A4Settings *settings = dict[@"set.x"];
				 settings.bpm = bpm;
				 [settings sendTemp];
				 completionHandler([NSString stringWithFormat:@"BPM %3.1f", bpm]);
				 
			 } errorHandler:^(NSError *err) {
				 
				 errorHandler(err.description);
				 
			 }];
	
}

- (void) executeGetBPMonCompletion:(void (^)(NSString *))completionHandler
						   onError:(void (^)(NSString *))errorHandler
{
	[A4Request requestWithKeys:@[@"set.x"]
			 completionHandler:^(NSDictionary *dict) {
				 
				 A4Settings *settings = dict[@"set.x"];
				 float bpm = settings.bpm;
				 completionHandler([NSString stringWithFormat:@"BPM: %3.1f", bpm]);
				 
			 } errorHandler:^(NSError *err) {
				 
				 errorHandler(err.description);
				 
			 }];

}

@end
