//
//  MDProcessingPipeline.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 6/25/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDProcessingPipeline.h"

@interface MDProcessingPipeline()
@property (nonatomic, strong) MDPatternPublicWrapper *patternCopy;
@property (nonatomic, strong) MDKit *kitCopy;
@end




@implementation MDProcessingPipeline

- (void)process
{
	if(!self.pattern)
	{
		DLog(@"no pattern!");
		return;
	}
	
	if(!self.kit)
	{
		DLog(@"no kit!");
		return;
	}
	self.patternCopy = [MDPatternPublicWrapper patternWithPattern:self.pattern];
	self.kitCopy = [MDKit kitWithKit:self.kit];
	
	for (id p in self.procedures)
	{
		if([p isKindOfClass: [MDProc class]])
			[(MDProc *)p processPattern:self.patternCopy kit:self.kitCopy];
	}
}

- (MDKit *)resultKit
{
	return self.kitCopy;
}

- (MDPatternPublicWrapper *)resultPattern
{
	return self.patternCopy;
}

@end
