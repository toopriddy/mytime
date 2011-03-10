// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTTerritoryStreet.h instead.

#import <CoreData/CoreData.h>


@class MTTerritory;
@class MTTerritoryHouse;





@interface MTTerritoryStreetID : NSManagedObjectID {}
@end

@interface _MTTerritoryStreet : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MTTerritoryStreetID*)objectID;



@property (nonatomic, retain) NSString *notes;

//- (BOOL)validateNotes:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *date;

//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) MTTerritory* territory;
//- (BOOL)validateTerritory:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSSet* houses;
- (NSMutableSet*)housesSet;




@end

@interface _MTTerritoryStreet (CoreDataGeneratedAccessors)

- (void)addHouses:(NSSet*)value_;
- (void)removeHouses:(NSSet*)value_;
- (void)addHousesObject:(MTTerritoryHouse*)value_;
- (void)removeHousesObject:(MTTerritoryHouse*)value_;

@end

@interface _MTTerritoryStreet (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveNotes;
- (void)setPrimitiveNotes:(NSString*)value;


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;


- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;




- (MTTerritory*)primitiveTerritory;
- (void)setPrimitiveTerritory:(MTTerritory*)value;



- (NSMutableSet*)primitiveHouses;
- (void)setPrimitiveHouses:(NSMutableSet*)value;


@end
