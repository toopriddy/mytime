//
//  MTTerritoryHouse.h
//  MyTime
//
//  Created by Brent Priddy on 5/28/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@class MTTerritoryStreet;

@interface MTTerritoryHouse :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * apartment;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * attempts;
@property (nonatomic, retain) MTTerritoryStreet * street;

@end



