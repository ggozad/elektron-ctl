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

- (void)a4SoundMorphDidApply:(A4SoundMorph *)morph
{
	[self.delegate a4MorpherController:self morphDidApply:morph];
	[self.morphs removeObject:morph];
}

- (void)a4SoundMorphDidBegin:(A4SoundMorph *)morph
{
	[self.delegate a4MorpherController:self morphDidBegin:morph];
}

- (void)a4SoundMorphDidRevert:(A4SoundMorph *)morph
{
	[self.delegate a4MorpherController:self morphDidRevert:morph];
	[self.morphs removeObject:morph];
}

- (id)init
{
	if (self = [super init])
	{
		self.morphs = @[].mutableCopy;
	}
	return self;
}

- (void)revertMorphWithHandle:(A4MorpherMorphID)id
{
	for(A4SoundMorph *morph in self.morphs)
	{
		if(morph.id.handle == id.handle)
		{
			[morph revert];
			return;
		}
	}
}

- (void)modifyMorphWithHandle:(A4MorpherMorphID)handle newTarget:(uint8_t)targetIdx additionalTime:(double)additionalTime
{
	for(A4SoundMorph *morph in self.morphs)
	{
		if(morph.id.handle == handle.handle)
		{
			[morph modifyNewTarget:targetIdx additionalTime:additionalTime];
			return;
		}
	}
}

- (A4MorpherMorphID)beginMorphWithMode:(A4MorpherMorphMode)mode target:(uint8_t)targetIdx time:(double)t
{
	A4SoundMorph *morph = [A4SoundMorph new];
	morph.delegate = self;
	A4MorpherMorphID id = [morph beginWithMode:morph target:targetIdx time:t];
	if(id.handle)[ self.morphs addObject:morph];
	return id;
}

- (void)applyMorphWithHandle:(A4MorpherMorphID)id immediately:(BOOL)immediately
{
	for(A4SoundMorph *morph in self.morphs)
	{
		if(morph.id.handle == id.handle)
		{
			[morph applyImmediately:immediately];
			return;
		}
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
