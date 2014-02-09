//
//  A4Morpher.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 24/12/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4MorpherController.h"
#import "A4Sound.h"
#import "A4Settings.h"

typedef enum A4MorpherIntent
{
	A4MorpherIntentNothing,
	A4MorpherIntentPushTargetSound,
	A4MorpherIntentApplyTargetSound,
	A4MorpherIntentRevertToOriginal,
}
A4MorpherIntent;

@interface A4MorpherController()
@property (nonatomic) A4RequestHandle trackIdxRequestHandle, originalSoundRequestHandle;
@property (nonatomic, strong) NSMutableArray *targetRequestHandles;
@property (nonatomic, strong) A4Sound *originalSound;
@property (nonatomic, strong) NSMutableArray *targetSounds;
@property (nonatomic) A4MorpherIntent intentOnOriginalSoundFetched, intentOnTargetSoundFetched;
@property (nonatomic) NSInteger targetIdxTemp;
@property (nonatomic) BOOL didAlterOrig;
@end

@implementation A4MorpherController


- (id)init
{
	if (self = [super init])
	{
		self.targetRequestHandles = @[].mutableCopy;
		self.targetSounds = @[].mutableCopy;
		[self cancelAll];
	}
	return self;
}


- (void) addTargetHandle:(A4RequestHandle) handle
{
	if(! [self containsTargetHandle:handle])
	{
		[self.targetRequestHandles addObject:@(handle)];
	}
}

- (BOOL) containsTargetHandle:(A4RequestHandle)handle
{
	if(!handle) return NO;
	for (NSNumber *n in self.targetRequestHandles)
	{
		if(n.integerValue == handle) return YES;
	}
	return NO;
}

- (void) removeTargetHandle:(A4RequestHandle)handle
{
	if (!handle) return;
	NSMutableArray *bin = @[].mutableCopy;
	for (NSNumber *n in self.targetRequestHandles)
	{
		if(n.integerValue == handle)
		{
			[bin addObject:n];
		}
	}
	[self.targetRequestHandles removeObjectsInArray:bin];
}

- (void) cancelAll
{
	self.intentOnOriginalSoundFetched = A4MorpherIntentNothing;
	self.intentOnTargetSoundFetched = A4MorpherIntentNothing;
	self.targetIdxTemp = -1;
	self.track = -1;
	self.originalSound = nil;
	self.trackIdxRequestHandle = 0;
	self.originalSoundRequestHandle = 0;
	[self.targetRequestHandles removeAllObjects];
	[self.targetSounds removeAllObjects];
	
//	[self.delegate a4morpher:self didPostMessage:[NSString stringWithFormat:@"CANCEL ALL"]];
}

- (void) popTarget:(uint8_t)target revertTo:(uint8_t)earlierTarget
{
	
}

- (void) revertToOriginal
{
	if(self.track == -1) { [self cancelAll]; return; }
	
	if(self.originalSound)
	{
//		[self.delegate a4morpher:self didPostMessage:[NSString stringWithFormat:@"REVERT: \"%@\"", self.originalSound.name]];
		[self.originalSound sendTemp];
		[self cancelAll];
	}
	else
	{
		[self.delegate a4morpher:self didPostMessage:[NSString stringWithFormat:@"REVERT BUT NO SRC SND !"]];
		self.intentOnTargetSoundFetched = A4MorpherIntentRevertToOriginal;
		self.intentOnOriginalSoundFetched = A4MorpherIntentRevertToOriginal;
	}
}


- (void)pushTarget:(uint8_t)targetIdx apply:(BOOL)apply
{
	if(self.track != -1 && self.originalSound && self.targetSounds.count)
	{
		for (A4Sound *s in self.targetSounds)
		{
			if(s.position == targetIdx)
			{
				s.position = self.track;
				[s sendTemp];
				s.position = targetIdx;
				
//				[self.delegate a4morpher:self didPostMessage:[NSString stringWithFormat:@"--- PUSH %@ (cached) ---", s.name]];
				
				if(apply)
				{
//					[self.delegate a4morpher:self didPostMessage:[NSString stringWithFormat:@"--- APPLY %@ (cached) ---", s.name]];
					[self cancelAll];
				}
				return;
			}
		}
	}
	
	if(self.track == -1 && !self.trackIdxRequestHandle)
	{
		self.trackIdxRequestHandle = [A4Request requestWithKeys:@[@"set.x"]
											  completionHandler:^(NSDictionary *dict) {
											  
												  
												  if(self.track == -1 && self.trackIdxRequestHandle)
												  {
													  
													  self.trackIdxRequestHandle = 0;
													  A4Settings *settings = dict[@"set.x"];
//													  [self.delegate a4morpher:self didPostMessage:@"GOT SETTINGS"];
													  
													  if(settings.selectedTrackParams < 4)
													  {
//														  [self.delegate a4morpher:self didPostMessage:
//														   [NSString stringWithFormat:@"TRK OKAY: %d", settings.selectedTrackParams]];
														  
														  self.track = settings.selectedTrackParams;
														  if(apply)
														  {
															  return;
														  }
														  
														  if(!self.originalSound && !self.originalSoundRequestHandle)
														  {
															  [self requestOriginalSound];
														  }
													  }
													  else
													  {
//														  [self.delegate a4morpher:self didPostMessage:
//														   [NSString stringWithFormat:@"TRK INVALID: %d", settings.selectedTrackParams]];
														  [self cancelAll];
													  }
												  }
											  
											  } errorHandler:^(NSError *err) {
											  
//												  [self.delegate a4morpher:self didPostMessage:
//												   [NSString stringWithFormat:@"FAIL SETTINGS REQUEST: %@", err]];
												  [self cancelAll];
											  
											  }];
	}
	
	if(apply)
	{
		[self requestAndPushTarget:targetIdx withIntent:A4MorpherIntentApplyTargetSound];
	}
	else
	{
		self.intentOnOriginalSoundFetched = A4MorpherIntentPushTargetSound;
		[self requestAndPushTarget:targetIdx withIntent:A4MorpherIntentPushTargetSound];
	}
}

- (void) requestAndPushTarget:(NSInteger)i withIntent:(A4MorpherIntent) intent
{
//	[self.delegate a4morpher:self didPostMessage:
//	 [NSString stringWithFormat:@"REQ TGT: %d for %@", i, intent == A4MorpherIntentApplyTargetSound ? @"APPLY" : @"HOLD"]];
	
	self.targetIdxTemp = i;
	self.intentOnTargetSoundFetched = intent;
	NSString *key = [NSString stringWithFormat:@"snd.%d", i];
	__block A4RequestHandle handle = [A4Request requestWithKeys:@[key]
											  completionHandler:^(NSDictionary *dict) {
												  
												  [self.delegate a4morpher:self didPostMessage:
												   [NSString stringWithFormat:@"GOT TGT: %d", i]];
												  if(self.intentOnTargetSoundFetched == A4MorpherIntentRevertToOriginal)
												  {
													  [self revertToOriginal];
												  }
										  
												  if([self containsTargetHandle:handle])
												  {
													  [self removeTargetHandle:handle];
													  A4Sound *sound = dict[key];
													  
													  NSMutableArray *bin = @[].mutableCopy;
													  for (A4Sound *s in self.targetSounds) {
														  if (s.position == sound.position) [bin addObject:s];
													  }
													  [self.targetSounds removeObjectsInArray:bin];
													  [self.targetSounds addObject:sound];
													  
													  if(self.intentOnTargetSoundFetched == A4MorpherIntentApplyTargetSound &&
														 self.track != -1)
													  {
//														  [self.delegate a4morpher:self didPostMessage:
//														   [NSString stringWithFormat:@"--- APPLY \"%@\" NOW ---", sound.name]];
														  
														  sound.position = self.track;
														  [sound sendTemp];
														  [self cancelAll];
													  }
													  else if (self.intentOnTargetSoundFetched == A4MorpherIntentPushTargetSound &&
															   self.track != -1 && self.originalSound)
													  {
														  int tmp = sound.position;
														  sound.position = self.track;
														  [sound sendTemp];
														  sound.position = tmp;
//														  [self.delegate a4morpher:self didPostMessage:
//														   [NSString stringWithFormat:@"--- PUSH \"%@\"NOW ---", sound.name]];
													  }
													  else if (self.intentOnTargetSoundFetched == A4MorpherIntentPushTargetSound &&
															   self.track != -1)
													  {
//														  [self.delegate a4morpher:self didPostMessage:
//														   [NSString stringWithFormat:@"QUEUE TGT \"%@\"", sound.name]];
														  self.targetIdxTemp = sound.position;
													  }
												  }
											
										  
											  } errorHandler:^(NSError *err) {
										  
//												  [self.delegate a4morpher:self didPostMessage:
//												   [NSString stringWithFormat:@"FAIL TGT SND REQUEST: %@", err]];
												  [self cancelAll];
										  
											  }];
	
	
	[self addTargetHandle:handle];
}

- (void) requestOriginalSound
{
	if(self.track == -1)
	{
//		[self.delegate a4morpher:self didPostMessage:
//		 [NSString stringWithFormat:@"FAIL @ REQ SRC, TRK INVALID"]];
		return;
	}
	
	NSString *sndKey = [NSString stringWithFormat:@"snd.x.%d", self.track];
	self.originalSoundRequestHandle =
	[A4Request requestWithKeys:@[sndKey]
			 completionHandler:^(NSDictionary *dict) {
				 
				 if(self.originalSoundRequestHandle &&
					!self.originalSound)
				 {
					 self.originalSound = dict[sndKey];
					 self.originalSoundRequestHandle = 0;
					 
//					 [self.delegate a4morpher:self didPostMessage:
//					  [NSString stringWithFormat:@"GOT SRC \"%@\"", self.originalSound.name]];
					 
					 if(self.intentOnOriginalSoundFetched == A4MorpherIntentPushTargetSound)
					 {
						 [self requestAndPushTarget:self.targetIdxTemp withIntent:A4MorpherIntentPushTargetSound];
					 }
					 else if (self.intentOnOriginalSoundFetched == A4MorpherIntentApplyTargetSound)
					 {
						 [self requestAndPushTarget:self.targetIdxTemp withIntent:A4MorpherIntentApplyTargetSound];
					 }
					 else if (self.intentOnOriginalSoundFetched == A4MorpherIntentRevertToOriginal)
					 {
						 [self revertToOriginal];
					 }

				 }
				 else
				 {
					 [self cancelAll];
				 }
				 
			 } errorHandler:^(NSError *err) {
				 
//				 [self.delegate a4morpher:self didPostMessage:
//				  [NSString stringWithFormat:@"FAIL ORIG SND REQUEST: %@", err]];
				 [self cancelAll];
				 
			 }];
}




@end
