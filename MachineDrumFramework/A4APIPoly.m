//
//  A4APIPoly.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 12/03/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import "A4APIPoly.h"
#import "A4Kit.h"
#import "A4Request.h"
#import "A4APIStringNumericIterator.h"

@implementation A4APIPoly

+ (void) executePolyCommandWithArgs:(NSArray *)args
					   onCompletion:(void (^)(NSString *))completionHandler
							onError:(void (^)(NSString *))errorHandler
{
	BOOL setVoices = NO;
	uint8_t voices = 0;
	NSString *voiceArgStr = nil;
	
	BOOL setAlloc = NO;
	A4PolyAllocationMode allocMode;
	NSString *allocString = nil;
	
	BOOL setTrkSounds = NO;
	BOOL useTrkSounds;
	
	BOOL setDetune = NO;
	uint8_t detune;
	
	BOOL setSpread = NO;
	uint8_t spread;
	
	if(!args.count || args.count % 2)
	{
		errorHandler(@"INVALID ARGS");
		return;
	}
	
	
	for(int i = 0; i < args.count; i+=2)
	{
		NSString *cmd = args[i];
		NSString *prm = args[i+1];
		
		if([cmd isEqualToString:@"VOICES"])
		{
			setVoices = YES;
			NSCharacterSet *prmSet = [NSCharacterSet characterSetWithCharactersInString:@"XO"];
			prm = [prm stringByTrimmingCharactersInSet:[prmSet invertedSet]];
			if(prm.length != 4)
			{
				errorHandler(@"INVALID VOICE PARAM");
				return;
			}
			
			for(int i = 0; i < 4; i++)
			{
				if([[prm substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"X"])
				{
					voices |= 1 << i;
				}
			}
			
			voiceArgStr = prm;
		}
		else if ([cmd isEqualToString:@"ALLOC"])
		{
			setAlloc = YES;
			if([prm isEqualToString:@"RESET"])
				allocMode = A4PolyAllocationModeReset;
			else if([prm isEqualToString:@"ROTATE"])
				allocMode = A4PolyAllocationModeRotate;
			else if([prm isEqualToString:@"REASSIGN"])
				allocMode = A4PolyAllocationModeReassign;
			else if([prm isEqualToString:@"UNISON"])
				allocMode = A4PolyAllocationModeUnison;
			else
			{
				errorHandler(@"INVALID ALLOC");
				return;
			}
			
			allocString = prm;
		}
		else if ([cmd isEqualToString:@"TRK"])
		{
			setTrkSounds = YES;
			if([prm isEqualToString:@"ON"])
				useTrkSounds = YES;
			else if([prm isEqualToString:@"OFF"])
				useTrkSounds = NO;
			else
			{
				errorHandler(@"INVALID TRK");
				return;
			}
		}
		else if ([cmd isEqualToString:@"DETUNE"])
		{
			A4APIStringNumericIterator *it =
			[A4APIStringNumericIterator iteratorWithStringToken:prm
														  range:A4ApiIteratorRangeMake(0, 127)
														   mode:A4ApiIteratorRangeModeBreak
														  inVal:A4ApiIteratorInputValInt
														 retVal:A4ApiIteratorReturnValInt];
			if(it.isValid)
			{
				setDetune = YES;
				detune = [it currentValue];
			}
			else
			{
				errorHandler(@"INVALID DETUNE");
				return;
			}
		}
		else if ([cmd isEqualToString:@"SPREAD"])
		{
			A4APIStringNumericIterator *it =
			[A4APIStringNumericIterator iteratorWithStringToken:prm
														  range:A4ApiIteratorRangeMake(0, 127)
														   mode:A4ApiIteratorRangeModeBreak
														  inVal:A4ApiIteratorInputValInt
														 retVal:A4ApiIteratorReturnValInt];
			if(it.isValid)
			{
				setSpread = YES;
				spread = [it currentValue];
			}
			else
			{
				errorHandler(@"INVALID SPREAD");
				return;
			}
		}
	}
	
	
	[A4Request requestWithKeys:@[@"kit.x"]
			 completionHandler:^(NSDictionary *dict) {
				 A4Kit *kit = dict[@"kit.x"];
				 NSString *completionString = @"POLY ";
				 if(setVoices)
				 {
					 kit.polyphony->activeVoices = voices;
					 completionString =
					 [completionString stringByAppendingString:
					  [NSString stringWithFormat:@"VOICES %@ ", voiceArgStr]];
				 }
				 if(setAlloc)
				 {
					 kit.polyphony->allocationMode = allocMode;
					 completionString =
					 [completionString stringByAppendingString:
					  [NSString stringWithFormat:@"ALLOC %@ ", allocString]];
				 }
				 if(setTrkSounds)
				 {
					 kit.polyphony->useTrackSounds = useTrkSounds;
					 completionString =
					 [completionString stringByAppendingString:
					  [NSString stringWithFormat:@"TRK %@ ", useTrkSounds ? @"ON" : @"OFF"]];
				 }
				 if(setDetune)
				 {
					 kit.polyphony->unisonDetuneAmount = detune;
					 completionString =
					 [completionString stringByAppendingString:
					  [NSString stringWithFormat:@"DETUNE %d ", detune]];
				 }
				 if(setSpread)
				 {
					 kit.polyphony->unisonPanSpreadAmount = spread;
					 completionString =
					 [completionString stringByAppendingString:
					  [NSString stringWithFormat:@"SPREAD %d ", spread]];
				 }
				 
				 [kit sendTemp];
				 completionHandler(completionString);
				 
			 } errorHandler:^(NSError *err) {
				 errorHandler(err.description);
			 }];
	
}
@end
