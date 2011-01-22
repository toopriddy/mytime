// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTPresentation.h instead.

#import <CoreData/CoreData.h>


@class MTUser;





@interface MTPresentationID : NSManagedObjectID {}
@end

@interface _MTPresentation : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MTPresentationID*)objectID;



@property (nonatomic, retain) NSNumber *order;

@property int orderValue;
- (int)orderValue;
- (void)setOrderValue:(int)value_;

//- (BOOL)validateOrder:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *notes;

//- (BOOL)validateNotes:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *downloaded;

@property BOOL downloadedValue;
- (BOOL)downloadedValue;
- (void)setDownloadedValue:(BOOL)value_;

//- (BOOL)validateDownloaded:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) MTUser* user;
//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;



@end

@interface _MTPresentation (CoreDataGeneratedAccessors)

@end

@interface _MTPresentation (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveOrder;
- (void)setPrimitiveOrder:(NSNumber*)value;

- (int)primitiveOrderValue;
- (void)setPrimitiveOrderValue:(int)value_;


- (NSString*)primitiveNotes;
- (void)setPrimitiveNotes:(NSString*)value;


- (NSNumber*)primitiveDownloaded;
- (void)setPrimitiveDownloaded:(NSNumber*)value;

- (BOOL)primitiveDownloadedValue;
- (void)setPrimitiveDownloadedValue:(BOOL)value_;




- (MTUser*)primitiveUser;
- (void)setPrimitiveUser:(MTUser*)value;


@end
