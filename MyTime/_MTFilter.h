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



@property (nonatomic, retain) NSNumber *diacriticSensitive;

@property BOOL diacriticSensitiveValue;
- (BOOL)diacriticSensitiveValue;
- (void)setDiacriticSensitiveValue:(BOOL)value_;

//- (BOOL)validateDiacriticSensitive:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *type;

@property short typeValue;
- (short)typeValue;
- (void)setTypeValue:(short)value_;

//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *path;

//- (BOOL)validatePath:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *caseSensitive;

@property BOOL caseSensitiveValue;
- (BOOL)caseSensitiveValue;
- (void)setCaseSensitiveValue:(BOOL)value_;

//- (BOOL)validateCaseSensitive:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *order;

@property double orderValue;
- (double)orderValue;
- (void)setOrderValue:(double)value_;

//- (BOOL)validateOrder:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *operator;

//- (BOOL)validateOperator:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *filterEntityName;

//- (BOOL)validateFilterEntityName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *list;

@property BOOL listValue;
- (BOOL)listValue;
- (void)setListValue:(BOOL)value_;

//- (BOOL)validateList:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *and;

@property BOOL andValue;
- (BOOL)andValue;
- (void)setAndValue:(BOOL)value_;

//- (BOOL)validateAnd:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *value;

//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *not;

@property BOOL notValue;
- (BOOL)notValue;
- (void)setNotValue:(BOOL)value_;

//- (BOOL)validateNot:(id*)value_ error:(NSError**)error_;




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


- (NSNumber*)primitiveDiacriticSensitive;
- (void)setPrimitiveDiacriticSensitive:(NSNumber*)value;

- (BOOL)primitiveDiacriticSensitiveValue;
- (void)setPrimitiveDiacriticSensitiveValue:(BOOL)value_;




- (NSNumber*)primitiveType;
- (void)setPrimitiveType:(NSNumber*)value;

- (short)primitiveTypeValue;
- (void)setPrimitiveTypeValue:(short)value_;




- (NSString*)primitivePath;
- (void)setPrimitivePath:(NSString*)value;




- (NSNumber*)primitiveCaseSensitive;
- (void)setPrimitiveCaseSensitive:(NSNumber*)value;

- (BOOL)primitiveCaseSensitiveValue;
- (void)setPrimitiveCaseSensitiveValue:(BOOL)value_;




- (NSNumber*)primitiveOrder;
- (void)setPrimitiveOrder:(NSNumber*)value;

- (double)primitiveOrderValue;
- (void)setPrimitiveOrderValue:(double)value_;




- (NSString*)primitiveOperator;
- (void)setPrimitiveOperator:(NSString*)value;




- (NSString*)primitiveFilterEntityName;
- (void)setPrimitiveFilterEntityName:(NSString*)value;




- (NSNumber*)primitiveList;
- (void)setPrimitiveList:(NSNumber*)value;

- (BOOL)primitiveListValue;
- (void)setPrimitiveListValue:(BOOL)value_;




- (NSNumber*)primitiveAnd;
- (void)setPrimitiveAnd:(NSNumber*)value;

- (BOOL)primitiveAndValue;
- (void)setPrimitiveAndValue:(BOOL)value_;




- (NSString*)primitiveValue;
- (void)setPrimitiveValue:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveNot;
- (void)setPrimitiveNot:(NSNumber*)value;

- (BOOL)primitiveNotValue;
- (void)setPrimitiveNotValue:(BOOL)value_;





- (MTFilter*)primitiveParent;
- (void)setPrimitiveParent:(MTFilter*)value;



- (NSMutableSet*)primitiveFilters;
- (void)setPrimitiveFilters:(NSMutableSet*)value;



- (MTDisplayRule*)primitiveDisplayRule;
- (void)setPrimitiveDisplayRule:(MTDisplayRule*)value;


@end
