// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTTimeEntry.h instead.

#import <CoreData/CoreData.h>


@class MTTimeType;





@interface MTTimeEntryID : NSManagedObjectID {}
@end

@interface _MTTimeEntry : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MTTimeEntryID*)objectID;



@property (nonatomic, retain) NSString *notes;

//- (BOOL)validateNotes:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *minutes;

@property long long minutesValue;
- (long long)minutesValue;
- (void)setMinutesValue:(long long)value_;

//- (BOOL)validateMinutes:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *date;

//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) MTTimeType* type;
//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;




@end

@interface _MTTimeEntry (CoreDataGeneratedAccessors)

@end

@interface _MTTimeEntry (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveNotes;
- (void)setPrimitiveNotes:(NSString*)value;


- (NSNumber*)primitiveMinutes;
- (void)setPrimitiveMinutes:(NSNumber*)value;

- (long long)primitiveMinutesValue;
- (void)setPrimitiveMinutesValue:(long long)value_;


- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;




- (MTTimeType*)primitiveType;
- (void)setPrimitiveType:(MTTimeType*)value;


@end
