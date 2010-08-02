//
//  MTStatisticsAdjustment.h
//  MyTime
//
//  Created by Brent Priddy on 5/28/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@class MTUser;

@interface MTStatisticsAdjustment :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * adjustment;
@property (nonatomic, retain) MTUser * user;

@end



