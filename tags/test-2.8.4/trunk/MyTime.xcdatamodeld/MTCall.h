//
//  MTCall.h
//  MyTime
//
//  Created by Brent Priddy on 5/28/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@class MTAdditionalInformation;
@class MTReturnVisit;
@class MTUser;

@interface MTCall :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * apartmentNumber;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * houseNumber;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSNumber * lattitude;
@property (nonatomic, retain) NSNumber * locationLookupType;
@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* additionalInformation;
@property (nonatomic, retain) MTUser * user;
@property (nonatomic, retain) NSSet* returnVisits;

@end


@interface MTCall (CoreDataGeneratedAccessors)
- (void)addAdditionalInformationObject:(MTAdditionalInformation *)value;
- (void)removeAdditionalInformationObject:(MTAdditionalInformation *)value;
- (void)addAdditionalInformation:(NSSet *)value;
- (void)removeAdditionalInformation:(NSSet *)value;

- (void)addReturnVisitsObject:(MTReturnVisit *)value;
- (void)removeReturnVisitsObject:(MTReturnVisit *)value;
- (void)addReturnVisits:(NSSet *)value;
- (void)removeReturnVisits:(NSSet *)value;

@end

