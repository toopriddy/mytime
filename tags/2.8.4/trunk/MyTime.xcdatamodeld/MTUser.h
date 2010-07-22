//
//  MTUser.h
//  MyTime
//
//  Created by Brent Priddy on 5/28/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@class MTAdditionalInformationType;
@class MTBulkPlacement;
@class MTCall;
@class MTPresentation;
@class MTStartTimestamp;
@class MTStatisticsAdjustment;
@class MTTerritory;
@class MTTimeType;

@interface MTUser :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * firstViewTitle;
@property (nonatomic, retain) NSNumber * monthDisplayCount;
@property (nonatomic, retain) NSString * secondViewTitle;
@property (nonatomic, retain) NSString * publisherType;
@property (nonatomic, retain) NSString * thirdViewTitle;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * fourthViewTitle;
@property (nonatomic, retain) NSSet* calls;
@property (nonatomic, retain) NSSet* presentations;
@property (nonatomic, retain) NSSet* bulkPlacements;
@property (nonatomic, retain) NSSet* timeTypes;
@property (nonatomic, retain) NSSet* additionalInformationTypes;
@property (nonatomic, retain) NSSet* startTimestamps;
@property (nonatomic, retain) NSSet* territories;
@property (nonatomic, retain) NSSet* statisticsAdjustments;

@end


@interface MTUser (CoreDataGeneratedAccessors)
- (void)addCallsObject:(MTCall *)value;
- (void)removeCallsObject:(MTCall *)value;
- (void)addCalls:(NSSet *)value;
- (void)removeCalls:(NSSet *)value;

- (void)addPresentationsObject:(MTPresentation *)value;
- (void)removePresentationsObject:(MTPresentation *)value;
- (void)addPresentations:(NSSet *)value;
- (void)removePresentations:(NSSet *)value;

- (void)addBulkPlacementsObject:(MTBulkPlacement *)value;
- (void)removeBulkPlacementsObject:(MTBulkPlacement *)value;
- (void)addBulkPlacements:(NSSet *)value;
- (void)removeBulkPlacements:(NSSet *)value;

- (void)addTimeTypesObject:(MTTimeType *)value;
- (void)removeTimeTypesObject:(MTTimeType *)value;
- (void)addTimeTypes:(NSSet *)value;
- (void)removeTimeTypes:(NSSet *)value;

- (void)addAdditionalInformationTypesObject:(MTAdditionalInformationType *)value;
- (void)removeAdditionalInformationTypesObject:(MTAdditionalInformationType *)value;
- (void)addAdditionalInformationTypes:(NSSet *)value;
- (void)removeAdditionalInformationTypes:(NSSet *)value;

- (void)addStartTimestampsObject:(MTStartTimestamp *)value;
- (void)removeStartTimestampsObject:(MTStartTimestamp *)value;
- (void)addStartTimestamps:(NSSet *)value;
- (void)removeStartTimestamps:(NSSet *)value;

- (void)addTerritoriesObject:(MTTerritory *)value;
- (void)removeTerritoriesObject:(MTTerritory *)value;
- (void)addTerritories:(NSSet *)value;
- (void)removeTerritories:(NSSet *)value;

- (void)addStatisticsAdjustmentsObject:(MTStatisticsAdjustment *)value;
- (void)removeStatisticsAdjustmentsObject:(MTStatisticsAdjustment *)value;
- (void)addStatisticsAdjustments:(NSSet *)value;
- (void)removeStatisticsAdjustments:(NSSet *)value;

@end

