//
//  MDDataDump.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 10/11/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDDataDump.h"
#import "MDMachinedrumPublic.h"

@implementation MDDataDump

static MDDataDump *_default = nil;
+ (id)sharedInstance
{
	if(_default != nil) return _default;
	static dispatch_once_t safer;
	dispatch_once(&safer, ^(void)
				  {
					  _default = [[self alloc] init];
				  });
	return _default;
}

- (id)init
{
	if(_default)return _default;
	if(self = [super init])
	{
		[self registerForNotifications];
	}
	return self;
}

- (void)dealloc
{
	[self unRegisterForNotifications];
}

- (void)registerForNotifications
{
	NSNotificationCenter *c = [NSNotificationCenter defaultCenter];
	[c addObserver:self selector:@selector(handlePattern:) name:kMDSysexPatternDumpNotification object:nil];
	[c addObserver:self selector:@selector(handleKit:) name:kMDSysexKitDumpNotification object:nil];
	[c addObserver:self selector:@selector(handleSettings:) name:kMDSysexGlobalSettingsDumpNotification object:nil];
}

-(void) unRegisterForNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) handlePattern:(NSNotification *)n
{
	NSData *d = n.object;
	MDPattern *pattern = [MDPattern patternWithData:d];
	if(pattern)
	{
		NSString *fileName = [NSString stringWithFormat:@"%03d_pattern.syx", pattern.savePosition];
		[self writeSyxData:d toFolderNamed:@"patterns" fileNamed:fileName];
	}
}

- (void) handleKit:(NSNotification *)n
{
	NSData *d = n.object;
	MDKit *kit = [MDKit kitWithData:d];
	if(kit)
	{
		NSString *fileName = [NSString stringWithFormat:@"%02d_kit.syx", kit.originalPosition];
		[self writeSyxData:d toFolderNamed:@"kits" fileNamed:fileName];
	}
}

- (void) handleSettings:(NSNotification *)n
{
	NSData *d = n.object;
	MDMachinedrumGlobalSettings *settings = [MDMachinedrumGlobalSettings globalSettingsWithData:d];
	if(settings)
	{
		NSString *fileName = [NSString stringWithFormat:@"%02d_globalSettings.syx", settings.originalPosition];
		[self writeSyxData:d toFolderNamed:@"settings" fileNamed:fileName];
	}
}

- (void) writeSyxData:(NSData *)syx toFolderNamed:(NSString *)folder fileNamed:(NSString *)fileName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSURL *url = [NSURL URLWithString:documentsDirectory];
	url = [url URLByAppendingPathComponent:@"dump2"];
	url = [url URLByAppendingPathComponent:folder];
	url = [url URLByAppendingPathComponent:fileName];
	
	NSError *err = nil;
	[syx writeToFile:[url path] options:NSDataWritingAtomic error:&err];
	if(err)DLog(@"error: %@", [err localizedDescription]);
}


@end
