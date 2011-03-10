// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTTerritoryHouseAttempt.h instead.

#import <CoreData/CoreData.h>


@class MTTerritoryHouse;



@interface MTTerritoryHouseAttemptID : NSManagedObjectID {}
@end

@interface _MTTerritoryHouseAttempt : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MTTerritoryHouseAttemptID*)objectID;



@property (nonatomic, retain) NSDate *date;

//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) MTTerritoryHouse* house;
//- (BOOL)validateHouse:(id*)value_ error:(NSError**)error_;




@end

@interface _MTTerritoryHouseAttempt (CoreDataGeneratedAccessors)

@end

@interface _MTTerritoryHouseAttempt (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;





- (MTTerritoryHouse*)primitiveHouse;
- (void)setPrimitiveHouse:(MTTerritoryHouse*)value;


@end
