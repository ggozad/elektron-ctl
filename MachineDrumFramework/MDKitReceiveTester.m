//
//  MDKitReceiveTester.m
//  sysexingApp
//
//  Created by Jakob Penca on 6/14/12.
//
//

#import "MDKitReceiveTester.h"
#import "MDKit.h"
#import "MDKitParser.h"
#import "MDSysexUtil.h"

@interface MDKitReceiveTester()
- (void) handleKitReceivedNotification:(NSNotification *) notification;
@end


@implementation MDKitReceiveTester

- (id)init
{
	if(self = [super init])
	{
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handleKitReceivedNotification:)
													 name:kMDSysexKitDumpNotification
												   object:nil];
	}
	return self;
}

- (void)handleKitReceivedNotification:(NSNotification *)notification
{
	DLog(@"kit dump received.");
	
	NSData *data = notification.object;
	MDKit *kit = [MDKit kitWithData:data];
	
	NSData *newData = [kit sysexData];
	[MDSysexUtil compareData:data withData:newData];
}

@end
