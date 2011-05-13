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



@property (nonatomic, retain) NSString *filterEntityName;

//- (BOOL)validateFilterEntityName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *type;

@property short typeValue;
- (short)typeValue;
- (void)setTypeValue:(short)value_;

//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *path;

//- (BOOL)validatePath:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *diacriticInsensitive;

@property BOOL diacriticInsensitiveValue;
- (BOOL)diacriticInsensitiveValue;
- (void)setDiacriticInsensitiveValue:(BOOL)value_;

//- (BOOL)validateDiacriticInsensitive:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *order;

@property double orderValue;
- (double)orderValue;
- (void)setOrderValue:(double)value_;

//- (BOOL)validateOrder:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *operator;

//- (BOOL)validateOperator:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *caseInsensitive;

@property BOOL caseInsensitiveValue;
- (BOOL)caseInsensitiveValue;
- (void)setCaseInsensitiveValue:(BOOL)value_;

//- (BOOL)validateCaseInsensitive:(id*)value_ error:(NSError**)error_;



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



@property (nonatomic, retain) NSString *untranslatedValueTitle;

//- (BOOL)validateUntranslatedValueTitle:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *untranslatedName;

//- (BOOL)validateUntranslatedName:(id*)value_ error:(NSError**)error_;



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


- (NSString*)primitiveFilterEntityName;
- (void)setPrimitiveFilterEntityName:(NSString*)value;




- (NSNumber*)primitiveType;
- (void)setPrimitiveType:(NSNumber*)value;

- (short)primitiveTypeValue;
- (void)setPrimitiveTypeValue:(short)value_;




- (NSString*)primitivePath;
- (void)setPrimitivePath:(NSString*)value;




- (NSNumber*)primitiveDiacriticInsensitive;
- (void)setPrimitiveDiacriticInsensitive:(NSNumber*)value;

- (BOOL)primitiveDiacriticInsensitiveValue;
- (void)setPrimitiveDiacriticInsensitiveValue:(BOOL)value_;




- (NSNumber*)primitiveOrder;
- (void)setPrimitiveOrder:(NSNumber*)value;

- (double)primitiveOrderValue;
- (void)setPrimitiveOrderValue:(double)value_;




- (NSString*)primitiveOperator;
- (void)setPrimitiveOperator:(NSString*)value;




- (NSNumber*)primitiveCaseInsensitive;
- (void)setPrimitiveCaseInsensitive:(NSNumber*)value;

- (BOOL)primitiveCaseInsensitiveValue;
- (void)setPrimitiveCaseInsensitiveValue:(BOOL)value_;




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




- (NSString*)primitiveUntranslatedValueTitle;
- (void)setPrimitiveUntranslatedValueTitle:(NSString*)value;




- (NSString*)primitiveUntranslatedName;
- (void)setPrimitiveUntranslatedName:(NSString*)value;




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
