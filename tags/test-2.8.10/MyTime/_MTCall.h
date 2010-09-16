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



@property (nonatomic, retain) NSNumber *deleted;

@property BOOL deletedValue;
- (BOOL)deletedValue;
- (void)setDeletedValue:(BOOL)value_;

//- (BOOL)validateDeleted:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *houseNumber;

//- (BOOL)validateHouseNumber:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *lattitude;

@property double lattitudeValue;
- (double)lattitudeValue;
- (void)setLattitudeValue:(double)value_;

//- (BOOL)validateLattitude:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *city;

//- (BOOL)validateCity:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *apartmentNumber;

//- (BOOL)validateApartmentNumber:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *locationLookupType;

@property short locationLookupTypeValue;
- (short)locationLookupTypeValue;
- (void)setLocationLookupTypeValue:(short)value_;

//- (BOOL)validateLocationLookupType:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *state;

//- (BOOL)validateState:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *longitude;

@property double longitudeValue;
- (double)longitudeValue;
- (void)setLongitudeValue:(double)value_;

//- (BOOL)validateLongitude:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *street;

//- (BOOL)validateStreet:(id*)value_ error:(NSError**)error_;




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

- (NSNumber*)primitiveDeleted;
- (void)setPrimitiveDeleted:(NSNumber*)value;

- (BOOL)primitiveDeletedValue;
- (void)setPrimitiveDeletedValue:(BOOL)value_;


- (NSString*)primitiveHouseNumber;
- (void)setPrimitiveHouseNumber:(NSString*)value;


- (NSNumber*)primitiveLattitude;
- (void)setPrimitiveLattitude:(NSNumber*)value;

- (double)primitiveLattitudeValue;
- (void)setPrimitiveLattitudeValue:(double)value_;


- (NSString*)primitiveCity;
- (void)setPrimitiveCity:(NSString*)value;


- (NSString*)primitiveApartmentNumber;
- (void)setPrimitiveApartmentNumber:(NSString*)value;


- (NSNumber*)primitiveLocationLookupType;
- (void)setPrimitiveLocationLookupType:(NSNumber*)value;

- (short)primitiveLocationLookupTypeValue;
- (void)setPrimitiveLocationLookupTypeValue:(short)value_;


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;


- (NSString*)primitiveState;
- (void)setPrimitiveState:(NSString*)value;


- (NSNumber*)primitiveLongitude;
- (void)setPrimitiveLongitude:(NSNumber*)value;

- (double)primitiveLongitudeValue;
- (void)setPrimitiveLongitudeValue:(double)value_;


- (NSString*)primitiveStreet;
- (void)setPrimitiveStreet:(NSString*)value;




- (NSMutableSet*)primitiveReturnVisits;
- (void)setPrimitiveReturnVisits:(NSMutableSet*)value;



- (NSMutableSet*)primitiveAdditionalInformation;
- (void)setPrimitiveAdditionalInformation:(NSMutableSet*)value;



- (MTUser*)primitiveUser;
- (void)setPrimitiveUser:(MTUser*)value;


@end
