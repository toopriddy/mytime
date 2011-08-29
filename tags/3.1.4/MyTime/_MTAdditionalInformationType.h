// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTAdditionalInformationType.h instead.

#import <CoreData/CoreData.h>


@class MTUser;
@class MTAdditionalInformation;
@class MTMultipleChoice;








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



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *alwaysShown;

@property BOOL alwaysShownValue;
- (BOOL)alwaysShownValue;
- (void)setAlwaysShownValue:(BOOL)value_;

//- (BOOL)validateAlwaysShown:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *order;

@property double orderValue;
- (double)orderValue;
- (void)setOrderValue:(double)value_;

//- (BOOL)validateOrder:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *uuid;

//- (BOOL)validateUuid:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *hidden;

@property BOOL hiddenValue;
- (BOOL)hiddenValue;
- (void)setHiddenValue:(BOOL)value_;

//- (BOOL)validateHidden:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) MTUser* user;
//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSSet* additionalInformation;
- (NSMutableSet*)additionalInformationSet;



@property (nonatomic, retain) NSSet* multipleChoices;
- (NSMutableSet*)multipleChoicesSet;




@end

@interface _MTAdditionalInformationType (CoreDataGeneratedAccessors)

- (void)addAdditionalInformation:(NSSet*)value_;
- (void)removeAdditionalInformation:(NSSet*)value_;
- (void)addAdditionalInformationObject:(MTAdditionalInformation*)value_;
- (void)removeAdditionalInformationObject:(MTAdditionalInformation*)value_;

- (void)addMultipleChoices:(NSSet*)value_;
- (void)removeMultipleChoices:(NSSet*)value_;
- (void)addMultipleChoicesObject:(MTMultipleChoice*)value_;
- (void)removeMultipleChoicesObject:(MTMultipleChoice*)value_;

@end

@interface _MTAdditionalInformationType (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveType;
- (void)setPrimitiveType:(NSNumber*)value;

- (short)primitiveTypeValue;
- (void)setPrimitiveTypeValue:(short)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveAlwaysShown;
- (void)setPrimitiveAlwaysShown:(NSNumber*)value;

- (BOOL)primitiveAlwaysShownValue;
- (void)setPrimitiveAlwaysShownValue:(BOOL)value_;




- (NSNumber*)primitiveOrder;
- (void)setPrimitiveOrder:(NSNumber*)value;

- (double)primitiveOrderValue;
- (void)setPrimitiveOrderValue:(double)value_;




- (NSString*)primitiveUuid;
- (void)setPrimitiveUuid:(NSString*)value;




- (NSNumber*)primitiveHidden;
- (void)setPrimitiveHidden:(NSNumber*)value;

- (BOOL)primitiveHiddenValue;
- (void)setPrimitiveHiddenValue:(BOOL)value_;





- (MTUser*)primitiveUser;
- (void)setPrimitiveUser:(MTUser*)value;



- (NSMutableSet*)primitiveAdditionalInformation;
- (void)setPrimitiveAdditionalInformation:(NSMutableSet*)value;



- (NSMutableSet*)primitiveMultipleChoices;
- (void)setPrimitiveMultipleChoices:(NSMutableSet*)value;


@end
