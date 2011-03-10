// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTAdditionalInformation.h instead.

#import <CoreData/CoreData.h>


@class MTAdditionalInformationType;
@class MTCall;






@interface MTAdditionalInformationID : NSManagedObjectID {}
@end

@interface _MTAdditionalInformation : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MTAdditionalInformationID*)objectID;



@property (nonatomic, retain) NSNumber *boolean;

@property BOOL booleanValue;
- (BOOL)booleanValue;
- (void)setBooleanValue:(BOOL)value_;

//- (BOOL)validateBoolean:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *value;

//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *number;

@property long long numberValue;
- (long long)numberValue;
- (void)setNumberValue:(long long)value_;

//- (BOOL)validateNumber:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *date;

//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) MTAdditionalInformationType* type;
//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) MTCall* call;
//- (BOOL)validateCall:(id*)value_ error:(NSError**)error_;




@end

@interface _MTAdditionalInformation (CoreDataGeneratedAccessors)

@end

@interface _MTAdditionalInformation (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveBoolean;
- (void)setPrimitiveBoolean:(NSNumber*)value;

- (BOOL)primitiveBooleanValue;
- (void)setPrimitiveBooleanValue:(BOOL)value_;




- (NSString*)primitiveValue;
- (void)setPrimitiveValue:(NSString*)value;




- (NSNumber*)primitiveNumber;
- (void)setPrimitiveNumber:(NSNumber*)value;

- (long long)primitiveNumberValue;
- (void)setPrimitiveNumberValue:(long long)value_;




- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;





- (MTAdditionalInformationType*)primitiveType;
- (void)setPrimitiveType:(MTAdditionalInformationType*)value;



- (MTCall*)primitiveCall;
- (void)setPrimitiveCall:(MTCall*)value;


@end
