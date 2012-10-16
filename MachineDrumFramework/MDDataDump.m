//
//  MDDataDump.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 10/11/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDDataDump.h"
#import "MDMachinedrumPublic.h"

@interface MDDataDump()
@property BOOL armed;
@end

@implementation MDDataDump

- (void)arm
{
	if(self.armed) return;
	[self registerForNotifications];
	self.armed = YES;
	DLog(@"armed");
}

- (void)disarm
{
	if(!self.armed)return;
	self.armed = NO;
	[self unRegisterForNotifications];
	DLog(@"disarmed");
}

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
		//[self registerForNotifications];
	}
	return self;
}

- (void)dealloc
{
	//[self unRegisterForNotifications];
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
		[self writeSyxData:d toFolderNamed:@"globals" fileNamed:fileName];
	}
}

- (NSURL *)currentSnapshotDirectory
{
	return [[self sortedSnapshots] objectAtIndex:self.currentSnapshot];
}

- (void) writeSyxData:(NSData *)syx toFolderNamed:(NSString *)folder fileNamed:(NSString *)fileName
{
	NSArray *urls = [self sortedSnapshots];
	if(self.currentSnapshot >= [urls count])
	{
		DLog(@"memememehh");
		return;
	}
	NSURL *url = [[self sortedSnapshots] objectAtIndex:self.currentSnapshot];
	url = [url URLByAppendingPathComponent:folder];
	url = [url URLByAppendingPathComponent:fileName];
	
	NSError *err = nil;
	[syx writeToFile:[url path] options:NSDataWritingAtomic error:&err];
	DLog(@"current snsapshot: %d", self.currentSnapshot);
	DLog(@"%@", [url path]);
	
	if(err)
	{
		DLog(@"error: %@", [err localizedDescription]);
	}
	else
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:kMDDataDumpDidWriteFileNotification object:url];
	}
		
}

- (NSUInteger)numberOfSnapshots
{
	NSURL *snapshotsDirectory = [self snapshotsDirectory];
	if(snapshotsDirectory)
	{
		NSError *err = nil;
		NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:snapshotsDirectory
													   includingPropertiesForKeys:nil
																		  options:0
																			error:&err];
		
		if(err)
		{
			DLog(@"can't do shit");
			return 0;
		}
		DLog(@"%d", [items count]);
		return [items count];
	}
	return 0;
}

- (NSURL *) snapshotsDirectory
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSURL *url = [NSURL fileURLWithPath:documentsDirectory];
	url = [url URLByAppendingPathComponent:@"snapshots"];
	
	NSError * error = nil;
	[[NSFileManager defaultManager] createDirectoryAtURL:url
							  withIntermediateDirectories:YES
											   attributes:nil
													error:&error];
	if(error)
	{
		DLog(@"error creating directory: %@", error);
		return nil;
	}
	
	return url;
}

- (NSString *)createNewSnapshotDirectory
{
	NSURL *snapshotDirectory = [self snapshotsDirectory];
	NSString *dirName = [NSString stringWithFormat:@"%03ld", [self numberOfSnapshots]];
	snapshotDirectory = [self createDirectoryNamed: dirName atURL:snapshotDirectory];
	if(snapshotDirectory)
	{
		[self createDirectoryNamed:@"kits" atURL:snapshotDirectory];
		[self createDirectoryNamed:@"patterns" atURL:snapshotDirectory];
		[self createDirectoryNamed:@"songs" atURL:snapshotDirectory];
		[self createDirectoryNamed:@"globals" atURL:snapshotDirectory];
		[self createDirectoryNamed:@"samples" atURL:snapshotDirectory];
		return dirName;
	}
	return nil;
}

- (void) deleteSnapShotWithIndex:(NSUInteger)i
{
	NSArray *snapshots = [self sortedSnapshots];
	if(i >= [snapshots count]) return;
	
	NSError *err = nil;
	[[NSFileManager defaultManager] removeItemAtURL:[snapshots objectAtIndex:i] error:&err];
	if(err)
	{
		DLog(@"error deleting snapshot: %@", err);
	}
}

- (NSURL *) createDirectoryNamed:(NSString *)dir atURL:(NSURL *)url
{
	url = [url URLByAppendingPathComponent:dir];
	NSError * error = nil;
	[[NSFileManager defaultManager] createDirectoryAtURL:url
							 withIntermediateDirectories:YES
											  attributes:nil
												   error:&error];
	if(error)
	{
		DLog(@"error creating directory named %@: %@", dir, error);
		return nil;
	}
	DLog(@"created: %@", url);
	return url;
}

- (NSString *)snapshotDirectoryNameForSnapshotWithIndex:(NSUInteger)i
{
	NSArray *items = [self sortedSnapshots];
	if(i >= [items count]) return nil;
	return [[items objectAtIndex:i] lastPathComponent];
}

- (NSArray *) sortedSnapshots
{
	NSError *err = nil;
	NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[self snapshotsDirectory]
												   includingPropertiesForKeys:nil
																	  options:NSDirectoryEnumerationSkipsHiddenFiles
																		error:&err];
	
	if(err)
	{
		DLog(@"can't do shit");
		return nil;
	}
	
	items = [items sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
			 {
				 NSString *s1 = [obj1 lastPathComponent];
				 NSString *s2 = [obj2 lastPathComponent];
				 
				 if([s1 integerValue] < [s2 integerValue]) return NSOrderedDescending;
				 if([s1 integerValue] > [s2 integerValue]) return NSOrderedAscending;
				 return NSOrderedSame;
			 }];
	
	return items;
}

- (NSArray *)filesInCurrentSnapshotForKey:(NSString *)s
{
	NSArray *items = [self sortedSnapshots];
	if(self.currentSnapshot >= [items count]) return nil;
	
	NSURL *snapshot = [items objectAtIndex:self.currentSnapshot];
	snapshot = [snapshot URLByAppendingPathComponent:s];
	
	DLog(@"%@", snapshot);
	
	NSError *err = nil;
	items = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:snapshot
												   includingPropertiesForKeys:nil
																	  options:NSDirectoryEnumerationSkipsHiddenFiles
																		error:&err];
	
	if(err)
	{
		DLog(@"can't do shit.. %@", snapshot);
		return nil;
	}
	
	return items;
}


@end
