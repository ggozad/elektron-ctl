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

typedef enum A4MorpherMorphMode
{
	A4MorpherMorphModeTrackSound
}
A4MorpherMorphMode;

typedef struct A4MorpherMorphID
{
	A4MorpherMorphMode mode;
	A4RequestHandle handle;
	uint8_t targetIndex;
}
A4MorpherMorphID;

@class A4SoundMorph;
@protocol A4SoundMorphDelegate <NSObject>
- (void) a4SoundMorph:(A4SoundMorph *)morph didFetchTrackIdx:(uint8_t)trackIdx;
- (void) a4SoundMorph:(A4SoundMorph *)morph didUpdateProgress:(double)progress;
- (void) a4SoundMorph:(A4SoundMorph *)morph didFailWithError:(NSError *)error;
- (void) a4SoundMorphDidBegin:(A4SoundMorph *)morph;
- (void) a4SoundMorphDidApply:(A4SoundMorph *)morph;
- (void) a4SoundMorphDidRevert:(A4SoundMorph *)morph;
@end

@interface A4SoundMorph : NSObject
@property (nonatomic, weak) id<A4SoundMorphDelegate> delegate;
@property (nonatomic) A4MorpherMorphID id;
@property (nonatomic) uint8_t targetIndex;
@property (nonatomic, strong) A4Sound *originalSound;
@property (nonatomic) uint8_t trackIndex;

- (A4MorpherMorphID) beginWithMode:(A4MorpherMorphMode)mode target:(uint8_t)targetIdx time:(double)t;
- (void) revert;
- (void) applyImmediately:(BOOL)immediately;
- (void) modifyNewTarget:(uint8_t)targetIdx additionalTime:(double)additionalTime;
- (void) update;

@end
