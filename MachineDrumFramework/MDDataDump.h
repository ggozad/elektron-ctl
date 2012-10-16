//
//  MDDataDump.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 10/11/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDDataDump : NSObject
@property NSUInteger currentSnapshot;

+ (id) sharedInstance;
- (void) arm;
- (void) disarm;
- (NSURL *)currentSnapshotDirectory;
- (NSUInteger) numberOfSnapshots;
- (NSString *) snapshotDirectoryNameForSnapshotWithIndex:(NSUInteger)i;
- (NSString *) createNewSnapshotDirectory;
- (void) deleteSnapShotWithIndex:(NSUInteger)i;
- (NSArray *)filesInCurrentSnapshotForKey:(NSString *)s;
@end
