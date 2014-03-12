//
//  A4APITrig.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 08/03/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import "A4APITrig.h"
#import "A4APIStringNumericIterator.h"
#import "A4Request.h"
#import "MDMath.h"
#import "A4Pattern.h"
#import "A4APIParams.h"

@interface ParamLockInfo : NSObject
@property (nonatomic, strong) A4APIStringNumericIterator *iterator;
@property (nonatomic) A4PVal pval;
@end

@implementation ParamLockInfo
@end

typedef enum A4APITrigType
{
	A4APITrigTypeTrig,
	A4APITrigTypeLock,
	A4APITrigTypeClear
}
A4APITrigType;

@implementation A4APITrig

+ (void) executePutTrigCommandWithTrackIterator:(A4APIStringNumericIterator *)trackIt
								   stepIterator:(A4APIStringNumericIterator *)stepIt
										   args:(NSArray *)argTokens
								   onCompletion:(void (^)(NSString *))completionHandler
										onError:(void (^)(NSString *))errorHandler
{
	if(!trackIt.isValid || !stepIt.isValid || !argTokens || !argTokens.count)
	{
		errorHandler(@"INVALID COMMAND");
		return;
	}
	
	A4APITrigType type;
	
	NSMutableArray *locks = [NSMutableArray array];
	
	if([argTokens[0] isEqualToString:@"TRIG"]) type = A4APITrigTypeTrig;
	else if([argTokens[0] isEqualToString:@"CLEAR"]) type = A4APITrigTypeClear;
	else if([argTokens[0] isEqualToString:@"LOCK"]) type = A4APITrigTypeLock;
	else
	{
		errorHandler(@"INVALID STEP COMMAND");
		return;
	}
	
	A4APIStringNumericIterator *soundLockIt = nil;
	A4APIStringNumericIterator *velocityLockIt = nil;
	A4APIStringNumericIterator *lengthLockIt = nil;
	
	A4APIStringNumericIterator *noteLockIt = nil;
	A4APIStringNumericIterator *note2LockIt = nil;
	A4APIStringNumericIterator *note3LockIt = nil;
	A4APIStringNumericIterator *note4LockIt = nil;

	A4APIStringNumericIterator *accentLockIt = nil;
	A4APIStringNumericIterator *muteLockIt = nil;
	A4APIStringNumericIterator *noteSlideLockIt = nil;
	A4APIStringNumericIterator *paramSlideLockIt = nil;
	
	NSUInteger i = 1;
	while(1)
	{
		if(i >= argTokens.count) break;
		NSString *arg = argTokens[i];
		NSString *params = nil;
		
		if(type != A4APITrigTypeClear)
		{
			if(([arg isEqualToString:@"SOUND"]|| [arg isEqualToString:@"S"]) && i < argTokens.count-1)
			{
				params = argTokens[i+1]; i += 2;
				soundLockIt = [A4APIStringNumericIterator iteratorWithStringToken:params
																			range:A4ApiIteratorRangeMake(0, 128)
																			 mode:A4ApiIteratorRangeModeWrap
																			inVal:A4ApiIteratorInputValInt
																		   retVal:A4ApiIteratorReturnValInt];
				
				
			}
			else if(([arg isEqualToString:@"NOTE"]||[arg isEqualToString:@"N"]) && i < argTokens.count-1)
			{
				params = argTokens[i+1]; i += 2;
				noteLockIt = [A4APIStringNumericIterator iteratorWithStringToken:params
																		   range:A4ApiIteratorRangeMake(0, 127)
																			mode:A4ApiIteratorRangeModeWrap
																		   inVal:A4ApiIteratorInputValInt
																		  retVal:A4ApiIteratorReturnValInt];
				
			}
			else if(([arg isEqualToString:@"NOTE2"]||[arg isEqualToString:@"N2"])  && i < argTokens.count-1)
			{
				params = argTokens[i+1]; i += 2;
				note2LockIt = [A4APIStringNumericIterator iteratorWithStringToken:params
																			range:A4ApiIteratorRangeMake(-64, 63)
																			 mode:A4ApiIteratorRangeModeWrap
																			inVal:A4ApiIteratorInputValInt
																		   retVal:A4ApiIteratorReturnValInt];
			}
			else if(([arg isEqualToString:@"NOTE3"]||[arg isEqualToString:@"N3"]) && i < argTokens.count-1)
			{
				params = argTokens[i+1]; i += 2;
				note3LockIt = [A4APIStringNumericIterator iteratorWithStringToken:params
																			range:A4ApiIteratorRangeMake(-64, 63)
																			 mode:A4ApiIteratorRangeModeWrap
																			inVal:A4ApiIteratorInputValInt
																		   retVal:A4ApiIteratorReturnValInt];
			}
			else if(([arg isEqualToString:@"NOTE4"]||[arg isEqualToString:@"N4"]) && i < argTokens.count-1)
			{
				params = argTokens[i+1]; i += 2;
				note4LockIt = [A4APIStringNumericIterator iteratorWithStringToken:params
																			range:A4ApiIteratorRangeMake(-64, 63)
																			 mode:A4ApiIteratorRangeModeWrap
																			inVal:A4ApiIteratorInputValInt
																		   retVal:A4ApiIteratorReturnValInt];
			}
			else if(([arg isEqualToString:@"VELOCITY"]||[arg isEqualToString:@"V"]) && i < argTokens.count-1)
			{
				params = argTokens[i+1]; i += 2;
				velocityLockIt = [A4APIStringNumericIterator iteratorWithStringToken:params
																			   range:A4ApiIteratorRangeMake(1, 127)
																				mode:A4ApiIteratorRangeModeWrap
																			   inVal:A4ApiIteratorInputValInt
																			  retVal:A4ApiIteratorReturnValInt];
			}
			else if(([arg isEqualToString:@"LENGTH"]||[arg isEqualToString:@"L"]) && i < argTokens.count-1)
			{
				params = argTokens[i+1]; i += 2;
				lengthLockIt = [A4APIStringNumericIterator iteratorWithStringToken:params
																			 range:A4ApiIteratorRangeMake(0, 127)
																			  mode:A4ApiIteratorRangeModeWrap
																			 inVal:A4ApiIteratorInputValInt
																			retVal:A4ApiIteratorReturnValInt];
			}
			else if(([arg isEqualToString:@"ACCENT"]||[arg isEqualToString:@"A"]) && i < argTokens.count-1)
			{
				params = argTokens[i+1]; i += 2;
				accentLockIt = [A4APIStringNumericIterator iteratorWithStringToken:params
																			 range:A4ApiIteratorRangeMake(0, 1)
																			  mode:A4ApiIteratorRangeModeWrap
																			 inVal:A4ApiIteratorInputValInt
																			retVal:A4ApiIteratorReturnValInt];
			}
			else if(([arg isEqualToString:@"MUTE"]||[arg isEqualToString:@"M"]) && i < argTokens.count-1)
			{
				params = argTokens[i+1]; i += 2;
				muteLockIt = [A4APIStringNumericIterator iteratorWithStringToken:params
																		   range:A4ApiIteratorRangeMake(0, 1)
																			mode:A4ApiIteratorRangeModeWrap
																		   inVal:A4ApiIteratorInputValInt
																		  retVal:A4ApiIteratorReturnValInt];
			}
			else if(([arg isEqualToString:@"NOTESLIDE"]||[arg isEqualToString:@"NS"]) && i < argTokens.count-1)
			{
				params = argTokens[i+1]; i += 2;
				noteSlideLockIt = [A4APIStringNumericIterator iteratorWithStringToken:params
																				range:A4ApiIteratorRangeMake(0, 1)
																				 mode:A4ApiIteratorRangeModeWrap
																				inVal:A4ApiIteratorInputValInt
																			   retVal:A4ApiIteratorReturnValInt];
			}
			else if(([arg isEqualToString:@"PARAMSLIDE"]||[arg isEqualToString:@"PS"]) && i < argTokens.count-1)
			{
				params = argTokens[i+1]; i += 2;
				paramSlideLockIt = [A4APIStringNumericIterator iteratorWithStringToken:params
																				 range:A4ApiIteratorRangeMake(0, 1)
																				  mode:A4ApiIteratorRangeModeWrap
																				 inVal:A4ApiIteratorInputValInt
																				retVal:A4ApiIteratorReturnValInt];
			}
		}
		if ([arg isEqualToString:@"PARAM"] || [arg isEqualToString:@"P"])
		{
			if(i < argTokens.count - 3)
			{
				NSArray *paramArgs = [argTokens subarrayWithRange:NSMakeRange(i+1, 2)];
				A4Param param = [A4APIParams synthParamWithArgs:paramArgs];
				if(param == A4NULL)
				{
					errorHandler(@"INVALID PARAM");
					return;
				}
				
				i+=3;
				if(A4ParamIsModulatorDestination(param) && i > argTokens.count-1)
				{
					errorHandler(@"INVALID MOD TARGET");
					return;
				}
				
				ParamLockInfo *plockInfo = [ParamLockInfo new];
				
				if(A4ParamIsModulatorDestination(param) && i <= argTokens.count - 2)
				{
					NSArray *paramArgs = [argTokens subarrayWithRange:NSMakeRange(i, 2)];
					A4Param target = [A4APIParams synthParamWithArgs:paramArgs];
					if(A4ParamIndexOfModTargetInModSource(target, param) != (int8_t) A4NULL)
					{
						plockInfo.pval = A4PValMake8(param, target);
						i+=2;
					}
					else
					{
						errorHandler(@"INVALID MOD TARGET");
						return;
					}
				}
				else if(i <= argTokens.count - 1)
				{
					A4APIStringNumericIterator *it =
					[A4APIStringNumericIterator iteratorWithStringToken:argTokens[i]
																  range:A4ApiIteratorRangeMake(A4ParamMin(param), A4ParamMax(param))
																   mode:A4ApiIteratorRangeModeWrap
																  inVal:A4ParamIs16Bit(param) ? A4ApiIteratorInputValFloat : A4ApiIteratorInputValInt
																 retVal:A4ParamIs16Bit(param) ? A4ApiIteratorReturnValFloat : A4ApiIteratorReturnValInt];
					
					if(it.isValid)
					{
						plockInfo.pval = A4PValMake8(param, 0);
						plockInfo.iterator = it;
						i+=1;
					}
					else
					{
						errorHandler(@"INVALID PARAM RANGE");
						return;
					}
					
					[locks addObject:plockInfo];
				}
				else
				{
					errorHandler(@"INVALID WHATEVER");
					return;
				}
			}
		}
		else
		{
			i++;
		}
	}
	
	
	if(soundLockIt && !soundLockIt.isValid)
	{
		errorHandler(@"INVALID SOUNDLOCK");
		return;
	}
	if(noteLockIt && !noteLockIt.isValid)
	{
		errorHandler(@"INVALID NOTE");
		return;
	}
	if(note2LockIt && !note2LockIt.isValid)
	{
		errorHandler(@"INVALID NOTE2");
		return;
	}
	if(note3LockIt && !note3LockIt.isValid)
	{
		errorHandler(@"INVALID NOTE3");
		return;
	}
	if(note4LockIt && !note4LockIt.isValid)
	{
		errorHandler(@"INVALID NOTE4");
		return;
	}
	if(velocityLockIt && !velocityLockIt.isValid)
	{
		errorHandler(@"INVALID VELOCITY");
		return;
	}
	if(lengthLockIt && !lengthLockIt.isValid)
	{
		errorHandler(@"INVALID LENGTH");
		return;
	}
	if(muteLockIt && !muteLockIt.isValid)
	{
		errorHandler(@"INVALID TRIGMUTE");
		return;
	}
	if(accentLockIt && !accentLockIt.isValid)
	{
		errorHandler(@"INVALID ACCENT");
		return;
	}
	if(noteSlideLockIt && !noteSlideLockIt.isValid)
	{
		errorHandler(@"INVALID NOTESLIDE");
		return;
	}
	if(paramSlideLockIt && !paramSlideLockIt.isValid)
	{
		errorHandler(@"INVALID PARAMSLIDE");
		return;
	}
	
	[A4Request requestWithKeys:@[@"pat.x"]
			 completionHandler:^(NSDictionary *dict) {
				 
				 A4Pattern *pattern = dict[@"pat.x"];
				 int track = [trackIt currentValue] - 1;
				 NSString *stepsStr = @"";
				 int stepsCnt = 0;
				 
				 while(stepIt.isValid)
				 {
					 double stepFloat = [stepIt currentValue] - 1;
					 int step = round(stepFloat);
					 double mTimeFloat = stepFloat - step;
					 
					 A4Trig trig = [pattern trigAtStep:step inTrack:track];
					 if(!(trig.flags & A4TRIGFLAGS.TRIG) && !(trig.flags & A4TRIGFLAGS.TRIGLESS))
					 {
						 if(type == A4APITrigTypeTrig)
							 trig = A4TrigMakeDefault();
						 else if (type == A4APITrigTypeLock)
							 trig = A4TrigMakeTrigless();
					 }
					 else if(type == A4APITrigTypeTrig && (trig.flags & A4TRIGFLAGS.TRIGLESS))
					 {
						 trig.flags &= ~A4TRIGFLAGS.TRIGLESS;
						 trig.flags |= A4TRIGFLAGS.TRIG;
					 }
					 
					 trig.microTiming = mdmath_map(mTimeFloat, 0, 1, 0, 24);
					 
					 if(soundLockIt.isValid)
					 {
						 char soundLock = (char)[soundLockIt currentValue] - 1;
						 trig.soundLock = soundLock;
						 [soundLockIt increment];
					 }
					 if(noteLockIt.isValid)
					 {
						 char note = (char)[noteLockIt currentValue];
						 trig.notes[0] = note;
						 [noteLockIt increment];
					 }
					 if(note2LockIt.isValid)
					 {
						 char note = (char)[note2LockIt currentValue] + 64;
						 trig.notes[1] = note;
						 [note2LockIt increment];
					 }
					 if(note3LockIt.isValid)
					 {
						 char note = (char)[note3LockIt currentValue] + 64;
						 trig.notes[2] = note;
						 [note3LockIt increment];
					 }
					 if(note4LockIt.isValid)
					 {
						 char note = (char)[note4LockIt currentValue] + 64;
						 trig.notes[3] = note;
						 [note4LockIt increment];
					 }
					 if(velocityLockIt.isValid)
					 {
						 char velocity = (char)[velocityLockIt currentValue];
						 trig.velocity = velocity;
						 [velocityLockIt increment];
					 }
					 if(lengthLockIt.isValid)
					 {
						 char length = (char)[lengthLockIt currentValue];
						 trig.length = length;
						 [lengthLockIt increment];
					 }
					 if(muteLockIt.isValid)
					 {
						 BOOL mute = (BOOL)[muteLockIt currentValue];
						 if(mute) trig.flags |= A4TRIGFLAGS.MUTE;
						 else trig.flags &= ~A4TRIGFLAGS.MUTE;
						 [muteLockIt increment];
					 }
					 if(accentLockIt.isValid)
					 {
						 BOOL accent = (BOOL)[accentLockIt currentValue];
						 if(accent) trig.flags |= A4TRIGFLAGS.ACCENT;
						 else trig.flags &= ~A4TRIGFLAGS.ACCENT;
						 [accentLockIt increment];
					 }
					 if(noteSlideLockIt.isValid)
					 {
						 BOOL noteslide = (BOOL)[noteSlideLockIt currentValue];
						 if(noteslide) trig.flags |= A4TRIGFLAGS.NOTESLIDE;
						 else trig.flags &= ~A4TRIGFLAGS.NOTESLIDE;
						 [noteSlideLockIt increment];
					 }
					 if(paramSlideLockIt.isValid)
					 {
						 BOOL paramslide = (BOOL)[paramSlideLockIt currentValue];
						 if(paramslide) trig.flags |= A4TRIGFLAGS.PARAMSLIDE;
						 else trig.flags &= ~A4TRIGFLAGS.PARAMSLIDE;
						 [paramSlideLockIt increment];
					 }
					 
					 
					 
					 
					 
					 
					 [pattern setTrig:trig atStep:step inTrack:track];
					 
					 for(ParamLockInfo *lock in locks)
					 {
						 A4PVal pval = lock.pval;
						 if(lock.iterator.isValid)
						 {
							 pval = A4PValMake(pval.param, [lock.iterator currentValue]);
							 [lock.iterator increment];
						 }
						 
						 [pattern setLock:pval atStep:step inTrack:track];
						 
					 }
					 
					 if(type == A4APITrigTypeClear)
					 {
						 [pattern clearTrigAtStep:step inTrack:track];
					 }
					 
					 
					 printf("trigging track %d step %d\n", track, step);
					 [stepIt increment];
					 stepsCnt++;
					 if(stepsCnt <= 8)
					 {
						 stepsStr = [stepsStr stringByAppendingString:[NSString stringWithFormat:@"%d ", step+1]];
					 }
					 else if (stepsCnt == 9)
					 {
						 stepsStr = [stepsStr stringByAppendingString:@"[...] "];
					 }
				 }
				 
				 [pattern sendTemp];
				 completionHandler([NSString stringWithFormat:
									@"TRACK %d %@ %@TRIGGED",
									track+1,
									stepsCnt > 1 ? @"STEPS" : @"STEP",
									stepsStr]);
				 
			 } errorHandler:^(NSError *err) {
				 
				 errorHandler(err.description);
				 
			 }];
	
	
}



+ (void) executeClearTrigCommandWithTrackIterator:(A4APIStringNumericIterator *)trackIt
									 stepIterator:(A4APIStringNumericIterator *)stepIt
									 onCompletion:(void (^)(NSString *))completionHandler
										  onError:(void (^)(NSString *))errorHandler
{
	if(!trackIt.isValid || !stepIt.isValid)
	{
		errorHandler(@"INVALID COMMAND");
		return;
	}
	
	[A4Request requestWithKeys:@[@"pat.x"]
			 completionHandler:^(NSDictionary *dict) {
				 
				 A4Pattern *pattern = dict[@"pat.x"];
				 
				 int track = [trackIt currentValue] - 1;
				 NSString *stepsStr = @"";
				 int stepsCnt = 0;
				 
				 while(stepIt.isValid)
				 {
					 double stepFloat = [stepIt currentValue] - 1;
					 int step = round(stepFloat);
					 
					 A4Trig trig = [pattern trigAtStep:step inTrack:track];
					 
					 if(trig.flags & A4TRIGFLAGS.TRIG ^ trig.flags & A4TRIGFLAGS.TRIGLESS)
					 {
						 trig = A4TrigMakeEmpty();
						 [pattern setTrig:trig atStep:step inTrack:track];
						 printf("clearing track %d step %d\n", track, step);
						 
						 stepsCnt++;
						 if(stepsCnt <= 8)
						 {
							 stepsStr = [stepsStr stringByAppendingString:[NSString stringWithFormat:@"%d ", step+1]];
						 }
						 else if (stepsCnt == 9)
						 {
							 stepsStr = [stepsStr stringByAppendingString:@"[...] "];
						 }
					 }
					 
					 
					 
					 [stepIt increment];
				 }
				 
				 [pattern sendTemp];
				 completionHandler([NSString stringWithFormat:
									@"TRACK %d %@ %@CLEARED",
									track+1,
									stepsCnt > 1 ? @"STEPS" : @"STEP",
									stepsStr]);
				 
			 } errorHandler:^(NSError *err) {
				 
				 errorHandler(err.description);
				 
			 }];
}


@end
