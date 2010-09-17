// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTReturnVisit.h instead.

#import <CoreData/CoreData.h>


@class MTPublication;
@class MTCall;





@interface MTReturnVisitID : NSManagedObjectID {}
@end

@interface _MTReturnVisit : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MTReturnVisitID*)objectID;



@property (nonatomic, retain) NSString *notes;

//- (BOOL)validateNotes:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *type;

//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *date;

//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* publications;
- (NSMutableSet*)publicationsSet;



@property (nonatomic, retain) MTCall* call;
//- (BOOL)validateCall:(id*)value_ error:(NSError**)error_;



@end

@interface _MTReturnVisit (CoreDataGeneratedAccessors)

- (void)addPublications:(NSSet*)value_;
- (void)removePublications:(NSSet*)value_;
- (void)addPublicationsObject:(MTPublication*)value_;
- (void)removePublicationsObject:(MTPublication*)value_;

@end

@interface _MTReturnVisit (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveNotes;
- (void)setPrimitiveNotes:(NSString*)value;


- (NSString*)primitiveType;
- (void)setPrimitiveType:(NSString*)value;


- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;




- (NSMutableSet*)primitivePublications;
- (void)setPrimitivePublications:(NSMutableSet*)value;



- (MTCall*)primitiveCall;
- (void)setPrimitiveCall:(MTCall*)value;


@end
