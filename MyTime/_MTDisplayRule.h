// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTDisplayRule.h instead.

#import <CoreData/CoreData.h>


@class MTFilter;
@class MTSorter;
@class MTUser;





@interface MTDisplayRuleID : NSManagedObjectID {}
@end

@interface _MTDisplayRule : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MTDisplayRuleID*)objectID;



@property (nonatomic, retain) NSNumber *order;

@property double orderValue;
- (double)orderValue;
- (void)setOrderValue:(double)value_;

//- (BOOL)validateOrder:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *deleteable;

@property BOOL deleteableValue;
- (BOOL)deleteableValue;
- (void)setDeleteableValue:(BOOL)value_;

//- (BOOL)validateDeleteable:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) MTFilter* filters;
//- (BOOL)validateFilters:(id*)value_ error:(NSError**)error_;



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

- (NSNumber*)primitiveOrder;
- (void)setPrimitiveOrder:(NSNumber*)value;

- (double)primitiveOrderValue;
- (void)setPrimitiveOrderValue:(double)value_;


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;


- (NSNumber*)primitiveDeleteable;
- (void)setPrimitiveDeleteable:(NSNumber*)value;

- (BOOL)primitiveDeleteableValue;
- (void)setPrimitiveDeleteableValue:(BOOL)value_;




- (MTFilter*)primitiveFilters;
- (void)setPrimitiveFilters:(MTFilter*)value;



- (NSMutableSet*)primitiveSorters;
- (void)setPrimitiveSorters:(NSMutableSet*)value;



- (MTUser*)primitiveUser;
- (void)setPrimitiveUser:(MTUser*)value;


@end
