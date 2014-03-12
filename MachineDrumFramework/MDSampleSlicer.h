//
//  MDSampleSlicer.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 02/03/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDPattern.h"

typedef enum MDSampleSlicerDirection
{
	MDSamplerSlicerDirectionForward,
	MDSamplerSlicerDirectionBackward
}
MDSamplerSlicerDirection;

@interface MDSampleSlicer : NSObject
@property (nonatomic) BOOL generateSliceLocks, generatePitchLocks;
@property (nonatomic) uint8_t pitchVal;
@property (nonatomic) uint8_t offset;
@property (nonatomic) uint8_t trackIdx;
@property (nonatomic) uint8_t stepInterval;
@property (nonatomic) uint8_t length, sampleLength;
@property (nonatomic) float randomPlacement;
@property (nonatomic) float sliceReverse;
@property (nonatomic) MDSamplerSlicerDirection direction;
@property (nonatomic, strong) MDPattern *pattern;
- (void) slice;
@end
