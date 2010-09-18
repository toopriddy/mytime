// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTTerritory.h instead.

#import <CoreData/CoreData.h>


@class MTUser;
@class MTTerritoryStreet;









@interface MTTerritoryID : NSManagedObjectID {}
@end

@interface _MTTerritory : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MTTerritoryID*)objectID;



@property (nonatomic, retain) NSString *ownerEmailAddress;

//- (BOOL)validateOwnerEmailAddress:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *city;

//- (BOOL)validateCity:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *ownerEmailId;

//- (BOOL)validateOwnerEmailId:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *notes;

//- (BOOL)validateNotes:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *state;

//- (BOOL)validateState:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *ownerId;

//- (BOOL)validateOwnerId:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) MTUser* user;
//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSSet* streets;
- (NSMutableSet*)streetsSet;



@end

@interface _MTTerritory (CoreDataGeneratedAccessors)

- (void)addStreets:(NSSet*)value_;
- (void)removeStreets:(NSSet*)value_;
- (void)addStreetsObject:(MTTerritoryStreet*)value_;
- (void)removeStreetsObject:(MTTerritoryStreet*)value_;

@end

@interface _MTTerritory (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveOwnerEmailAddress;
- (void)setPrimitiveOwnerEmailAddress:(NSString*)value;


- (NSString*)primitiveCity;
- (void)setPrimitiveCity:(NSString*)value;


- (NSString*)primitiveOwnerEmailId;
- (void)setPrimitiveOwnerEmailId:(NSString*)value;


- (NSString*)primitiveNotes;
- (void)setPrimitiveNotes:(NSString*)value;


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;


- (NSString*)primitiveState;
- (void)setPrimitiveState:(NSString*)value;


- (NSString*)primitiveOwnerId;
- (void)setPrimitiveOwnerId:(NSString*)value;




- (MTUser*)primitiveUser;
- (void)setPrimitiveUser:(MTUser*)value;



- (NSMutableSet*)primitiveStreets;
- (void)setPrimitiveStreets:(NSMutableSet*)value;


@end
