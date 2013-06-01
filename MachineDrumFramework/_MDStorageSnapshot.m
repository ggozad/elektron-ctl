// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MDStorageSnapshot.m instead.

#import "_MDStorageSnapshot.h"

const struct MDStorageSnapshotAttributes MDStorageSnapshotAttributes = {
	.lastModifiedDate = @"lastModifiedDate",
	.name = @"name",
};

const struct MDStorageSnapshotRelationships MDStorageSnapshotRelationships = {
	.globals = @"globals",
	.patterns = @"patterns",
};

const struct MDStorageSnapshotFetchedProperties MDStorageSnapshotFetchedProperties = {
};

@implementation MDStorageSnapshotID
@end

@implementation _MDStorageSnapshot

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MDStorageSnapshot" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MDStorageSnapshot";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MDStorageSnapshot" inManagedObjectContext:moc_];
}

- (MDStorageSnapshotID*)objectID {
	return (MDStorageSnapshotID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic lastModifiedDate;






@dynamic name;






@dynamic globals;

	
- (NSMutableOrderedSet*)globalsSet {
	[self willAccessValueForKey:@"globals"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"globals"];
  
	[self didAccessValueForKey:@"globals"];
	return result;
}
	

@dynamic patterns;

	
- (NSMutableOrderedSet*)patternsSet {
	[self willAccessValueForKey:@"patterns"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"patterns"];
  
	[self didAccessValueForKey:@"patterns"];
	return result;
}
	






@end
