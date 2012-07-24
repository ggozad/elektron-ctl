//
//  MDPatternSelection.m
//  MachineDrumFrameworkOSX
//
//  Created by Jakob Penca on 7/20/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDPatternSelection.h"
#import "MDPatternSelectionNode.h"
#import "MDPatternSelectionNodePosition.h"

static float map(float value,
				 float istart, float istop,
				 float ostart, float ostop)
{
    return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
}

static int Wrap(int kX, int const kLowerBound, int const kUpperBound)
{
    int range = kUpperBound - kLowerBound + 1;
	kX = ((kX-kLowerBound) % range);
	if (kX<0)
		return kUpperBound + 1 + kX;
	else
		return kLowerBound + kX;
}

@interface MDPatternSelection()
- (NSMutableArray *) sourceNodes;
- (void) removeNodesFromSourcePattern:(NSArray *)nodes;
- (void) applyToTargetPattern:(NSArray *)nodes;
@end


@implementation MDPatternSelection


- (NSMutableArray *)sourceNodes
{
	return [self nodesForPattern:self.sourcePattern withRegion:self.sourceRegion];
}

- (NSMutableArray *)targetNodes
{
	return [self nodesForPattern:self.targetPattern withRegion:self.targetRegion];
}

- (NSMutableArray *) nodesForPattern:(MDPatternPublicWrapper *)pattern withRegion:(MDPatternRegion *)r
{
	//DLog(@"fetching sourcenodes from source pattern:");
	
	NSMutableArray *nodes = [NSMutableArray array];
	
	int numNodes = 0;
	int numNodesWithLocks = 0;
	
	/*
	DLog(@"src rect: t: %d s: %d nt: %d ns: %d",
		 self.sourceSelectionRectangle.track,
		 self.sourceSelectionRectangle.step,
		 self.sourceSelectionRectangle.numTracks,
		 self.sourceSelectionRectangle.numSteps);
	*/
	
	for (int step = r.step; step < r.step + r.numSteps; step++)
	{
		for (int track = r.track; track < r.track + r.numTracks; track++)
		{
			
			int wrappedStep = Wrap(step, 0, 63);
			int wrappedTrack = Wrap(track, 0, 15);
			
			DLog(@"t: %d s: %d ", wrappedTrack, wrappedStep);
			
			if(![pattern trigAtTrack:wrappedTrack step:wrappedStep]) continue;
			
			MDPatternSelectionNode *node = [MDPatternSelectionNode selectionNodeWithPosition:
											[MDPatternSelectionNodePosition nodePositionAtTrack:wrappedTrack step:wrappedStep]];
			
			BOOL currentNodeHasLocks = NO;
			
			for(int param = 0; param < 24; param++)
			{
				MDParameterLock *lock = [pattern lockAtTrack:wrappedTrack step:wrappedStep param:param];
				if(lock)
				{
					[node addLock:lock];
					currentNodeHasLocks = YES;
				}
			}
			
			[nodes addObject:node];
			numNodes++;
			if(currentNodeHasLocks) numNodesWithLocks++;
			
		}
	}
	
	DLog(@"found %d nodes, %d of which have locks. details:", numNodes, numNodesWithLocks);
	for (MDPatternSelectionNode *n in nodes)
	{
		DLog(@"%@", [n description]);
	}
	
	return nodes;
}

- (void) remapNodes:(NSArray *)nodes fromRegion:(MDPatternRegion *)src intoRegion: (MDPatternRegion *)tgt
{
	for (MDPatternSelectionNode *n in nodes)
	{
		int track = n.position.track;
		int step = n.position.step;
		
		int newTrack = Wrap(map(track, src.track, src.track + src.numTracks, tgt.track, tgt.track + tgt.numTracks), 0, 15);
		
		int newStep = Wrap(map(step, src.step, src.step + src.numSteps, tgt.step, tgt.step + tgt.numSteps), 0, 63);
		
		DLog(@"moving node\nt: %d -> %d\ns: %d -> %d", track, newTrack, step, newStep);
		
		[n setPosition:[MDPatternSelectionNodePosition nodePositionAtTrack:newTrack step:newStep]];
	}
}

- (void)applyToTargetPattern:(NSArray *)nodes
{
	MDPatternPublicWrapper *pattern = self.targetPattern;
	[self applyNodes:nodes ToPattern:pattern];
}

- (void)applyToSourcePattern:(NSArray *)nodes
{
	MDPatternPublicWrapper *pattern = self.sourcePattern;
	[self applyNodes:nodes ToPattern:pattern];
}

- (void) applyNodes:(NSArray *)nodes ToPattern:(MDPatternPublicWrapper *)pattern
{
	for (MDPatternSelectionNode *n in nodes)
	{
		if(![n.locks count])
		{
			[pattern setTrigAtTrack:n.position.track step:n.position.step toValue:YES];
		}
		else
		{
			for (MDParameterLock *l in n.locks)
			{
				BOOL success = [pattern setLock:l setTrigIfNone:YES];
				if(!success) DLog(@"failed to set lock: %@", l);
			}
		}
	}
}

- (void) removeNodesFromSourcePattern:(NSArray *)nodes
{
	[self removeNodes:nodes fromPattern:self.sourcePattern];
}

- (void)removeNodesFromTargetPattern:(NSArray *)nodes
{
	[self removeNodes:nodes fromPattern:self.targetPattern];
}

- (void) removeNodes:(NSArray *)nodes fromPattern: (MDPatternPublicWrapper *) pattern
{
	for (MDPatternSelectionNode *n in nodes)
	{
		for (MDParameterLock *l in n.locks)
		{
			[pattern clearLock:l clearTrig:NO];
		}
		
		[pattern setTrigAtTrack:n.position.track step:n.position.step toValue:NO];
	}
}


- (void)remapMoveSourceToTarget
{
	if(!self.sourcePattern ||
	   !self.targetPattern ||
	   !self.sourceRegion ||
	   !self.targetRegion)
	{
		DLog(@":(");
		return;
	}
	
	NSMutableArray *sourceNodes = [self sourceNodes];
	[self removeNodesFromSourcePattern:sourceNodes];
	[self remapNodes:sourceNodes fromRegion:self.sourceRegion intoRegion:self.targetRegion];
	[self applyToTargetPattern: sourceNodes];
}

- (void)remapCopySourceToTarget
{
	if(!self.sourcePattern ||
	   !self.targetPattern ||
	   !self.sourceRegion ||
	   !self.targetRegion)
	{
		DLog(@":(");
		return;
	}
	
	NSMutableArray *sourceNodes = [self sourceNodes];
	[self remapNodes:sourceNodes fromRegion:self.sourceRegion intoRegion:self.targetRegion];
	[self applyToTargetPattern: sourceNodes];
}

- (void)remapSwapSourceWithTarget
{
	if(!self.sourcePattern ||
	   !self.targetPattern ||
	   !self.sourceRegion ||
	   !self.targetRegion)
	{
		DLog(@":(");
		return;
	}
	
	NSMutableArray *sourceNodes = [self sourceNodes];
	NSMutableArray *targetNodes = [self targetNodes];
	
	[self removeNodes:sourceNodes fromPattern:self.sourcePattern];
	[self removeNodes:targetNodes fromPattern:self.targetPattern];
	
	[self remapNodes:sourceNodes fromRegion:self.sourceRegion intoRegion:self.targetRegion];
	[self remapNodes:targetNodes fromRegion:self.targetRegion intoRegion:self.sourceRegion];
	
	[self applyToTargetPattern:sourceNodes];
	[self applyToSourcePattern:targetNodes];
}

- (void)clearTargetRegion
{
	if(!self.targetPattern ||
	   !self.targetRegion)
	{
		DLog(@":(");
		return;
	}
	
	NSMutableArray *targetNodes = [self targetNodes];
	[self removeNodesFromTargetPattern:targetNodes];
}

- (void)clearSourceRegion
{
	if(!self.sourcePattern ||
	   !self.sourceRegion)
	{
		DLog(@":(");
		return;
	}
	
	NSMutableArray *sourceNodes = [self sourceNodes];
	[self removeNodes:sourceNodes fromPattern:self.sourcePattern];
}

- (void) clearRegion:(MDPatternRegion *)r fromPattern:(MDPatternPublicWrapper *)pattern
{
	if(!r || !pattern) return;
	
	NSMutableArray *nodes = [self nodesForPattern:pattern withRegion:r];
	[self removeNodes:nodes fromPattern:pattern];
}

@end
