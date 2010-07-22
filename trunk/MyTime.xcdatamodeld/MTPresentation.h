//
//  MTPresentation.h
//  MyTime
//
//  Created by Brent Priddy on 5/28/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@class MTUser;

@interface MTPresentation :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * downloaded;
@property (nonatomic, retain) MTUser * user;

@end



