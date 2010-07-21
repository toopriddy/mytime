//
//  MTTimeType.h
//  MyTime
//
//  Created by Brent Priddy on 5/28/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@class MTTimeEntry;
@class MTUser;

@interface MTTimeType :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * startTimerDate;
@property (nonatomic, retain) NSString * imageFile;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * deleteable;
@property (nonatomic, retain) NSSet* timeEntries;
@property (nonatomic, retain) MTUser * user;

@end


@interface MTTimeType (CoreDataGeneratedAccessors)
- (void)addTimeEntriesObject:(MTTimeEntry *)value;
- (void)removeTimeEntriesObject:(MTTimeEntry *)value;
- (void)addTimeEntries:(NSSet *)value;
- (void)removeTimeEntries:(NSSet *)value;

@end

