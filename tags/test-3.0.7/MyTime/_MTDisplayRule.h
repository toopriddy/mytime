// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTDisplayRule.h instead.

#import <CoreData/CoreData.h>


@class MTSorter;
@class MTUser;






@interface MTDisplayRuleID : NSManagedObjectID {}
@end

@interface _MTDisplayRule : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MTDisplayRuleID*)objectID;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *order;

@property double orderValue;
- (double)orderValue;
- (void)setOrderValue:(double)value_;

//- (BOOL)validateOrder:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *deleteable;

@property BOOL deleteableValue;
- (BOOL)deleteableValue;
- (void)setDeleteableValue:(BOOL)value_;

//- (BOOL)validateDeleteable:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *internal;

@property BOOL internalValue;
- (BOOL)internalValue;
- (void)setInternalValue:(BOOL)value_;

//- (BOOL)validateInternal:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* sorters;
- (NSMutableSet*)sortersSet;



@property (nonatomic, retain) MTUser* user;
//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;




@end

@interface _MTDisplayRule (CoreDataGeneratedAccessors)

- (void)addSorters:(NSSet*)value_;
- (void)removeSorters:(NSSet*)value_;
- (void)addSortersObject:(MTSorter*)value_;
- (void)removeSortersObject:(MTSorter*)value_;

@end

@interface _MTDisplayRule (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveOrder;
- (void)setPrimitiveOrder:(NSNumber*)value;

- (double)primitiveOrderValue;
- (void)setPrimitiveOrderValue:(double)value_;




- (NSNumber*)primitiveDeleteable;
- (void)setPrimitiveDeleteable:(NSNumber*)value;

- (BOOL)primitiveDeleteableValue;
- (void)setPrimitiveDeleteableValue:(BOOL)value_;




- (NSNumber*)primitiveInternal;
- (void)setPrimitiveInternal:(NSNumber*)value;

- (BOOL)primitiveInternalValue;
- (void)setPrimitiveInternalValue:(BOOL)value_;





- (NSMutableSet*)primitiveSorters;
- (void)setPrimitiveSorters:(NSMutableSet*)value;



- (MTUser*)primitiveUser;
- (void)setPrimitiveUser:(MTUser*)value;


@end
