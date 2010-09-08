// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTUser.h instead.

#import <CoreData/CoreData.h>


@class MTTimeType;
@class MTStatisticsAdjustment;
@class MTBulkPlacement;
@class MTTerritory;
@class MTPresentation;
@class MTAdditionalInformationType;
@class MTCall;
@class MTStartTimestamp;










@interface MTUserID : NSManagedObjectID {}
@end

@interface _MTUser : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MTUserID*)objectID;



@property (nonatomic, retain) NSNumber *monthDisplayCount;

@property short monthDisplayCountValue;
- (short)monthDisplayCountValue;
- (void)setMonthDisplayCountValue:(short)value_;

//- (BOOL)validateMonthDisplayCount:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *firstViewTitle;

//- (BOOL)validateFirstViewTitle:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *order;

@property double orderValue;
- (double)orderValue;
- (void)setOrderValue:(double)value_;

//- (BOOL)validateOrder:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *thirdViewTitle;

//- (BOOL)validateThirdViewTitle:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *fourthViewTitle;

//- (BOOL)validateFourthViewTitle:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *secondViewTitle;

//- (BOOL)validateSecondViewTitle:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *publisherType;

//- (BOOL)validatePublisherType:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* timeTypes;
- (NSMutableSet*)timeTypesSet;



@property (nonatomic, retain) NSSet* statisticsAdjustments;
- (NSMutableSet*)statisticsAdjustmentsSet;



@property (nonatomic, retain) NSSet* bulkPlacements;
- (NSMutableSet*)bulkPlacementsSet;



@property (nonatomic, retain) NSSet* territories;
- (NSMutableSet*)territoriesSet;



@property (nonatomic, retain) NSSet* presentations;
- (NSMutableSet*)presentationsSet;



@property (nonatomic, retain) NSSet* additionalInformationTypes;
- (NSMutableSet*)additionalInformationTypesSet;



@property (nonatomic, retain) NSSet* calls;
- (NSMutableSet*)callsSet;



@property (nonatomic, retain) NSSet* startTimestamps;
- (NSMutableSet*)startTimestampsSet;



@end

@interface _MTUser (CoreDataGeneratedAccessors)

- (void)addTimeTypes:(NSSet*)value_;
- (void)removeTimeTypes:(NSSet*)value_;
- (void)addTimeTypesObject:(MTTimeType*)value_;
- (void)removeTimeTypesObject:(MTTimeType*)value_;

- (void)addStatisticsAdjustments:(NSSet*)value_;
- (void)removeStatisticsAdjustments:(NSSet*)value_;
- (void)addStatisticsAdjustmentsObject:(MTStatisticsAdjustment*)value_;
- (void)removeStatisticsAdjustmentsObject:(MTStatisticsAdjustment*)value_;

- (void)addBulkPlacements:(NSSet*)value_;
- (void)removeBulkPlacements:(NSSet*)value_;
- (void)addBulkPlacementsObject:(MTBulkPlacement*)value_;
- (void)removeBulkPlacementsObject:(MTBulkPlacement*)value_;

- (void)addTerritories:(NSSet*)value_;
- (void)removeTerritories:(NSSet*)value_;
- (void)addTerritoriesObject:(MTTerritory*)value_;
- (void)removeTerritoriesObject:(MTTerritory*)value_;

- (void)addPresentations:(NSSet*)value_;
- (void)removePresentations:(NSSet*)value_;
- (void)addPresentationsObject:(MTPresentation*)value_;
- (void)removePresentationsObject:(MTPresentation*)value_;

- (void)addAdditionalInformationTypes:(NSSet*)value_;
- (void)removeAdditionalInformationTypes:(NSSet*)value_;
- (void)addAdditionalInformationTypesObject:(MTAdditionalInformationType*)value_;
- (void)removeAdditionalInformationTypesObject:(MTAdditionalInformationType*)value_;

- (void)addCalls:(NSSet*)value_;
- (void)removeCalls:(NSSet*)value_;
- (void)addCallsObject:(MTCall*)value_;
- (void)removeCallsObject:(MTCall*)value_;

- (void)addStartTimestamps:(NSSet*)value_;
- (void)removeStartTimestamps:(NSSet*)value_;
- (void)addStartTimestampsObject:(MTStartTimestamp*)value_;
- (void)removeStartTimestampsObject:(MTStartTimestamp*)value_;

@end

@interface _MTUser (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveMonthDisplayCount;
- (void)setPrimitiveMonthDisplayCount:(NSNumber*)value;

- (short)primitiveMonthDisplayCountValue;
- (void)setPrimitiveMonthDisplayCountValue:(short)value_;


- (NSString*)primitiveFirstViewTitle;
- (void)setPrimitiveFirstViewTitle:(NSString*)value;


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;


- (NSNumber*)primitiveOrder;
- (void)setPrimitiveOrder:(NSNumber*)value;

- (double)primitiveOrderValue;
- (void)setPrimitiveOrderValue:(double)value_;


- (NSString*)primitiveThirdViewTitle;
- (void)setPrimitiveThirdViewTitle:(NSString*)value;


- (NSString*)primitiveFourthViewTitle;
- (void)setPrimitiveFourthViewTitle:(NSString*)value;


- (NSString*)primitiveSecondViewTitle;
- (void)setPrimitiveSecondViewTitle:(NSString*)value;


- (NSString*)primitivePublisherType;
- (void)setPrimitivePublisherType:(NSString*)value;




- (NSMutableSet*)primitiveTimeTypes;
- (void)setPrimitiveTimeTypes:(NSMutableSet*)value;



- (NSMutableSet*)primitiveStatisticsAdjustments;
- (void)setPrimitiveStatisticsAdjustments:(NSMutableSet*)value;



- (NSMutableSet*)primitiveBulkPlacements;
- (void)setPrimitiveBulkPlacements:(NSMutableSet*)value;



- (NSMutableSet*)primitiveTerritories;
- (void)setPrimitiveTerritories:(NSMutableSet*)value;



- (NSMutableSet*)primitivePresentations;
- (void)setPrimitivePresentations:(NSMutableSet*)value;



- (NSMutableSet*)primitiveAdditionalInformationTypes;
- (void)setPrimitiveAdditionalInformationTypes:(NSMutableSet*)value;



- (NSMutableSet*)primitiveCalls;
- (void)setPrimitiveCalls:(NSMutableSet*)value;



- (NSMutableSet*)primitiveStartTimestamps;
- (void)setPrimitiveStartTimestamps:(NSMutableSet*)value;


@end
