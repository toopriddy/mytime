// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTSorter.h instead.

#import <CoreData/CoreData.h>


@class MTDisplayRule;




@interface MTSorterID : NSManagedObjectID {}
@end

@interface _MTSorter : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MTSorterID*)objectID;



@property (nonatomic, retain) NSString *path;

//- (BOOL)validatePath:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *ascending;

@property BOOL ascendingValue;
- (BOOL)ascendingValue;
- (void)setAscendingValue:(BOOL)value_;

//- (BOOL)validateAscending:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) MTDisplayRule* displayRule;
//- (BOOL)validateDisplayRule:(id*)value_ error:(NSError**)error_;



@end

@interface _MTSorter (CoreDataGeneratedAccessors)

@end

@interface _MTSorter (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitivePath;
- (void)setPrimitivePath:(NSString*)value;


- (NSNumber*)primitiveAscending;
- (void)setPrimitiveAscending:(NSNumber*)value;

- (BOOL)primitiveAscendingValue;
- (void)setPrimitiveAscendingValue:(BOOL)value_;




- (MTDisplayRule*)primitiveDisplayRule;
- (void)setPrimitiveDisplayRule:(MTDisplayRule*)value;


@end
