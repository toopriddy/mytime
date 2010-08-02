//
//  MTAdditionalInformation.h
//  MyTime
//
//  Created by Brent Priddy on 5/28/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@class MTAdditionalInformationType;
@class MTCall;

@interface MTAdditionalInformation :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) MTCall * call;
@property (nonatomic, retain) MTAdditionalInformationType * type;

@end



