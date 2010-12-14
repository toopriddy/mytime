// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTMultipleChoice.h instead.

#import <CoreData/CoreData.h>


@class MTAdditionalInformationType;




@interface MTMultipleChoiceID : NSManagedObjectID {}
@end

@interface _MTMultipleChoice : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MTMultipleChoiceID*)objectID;



@property (nonatomic, retain) NSNumber *order;

@property int orderValue;
- (int)orderValue;
- (void)setOrderValue:(int)value_;

//- (BOOL)validateOrder:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) MTAdditionalInformationType* type;
//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;



@end

@interface _MTMultipleChoice (CoreDataGeneratedAccessors)

@end

@interface _MTMultipleChoice (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveOrder;
- (void)setPrimitiveOrder:(NSNumber*)value;

- (int)primitiveOrderValue;
- (void)setPrimitiveOrderValue:(int)value_;


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (MTAdditionalInformationType*)primitiveType;
- (void)setPrimitiveType:(MTAdditionalInformationType*)value;


@end
