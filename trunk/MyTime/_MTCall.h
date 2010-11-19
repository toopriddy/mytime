// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTCall.h instead.

#import <CoreData/CoreData.h>


@class MTReturnVisit;
@class MTAdditionalInformation;
@class MTUser;















@interface MTCallID : NSManagedObjectID {}
@end

@interface _MTCall : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MTCallID*)objectID;



@property (nonatomic, retain) NSString *city;

//- (BOOL)validateCity:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *apartmentNumber;

//- (BOOL)validateApartmentNumber:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *street;

//- (BOOL)validateStreet:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *mostRecentReturnVisitDate;

//- (BOOL)validateMostRecentReturnVisitDate:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *state;

//- (BOOL)validateState:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDecimalNumber *longitude;

//- (BOOL)validateLongitude:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *locationAquisitionAttempted;

@property BOOL locationAquisitionAttemptedValue;
- (BOOL)locationAquisitionAttemptedValue;
- (void)setLocationAquisitionAttemptedValue:(BOOL)value_;

//- (BOOL)validateLocationAquisitionAttempted:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *houseNumber;

//- (BOOL)validateHouseNumber:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDecimalNumber *lattitude;

//- (BOOL)validateLattitude:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *locationLookupType;

//- (BOOL)validateLocationLookupType:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *deleted;

@property BOOL deletedValue;
- (BOOL)deletedValue;
- (void)setDeletedValue:(BOOL)value_;

//- (BOOL)validateDeleted:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *locationAquired;

@property BOOL locationAquiredValue;
- (BOOL)locationAquiredValue;
- (void)setLocationAquiredValue:(BOOL)value_;

//- (BOOL)validateLocationAquired:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* returnVisits;
- (NSMutableSet*)returnVisitsSet;



@property (nonatomic, retain) NSSet* additionalInformation;
- (NSMutableSet*)additionalInformationSet;



@property (nonatomic, retain) MTUser* user;
//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;



@end

@interface _MTCall (CoreDataGeneratedAccessors)

- (void)addReturnVisits:(NSSet*)value_;
- (void)removeReturnVisits:(NSSet*)value_;
- (void)addReturnVisitsObject:(MTReturnVisit*)value_;
- (void)removeReturnVisitsObject:(MTReturnVisit*)value_;

- (void)addAdditionalInformation:(NSSet*)value_;
- (void)removeAdditionalInformation:(NSSet*)value_;
- (void)addAdditionalInformationObject:(MTAdditionalInformation*)value_;
- (void)removeAdditionalInformationObject:(MTAdditionalInformation*)value_;

@end

@interface _MTCall (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveCity;
- (void)setPrimitiveCity:(NSString*)value;


- (NSString*)primitiveApartmentNumber;
- (void)setPrimitiveApartmentNumber:(NSString*)value;


- (NSString*)primitiveStreet;
- (void)setPrimitiveStreet:(NSString*)value;


- (NSDate*)primitiveMostRecentReturnVisitDate;
- (void)setPrimitiveMostRecentReturnVisitDate:(NSDate*)value;


- (NSString*)primitiveState;
- (void)setPrimitiveState:(NSString*)value;


- (NSDecimalNumber*)primitiveLongitude;
- (void)setPrimitiveLongitude:(NSDecimalNumber*)value;


- (NSNumber*)primitiveLocationAquisitionAttempted;
- (void)setPrimitiveLocationAquisitionAttempted:(NSNumber*)value;

- (BOOL)primitiveLocationAquisitionAttemptedValue;
- (void)setPrimitiveLocationAquisitionAttemptedValue:(BOOL)value_;


- (NSString*)primitiveHouseNumber;
- (void)setPrimitiveHouseNumber:(NSString*)value;


- (NSDecimalNumber*)primitiveLattitude;
- (void)setPrimitiveLattitude:(NSDecimalNumber*)value;


- (NSString*)primitiveLocationLookupType;
- (void)setPrimitiveLocationLookupType:(NSString*)value;


- (NSNumber*)primitiveDeleted;
- (void)setPrimitiveDeleted:(NSNumber*)value;

- (BOOL)primitiveDeletedValue;
- (void)setPrimitiveDeletedValue:(BOOL)value_;


- (NSNumber*)primitiveLocationAquired;
- (void)setPrimitiveLocationAquired:(NSNumber*)value;

- (BOOL)primitiveLocationAquiredValue;
- (void)setPrimitiveLocationAquiredValue:(BOOL)value_;


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSMutableSet*)primitiveReturnVisits;
- (void)setPrimitiveReturnVisits:(NSMutableSet*)value;



- (NSMutableSet*)primitiveAdditionalInformation;
- (void)setPrimitiveAdditionalInformation:(NSMutableSet*)value;



- (MTUser*)primitiveUser;
- (void)setPrimitiveUser:(MTUser*)value;


@end
