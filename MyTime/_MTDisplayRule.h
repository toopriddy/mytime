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



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




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

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (MTFilter*)primitiveFilters;
- (void)setPrimitiveFilters:(MTFilter*)value;



- (NSMutableSet*)primitiveSorters;
- (void)setPrimitiveSorters:(NSMutableSet*)value;



- (MTUser*)primitiveUser;
- (void)setPrimitiveUser:(MTUser*)value;


@end
