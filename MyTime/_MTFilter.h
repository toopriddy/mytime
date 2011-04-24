// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTFilter.h instead.

#import <CoreData/CoreData.h>


@class MTFilter;
@class MTFilter;
@class MTDisplayRule;











@interface MTFilterID : NSManagedObjectID {}
@end

@interface _MTFilter : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MTFilterID*)objectID;



@property (nonatomic, retain) NSNumber *and;

@property BOOL andValue;
- (BOOL)andValue;
- (void)setAndValue:(BOOL)value_;

//- (BOOL)validateAnd:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *type;

@property short typeValue;
- (short)typeValue;
- (void)setTypeValue:(short)value_;

//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *path;

//- (BOOL)validatePath:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *list;

@property BOOL listValue;
- (BOOL)listValue;
- (void)setListValue:(BOOL)value_;

//- (BOOL)validateList:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *order;

@property double orderValue;
- (double)orderValue;
- (void)setOrderValue:(double)value_;

//- (BOOL)validateOrder:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *value;

//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *operator;

//- (BOOL)validateOperator:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *filterEntityName;

//- (BOOL)validateFilterEntityName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) MTFilter* parent;
//- (BOOL)validateParent:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSSet* filters;
- (NSMutableSet*)filtersSet;



@property (nonatomic, retain) MTDisplayRule* displayRule;
//- (BOOL)validateDisplayRule:(id*)value_ error:(NSError**)error_;




@end

@interface _MTFilter (CoreDataGeneratedAccessors)

- (void)addFilters:(NSSet*)value_;
- (void)removeFilters:(NSSet*)value_;
- (void)addFiltersObject:(MTFilter*)value_;
- (void)removeFiltersObject:(MTFilter*)value_;

@end

@interface _MTFilter (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveAnd;
- (void)setPrimitiveAnd:(NSNumber*)value;

- (BOOL)primitiveAndValue;
- (void)setPrimitiveAndValue:(BOOL)value_;




- (NSNumber*)primitiveType;
- (void)setPrimitiveType:(NSNumber*)value;

- (short)primitiveTypeValue;
- (void)setPrimitiveTypeValue:(short)value_;




- (NSString*)primitivePath;
- (void)setPrimitivePath:(NSString*)value;




- (NSNumber*)primitiveList;
- (void)setPrimitiveList:(NSNumber*)value;

- (BOOL)primitiveListValue;
- (void)setPrimitiveListValue:(BOOL)value_;




- (NSNumber*)primitiveOrder;
- (void)setPrimitiveOrder:(NSNumber*)value;

- (double)primitiveOrderValue;
- (void)setPrimitiveOrderValue:(double)value_;




- (NSString*)primitiveValue;
- (void)setPrimitiveValue:(NSString*)value;




- (NSString*)primitiveOperator;
- (void)setPrimitiveOperator:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveFilterEntityName;
- (void)setPrimitiveFilterEntityName:(NSString*)value;





- (MTFilter*)primitiveParent;
- (void)setPrimitiveParent:(MTFilter*)value;



- (NSMutableSet*)primitiveFilters;
- (void)setPrimitiveFilters:(NSMutableSet*)value;



- (MTDisplayRule*)primitiveDisplayRule;
- (void)setPrimitiveDisplayRule:(MTDisplayRule*)value;


@end
