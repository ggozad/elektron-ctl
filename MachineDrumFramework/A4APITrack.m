//
//  A4APITrack.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 09/03/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import "A4APITrack.h"
#import "A4Pattern.h"
#import "A4PatternTrack.h"
#import "A4Request.h"
#import "MDMath.h"

@implementation A4APITrack

+ (void) executeShiftCommandWithTrackIterator:(A4APIStringNumericIterator *)trackIt
										 args:(NSString *)arg
								 onCompletion:(void (^)(NSString *))completionHandler
									  onError:(void (^)(NSString *))errorHandler
{
	A4APIStringNumericIterator *it =
	[A4APIStringNumericIterator iteratorWithStringToken:arg
												  range:A4ApiIteratorRangeMake(-63, 63)
												   mode:A4ApiIteratorRangeModeBreak
												  inVal:A4ApiIteratorInputValInt
												 retVal:A4ApiIteratorReturnValInt];
	
	int shift = 0;
	int track = [trackIt currentValue]-1;
	
	if(it.isValid) shift = [it currentValue];
	
	if(shift == 0)
	{
		errorHandler(@"INVALID SHIFT AMOUNT");
		return;
	}
	
	[A4Request requestWithKeys:@[@"pat.x"]
			 completionHandler:^(NSDictionary *dict) {
				 
				 A4Pattern *pattern = dict[@"pat.x"];
				 [pattern shiftTrack:track steps:shift];
				 [pattern sendTemp];
				 completionHandler([NSString stringWithFormat:@"TRACK %d SHIFTED %d STEPS", track+1, shift]);
				 
			 } errorHandler:^(NSError *err) {
				 
				 errorHandler(err.description);
			 }];

}

+ (void)executeArpCommandWithTrackIterator:(A4APIStringNumericIterator *)trackIt
									  args:(NSArray *)args
							  onCompletion:(void (^)(NSString *))completionHandler
								   onError:(void (^)(NSString *))errorHandler
{
	if(!trackIt.isValid || (args.count && args.count%2 != 0) || !args.count)
	{
		errorHandler(@"INVALID COMMAND");
		return;
	}
	
	int trackIdx = [trackIt currentValue] - 1;
	
	BOOL changeMode = NO;
	A4ArpMode mode = A4ArpModeOff;
	NSString *modeStr = nil;
	
	BOOL changeSpeed = NO;
	int speed = 0;
	NSString *speedStr = nil;
	
	BOOL changeLen = NO;
	int len = 0;
	NSString *lenStr = nil;
	
	BOOL changeRange = NO;
	int range = 0;
	NSString *rangeStr = nil;
	
	BOOL changeLegato = NO;
	uint8_t legato = 0;
	NSString *legatoStr = nil;
	
	
	for(NSUInteger i = 0; i < args.count; i+=2)
	{
		NSString *arg = args[i];
		NSString *params = args[i+1];
		
		if([arg isEqualToString:@"MODE"])
		{
			if([params isEqualToString:@"OFF"])
			{
				changeMode = YES;
				modeStr = params;
				mode = A4ArpModeOff;
			}
			else if([params isEqualToString:@"TRUE"])
			{
				changeMode = YES;
				modeStr = params;
				mode = A4ArpModeTrue;
			}
			else if([params isEqualToString:@"UP"])
			{
				changeMode = YES;
				modeStr = params;
				mode = A4ArpModeUp;
			}
			else if([params isEqualToString:@"DOWN"])
			{
				changeMode = YES;
				modeStr = params;
				mode = A4ArpModeDown;
			}
			else if([params isEqualToString:@"CYCLE"])
			{
				changeMode = YES;
				modeStr = params;
				mode = A4ArpModeCycle;
			}
			else if([params isEqualToString:@"SHUFFLE"])
			{
				changeMode = YES;
				modeStr = params;
				mode = A4ArpModeShuffle;
			}
			else if([params isEqualToString:@"RANDOM"])
			{
				changeMode = YES;
				modeStr = params;
				mode = A4ArpModeRandom;
			}
			else if([params isEqualToString:@"POLY"])
			{
				changeMode = YES;
				modeStr = params;
				mode = A4ArpModePoly;
			}
			else
			{
				NSString *err = [NSString stringWithFormat:@"INVALID ARP MODE %@", params];
				errorHandler(err);
				return;
			}
		}
		else if ([arg isEqualToString:@"SPEED"])
		{
			A4APIStringNumericIterator *it = [A4APIStringNumericIterator
											  iteratorWithStringToken:params
											  range:A4ApiIteratorRangeMake(1, 96)
											  mode:A4ApiIteratorRangeModeBreak
											  inVal:A4ApiIteratorInputValInt
											  retVal:A4ApiIteratorReturnValInt];
			if(it.isValid)
			{
				speed = [it currentValue] - 1;
				changeSpeed = YES;
				speedStr = [NSString stringWithFormat:@"SPEED %d ", speed+1];
			}
			else
			{
				errorHandler(@"INVALID ARP SPEED");
				return;
			}
		}
		else if ([arg isEqualToString:@"LENGTH"])
		{
			A4APIStringNumericIterator *it = [A4APIStringNumericIterator
											  iteratorWithStringToken:params
											  range:A4ApiIteratorRangeMake(0, 127)
											  mode:A4ApiIteratorRangeModeBreak
											  inVal:A4ApiIteratorInputValInt
											  retVal:A4ApiIteratorReturnValInt];
			if(it.isValid)
			{
				len = [it currentValue];
				changeLen = YES;
				lenStr = [NSString stringWithFormat:@"LENGTH %d ", len];
			}
			else
			{
				errorHandler(@"INVALID ARP SPEED");
				return;
			}
		}
		else if ([arg isEqualToString:@"RANGE"])
		{
			A4APIStringNumericIterator *it = [A4APIStringNumericIterator
											  iteratorWithStringToken:params
											  range:A4ApiIteratorRangeMake(1, 8)
											  mode:A4ApiIteratorRangeModeBreak
											  inVal:A4ApiIteratorInputValInt
											  retVal:A4ApiIteratorReturnValInt];
			if(it.isValid)
			{
				range = [it currentValue] - 1;
				changeRange = YES;
				rangeStr = [NSString stringWithFormat:@"RANGE %d ", range+1];
			}
			else
			{
				errorHandler(@"INVALID ARP RANGE");
				return;
			}
		}
		else if ([arg isEqualToString:@"LEGATO"])
		{
			if([params isEqualToString:@"OFF"] || [params isEqualToString:@"ON"])
			{
				legato = [params isEqualToString:@"ON"] ? 1 : 0;
				changeLegato = YES;
				legatoStr = [NSString stringWithFormat:@"LEGATO %@ ", params];
			}
			else
			{
				errorHandler(@"INVALID LEGATO PARAM");
				return;
			}
		}
		else
		{
			errorHandler(@"INVALID COMMAND");
			return;
		}
	}
	
	[A4Request requestWithKeys:@[@"pat.x"]
			 completionHandler:^(NSDictionary *dict) {
				 
				 NSString *returnString = [NSString stringWithFormat: @"TRACK %d ARP ", trackIdx+1];
				 A4Pattern *pattern = dict[@"pat.x"];
				 A4PatternTrack *track = [pattern track:trackIdx];
				 if(changeMode)
				 {
					 track.arp->mode = mode;
					 returnString = [returnString stringByAppendingString:[NSString stringWithFormat:@"MODE %@ ", modeStr]];
				 }
				 if(changeSpeed)
				 {
					 track.arp->speed = speed;
					 returnString = [returnString stringByAppendingString:speedStr];
				 }
				 if(changeRange)
				 {
					 track.arp->range = range;
					 returnString = [returnString stringByAppendingString:rangeStr];
				 }
				 if(changeLegato)
				 {
					 track.arp->legato = legato;
					 returnString = [returnString stringByAppendingString:legatoStr];
				 }
				 if(changeLen)
				 {
					 track.arp->noteLength = len;
					 returnString = [returnString stringByAppendingString:lenStr];
				 }
				 [pattern sendTemp];
				 completionHandler(returnString);
				 
			 } errorHandler:^(NSError *err) {
				 errorHandler(err.description);
			 }];
}

+ (void)executeTrackSettingsCommandWithTrackIterator:(A4APIStringNumericIterator *)trackIt
												args:(NSArray *)args
										onCompletion:(void (^)(NSString *))completionHandler
											 onError:(void (^)(NSString *))errorHandler
{
	if(!trackIt.isValid || (args.count && args.count%2 != 0) || !args.count)
	{
		errorHandler(@"INVALID COMMAND");
		return;
	}
	
	int trackIdx = [trackIt currentValue]-1;
	
	A4APIStringNumericIterator *quantizeIt = nil;
	
	
	BOOL changeTransposable = NO;
	BOOL transpose = NO;
	
	BOOL changeKeyScale = NO;
	char keyScale = 0;
	NSString *keyScaleReturnString = nil;
	
	BOOL changeKeyNote = NO;
	char keyNote = 0;
	NSString *keyNoteReturnString = nil;
	
	for(NSUInteger i = 0; i < args.count; i+=2)
	{
		NSString *arg = args[i];
		NSString *params = args[i+1];
		
		if([arg isEqualToString:@"QUANTIZE"])
		{
			quantizeIt = [A4APIStringNumericIterator iteratorWithStringToken:params
																		range:A4ApiIteratorRangeMake(0, 127)
																		 mode:A4ApiIteratorRangeModeWrap
																		inVal:A4ApiIteratorInputValInt
																	   retVal:A4ApiIteratorReturnValInt];
			
			if(!quantizeIt.isValid)
			{
				errorHandler(@"QUANTIZE INVALID");
				return;
			}
		}
		else if([arg isEqualToString:@"TRANSPOSE"] && ([params isEqualToString:@"ON"] || [params isEqualToString:@"OFF"]))
		{
			changeTransposable = YES;
			transpose = [params isEqualToString:@"ON"];
		}
		else if ([arg isEqualToString:@"SCALE"] &&
				 ([params isEqualToString:@"OFF"] || [params isEqualToString:@"MAJ"] || [params isEqualToString:@"MIN"]))
		{
			changeKeyScale = YES;
			if([params isEqualToString:@"MAJ"]) keyScale = A4KeyScaleMaj;
			else if([params isEqualToString:@"MIN"]) keyScale = A4KeyScaleMin;
			else keyScale = A4KeyScaleOff;
			keyScaleReturnString = params;
		}
		else if ([arg isEqualToString:@"KEY"])
		{
			if([params isEqualToString:@"C"])
			{
				keyNote = A4NoteValueC;
				changeKeyNote = YES;
			}
			else if([params isEqualToString:@"C#"])
			{
				keyNote = A4NoteValueCS;
				changeKeyNote = YES;
			}
			else if([params isEqualToString:@"D"])
			{
				keyNote = A4NoteValueD;
				changeKeyNote = YES;
			}
			else if([params isEqualToString:@"D#"])
			{
				keyNote = A4NoteValueDS;
				changeKeyNote = YES;
			}
			else if([params isEqualToString:@"E"])
			{
				keyNote = A4NoteValueE;
				changeKeyNote = YES;
			}
			else if([params isEqualToString:@"F"])
			{
				keyNote = A4NoteValueF;
				changeKeyNote = YES;
			}
			else if([params isEqualToString:@"F#"])
			{
				keyNote = A4NoteValueFS;
				changeKeyNote = YES;
			}
			else if([params isEqualToString:@"G"])
			{
				keyNote = A4NoteValueG;
				changeKeyNote = YES;
			}
			else if([params isEqualToString:@"G#"])
			{
				keyNote = A4NoteValueGS;
				changeKeyNote = YES;
			}
			else if([params isEqualToString:@"A"])
			{
				keyNote = A4NoteValueA;
				changeKeyNote = YES;
			}
			else if([params isEqualToString:@"A#"])
			{
				keyNote = A4NoteValueAS;
				changeKeyNote = YES;
			}
			else if([params isEqualToString:@"B"])
			{
				keyNote = A4NoteValueB;
				changeKeyNote = YES;
			}
			else
			{
				NSString *str = [NSString stringWithFormat:@"INVALID KEY: %@", params];
				errorHandler(str);
				return;
			}
			
			if(changeKeyNote) keyNoteReturnString = params;
		}
		else
		{
			errorHandler([NSString stringWithFormat:@"INVALID ARG OR PARAM: %@ - %@", arg, params]);
			return;
		}
	}
	
	[A4Request requestWithKeys:@[@"pat.x"]
			 completionHandler:^(NSDictionary *dict) {
				
				 A4Pattern *pattern = dict[@"pat.x"];
				 A4PatternTrack *track = [pattern track:trackIdx];
				 
				 uint8_t quant = (uint8_t)[quantizeIt currentValue];
				 if(changeKeyNote) track.settings->keyNote = keyNote;
				 if(changeKeyScale) track.settings->keyScale = keyScale;
				 if(changeTransposable) track.settings->transposable = transpose;
				 if(quantizeIt) track.settings->quantizeAmount = quant;
				 
				 [pattern sendTemp];
				 
				 NSString *str = [NSString stringWithFormat:@"TRACK %d ",
								  trackIdx+1];
				 
				 
				 if(changeKeyNote) str = [str stringByAppendingString:
										  [NSString stringWithFormat:@"KEY %@ ", keyNoteReturnString]];
				 
				 if(changeKeyScale) str = [str stringByAppendingString:
										   [NSString stringWithFormat:@"SCALE %@ ", keyScaleReturnString]];
				 
				 if(changeTransposable) str = [str stringByAppendingString:transpose ? @"TRANSPOSE ON " : @"TRANSPOSE OFF "];
				 
				 if(quantizeIt) str = [str stringByAppendingString:
									   [NSString stringWithFormat:@"QUANTIZE %d ", quant]];
				 
				 completionHandler(str);
				 
			 } errorHandler:^(NSError *err) {
				 errorHandler(err.description);
			 }];
	
	
}

+ (void) executeTrackLengthCommandWithTrackIterator:(A4APIStringNumericIterator *)trackIt
											   args:(NSArray *)args
									   onCompletion:(void (^)(NSString *))completionHandler
											onError:(void (^)(NSString *))errorHandler
{
	if(!args.count)
	{
		errorHandler(@"BLEH");
		return;
	}
	
	A4APIStringNumericIterator *lengthIt = [A4APIStringNumericIterator iteratorWithStringToken:args[0]
																						 range:A4ApiIteratorRangeMake(2, 64)
																						  mode:A4ApiIteratorRangeModeBreak
																						 inVal:A4ApiIteratorInputValInt
																						retVal:A4ApiIteratorReturnValInt];
	
	uint8_t length = 2;
	uint8_t trackIdx = [trackIt currentValue] - 1;
	
	if(!lengthIt.isValid)
	{
		errorHandler(@"LENGTH INVALID");
		return;
	}
	
	length = [lengthIt currentValue];
	
	[A4Request requestWithKeys:@[@"pat.x"]
			 completionHandler:^(NSDictionary *dict) {
				 
				 NSString *completionString = @"";
				 A4Pattern *pattern = dict[@"pat.x"];
				 
				 for(int trk = 0; trk < 6; trk++)
				 {
					 if((pattern.timeMode == A4PatternTimeModeAdvanced && trk == trackIdx) ||
						pattern.timeMode == A4PatternTimeModeNormal)
					 {
						 uint8_t oldLength = [pattern track:trackIdx].settings->trackLength;
						 
						 if(length > oldLength)
						 {
							 A4PVal locksBuf[128];
							 uint8_t locksLen = 0;
							 
							 for(int i = oldLength; i < length; i++)
							 {
								 [pattern clearTrigAtStep:i inTrack:trackIdx];
								 int stepToCopyFrom = mdmath_wrap(i-oldLength, 0, oldLength-1);
								 
								 A4Trig trig = [pattern trigAtStep:stepToCopyFrom inTrack:trackIdx];
								 [pattern setTrig:trig atStep:i inTrack:trackIdx];
								 
								 if(A4LocksForTrackAndStep(pattern, stepToCopyFrom, trackIdx, locksBuf, &locksLen))
								 {
									 for(int j = 0; j < locksLen; j++)
									 {
										 [pattern setLock:locksBuf[j] atStep:i inTrack:trackIdx];
									 }
								 }
							 }
						 }
						 
						 [pattern track:trackIdx].settings->trackLength = length;
						 completionString = [NSString stringWithFormat:@"TRACK LENGTH %d", length];
					 }
				 }
				 if(pattern.timeMode == A4PatternTimeModeNormal)
				 {
					 pattern.masterLength = length;
					 completionString = [NSString stringWithFormat:@"PATTERN LENGTH %d", length];
				 }
				 
				 [pattern sendTemp];
				 completionHandler(completionString);
				 
			 } errorHandler:^(NSError *err) {
				 
				 errorHandler(err.description);
				 
			 }];
	
	
}


@end
