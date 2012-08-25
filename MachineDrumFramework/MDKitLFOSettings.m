//
//  MDLFOSettings.m
//  sysexingApp
//
//  Created by Jakob Penca on 5/20/12.
//
//

#import "MDKitLFOSettings.h"
#import "MDSysexUtil.h"

@implementation MDKitLFOSettings
@synthesize destinationTrack, destinationParam, shape1, shape2, type;


- (id)init
{
    self = [super init];
    if (self)
	{
        self.type = MD_LFO_TYPE_FREE;
		self.destinationTrack = [NSNumber numberWithInt:0];
		self.destinationParam = [NSNumber numberWithInt:0];
		self.shape1 = [NSNumber numberWithInt:0];
		self.shape2 = [NSNumber numberWithInt:0];
		
		self.internalState = [MDSysexUtil dataFromHexString:@"00000000000000000000000000000000000000000000000000029a00000000"];
    }
    return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@\ntype:%d\ndest:%d\nshp1:%d\nshp2:%d\ninternalstate:%@",
			
			[super description],
			self.type,
			self.destinationTrack.intValue,
			self.shape1.intValue,
			self.shape2.intValue,
			self.internalState
			];
}


@end
