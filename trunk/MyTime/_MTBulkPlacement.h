// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTBulkPlacement.h instead.

#import <CoreData/CoreData.h>


@class MTPublication;
@class MTUser;




@interface MTBulkPlacementID : NSManagedObjectID {}
@end

@interface _MTBulkPlacement : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MTBulkPlacementID*)objectID;



@property (nonatomic, retain) NSString *notes;

//- (BOOL)validateNotes:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *date;

//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* publications;
- (NSMutableSet*)publicationsSet;



@property (nonatomic, retain) MTUser* user;
//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;




@end

@interface _MTBulkPlacement (CoreDataGeneratedAccessors)

- (void)addPublications:(NSSet*)value_;
- (void)removePublications:(NSSet*)value_;
- (void)addPublicationsObject:(MTPublication*)value_;
- (void)removePublicationsObject:(MTPublication*)value_;

@end

@interface _MTBulkPlacement (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveNotes;
- (void)setPrimitiveNotes:(NSString*)value;




- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;





- (NSMutableSet*)primitivePublications;
- (void)setPrimitivePublications:(NSMutableSet*)value;



- (MTUser*)primitiveUser;
- (void)setPrimitiveUser:(MTUser*)value;


@end
