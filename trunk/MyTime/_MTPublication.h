// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTPublication.h instead.

#import <CoreData/CoreData.h>


@class MTBulkPlacement;
@class MTReturnVisit;










@interface MTPublicationID : NSManagedObjectID {}
@end

@interface _MTPublication : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MTPublicationID*)objectID;



@property (nonatomic, retain) NSNumber *month;

@property short monthValue;
- (short)monthValue;
- (void)setMonthValue:(short)value_;

//- (BOOL)validateMonth:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *type;

//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *order;

@property short orderValue;
- (short)orderValue;
- (void)setOrderValue:(short)value_;

//- (BOOL)validateOrder:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *day;

@property short dayValue;
- (short)dayValue;
- (void)setDayValue:(short)value_;

//- (BOOL)validateDay:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *year;

@property short yearValue;
- (short)yearValue;
- (void)setYearValue:(short)value_;

//- (BOOL)validateYear:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *count;

@property short countValue;
- (short)countValue;
- (void)setCountValue:(short)value_;

//- (BOOL)validateCount:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) MTBulkPlacement* bulkPlacement;
//- (BOOL)validateBulkPlacement:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) MTReturnVisit* returnVisit;
//- (BOOL)validateReturnVisit:(id*)value_ error:(NSError**)error_;



@end

@interface _MTPublication (CoreDataGeneratedAccessors)

@end

@interface _MTPublication (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveMonth;
- (void)setPrimitiveMonth:(NSNumber*)value;

- (short)primitiveMonthValue;
- (void)setPrimitiveMonthValue:(short)value_;


- (NSString*)primitiveType;
- (void)setPrimitiveType:(NSString*)value;


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;


- (NSNumber*)primitiveOrder;
- (void)setPrimitiveOrder:(NSNumber*)value;

- (short)primitiveOrderValue;
- (void)setPrimitiveOrderValue:(short)value_;


- (NSNumber*)primitiveDay;
- (void)setPrimitiveDay:(NSNumber*)value;

- (short)primitiveDayValue;
- (void)setPrimitiveDayValue:(short)value_;


- (NSNumber*)primitiveYear;
- (void)setPrimitiveYear:(NSNumber*)value;

- (short)primitiveYearValue;
- (void)setPrimitiveYearValue:(short)value_;


- (NSNumber*)primitiveCount;
- (void)setPrimitiveCount:(NSNumber*)value;

- (short)primitiveCountValue;
- (void)setPrimitiveCountValue:(short)value_;


- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (MTBulkPlacement*)primitiveBulkPlacement;
- (void)setPrimitiveBulkPlacement:(MTBulkPlacement*)value;



- (MTReturnVisit*)primitiveReturnVisit;
- (void)setPrimitiveReturnVisit:(MTReturnVisit*)value;


@end
