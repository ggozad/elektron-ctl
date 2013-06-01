//
//  MDStorage.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 11/6/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDStorage.h"

@implementation NSManagedObjectContext(insert)
-(NSManagedObject *) insertNewEntityWithName:(NSString *)name
{
    return [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:self];
}
@end

@interface MDStorage()
@property (strong, nonatomic) NSPersistentStoreCoordinator *storeCoordinator;
@property (strong, nonatomic) NSManagedObjectContext *backgroundWriterContext;
@end

@implementation MDStorage

MDStorage *_default = nil;
+ (MDStorage *) sharedInstance
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
	if(self = [super init])
	{
		[self setup];
	}
	return self;
}

- (void)numberOfSnapshotsWithCompletionBlock:(void (^)(NSUInteger i))block
{
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kMDStorageSnapshotString];
	request.includesSubentities = NO;
	request.includesPendingChanges = NO;
	
	NSManagedObjectContext *tmp = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
	tmp.parentContext = self.mainContext;
	[tmp performBlock:^{
		
		NSError *err = nil;
		NSUInteger i =  [tmp countForFetchRequest:request error:&err];
		if(err)
		{
			DLog(@"err: %@", [err description]);
			abort();
		}
		block(i);
		[tmp reset];
	}];
}

- (void) fetchAllSnapshotsWithCompletionBlock:(void (^)(NSArray *results)) block
{
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kMDStorageSnapshotString];
	request.includesSubentities = NO;
	request.includesPendingChanges = YES;
	
	NSManagedObjectContext *tmp = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
	tmp.parentContext = self.mainContext;
	[tmp performBlock:^{
		
		NSError *err = nil;
		NSArray *results = [tmp executeFetchRequest:request error:&err];
		if(err)
		{
			DLog(@"err %@", [err description]);
			abort();
		}
		block(results);
		//[tmp reset];
	}];
}

- (void)fetchFirstGlobalWithCompletionBlock:(void (^)(NSManagedObject *result))block
{
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kMDStorageGlobalString];
	request.includesPropertyValues = YES;
	request.includesPendingChanges = YES;
	request.includesSubentities = YES;
	request.fetchLimit = 1;
	request.returnsObjectsAsFaults = NO;
	
	NSManagedObjectContext *tmp = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
	tmp.parentContext = self.mainContext;
	[tmp performBlock:^{
		
		NSError *err = nil;
		MDStorageGlobal *g = [[tmp executeFetchRequest:request error:&err] objectAtIndex:0];
		if(err)
		{
			DLog(@"err: %@", [err description]);
		}
		block(g);
		
	}];
}

- (void) fetchPatterninSnapshot:(MDStorageSnapshot *)s withIndex:(NSUInteger)i withCompletionBlock:(void (^)(MDStoragePattern *result))block
{
	NSFetchRequest *r = [NSFetchRequest fetchRequestWithEntityName:kMDStoragePatternString];
	r.includesPendingChanges = YES;
	r.includesPropertyValues = YES;
	r.includesSubentities = YES;
	r.fetchLimit = 1;
	r.returnsObjectsAsFaults = NO;
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"snapshot == %@ AND slot == %d", s, i];
	[r setPredicate:predicate];
	
	NSManagedObjectContext *tmp = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
	tmp.parentContext = self.mainContext;
	[tmp performBlock:^{
		
		NSError *err = nil;
		MDStoragePattern *p = nil;
		NSArray *results = [tmp executeFetchRequest:r error:&err];
		if(err)
		{
			DLog(@"err: %@", [err description]);
		}
		
		if([results count])
			p = [results objectAtIndex:0];
		block(p);
	}];
}

- (void)fetchFirstPatternWithCompletionBlock:(void (^)(NSManagedObject *result))block
{
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kMDStoragePatternString];
	request.includesPropertyValues = YES;
	request.includesPendingChanges = YES;
	request.includesSubentities = YES;
	request.fetchLimit = 1;
	request.returnsObjectsAsFaults = NO;
	
	NSManagedObjectContext *tmp = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
	tmp.parentContext = self.mainContext;
	[tmp performBlock:^{
		
		NSError *err = nil;
		MDStoragePattern *p = [[tmp executeFetchRequest:request error:&err] objectAtIndex:0];
		if(err)
		{
			DLog(@"err: %@", [err description]);
		}
		block(p);
		
	}];
}



- (void)setup
{
	NSURL *url = [[NSBundle mainBundle] URLForResource:@"MDStorageModel" withExtension:@"mom"];
	NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentPath = [searchPaths objectAtIndex:0];
	NSURL *storeURL = [NSURL fileURLWithPath:documentPath];
	storeURL = [storeURL URLByAppendingPathComponent:@"database.sqlite"];
	NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
	self.storeCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
	
	NSError *err = nil;
	[self.storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType
										configuration:nil
												  URL:storeURL
											  options:nil
												error:&err];
	if(err)
	{
		DLog(@"err: %@", [err description]);
		abort();
	}
	
	
	self.backgroundWriterContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
	self.backgroundWriterContext.persistentStoreCoordinator = self.storeCoordinator;
	self.mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	self.mainContext.parentContext = self.backgroundWriterContext;
}

- (void) save
{
	if(!self.mainContext.hasChanges)
	{
		DLog(@"nothing to save");
		return;
	}
	NSError *err = nil;
	DLog(@"saving main context");
	[self.mainContext save:&err];
	if(err)
	{
		DLog(@"err: %@", [err description]);
		abort();
	}
	[self.backgroundWriterContext performBlock:^{
		
		NSError *err = nil;
		DLog(@"writing to disk");
		[self.backgroundWriterContext save:&err];
		if(err)
		{
			DLog(@"err: %@", [err description]);
			abort();
		}
		[self.backgroundWriterContext reset];
		DLog(@"done");
	}];
	[self.mainContext reset];
	
}

@end
