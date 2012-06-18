//
//  MDTrack.m
//  sysexingApp
//
//  Created by Jakob Penca on 5/20/12.
//
//

#import "MDKitTrack.h"

@implementation MDKitTrack
@synthesize params, level, lfoSettings;

+ (id) trackWithIndex:(NSUInteger)index
{
	while (index > 15) index -= 16;
	MDKitTrack *track = [MDKitTrack new];
	track.index = index;
	track.lfoSettings.destinationTrack = [NSNumber numberWithInt:index];
	return track;
}

- (id)init
{
	if(self = [super init])
	{
		self.params = [MDKitTrackParams new];
		self.level = [NSNumber numberWithInt:100];
		self.drumModel = [NSNumber numberWithInt:0];
		self.lfoSettings = [MDKitLFOSettings new];
		self.trigGroup = -1;
		self.muteGroup = -1;
	}
	return self;
}

@end
