//
//  MTPublication.h
//  MyTime
//
//  Created by Brent Priddy on 5/28/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@class MTBulkPlacement;
@class MTReturnVisit;

@interface MTPublication :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * day;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * month;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) MTReturnVisit * returnVisit;
@property (nonatomic, retain) MTBulkPlacement * newRelationship;

@end



