// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MDStorageGlobal.m instead.

#import "_MDStorageGlobal.h"

const struct MDStorageGlobalAttributes MDStorageGlobalAttributes = {
	.lastModifiedDate = @"lastModifiedDate",
	.slot = @"slot",
	.sysexData = @"sysexData",
};

const struct MDStorageGlobalRelationships MDStorageGlobalRelationships = {
	.snapshot = @"snapshot",
};

const struct MDStorageGlobalFetchedProperties MDStorageGlobalFetchedProperties = {
};

@implementation MDStorageGlobalID
@end

@implementation _MDStorageGlobal

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MDStorageGlobal" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MDStorageGlobal";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MDStorageGlobal" inManagedObjectContext:moc_];
}

- (MDStorageGlobalID*)objectID {
	return (MDStorageGlobalID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"slotValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"slot"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic lastModifiedDate;






@dynamic slot;



- (int16_t)slotValue {
	NSNumber *result = [self slot];
	return [result shortValue];
}

- (void)setSlotValue:(int16_t)value_ {
	[self setSlot:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveSlotValue {
	NSNumber *result = [self primitiveSlot];
	return [result shortValue];
}

- (void)setPrimitiveSlotValue:(int16_t)value_ {
	[self setPrimitiveSlot:[NSNumber numberWithShort:value_]];
}





@dynamic sysexData;






@dynamic snapshot;

	






@end
