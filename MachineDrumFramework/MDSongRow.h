//
//  MDSongRow.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 6/30/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum MDSongRowPatternPosition
{
	MDSongRowPatternPositionEnd = -1,
	MDSongRowPatternPositionJumpHaltEnd = -2,
	MDSongRowPatternPositionRemark = -3
}
MDSongRowPatternPosition;

@interface MDSongRow : NSObject
@property (nonatomic) MDSongRowPatternPosition pattern;
@property (nonatomic) uint8_t kit;
@property (nonatomic) uint8_t loopCount;
@property (nonatomic) uint8_t rowJump;
@property (nonatomic) uint16_t mutes;
@property (nonatomic) float tempo;
@property (nonatomic) uint8_t start, stop;


+ (MDSongRow *)songRowWithSongRow:(MDSongRow *)songRow;
- (BOOL) isTrackMuted:(uint8_t)track;
- (void) setTrack:(uint8_t)track muted:(BOOL)muted;
@end
