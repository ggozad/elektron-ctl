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


@class A4MorpherController;
@protocol A4MorpherControllerDelegate <NSObject>
@optional
-(void) a4morpher:(A4MorpherController *)morpher didPostMessage:(NSString *)msg;
@end

@interface A4MorpherController : NSObject
@property (nonatomic, weak) id<A4MorpherControllerDelegate> delegate;
@property (nonatomic) NSInteger track;

- (void) pushTarget:(uint8_t)targetIdx apply:(BOOL)apply;
- (void) popTarget:(uint8_t)target revertTo:(uint8_t)earlierTarget;
- (void) revertToOriginal;

@end
