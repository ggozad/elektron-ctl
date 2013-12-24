//
//  A4SoundMorph.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 24/12/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A4Sound.h"
#import "A4Request.h"

typedef enum A4MorpherCompletionAction
{
	A4MorpherCompletionActionHold,
	A4MorpherCompletionActionApply,
	A4MorpherCompletionActionRevert
}
A4MorpherCompletionAction;

typedef enum A4MorpherMorphMode
{
	A4MorpherMorphModeTrackSound
}
A4MorpherMorphMode;

@class A4SoundMorph;
@protocol A4SoundMorphDelegate <NSObject>
- (void) a4SoundMorph:(A4SoundMorph *)morph didFetchTrackIdx:(uint8_t)trackIdx;
- (void) a4SoundMorph:(A4SoundMorph *)morph didUpdateProgress:(double)progress;
- (void) a4SoundMorph:(A4SoundMorph *)morph didFailWithError:(NSError *)error;
- (void) a4SoundMorph:(A4SoundMorph *)morph didReachEndWithAction:(A4MorpherCompletionAction)action;
@end

@interface A4SoundMorph : NSObject
@property (nonatomic, weak) id<A4SoundMorphDelegate> delegate;
@property (nonatomic) uint8_t targetIndex, trackIndex;
@property (nonatomic, readonly) double remainingTime;
@property (nonatomic, strong) A4Sound *originalSound, *targetSound, *intermediateSound;

- (void) beginWithMode:(A4MorpherMorphMode)mode target:(uint8_t)targetIdx time:(double)t completionAction:(A4MorpherCompletionAction)action;
- (void) setCompletionAction:(A4MorpherCompletionAction)action applyImmediately:(BOOL)immediately;
- (void) setNewTarget:(uint8_t)targetIdx additionalTime:(double)additionalTime;
- (void) setNewTarget:(uint8_t)targetIdx setTimeFromNow:(double)newTime;
- (void) update;

@end
