// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MDStoragePattern.h instead.

#import <CoreData/CoreData.h>


extern const struct MDStoragePatternAttributes {
	__unsafe_unretained NSString *lastModifiedDate;
	__unsafe_unretained NSString *slot;
	__unsafe_unretained NSString *sysexData;
} MDStoragePatternAttributes;

extern const struct MDStoragePatternRelationships {
	__unsafe_unretained NSString *snapshot;
} MDStoragePatternRelationships;

extern const struct MDStoragePatternFetchedProperties {
} MDStoragePatternFetchedProperties;

@class MDStorageSnapshot;





@interface MDStoragePatternID : NSManagedObjectID {}
@end

@interface _MDStoragePattern : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MDStoragePatternID*)objectID;




@property (nonatomic, strong) NSDate* lastModifiedDate;


//- (BOOL)validateLastModifiedDate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* slot;


@property int16_t slotValue;
- (int16_t)slotValue;
- (void)setSlotValue:(int16_t)value_;

//- (BOOL)validateSlot:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSData* sysexData;


//- (BOOL)validateSysexData:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) MDStorageSnapshot* snapshot;

//- (BOOL)validateSnapshot:(id*)value_ error:(NSError**)error_;





@end

@interface _MDStoragePattern (CoreDataGeneratedAccessors)

@end

@interface _MDStoragePattern (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveLastModifiedDate;
- (void)setPrimitiveLastModifiedDate:(NSDate*)value;




- (NSNumber*)primitiveSlot;
- (void)setPrimitiveSlot:(NSNumber*)value;

- (int16_t)primitiveSlotValue;
- (void)setPrimitiveSlotValue:(int16_t)value_;




- (NSData*)primitiveSysexData;
- (void)setPrimitiveSysexData:(NSData*)value;





- (MDStorageSnapshot*)primitiveSnapshot;
- (void)setPrimitiveSnapshot:(MDStorageSnapshot*)value;


@end
