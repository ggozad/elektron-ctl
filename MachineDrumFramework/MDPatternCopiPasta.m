//
//  MDPatternSelection.m
//  MachineDrumFrameworkOSX
//
//  Created by Jakob Penca on 7/20/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDPatternCopiPasta.h"
#import "MDPatternNode.h"
#import "MDPatternNodePosition.h"

static float map(float value,
				 float istart, float istop,
				 float ostart, float ostop)
{
    return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
}

static int Wrap(int kX, int const kLowerBound, int const kUpperBound)
{
    int range_size = kUpperBound - kLowerBound + 1;
	
    if (kX < kLowerBound)
        kX += range_size * ((kLowerBound - kX) / range_size + 1);
	
    return kLowerBound + (kX - kLowerBound) % range_size;
}

@interface MDPatternCopiPasta()
- (NSMutableArray *) sourceNodes;
- (void) removeNodesFromSourcePattern:(NSArray *)nodes;
- (void) writeToTargetPattern:(NSArray *)nodes;
- (void) shiftSourceSteps: (int8_t)s tracks: (int8_t) t;
@end


@implementation MDPatternCopiPasta


- (NSMutableArray *)sourceNodes
{
	return [self nodesForPattern:self.sourcePattern withRegion:self.sourceRegion];
}

- (NSMutableArray *)targetNodes
{
	return [self nodesForPattern:self.targetPattern withRegion:self.targetRegion];
}

- (void)swapRegions
{
	MDPatternRegion *tmp = self.sourceRegion;
	self.sourceRegion = self.targetRegion;
	self.targetRegion = tmp;	
}

- (void)shiftSourceInDirection:(MDPatternCopiPastaShiftDirection)dir
{
	int s = 0; int t = 0;
	if(dir == MDPatternCopiPastaShiftDirectionRight) s = 1;
	else if ( dir == MDPatternCopiPastaShiftDirectionDown) t = 1;
	else if ( dir == MDPatternCopiPastaShiftDirectionLeft) s = -1;
	else if ( dir == MDPatternCopiPastaShiftDirectionUp) t = -1;
		
	[self shiftSourceSteps:s tracks:t];
}


- (void)shiftSourceSteps:(int8_t)s tracks:(int8_t)t
{
	if(!self.sourcePattern ||
	   !self.targetPattern ||
	   !self.sourceRegion)
	{
		DLog(@":(");
		return;
	}
	
	s = Wrap(s, -64, 64);
	t = Wrap(t, -16, 16);
	
	
	NSMutableArray *sourceNodes = [self sourceNodes];
	[self removeNodesFromSourcePattern:sourceNodes];
	
	MDPatternRegion *r = self.sourceRegion;

	int8_t trackStart = r.track;
	int8_t trackEnd = r.track + r.numTracks - 1;
	
	DLog(@"region track: %d numTracks: %d", r.track, r.numTracks);
	DLog(@"trackstart: %d end: %d", trackStart, trackEnd);
	
	
	if(trackStart > trackEnd) // reverse
	{
		DLog(@"reversing tracks..");
		
		if(r.track + r.numTracks < 0)
			trackStart = Wrap(r.track + r.numTracks - 1, 0, 16);
		else
			trackStart = Wrap(r.track + r.numTracks, 0, 16);
		
		trackEnd = trackStart - r.numTracks - 1;
	}
	
	int8_t stepStart = r.step;
	int8_t stepEnd = r.step + r.numSteps - 1;
	DLog(@"stepstart: %d end: %d", stepStart, stepEnd);
	
	if(stepStart > stepEnd) // reverse
	{
		DLog(@"reversing steps..");
		
		
		if(r.step + r.numSteps < 0)
			stepStart = Wrap(r.step + r.numSteps - 1, 0, 64);
		else
			stepStart = Wrap(r.step + r.numSteps, 0, 64);
		
		stepEnd = stepStart - r.numSteps - 1;
	}
	
	DLog(@"stepstart: %d end: %d", stepStart, stepEnd);
	DLog(@"trackstart: %d end: %d", trackStart, trackEnd);
	
	
	for (MDPatternNode *n in sourceNodes)
	{
		int8_t track = 0;
		int8_t step = 0;
		
		if(trackEnd < 16)
			track = Wrap(n.position.track + t, trackStart, trackEnd);
		else
		{
			track = n.position.track + t;
			if(t > 0)
			{
				if(n.position.track < trackStart)
				{
					int rest = trackEnd % 16;
					DLog(@"rest: %d", rest);
					if(n.position.track <= rest)
					{
						int ntrack = n.position.track + t;
						if(ntrack > rest)
							track = trackStart + ntrack - rest - 1;
					}
				}
			}
			else if(t < 0)
			{
				if(n.position.track >= trackStart &&
				   n.position.track + t < trackStart)
				{
					int rest = trackEnd % 16;
					DLog(@"rest: %d", rest);
					
					int ntrack = n.position.track + t;
					track = rest - (ntrack - trackStart) - 1;
				}
			}
		}
		
		
		if(stepEnd < 64)
			step = Wrap(n.position.step + s, stepStart, stepEnd);
		else
		{
			step = n.position.step + s;
			if(s > 0)
			{
				if(n.position.step < stepStart)
				{
					int rest = stepEnd % 64;
					DLog(@"rest: %d", rest);
					if(n.position.step <= rest)
					{
						int nstep = n.position.step + s;
						if(nstep > rest)
							step = stepStart + nstep - rest - 1;
					}
				}
			}
			else if(s < 0)
			{
				if(n.position.step >= stepStart &&
				   n.position.step + s < stepStart)
				{
					int rest = stepEnd % 64;
					DLog(@"rest: %d", rest);
					
					int nstep = n.position.step + s;
					step = rest - (nstep - stepStart) - 1;
				}
			}
		}
		
		[n setPosition:[MDPatternNodePosition nodePositionAtTrack:track step:step]];
	}
	
	[self writeToTargetPattern:sourceNodes];
}

- (NSMutableArray *) nodesForPattern:(MDPattern *)pattern withRegion:(MDPatternRegion *)r
{
	//DLog(@"fetching sourcenodes from source pattern:");
	
	NSMutableArray *nodes = [NSMutableArray array];
	
	int numNodes = 0;
	int numNodesWithLocks = 0;
	
	int startStep = r.step;
	int lastStep = r.numSteps + r.step;
	
	if(lastStep < startStep)
	{
		lastStep = startStep;
		startStep = r.numSteps + r.step;
	}
	
	int lastTrack = r.numTracks + r.track;
	int startTrack = r.track;
	
	if(lastTrack < startTrack)
	{
		lastTrack = startTrack;
		startTrack = r.numTracks + r.track;
	}
	
	
	for (int step = startStep; step < lastStep; step++)
	{
		for (int track = startTrack; track < lastTrack; track++)
		{
			
			int wrappedStep = Wrap(step, 0, 63);
			int wrappedTrack = Wrap(track, 0, 15);
			
			//DLog(@"t: %d s: %d ", wrappedTrack, wrappedStep);
			
			if(![pattern trigAtTrack:wrappedTrack step:wrappedStep]) continue;
			
			MDPatternNode *node = [MDPatternNode nodeWithPosition:
											[MDPatternNodePosition nodePositionAtTrack:wrappedTrack step:wrappedStep]];
			
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
	
	
	DLog(@"found %d nodes, %d of which have locks.", numNodes, numNodesWithLocks);
	/*
	for (MDPatternNode *n in nodes)
		DLog(@"%@", [n description]);
	*/
	return nodes;
}

- (void) remapNodes:(NSArray *)nodes fromRegion:(MDPatternRegion *)src intoRegion: (MDPatternRegion *)tgt withMode:(MDPatternCopiPastaRemapMode)mode
{
	for (MDPatternNode *n in nodes)
	{
		int track = n.position.track;
		int step = n.position.step;
		
		int newTrack = 0;
		int newStep = 0;
		
		if(mode == MDPatternCopiPastaRemapModeScale)
		{
			if((tgt.numTracks < 0 && src.numTracks > 0 )||
			   (tgt.numTracks > 0 && src.numTracks < 0))
			{
				newTrack = Wrap(ceilf(map(track, src.track, src.track + src.numTracks, tgt.track, tgt.track + tgt.numTracks)), 0, 15);
				newTrack -= 1;
			}
			else
				newTrack = Wrap(floorf(map(track, src.track, src.track + src.numTracks, tgt.track, tgt.track + tgt.numTracks)), 0, 15);
			
			if((tgt.numSteps < 0 && src.numSteps > 0) ||
			   (tgt.numSteps > 0 && src.numSteps < 0))
			{
				newStep = Wrap(ceilf(map(step, src.step, src.step + src.numSteps, tgt.step, tgt.step + tgt.numSteps)), 0, 63);
				newStep -= 1;
			}
			else
				newStep = Wrap(floorf(map(step, src.step, src.step + src.numSteps, tgt.step, tgt.step + tgt.numSteps)), 0, 63);
		}
		//DLog(@"moving node\nt: %d -> %d\ns: %d -> %d", track, newTrack, step, newStep);
		
		[n setPosition:[MDPatternNodePosition nodePositionAtTrack:newTrack step:newStep]];
	}
}

- (void)writeToTargetPattern:(NSArray *)nodes
{
	MDPattern *pattern = self.targetPattern;
	[self writeNodes:nodes ToPattern:pattern];
}

- (void)writeToSourcePattern:(NSArray *)nodes
{
	MDPattern *pattern = self.sourcePattern;
	[self writeNodes:nodes ToPattern:pattern];
}

- (void) writeNodes:(NSArray *)nodes ToPattern:(MDPattern *)pattern
{
	for (MDPatternNode *n in nodes)
	{
		if(![n.locks count])
		{
			if(![pattern trigAtTrack:n.position.track step:n.position.step])
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

- (void) removeNodes:(NSArray *)nodes fromPattern: (MDPattern *) pattern
{
	for (MDPatternNode *n in nodes)
	{
		for (MDParameterLock *l in n.locks)
		{
			[pattern clearLock:l clearTrig:NO];
		}
		
		[pattern setTrigAtTrack:n.position.track step:n.position.step toValue:NO];
	}
}


- (void)remapMoveSourceToTarget_Transparent_WithMode:(MDPatternCopiPastaRemapMode)mode
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
	[self remapNodes:sourceNodes fromRegion:self.sourceRegion intoRegion:self.targetRegion withMode:mode];
	[self writeToTargetPattern: sourceNodes];
}

- (void)remapMoveSourceToTarget_Opaque_WithMode:(MDPatternCopiPastaRemapMode)mode
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
	[self clearTargetRegion];
	[self remapNodes:sourceNodes fromRegion:self.sourceRegion intoRegion:self.targetRegion withMode:mode];
	[self writeToTargetPattern: sourceNodes];
}

- (void)remapCopySourceToTarget_Transparent_WithMode:(MDPatternCopiPastaRemapMode)mode
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
	[self remapNodes:sourceNodes fromRegion:self.sourceRegion intoRegion:self.targetRegion withMode:mode];
	[self writeToTargetPattern: sourceNodes];
}

- (void)remapCopySourceToTarget_Opaque_WithMode:(MDPatternCopiPastaRemapMode)mode
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
	[self clearTargetRegion];
	[self remapNodes:sourceNodes fromRegion:self.sourceRegion intoRegion:self.targetRegion withMode:mode];
	[self writeToTargetPattern: sourceNodes];
}

- (void)remapSwapSourceWithTarget_WithMode:(MDPatternCopiPastaRemapMode)mode
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
	
	[self remapNodes:sourceNodes fromRegion:self.sourceRegion intoRegion:self.targetRegion withMode:mode];
	[self remapNodes:targetNodes fromRegion:self.targetRegion intoRegion:self.sourceRegion withMode:mode];
	
	[self writeToTargetPattern:sourceNodes];
	[self writeToSourcePattern:targetNodes];
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

- (void) clearRegion:(MDPatternRegion *)r fromPattern:(MDPattern *)pattern
{
	if(!r || !pattern) return;
	
	NSMutableArray *nodes = [self nodesForPattern:pattern withRegion:r];
	[self removeNodes:nodes fromPattern:pattern];
}

@end
