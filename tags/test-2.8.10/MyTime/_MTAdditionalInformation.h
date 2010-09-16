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



@property (nonatomic, retain) NSData *data;

//- (BOOL)validateData:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *value;

//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) MTAdditionalInformationType* type;
//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) MTCall* call;
//- (BOOL)validateCall:(id*)value_ error:(NSError**)error_;



@end

@interface _MTAdditionalInformation (CoreDataGeneratedAccessors)

@end

@interface _MTAdditionalInformation (CoreDataGeneratedPrimitiveAccessors)

- (NSData*)primitiveData;
- (void)setPrimitiveData:(NSData*)value;


- (NSString*)primitiveValue;
- (void)setPrimitiveValue:(NSString*)value;




- (MTAdditionalInformationType*)primitiveType;
- (void)setPrimitiveType:(MTAdditionalInformationType*)value;



- (MTCall*)primitiveCall;
- (void)setPrimitiveCall:(MTCall*)value;


@end
