// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTPublication.h instead.

#import <CoreData/CoreData.h>


@class MTReturnVisit;
@class MTBulkPlacement;








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



@property (nonatomic, retain) NSNumber *type;

@property short typeValue;
- (short)typeValue;
- (void)setTypeValue:(short)value_;

//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *year;

@property short yearValue;
- (short)yearValue;
- (void)setYearValue:(short)value_;

//- (BOOL)validateYear:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *day;

@property short dayValue;
- (short)dayValue;
- (void)setDayValue:(short)value_;

//- (BOOL)validateDay:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) MTReturnVisit* returnVisit;
//- (BOOL)validateReturnVisit:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) MTBulkPlacement* newRelationship;
//- (BOOL)validateNewRelationship:(id*)value_ error:(NSError**)error_;



@end

@interface _MTPublication (CoreDataGeneratedAccessors)

@end

@interface _MTPublication (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveMonth;
- (void)setPrimitiveMonth:(NSNumber*)value;

- (short)primitiveMonthValue;
- (void)setPrimitiveMonthValue:(short)value_;


- (NSNumber*)primitiveType;
- (void)setPrimitiveType:(NSNumber*)value;

- (short)primitiveTypeValue;
- (void)setPrimitiveTypeValue:(short)value_;


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;


- (NSNumber*)primitiveYear;
- (void)setPrimitiveYear:(NSNumber*)value;

- (short)primitiveYearValue;
- (void)setPrimitiveYearValue:(short)value_;


- (NSNumber*)primitiveDay;
- (void)setPrimitiveDay:(NSNumber*)value;

- (short)primitiveDayValue;
- (void)setPrimitiveDayValue:(short)value_;


- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (MTReturnVisit*)primitiveReturnVisit;
- (void)setPrimitiveReturnVisit:(MTReturnVisit*)value;



- (MTBulkPlacement*)primitiveNewRelationship;
- (void)setPrimitiveNewRelationship:(MTBulkPlacement*)value;


@end
