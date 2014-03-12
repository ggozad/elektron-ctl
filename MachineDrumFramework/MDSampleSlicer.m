//
//  MDSampleSlicer.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 02/03/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import "MDSampleSlicer.h"
#import "MDMath.h"
#import "MDParameterLock.h"

@implementation MDSampleSlicer

- (id)init
{
	if(self = [super init])
	{
		_length = 16;
		_sampleLength = 16;
		_stepInterval = 1;
		_generateSliceLocks = YES;
		_pitchVal = 64;
	}
	return self;
}

- (void)slice
{
	if(!self.pattern) return;
	
	int patternLength = self.pattern.length;
	if(_offset >= patternLength) return;
	patternLength = MIN(patternLength, _offset + _length);
	
//	int numSlices = _sampleLength / _stepInterval;
	int numSlices = _sampleLength;
	int sliceLen = 128.0/numSlices;
	sliceLen *= .95;
	int sliceIdx = 0;
	
	for(int stepIdx = _offset; stepIdx < patternLength; stepIdx+=_stepInterval)
	{
		if(_generateSliceLocks)
		{
			int innerSliceIdx = sliceIdx;
			if(_direction == MDSamplerSlicerDirectionBackward)
			{
				innerSliceIdx = (numSlices-1) - sliceIdx;
			}
			
			if(_randomPlacement > 0 && mdmath_rand(0, 1) <= _randomPlacement)
			{
				innerSliceIdx = mdmath_randi(0, numSlices-1);
			}
			
			int strt = mdmath_map(innerSliceIdx, 0, numSlices, 0, 128);
			int stop = strt + sliceLen;
			
			strt = mdmath_clamp(strt, 0, 127);
			stop = mdmath_clamp(stop, 0, 127);
			
			if(_sliceReverse > 0 && mdmath_rand(0, 1) <= _sliceReverse)
			{
				int tmp = strt;
				strt = stop;
				stop = tmp;
			}
			
			MDParameterLock *lock = [MDParameterLock lockForTrack:_trackIdx param:4 step:stepIdx value:strt];
			[self.pattern setLock:lock setTrigIfNone:YES];
			lock = [MDParameterLock lockForTrack:_trackIdx param:5 step:stepIdx value:stop];
			[self.pattern setLock:lock setTrigIfNone:YES];
			
			
			
			sliceIdx++;
			sliceIdx = mdmath_wrap(sliceIdx, 0, numSlices-1);
		}
		else
		{
			[self.pattern setTrigAtTrack:_trackIdx step:stepIdx toValue:YES];
		}
		
		if(_generatePitchLocks)
		{
			MDParameterLock *lock = [MDParameterLock lockForTrack:_trackIdx param:0 step:stepIdx value:_pitchVal];
			[self.pattern setLock:lock setTrigIfNone:YES];
		}
	}
}

@end
