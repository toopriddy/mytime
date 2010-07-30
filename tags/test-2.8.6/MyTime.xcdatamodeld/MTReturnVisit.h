//
//  MTReturnVisit.h
//  MyTime
//
//  Created by Brent Priddy on 5/28/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@class MTCall;
@class MTPublication;

@interface MTReturnVisit :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) MTCall * call;
@property (nonatomic, retain) NSSet* publications;

@end


@interface MTReturnVisit (CoreDataGeneratedAccessors)
- (void)addPublicationsObject:(MTPublication *)value;
- (void)removePublicationsObject:(MTPublication *)value;
- (void)addPublications:(NSSet *)value;
- (void)removePublications:(NSSet *)value;

@end

