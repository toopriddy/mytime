//
//  MTAdditionalInformationType.h
//  MyTime
//
//  Created by Brent Priddy on 5/28/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@class MTAdditionalInformation;
@class MTUser;

@interface MTAdditionalInformationType :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * hidden;
@property (nonatomic, retain) NSNumber * alwaysShown;
@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) MTAdditionalInformation * additionalInformation;
@property (nonatomic, retain) MTUser * user;

@end



