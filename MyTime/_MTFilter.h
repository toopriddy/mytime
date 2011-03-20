// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTFilter.h instead.

#import <CoreData/CoreData.h>


@class MTDisplayRule;
@class MTFilter;
@class MTFilter;










@interface MTFilterID : NSManagedObjectID {}
@end

@interface _MTFilter : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MTFilterID*)objectID;



@property (nonatomic, retain) NSString *predicateString;

//- (BOOL)validatePredicateString:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *and;

@property BOOL andValue;
- (BOOL)andValue;
- (void)setAndValue:(BOOL)value_;

//- (BOOL)validateAnd:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *path;

//- (BOOL)validatePath:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *list;

@property BOOL listValue;
- (BOOL)listValue;
- (void)setListValue:(BOOL)value_;

//- (BOOL)validateList:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *type;

@property short typeValue;
- (short)typeValue;
- (void)setTypeValue:(short)value_;

//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *order;

@property double orderValue;
- (double)orderValue;
- (void)setOrderValue:(double)value_;

//- (BOOL)validateOrder:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *value;

//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) MTDisplayRule* displayRule;
//- (BOOL)validateDisplayRule:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSSet* filters;
- (NSMutableSet*)filtersSet;



@property (nonatomic, retain) MTFilter* parent;
//- (BOOL)validateParent:(id*)value_ error:(NSError**)error_;




@end

@interface _MTFilter (CoreDataGeneratedAccessors)

- (void)addFilters:(NSSet*)value_;
- (void)removeFilters:(NSSet*)value_;
- (void)addFiltersObject:(MTFilter*)value_;
- (void)removeFiltersObject:(MTFilter*)value_;

@end

@interface _MTFilter (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitivePredicateString;
- (void)setPrimitivePredicateString:(NSString*)value;




- (NSNumber*)primitiveAnd;
- (void)setPrimitiveAnd:(NSNumber*)value;

- (BOOL)primitiveAndValue;
- (void)setPrimitiveAndValue:(BOOL)value_;




- (NSString*)primitivePath;
- (void)setPrimitivePath:(NSString*)value;




- (NSNumber*)primitiveList;
- (void)setPrimitiveList:(NSNumber*)value;

- (BOOL)primitiveListValue;
- (void)setPrimitiveListValue:(BOOL)value_;




- (NSNumber*)primitiveType;
- (void)setPrimitiveType:(NSNumber*)value;

- (short)primitiveTypeValue;
- (void)setPrimitiveTypeValue:(short)value_;




- (NSNumber*)primitiveOrder;
- (void)setPrimitiveOrder:(NSNumber*)value;

- (double)primitiveOrderValue;
- (void)setPrimitiveOrderValue:(double)value_;




- (NSString*)primitiveValue;
- (void)setPrimitiveValue:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;





- (MTDisplayRule*)primitiveDisplayRule;
- (void)setPrimitiveDisplayRule:(MTDisplayRule*)value;



- (NSMutableSet*)primitiveFilters;
- (void)setPrimitiveFilters:(NSMutableSet*)value;



- (MTFilter*)primitiveParent;
- (void)setPrimitiveParent:(MTFilter*)value;


@end
