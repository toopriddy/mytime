//
//  MTTerritory.h
//  MyTime
//
//  Created by Brent Priddy on 5/28/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@class MTTerritoryStreet;
@class MTUser;

@interface MTTerritory :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * ownerId;
@property (nonatomic, retain) NSString * ownerEmailId;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * ownerEmailAddress;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* streets;
@property (nonatomic, retain) MTUser * user;

@end


@interface MTTerritory (CoreDataGeneratedAccessors)
- (void)addStreetsObject:(MTTerritoryStreet *)value;
- (void)removeStreetsObject:(MTTerritoryStreet *)value;
- (void)addStreets:(NSSet *)value;
- (void)removeStreets:(NSSet *)value;

@end

