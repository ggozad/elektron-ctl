//
//  MDPattern.m
//  sysexingApp
//
//  Created by Jakob Penca on 6/14/12.
//
//

#import "MDPattern.h"
#import "MDPatternParser.h"

@implementation MDPattern

- (id)init
{
	if(self = [super init])
	{
		self.tracks = [NSArray arrayWithObjects:
					  [MDPatternTrack new],
					  [MDPatternTrack new],
					  [MDPatternTrack new],
					  [MDPatternTrack new],
					  
					  [MDPatternTrack new],
					  [MDPatternTrack new],
					  [MDPatternTrack new],
					  [MDPatternTrack new],
					  
					  [MDPatternTrack new],
					  [MDPatternTrack new],
					  [MDPatternTrack new],
					  [MDPatternTrack new],
					  
					  [MDPatternTrack new],
					  [MDPatternTrack new],
					  [MDPatternTrack new],
					  [MDPatternTrack new],
					  nil];
		
		self.locks = [MDPatternParameterLocks new];
		self.locks.pattern = self;
	}
	return self;
}

+ (id)patternWithData:(NSData *)data
{
	return [MDPatternParser patternFromSysexData:data];
}

- (NSData *)sysexData
{
	return [MDPatternParser sysexDataFromPattern:self];
}

@end
