// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTFilter.h instead.

#import <CoreData/CoreData.h>


@class MTDisplayRule;





@interface MTFilterID : NSManagedObjectID {}
@end

@interface _MTFilter : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MTFilterID*)objectID;



@property (nonatomic, retain) NSNumber *order;

@property double orderValue;
- (double)orderValue;
- (void)setOrderValue:(double)value_;

//- (BOOL)validateOrder:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *predicate;

//- (BOOL)validatePredicate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) MTDisplayRule* displayRule;
//- (BOOL)validateDisplayRule:(id*)value_ error:(NSError**)error_;




@end

@interface _MTFilter (CoreDataGeneratedAccessors)

@end

@interface _MTFilter (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveOrder;
- (void)setPrimitiveOrder:(NSNumber*)value;

- (double)primitiveOrderValue;
- (void)setPrimitiveOrderValue:(double)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitivePredicate;
- (void)setPrimitivePredicate:(NSString*)value;





- (MTDisplayRule*)primitiveDisplayRule;
- (void)setPrimitiveDisplayRule:(MTDisplayRule*)value;


@end
