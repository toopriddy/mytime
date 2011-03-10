// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTTimeType.h instead.

#import <CoreData/CoreData.h>


@class MTTimeEntry;
@class MTUser;






@interface MTTimeTypeID : NSManagedObjectID {}
@end

@interface _MTTimeType : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MTTimeTypeID*)objectID;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *imageFileName;

//- (BOOL)validateImageFileName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *deleteable;

@property BOOL deleteableValue;
- (BOOL)deleteableValue;
- (void)setDeleteableValue:(BOOL)value_;

//- (BOOL)validateDeleteable:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *startTimerDate;

//- (BOOL)validateStartTimerDate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* timeEntries;
- (NSMutableSet*)timeEntriesSet;



@property (nonatomic, retain) MTUser* user;
//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;




@end

@interface _MTTimeType (CoreDataGeneratedAccessors)

- (void)addTimeEntries:(NSSet*)value_;
- (void)removeTimeEntries:(NSSet*)value_;
- (void)addTimeEntriesObject:(MTTimeEntry*)value_;
- (void)removeTimeEntriesObject:(MTTimeEntry*)value_;

@end

@interface _MTTimeType (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveImageFileName;
- (void)setPrimitiveImageFileName:(NSString*)value;




- (NSNumber*)primitiveDeleteable;
- (void)setPrimitiveDeleteable:(NSNumber*)value;

- (BOOL)primitiveDeleteableValue;
- (void)setPrimitiveDeleteableValue:(BOOL)value_;




- (NSDate*)primitiveStartTimerDate;
- (void)setPrimitiveStartTimerDate:(NSDate*)value;





- (NSMutableSet*)primitiveTimeEntries;
- (void)setPrimitiveTimeEntries:(NSMutableSet*)value;



- (MTUser*)primitiveUser;
- (void)setPrimitiveUser:(MTUser*)value;


@end
