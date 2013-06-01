// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MDStorageSnapshot.h instead.

#import <CoreData/CoreData.h>


extern const struct MDStorageSnapshotAttributes {
	__unsafe_unretained NSString *lastModifiedDate;
	__unsafe_unretained NSString *name;
} MDStorageSnapshotAttributes;

extern const struct MDStorageSnapshotRelationships {
	__unsafe_unretained NSString *globals;
	__unsafe_unretained NSString *patterns;
} MDStorageSnapshotRelationships;

extern const struct MDStorageSnapshotFetchedProperties {
} MDStorageSnapshotFetchedProperties;

@class MDStorageGlobal;
@class MDStoragePattern;




@interface MDStorageSnapshotID : NSManagedObjectID {}
@end

@interface _MDStorageSnapshot : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MDStorageSnapshotID*)objectID;




@property (nonatomic, strong) NSDate* lastModifiedDate;


//- (BOOL)validateLastModifiedDate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSOrderedSet* globals;

- (NSMutableOrderedSet*)globalsSet;




@property (nonatomic, strong) NSOrderedSet* patterns;

- (NSMutableOrderedSet*)patternsSet;





@end

@interface _MDStorageSnapshot (CoreDataGeneratedAccessors)

- (void)addGlobals:(NSOrderedSet*)value_;
- (void)removeGlobals:(NSOrderedSet*)value_;
- (void)addGlobalsObject:(MDStorageGlobal*)value_;
- (void)removeGlobalsObject:(MDStorageGlobal*)value_;

- (void)addPatterns:(NSOrderedSet*)value_;
- (void)removePatterns:(NSOrderedSet*)value_;
- (void)addPatternsObject:(MDStoragePattern*)value_;
- (void)removePatternsObject:(MDStoragePattern*)value_;

@end

@interface _MDStorageSnapshot (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveLastModifiedDate;
- (void)setPrimitiveLastModifiedDate:(NSDate*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (NSMutableOrderedSet*)primitiveGlobals;
- (void)setPrimitiveGlobals:(NSMutableOrderedSet*)value;



- (NSMutableOrderedSet*)primitivePatterns;
- (void)setPrimitivePatterns:(NSMutableOrderedSet*)value;


@end
