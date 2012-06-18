//
//  MDPatternReceiveTester.m
//  sysexingApp
//
//  Created by Jakob Penca on 6/14/12.
//
//

#import "MDPatternReceiveTester.h"
#import "MDPattern.h"
#import "MDSysexUtil.h"

@interface MDPatternReceiveTester()
- (void) handlePatternReceivedNotification:(NSNotification *)notification;
@end

@implementation MDPatternReceiveTester

- (id)init
{
	if(self = [super init])
	{
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handlePatternReceivedNotification:)
													 name:kMDSysexPatternDumpNotification
												   object:nil];
	}
	return self;
}

- (void)handlePatternReceivedNotification:(NSNotification *)notification
{
	DLog(@"pattern dump received.");
	NSData *data = notification.object;
	
	MDPattern *p = [MDPattern patternWithData:data];
	NSData *repack = [p sysexData];
	
	BOOL same = [MDSysexUtil compareData:data withData:repack];
	DLog(@"hydrate/dehydrate %@.", same ? @"successful" : @"failed");
}

@end
