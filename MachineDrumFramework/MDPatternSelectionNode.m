//
//  MDPatternSelectionNode.m
//  MachineDrumFrameworkOSX
//
//  Created by Jakob Penca on 7/20/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDPatternSelectionNode.h"

@interface MDPatternSelectionNode()
{
	MDPatternSelectionNodePosition *_position;
	NSMutableArray *_locks;
	BOOL _trig;
}

- (void) updateLocks;

@end


@implementation MDPatternSelectionNode

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ | t: %d s: %d numLocks: %ld", [super description], self.position.track, self.position.step, [self.locks count]];
}

+ (id)selectionNodeWithPosition:(MDPatternSelectionNodePosition *)position
{
	MDPatternSelectionNode *n = [self new];
	n.position = position;
	return n;
}

- (void)setTrig:(BOOL)trig
{
	_trig = trig;
	if(!trig) [self clear];
}

- (BOOL)trig
{
	return _trig;
}

- (void)clear
{
	_locks = [NSMutableArray array];
	_trig = NO;
}

- (void)addLock:(MDParameterLock *)lock
{
	if(!lock) return;
	
	MDParameterLock *newLock = [lock copy];
	
	for (MDParameterLock *pLock in self.locks)
	{
		if(pLock.param == newLock.param)
		{
			pLock.lockValue = newLock.lockValue;
			break;
		}
	}
	
	[_locks addObject:newLock];
	[self updateLocks];
}

- (void)updateLocks
{
	for (MDParameterLock *pLock in self.locks)
	{
		pLock.track = _position.track;
		pLock.step = _position.step;
	}
}

- (id)init
{
	if(self = [super init])
	{
		_locks = [NSMutableArray array];
	}
	return self;
}

- (void)setPosition:(MDPatternSelectionNodePosition *)position
{
	_position = position;
	[self updateLocks];
}

- (MDPatternSelectionNodePosition *)position
{
	return _position;
}

@end
