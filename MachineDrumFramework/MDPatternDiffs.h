//
//  MDPatternDiffs.h
//  yolo
//
//  Created by Jakob Penca on 5/30/13.
//
//

#import <Foundation/Foundation.h>

@class MDPattern;

@interface MDPatternDiffs : NSObject
@property (strong, nonatomic) MDPattern *insertions, *deletions, *earlierPattern, *laterPattern;
+ (MDPatternDiffs *) diffsWithData:(NSData *)data;
+ (MDPatternDiffs *) diffsBetweenEarlierPattern:(MDPattern *)earlierPattern laterPattern:(MDPattern *)laterPattern;
- (void) applyToEarlierPattern;
- (NSData *)data;
+ (NSUInteger) dataLength;
@end
