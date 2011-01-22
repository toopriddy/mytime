// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTStatisticsAdjustment.h instead.

#import <CoreData/CoreData.h>


@class MTUser;





@interface MTStatisticsAdjustmentID : NSManagedObjectID {}
@end

@interface _MTStatisticsAdjustment : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MTStatisticsAdjustmentID*)objectID;



@property (nonatomic, retain) NSNumber *adjustment;

@property long long adjustmentValue;
- (long long)adjustmentValue;
- (void)setAdjustmentValue:(long long)value_;

//- (BOOL)validateAdjustment:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *type;

//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *timestamp;

@property int timestampValue;
- (int)timestampValue;
- (void)setTimestampValue:(int)value_;

//- (BOOL)validateTimestamp:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) MTUser* user;
//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;



@end

@interface _MTStatisticsAdjustment (CoreDataGeneratedAccessors)

@end

@interface _MTStatisticsAdjustment (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveAdjustment;
- (void)setPrimitiveAdjustment:(NSNumber*)value;

- (long long)primitiveAdjustmentValue;
- (void)setPrimitiveAdjustmentValue:(long long)value_;


- (NSString*)primitiveType;
- (void)setPrimitiveType:(NSString*)value;


- (NSNumber*)primitiveTimestamp;
- (void)setPrimitiveTimestamp:(NSNumber*)value;

- (int)primitiveTimestampValue;
- (void)setPrimitiveTimestampValue:(int)value_;




- (MTUser*)primitiveUser;
- (void)setPrimitiveUser:(MTUser*)value;


@end
