//
//  MDTrack.h
//  sysexingApp
//
//  Created by Jakob Penca on 5/20/12.
//
//

#import <Foundation/Foundation.h>
#import "MDKitTrackParams.h"
#import "MDKitLFOSettings.h"
#import "MDConstants.h"
#import "MDKitMachine.h"

@interface MDKitTrack : NSObject
@property (strong, nonatomic) MDKitTrackParams *params;
@property (strong, nonatomic) NSNumber *level;
@property MDMachineID machine;
@property (strong, nonatomic) MDKitLFOSettings *lfoSettings;
@property NSInteger trigGroup;
@property NSInteger muteGroup;
@property NSUInteger index;

+ (id) trackWithIndex:(NSUInteger)index;

@end
