//
//  MTTimeEntry.h
//  MyTime
//
//  Created by Brent Priddy on 5/28/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@class MTTimeType;

@interface MTTimeEntry :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * minutes;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) MTTimeType * type;

@end



