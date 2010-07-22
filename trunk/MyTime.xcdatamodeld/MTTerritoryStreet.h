//
//  MTTerritoryStreet.h
//  MyTime
//
//  Created by Brent Priddy on 5/28/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@class MTTerritory;
@class MTTerritoryHouse;

@interface MTTerritoryStreet :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSSet* houses;
@property (nonatomic, retain) MTTerritory * territory;

@end


@interface MTTerritoryStreet (CoreDataGeneratedAccessors)
- (void)addHousesObject:(MTTerritoryHouse *)value;
- (void)removeHousesObject:(MTTerritoryHouse *)value;
- (void)addHouses:(NSSet *)value;
- (void)removeHouses:(NSSet *)value;

@end

