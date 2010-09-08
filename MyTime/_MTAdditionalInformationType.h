// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTAdditionalInformationType.h instead.

#import <CoreData/CoreData.h>


@class MTAdditionalInformation;
@class MTUser;







@interface MTAdditionalInformationTypeID : NSManagedObjectID {}
@end

@interface _MTAdditionalInformationType : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MTAdditionalInformationTypeID*)objectID;



@property (nonatomic, retain) NSNumber *type;

@property short typeValue;
- (short)typeValue;
- (void)setTypeValue:(short)value_;

//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSData *data;

//- (BOOL)validateData:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *alwaysShown;

@property BOOL alwaysShownValue;
- (BOOL)alwaysShownValue;
- (void)setAlwaysShownValue:(BOOL)value_;

//- (BOOL)validateAlwaysShown:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *hidden;

@property BOOL hiddenValue;
- (BOOL)hiddenValue;
- (void)setHiddenValue:(BOOL)value_;

//- (BOOL)validateHidden:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) MTAdditionalInformation* additionalInformation;
//- (BOOL)validateAdditionalInformation:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) MTUser* user;
//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;



@end

@interface _MTAdditionalInformationType (CoreDataGeneratedAccessors)

@end

@interface _MTAdditionalInformationType (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveType;
- (void)setPrimitiveType:(NSNumber*)value;

- (short)primitiveTypeValue;
- (void)setPrimitiveTypeValue:(short)value_;


- (NSData*)primitiveData;
- (void)setPrimitiveData:(NSData*)value;


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;


- (NSNumber*)primitiveAlwaysShown;
- (void)setPrimitiveAlwaysShown:(NSNumber*)value;

- (BOOL)primitiveAlwaysShownValue;
- (void)setPrimitiveAlwaysShownValue:(BOOL)value_;


- (NSNumber*)primitiveHidden;
- (void)setPrimitiveHidden:(NSNumber*)value;

- (BOOL)primitiveHiddenValue;
- (void)setPrimitiveHiddenValue:(BOOL)value_;




- (MTAdditionalInformation*)primitiveAdditionalInformation;
- (void)setPrimitiveAdditionalInformation:(MTAdditionalInformation*)value;



- (MTUser*)primitiveUser;
- (void)setPrimitiveUser:(MTUser*)value;


@end
