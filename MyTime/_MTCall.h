// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTCall.h instead.

#import <CoreData/CoreData.h>


@class MTAdditionalInformation;
@class MTReturnVisit;
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



@property (nonatomic, retain) NSString *sectionIndexString;

//- (BOOL)validateSectionIndexString:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *state;

//- (BOOL)validateState:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *deletedCall;

@property BOOL deletedCallValue;
- (BOOL)deletedCallValue;
- (void)setDeletedCallValue:(BOOL)value_;

//- (BOOL)validateDeletedCall:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *locationAquired;

@property BOOL locationAquiredValue;
- (BOOL)locationAquiredValue;
- (void)setLocationAquiredValue:(BOOL)value_;

//- (BOOL)validateLocationAquired:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *uppercaseFirstLetterOfName;

//- (BOOL)validateUppercaseFirstLetterOfName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *houseNumber;

//- (BOOL)validateHouseNumber:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *locationLookupType;

//- (BOOL)validateLocationLookupType:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *uppercaseFirstLetterOfStreet;

//- (BOOL)validateUppercaseFirstLetterOfStreet:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *mostRecentReturnVisitDate;

//- (BOOL)validateMostRecentReturnVisitDate:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *street;

//- (BOOL)validateStreet:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDecimalNumber *lattitude;

//- (BOOL)validateLattitude:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDecimalNumber *longitude;

//- (BOOL)validateLongitude:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *uppercaseFirstLetterOfCity;

//- (BOOL)validateUppercaseFirstLetterOfCity:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *sectionIndexNumber;

@property long long sectionIndexNumberValue;
- (long long)sectionIndexNumberValue;
- (void)setSectionIndexNumberValue:(long long)value_;

//- (BOOL)validateSectionIndexNumber:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *apartmentNumber;

//- (BOOL)validateApartmentNumber:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *locationAquisitionAttempted;

@property BOOL locationAquisitionAttemptedValue;
- (BOOL)locationAquisitionAttemptedValue;
- (void)setLocationAquisitionAttemptedValue:(BOOL)value_;

//- (BOOL)validateLocationAquisitionAttempted:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *dateSortedSectionIndex;

@property short dateSortedSectionIndexValue;
- (short)dateSortedSectionIndexValue;
- (void)setDateSortedSectionIndexValue:(short)value_;

//- (BOOL)validateDateSortedSectionIndex:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *uppercaseFirstLetterOfState;

//- (BOOL)validateUppercaseFirstLetterOfState:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* additionalInformation;
- (NSMutableSet*)additionalInformationSet;



@property (nonatomic, retain) NSSet* returnVisits;
- (NSMutableSet*)returnVisitsSet;



@property (nonatomic, retain) MTUser* user;
//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;




@end

@interface _MTCall (CoreDataGeneratedAccessors)

- (void)addAdditionalInformation:(NSSet*)value_;
- (void)removeAdditionalInformation:(NSSet*)value_;
- (void)addAdditionalInformationObject:(MTAdditionalInformation*)value_;
- (void)removeAdditionalInformationObject:(MTAdditionalInformation*)value_;

- (void)addReturnVisits:(NSSet*)value_;
- (void)removeReturnVisits:(NSSet*)value_;
- (void)addReturnVisitsObject:(MTReturnVisit*)value_;
- (void)removeReturnVisitsObject:(MTReturnVisit*)value_;

@end

@interface _MTCall (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCity;
- (void)setPrimitiveCity:(NSString*)value;




- (NSString*)primitiveSectionIndexString;
- (void)setPrimitiveSectionIndexString:(NSString*)value;




- (NSString*)primitiveState;
- (void)setPrimitiveState:(NSString*)value;




- (NSNumber*)primitiveDeletedCall;
- (void)setPrimitiveDeletedCall:(NSNumber*)value;

- (BOOL)primitiveDeletedCallValue;
- (void)setPrimitiveDeletedCallValue:(BOOL)value_;




- (NSNumber*)primitiveLocationAquired;
- (void)setPrimitiveLocationAquired:(NSNumber*)value;

- (BOOL)primitiveLocationAquiredValue;
- (void)setPrimitiveLocationAquiredValue:(BOOL)value_;




- (NSString*)primitiveUppercaseFirstLetterOfName;
- (void)setPrimitiveUppercaseFirstLetterOfName:(NSString*)value;




- (NSString*)primitiveHouseNumber;
- (void)setPrimitiveHouseNumber:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveLocationLookupType;
- (void)setPrimitiveLocationLookupType:(NSString*)value;




- (NSString*)primitiveUppercaseFirstLetterOfStreet;
- (void)setPrimitiveUppercaseFirstLetterOfStreet:(NSString*)value;




- (NSDate*)primitiveMostRecentReturnVisitDate;
- (void)setPrimitiveMostRecentReturnVisitDate:(NSDate*)value;




- (NSString*)primitiveStreet;
- (void)setPrimitiveStreet:(NSString*)value;




- (NSDecimalNumber*)primitiveLattitude;
- (void)setPrimitiveLattitude:(NSDecimalNumber*)value;




- (NSDecimalNumber*)primitiveLongitude;
- (void)setPrimitiveLongitude:(NSDecimalNumber*)value;




- (NSString*)primitiveUppercaseFirstLetterOfCity;
- (void)setPrimitiveUppercaseFirstLetterOfCity:(NSString*)value;




- (NSNumber*)primitiveSectionIndexNumber;
- (void)setPrimitiveSectionIndexNumber:(NSNumber*)value;

- (long long)primitiveSectionIndexNumberValue;
- (void)setPrimitiveSectionIndexNumberValue:(long long)value_;




- (NSString*)primitiveApartmentNumber;
- (void)setPrimitiveApartmentNumber:(NSString*)value;




- (NSNumber*)primitiveLocationAquisitionAttempted;
- (void)setPrimitiveLocationAquisitionAttempted:(NSNumber*)value;

- (BOOL)primitiveLocationAquisitionAttemptedValue;
- (void)setPrimitiveLocationAquisitionAttemptedValue:(BOOL)value_;




- (NSNumber*)primitiveDateSortedSectionIndex;
- (void)setPrimitiveDateSortedSectionIndex:(NSNumber*)value;

- (short)primitiveDateSortedSectionIndexValue;
- (void)setPrimitiveDateSortedSectionIndexValue:(short)value_;




- (NSString*)primitiveUppercaseFirstLetterOfState;
- (void)setPrimitiveUppercaseFirstLetterOfState:(NSString*)value;





- (NSMutableSet*)primitiveAdditionalInformation;
- (void)setPrimitiveAdditionalInformation:(NSMutableSet*)value;



- (NSMutableSet*)primitiveReturnVisits;
- (void)setPrimitiveReturnVisits:(NSMutableSet*)value;



- (MTUser*)primitiveUser;
- (void)setPrimitiveUser:(MTUser*)value;


@end
