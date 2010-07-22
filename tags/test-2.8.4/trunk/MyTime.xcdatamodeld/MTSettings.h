//
//  MTSettings.h
//  MyTime
//
//  Created by Brent Priddy on 5/28/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface MTSettings :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * lastLongitude;
@property (nonatomic, retain) NSString * secretaryEmailAddress;
@property (nonatomic, retain) NSString * lastCity;
@property (nonatomic, retain) NSString * lastState;
@property (nonatomic, retain) NSNumber * autobackupInterval;
@property (nonatomic, retain) NSString * currentUser;
@property (nonatomic, retain) NSString * lastStreet;
@property (nonatomic, retain) NSString * lastHouseNumber;
@property (nonatomic, retain) NSString * passcode;
@property (nonatomic, retain) NSString * backupEmail;
@property (nonatomic, retain) NSNumber * newAttribute;
@property (nonatomic, retain) NSString * lastApartmentNumber;
@property (nonatomic, retain) NSNumber * lastLattitude;
@property (nonatomic, retain) NSDate * lastBackupDate;
@property (nonatomic, retain) NSString * secretaryEmailNotes;
@property (nonatomic, retain) NSNumber * backupShouldIncludeAttachment;

@end



