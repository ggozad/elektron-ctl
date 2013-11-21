//
//  A4Project.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 9/28/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A4Pattern.h"
#import "A4Kit.h"
#import "A4SysexMessage.h"

@interface A4Project : A4SysexMessage
@property (nonatomic) BOOL autoReceiveEnabled;

+ (instancetype)defaultProject;

- (A4Sound *) soundAsCopyAtStep:(uint8_t)step inTrack:(uint8_t)track forPattern:(uint8_t)i;

- (int8_t)indexOfFirstDefaultSound;
- (A4Sound *) soundAtPosition:(uint8_t) i;
- (A4Sound *) soundAtPosition:(uint8_t) i copy:(BOOL)copy;
- (A4Sound *) copySound:(A4Sound *)sound toPosition:(uint8_t)i;
- (A4Sound *) copySoundToFirstUnusedPosition:(A4Sound *)sound;
- (BOOL) soundAtIndexIsLockedFromAnyPattern:(uint8_t)i;
- (NSArray *) patternIndicesLockingSoundAtIndex:(uint8_t) i;

- (int8_t) indexOfFirstDefaultKit;
- (A4Kit *) kitAtPosition:(uint8_t) i;
- (A4Kit *) kitAtPosition:(uint8_t) i copy:(BOOL)copy;
- (A4Kit *) copyKit:(A4Kit *)kit toPosition:(uint8_t)i;
- (A4Kit *) copyKitToFirstUnusedPosition:(A4Kit *)kit;
- (BOOL) kitAtIndexIsLinkedFromAnyPattern:(uint8_t) i;
- (NSArray *) patternIndicesLinkingToKitAtIndex:(uint8_t) i;

- (int8_t) indexOfFirstDefaultPattern;
- (A4Pattern *) patternAtPosition:(uint8_t) i;
- (A4Pattern *) patternAtPosition:(uint8_t) i copy:(BOOL)copy;
- (A4Pattern *) copyPattern:(A4Pattern *)pattern toPosition:(uint8_t)i;
- (A4Pattern *) copyPatternToFirstUnusedPosition:(A4Pattern *)pattern;

@end
