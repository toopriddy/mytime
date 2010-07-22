//
//  MTBulkPlacement.h
//  MyTime
//
//  Created by Brent Priddy on 5/28/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@class MTPublication;
@class MTUser;

@interface MTBulkPlacement :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSSet* publications;
@property (nonatomic, retain) MTUser * user;

@end


@interface MTBulkPlacement (CoreDataGeneratedAccessors)
- (void)addPublicationsObject:(MTPublication *)value;
- (void)removePublicationsObject:(MTPublication *)value;
- (void)addPublications:(NSSet *)value;
- (void)removePublications:(NSSet *)value;

@end

