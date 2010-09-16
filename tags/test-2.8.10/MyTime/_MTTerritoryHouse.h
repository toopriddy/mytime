// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTTerritoryHouse.h instead.

#import <CoreData/CoreData.h>


@class MTTerritoryStreet;






@interface MTTerritoryHouseID : NSManagedObjectID {}
@end

@interface _MTTerritoryHouse : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MTTerritoryHouseID*)objectID;



@property (nonatomic, retain) NSString *notes;

//- (BOOL)validateNotes:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *number;

//- (BOOL)validateNumber:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *apartment;

//- (BOOL)validateApartment:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *attempts;

@property short attemptsValue;
- (short)attemptsValue;
- (void)setAttemptsValue:(short)value_;

//- (BOOL)validateAttempts:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) MTTerritoryStreet* street;
//- (BOOL)validateStreet:(id*)value_ error:(NSError**)error_;



@end

@interface _MTTerritoryHouse (CoreDataGeneratedAccessors)

@end

@interface _MTTerritoryHouse (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveNotes;
- (void)setPrimitiveNotes:(NSString*)value;


- (NSString*)primitiveNumber;
- (void)setPrimitiveNumber:(NSString*)value;


- (NSString*)primitiveApartment;
- (void)setPrimitiveApartment:(NSString*)value;


- (NSNumber*)primitiveAttempts;
- (void)setPrimitiveAttempts:(NSNumber*)value;

- (short)primitiveAttemptsValue;
- (void)setPrimitiveAttemptsValue:(short)value_;




- (MTTerritoryStreet*)primitiveStreet;
- (void)setPrimitiveStreet:(MTTerritoryStreet*)value;


@end
