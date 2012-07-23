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

@interface MDPatternSelection()
- (NSMutableArray *) sourceNodes;
- (void) reMapNodes:(NSArray *)nodes;
- (void) applyToTargetPattern:(NSArray *)nodes;
@end


@implementation MDPatternSelection


- (NSMutableArray *)sourceNodes
{
	
	DLog(@"fetching sourcenodes from source pattern:");
	
	NSMutableArray *nodes = [NSMutableArray array];
	
	int numNodes = 0;
	int numNodesWithLocks = 0;
	
	for (int step = self.sourceSelectionRectangle.step; step < self.sourceSelectionRectangle.numSteps + self.sourceSelectionRectangle.step; step++)
	{
		for (int track = self.sourceSelectionRectangle.track; track < self.sourceSelectionRectangle.track + self.sourceSelectionRectangle.numTracks; track++)
		{
			
			if(![self.sourcePattern trigAtTrack:track step:step]) continue;
			
			MDPatternSelectionNode *node = [MDPatternSelectionNode selectionNodeWithPosition:
											[MDPatternSelectionNodePosition nodePositionAtTrack:track step:step]];
			
			BOOL currentNodeHasLocks = NO;
			
			for(int param = 0; param < 24; param++)
			{
				MDParameterLock *lock = [self.sourcePattern lockAtTrack:track step:step param:param];
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
	
	DLog(@"found %d nodes. %d of which have locks. details:", numNodes, numNodesWithLocks);
	for (MDPatternSelectionNode *n in nodes)
	{
		DLog(@"%@", [n description]);
	}
	
	return nodes;
}

- (void)reMapNodes:(NSArray *)nodes
{
	for (MDPatternSelectionNode *n in nodes)
	{
		int track = n.position.track;
		int step = n.position.step;
		
		int newTrack = map(track, self.sourceSelectionRectangle.track, self.sourceSelectionRectangle.track + self.sourceSelectionRectangle.numTracks, self.targetSelectionRectangle.track, self.targetSelectionRectangle.track + self.targetSelectionRectangle.numTracks);
		
		int newStep = map(step, self.sourceSelectionRectangle.step, self.sourceSelectionRectangle.step + self.sourceSelectionRectangle.numSteps, self.targetSelectionRectangle.step, self.targetSelectionRectangle.step + self.targetSelectionRectangle.numSteps);
		
		DLog(@"moving node\nt: %d -> %d\ns: %d -> %d", track, newTrack, step, newStep);
		
		
		[n setPosition:[MDPatternSelectionNodePosition nodePositionAtTrack:newTrack step:newStep]];
	}
}

- (void)applyToTargetPattern:(NSArray *)nodes
{
	
}


- (void)reMapMove
{
	if(!self.sourcePattern ||
	   !self.targetPattern ||
	   !self.sourceSelectionRectangle ||
	   !self.targetSelectionRectangle)
	{
		DLog(@":(");
		return;
	}
	
	NSMutableArray *sourceNodes = [self sourceNodes];
	[self reMapNodes: sourceNodes];
	[self applyToTargetPattern: sourceNodes];
}

- (void)reMapCopyPaste
{
	if(!self.sourcePattern ||
	   !self.targetPattern ||
	   !self.sourceSelectionRectangle ||
	   !self.targetSelectionRectangle)
	{
		DLog(@":(");
		return;
	}
}

@end
