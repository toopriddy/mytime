// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTStartTimestamp.h instead.

#import <CoreData/CoreData.h>


@class MTUser;




@interface MTStartTimestampID : NSManagedObjectID {}
@end

@interface _MTStartTimestamp : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MTStartTimestampID*)objectID;



@property (nonatomic, retain) NSString *type;

//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *date;

//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) MTUser* user;
//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;



@end

@interface _MTStartTimestamp (CoreDataGeneratedAccessors)

@end

@interface _MTStartTimestamp (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveType;
- (void)setPrimitiveType:(NSString*)value;


- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;




- (MTUser*)primitiveUser;
- (void)setPrimitiveUser:(MTUser*)value;


@end
