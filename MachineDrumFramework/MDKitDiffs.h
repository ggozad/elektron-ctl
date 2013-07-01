//
//  MDKitDiffs.h
//  yolo
//
//  Created by Jakob Penca on 5/31/13.
//
//

#import <Foundation/Foundation.h>

@class MDKit;

@interface MDKitDiffs : NSObject
+ (MDKitDiffs *) diffsBetweenEarlierKit:(MDKit *)earlierKit laterKit:(MDKit *)laterKit;
+ (MDKitDiffs *) diffsWithData:(NSData *)d;
- (void) applyDiffsFromKit:(MDKit *)laterKit toKit:(MDKit *)earlierKit;
- (NSData *) data;
+ (NSUInteger) dataLength;
@end
