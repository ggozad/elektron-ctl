//
//  A4Morpher.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 24/12/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4MorpherController.h"
#import "A4Sound.h"
#import "A4Kit.h"
#import "A4Settings.h"

typedef enum A4MorpherIntent
{
	A4MorpherIntentNothing,
	A4MorpherIntentPushTarget,
	A4MorpherIntentApplyTarget,
	A4MorpherIntentRevertToOriginal,
}
A4MorpherIntent;

@interface A4MorpherController()
@property (nonatomic) A4RequestHandle trackIdxRequestHandle, originalRequestHandle;
@property (nonatomic, strong) A4Sound *originalSound, *originalKit;
@property (nonatomic) A4MorpherIntent intentOnOriginalFetched, intentOnTargetFetched;
@property (nonatomic) NSInteger targetIdxTemp;
@property (nonatomic) BOOL didAlterOrig;
@end

@implementation A4MorpherController


- (id)init
{
	if (self = [super init])
	{
		self.soundCache = @[].mutableCopy;
		
		for (int i  = 0; i < 128; i++)
		{
			[self.soundCache addObject:[A4Sound defaultSound]];
		}
		
		self.kitCache = @[].mutableCopy;
		
		for (int i = 0; i < 128; i++)
		{
			[self.kitCache addObject:[A4Kit defaultKit]];
		}
		self.mode = A4MorpherControllerModeKits;
		[self cancelAll];
	}
	return self;
}

- (void)setMode:(A4MorpherControllerMode)mode
{
	[self revertToOriginal];
	_mode = mode;
}

- (void) cancelAll
{
	self.intentOnOriginalFetched = A4MorpherIntentNothing;
	self.intentOnTargetFetched = A4MorpherIntentNothing;
	self.targetIdxTemp = -1;
	self.track = -1;
	self.originalSound = nil;
	self.originalKit = nil;
	self.trackIdxRequestHandle = 0;
	self.originalRequestHandle = 0;
}

- (void) revertToOriginal
{
	if(_mode == A4MorpherControllerModeSounds && self.track == -1) { [self cancelAll]; return; }
	
	if(_mode == A4MorpherControllerModeSounds && self.originalSound)
	{
		[self.originalSound sendTemp];
		[self cancelAll];
	}
	else if(_mode == A4MorpherControllerModeKits && self.originalKit)
	{
		[self.originalKit sendTemp];
		[self cancelAll];
	}
	else
	{
		self.intentOnTargetFetched = A4MorpherIntentRevertToOriginal;
		self.intentOnOriginalFetched = A4MorpherIntentRevertToOriginal;
	}
}


- (void)pushTarget:(uint8_t)targetIdx apply:(BOOL)apply
{
	if(_mode == A4MorpherControllerModeSounds && self.track != -1 && self.originalSound)
	{
		A4Sound *sound = self.soundCache[targetIdx];
		sound.position = self.track;
		[sound sendTemp];
		sound.position = targetIdx;
		
		if(apply)
		{
			[self cancelAll];
		}
		return;
	}
	else if(_mode == A4MorpherControllerModeKits && self.originalKit)
	{
		A4Kit *kit = self.kitCache[targetIdx];
		[kit sendTemp];
		kit.position = targetIdx;
		
		if(apply)
		{
			[self cancelAll];
		}
		return;
	}
	
	if(_mode == A4MorpherControllerModeSounds && self.track == -1 && !self.trackIdxRequestHandle)
	{
		self.trackIdxRequestHandle = [A4Request requestWithKeys:@[@"set.x"]
											  completionHandler:^(NSDictionary *dict) {
											  
												  
												  if(self.track == -1 && self.trackIdxRequestHandle)
												  {
													  
													  self.trackIdxRequestHandle = 0;
													  A4Settings *settings = dict[@"set.x"];
													  
													  if(settings.selectedTrackParams < 4)
													  {
														  self.track = self.useManualTrack ? self.manualTrack : settings.selectedTrackParams;
														  
														  if(apply)
														  {
															  return;
														  }
														  
														  if(!self.originalSound && !self.originalRequestHandle)
														  {
															  [self requestOriginalSound];
														  }
													  }
													  else
													  {
														  [self cancelAll];
													  }
												  }
											  
											  } errorHandler:^(NSError *err) {
											  
												  [self cancelAll];
											  
											  }];
	}
	else if(_mode == A4MorpherControllerModeKits && !self.originalKit)
	{
		[self requestOriginalKit];
	}
	
	if(apply)
	{
		[self pushTarget:targetIdx withIntent:A4MorpherIntentApplyTarget];
	}
	else
	{
		self.intentOnOriginalFetched = A4MorpherIntentPushTarget;
		[self pushTarget:targetIdx withIntent:A4MorpherIntentPushTarget];
	}
}

- (void) pushTarget:(NSInteger)i withIntent:(A4MorpherIntent) intent
{
	self.targetIdxTemp = i;
	self.intentOnTargetFetched = intent;
	
	if(self.intentOnTargetFetched == A4MorpherIntentRevertToOriginal)
	{
		[self revertToOriginal];
	}
	
	if(_mode == A4MorpherControllerModeSounds)
	{
		A4Sound *sound = self.soundCache[i];
		
		if(self.intentOnTargetFetched == A4MorpherIntentApplyTarget &&
		   self.track != -1)
		{
			sound.position = self.track;
			[sound sendTemp];
			[self cancelAll];
		}
		else if (self.intentOnTargetFetched == A4MorpherIntentPushTarget &&
				 self.track != -1 && self.originalSound)
		{
			int tmp = sound.position;
			sound.position = self.track;
			[sound sendTemp];
			sound.position = tmp;
		}
		else if (self.intentOnTargetFetched == A4MorpherIntentPushTarget &&
				 self.track != -1)
		{
			self.targetIdxTemp = sound.position;
		}
	}
	else if (_mode == A4MorpherControllerModeKits)
	{
		A4Kit *kit = self.kitCache[i];
		
		if(self.intentOnTargetFetched == A4MorpherIntentApplyTarget)
		{
			[kit sendTemp];
			[self cancelAll];
		}
		else if (self.intentOnTargetFetched == A4MorpherIntentPushTarget && self.originalKit)
		{
			[kit sendTemp];
		}
		else if (self.intentOnTargetFetched == A4MorpherIntentPushTarget)
		{
			self.targetIdxTemp = kit.position;
		}
	}
}

- (void) requestOriginalSound
{
	if(self.track == -1)
	{
		return;
	}
	
	NSString *sndKey = [NSString stringWithFormat:@"snd.x.%d", self.track];
	self.originalRequestHandle =
	[A4Request requestWithKeys:@[sndKey]
			 completionHandler:^(NSDictionary *dict) {
				 
				 if(self.originalRequestHandle &&
					!self.originalSound)
				 {
					 self.originalSound = dict[sndKey];
					 self.originalRequestHandle = 0;
					 					 
					 if(self.intentOnOriginalFetched == A4MorpherIntentPushTarget)
					 {
						 [self pushTarget:self.targetIdxTemp withIntent:A4MorpherIntentPushTarget];
					 }
					 else if (self.intentOnOriginalFetched == A4MorpherIntentApplyTarget)
					 {
						 [self pushTarget:self.targetIdxTemp withIntent:A4MorpherIntentApplyTarget];
					 }
					 else if (self.intentOnOriginalFetched == A4MorpherIntentRevertToOriginal)
					 {
						 [self revertToOriginal];
					 }

				 }
				 else
				 {
					 [self cancelAll];
				 }
				 
			 } errorHandler:^(NSError *err) {
				 
				 [self cancelAll];
				 
			 }];
}

- (void) requestOriginalKit
{
	
	NSString *kitKey = @"kit.x";
	self.originalRequestHandle =
	[A4Request requestWithKeys:@[kitKey]
			 completionHandler:^(NSDictionary *dict) {
				 
				 if(self.originalRequestHandle &&
					!self.originalKit)
				 {
					 self.originalKit = dict[kitKey];
					 self.originalRequestHandle = 0;
					 
					 if(self.intentOnOriginalFetched == A4MorpherIntentPushTarget)
					 {
						 [self pushTarget:self.targetIdxTemp withIntent:A4MorpherIntentPushTarget];
					 }
					 else if (self.intentOnOriginalFetched == A4MorpherIntentApplyTarget)
					 {
						 [self pushTarget:self.targetIdxTemp withIntent:A4MorpherIntentApplyTarget];
					 }
					 else if (self.intentOnOriginalFetched == A4MorpherIntentRevertToOriginal)
					 {
						 [self revertToOriginal];
					 }
					 
				 }
				 else
				 {
					 [self cancelAll];
				 }
				 
			 } errorHandler:^(NSError *err) {
				 
				 [self cancelAll];
				 
			 }];
}




@end
