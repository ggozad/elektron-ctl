//
//  MDLFOSettings.h
//  sysexingApp
//
//  Created by Jakob Penca on 5/20/12.
//
//

#import <Foundation/Foundation.h>

typedef enum MDLFOType
{
	MD_LFO_TYPE_FREE = 0,
	MD_LFO_TYPE_TRIG = 1,
	MD_LFO_TYPE_HOLD = 2
}MDLFOType;

@interface MDKitLFOSettings : NSObject
@property (strong, nonatomic) NSNumber *destinationTrack;
@property (strong, nonatomic) NSNumber *destinationParam;
@property (strong, nonatomic) NSNumber *shape1;
@property (strong, nonatomic) NSNumber *shape2;
@property (strong, nonatomic) NSData *internalState;
@property MDLFOType type;
@end
