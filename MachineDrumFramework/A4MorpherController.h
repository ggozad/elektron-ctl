//
//  A4Morpher.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 24/12/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A4Request.h"
#import "A4Sound.h"
#import "A4SoundMorph.h"


@class A4MorpherController;
@protocol A4MorpherControllerDelegate <NSObject>
- (void) a4MorpherController:(A4MorpherController *)controller morphDidBegin:(A4SoundMorph *)morph;
- (void) a4MorpherController:(A4MorpherController *)controller morphDidRevert:(A4SoundMorph *)morph;
- (void) a4MorpherController:(A4MorpherController *)controller morphDidApply:(A4SoundMorph *)morph;
- (void) a4MorpherController:(A4MorpherController *)controller morph:(A4SoundMorph *)morph didUpdateProgress:(double)progress;
- (void) a4MorpherController:(A4MorpherController *)controller morph:(A4SoundMorph *)morph didFetchTrackIdx:(uint8_t)trackIdx;
- (void)a4MorpherController:(A4MorpherController *)controller morph:(A4SoundMorph *)morph didFailWithError:(NSError *)error;
@end

@interface A4MorpherController : NSObject <A4SoundMorphDelegate>
@property (nonatomic, weak) id<A4MorpherControllerDelegate> delegate;
- (A4MorpherMorphID) beginMorphWithMode:(A4MorpherMorphMode)mode target:(uint8_t)targetIdx time:(double)t;
- (void) revertMorphWithHandle:(A4MorpherMorphID)id;
- (void) applyMorphWithHandle:(A4MorpherMorphID)id immediately:(BOOL)immediately;
- (void) modifyMorphWithHandle:(A4MorpherMorphID)handle newTarget:(uint8_t)targetIdx additionalTime:(double)additionalTime;
- (void) updateMorphs;
@end
