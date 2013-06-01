//
//  MDStorage.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 11/6/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDStorageGlobal.h"
#import "MDStorageSnapshot.h"
#import "MDStoragePattern.h"

#define kMDStorageSnapshotString @"MDStorageSnapshot"
#define kMDStorageGlobalString @"MDStorageGlobal"
#define kMDStoragePatternString @"MDStoragePattern"

@interface NSManagedObjectContext(insert)
-(NSManagedObject *) insertNewEntityWithName:(NSString *)name;
@end


@interface MDStorage : NSObject
@property (strong, nonatomic) NSManagedObjectContext *mainContext;
+ (MDStorage *) sharedInstance;
- (void) setup;
- (void) save;
- (void) numberOfSnapshotsWithCompletionBlock:(void (^)(NSUInteger i))block;
- (void) fetchAllSnapshotsWithCompletionBlock:(void (^)(NSArray *results)) block;
- (void) fetchFirstGlobalWithCompletionBlock:(void (^)(NSManagedObject *result)) block;
- (void) fetchFirstPatternWithCompletionBlock:(void (^)(NSManagedObject *result))block;
- (void) fetchPatterninSnapshot:(MDStorageSnapshot *)s withIndex:(NSUInteger)i withCompletionBlock:(void (^)(MDStoragePattern *result))block;
@end
