// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MDStoragePattern.m instead.

#import "_MDStoragePattern.h"

const struct MDStoragePatternAttributes MDStoragePatternAttributes = {
	.lastModifiedDate = @"lastModifiedDate",
	.slot = @"slot",
	.sysexData = @"sysexData",
};

const struct MDStoragePatternRelationships MDStoragePatternRelationships = {
	.snapshot = @"snapshot",
};

const struct MDStoragePatternFetchedProperties MDStoragePatternFetchedProperties = {
};

@implementation MDStoragePatternID
@end

@implementation _MDStoragePattern

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MDStoragePattern" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MDStoragePattern";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MDStoragePattern" inManagedObjectContext:moc_];
}

- (MDStoragePatternID*)objectID {
	return (MDStoragePatternID*)[super objectID];
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
