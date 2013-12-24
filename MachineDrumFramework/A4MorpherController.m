//
//  A4Morpher.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 24/12/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4MorpherController.h"


@interface A4MorpherController()
@property (nonatomic, strong) NSMutableArray *morphs;
@end

@implementation A4MorpherController


- (void)a4SoundMorph:(A4SoundMorph *)morph didFailWithError:(NSError *)error
{
	[self.delegate a4MorpherController:self morph:morph didFailWithError:error];
	[self.morphs removeObject:morph];
}

- (void)a4SoundMorph:(A4SoundMorph *)morph didFetchTrackIdx:(uint8_t)trackIdx
{
	[self.delegate a4MorpherController:self morph:morph didFetchTrackIdx:trackIdx];
}

- (void)a4SoundMorph:(A4SoundMorph *)morph didUpdateProgress:(double)progress
{
	[self.delegate a4MorpherController:self morph:morph didUpdateProgress:progress];
}

- (void)a4SoundMorph:(A4SoundMorph *)morph didReachEndWithAction:(A4MorpherCompletionAction)action
{
	[self.delegate a4MorpherController:self morph:morph didReachEndWithAction:action];
}

- (void)a4SoundMorphDidBegin:(A4SoundMorph *)morph
{
	[self.delegate a4MorpherController:self morphDidBegin:morph];
}

- (id)init
{
	if (self = [super init])
	{
		self.morphs = @[].mutableCopy;
	}
	return self;
}


- (A4SoundMorph *)beginMorphWithMode:(A4MorpherMorphMode)mode target:(uint8_t)targetIdx time:(double)t completionAction:(A4MorpherCompletionAction)action
{
	A4SoundMorph *morph = [A4SoundMorph new];
	morph.delegate = self;
	[self.morphs addObject:morph];
	[morph beginWithMode:mode target:targetIdx time:t completionAction:action];
	return morph;
}

- (void)setMorph:(A4SoundMorph *)morph completionAction:(A4MorpherCompletionAction)action applyImmediately:(BOOL)immediately
{
	if([self.morphs containsObject:morph])
	{
		[morph setCompletionAction:action applyImmediately:immediately];
	}
}

- (void)setMorph:(A4SoundMorph *)morph newTarget:(uint8_t)targetIdx additionalTime:(double)additionalTime
{
	if([self.morphs containsObject:morph])
	{
		[morph setNewTarget:targetIdx additionalTime:additionalTime];
	}
}

- (void)setMorph:(A4SoundMorph *)morph newTarget:(uint8_t)targetIdx setTimeFromNow:(double)newTime
{
	if([self.morphs containsObject:morph])
	{
		[morph setNewTarget:targetIdx setTimeFromNow:newTime];
	}
}

- (void)updateMorphs
{
	for (A4SoundMorph *morph in self.morphs)
	{
		[morph update];
	}
}

@end
