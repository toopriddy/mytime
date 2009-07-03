//
//  Settings.m
//  MyTime
//
//  Created by Brent Priddy on 7/24/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "Settings.h"
#import "PSLocalization.h"


static Settings *instance = nil;

NSString * const CallName = @"name";
NSString * const CallStreetNumber = @"streetNumber";
NSString * const CallApartmentNumber = @"apartmentNumber";
NSString * const CallStreet = @"street";
NSString * const CallCity = @"city";
NSString * const CallState = @"state";
NSString * const CallLattitudeLongitude = @"latLong";
NSString * const CallLocationType = @"locationType";

#include "PSRemoveLocalizedString.h"
NSString * const CallLocationTypeManual = NSLocalizedString(@"Manually pick Location", @"Label for picking the location lookup type");
NSString * const CallLocationTypeGoogleMaps = NSLocalizedString(@"Locate using google Maps", @"Label for picking the location lookup type");
NSString * const CallLocationTypeDoNotShow = NSLocalizedString(@"Do not show in map", @"Label for picking the location lookup type when they do not want the return visit to show up in the map");
#include "PSAddLocalizedString.h"

NSString * const CallMetadata = @"metadata";
NSString * const CallMetadataName = @"name";
NSString * const CallMetadataType = @"type";
NSString * const CallMetadataData = @"data";
NSString * const CallMetadataValue = @"value";
NSString * const CallReturnVisits = @"returnVisits";
NSString * const CallReturnVisitNotes = @"notes";
NSString * const CallReturnVisitDate = @"date";
NSString * const CallReturnVisitType = @"type";
NSString * const CallReturnVisitPublications = @"publications";
NSString * const CallReturnVisitPublicationTitle = @"title";
NSString * const CallReturnVisitPublicationType = @"type";
NSString * const CallReturnVisitPublicationName = @"name";
NSString * const CallReturnVisitPublicationYear = @"year";
NSString * const CallReturnVisitPublicationMonth = @"month";
NSString * const CallReturnVisitPublicationDay = @"day";

extern NSString * const CallReturnVisitTypeTransferedStudy;
extern NSString * const CallReturnVisitTypeTransferedNotAtHome;
extern NSString * const CallReturnVisitTypeTransferedReturnVisit;

#include "PSRemoveLocalizedString.h"
NSString * const CallReturnVisitTypeTransferedStudy = NSLocalizedString(@"Transfered Study", @"return visit type name when this call is transfered from another witness");
NSString * const CallReturnVisitTypeTransferedNotAtHome = NSLocalizedString(@"Transfered Not At Home", @"return visit type name when this call is transfered from another witness");
NSString * const CallReturnVisitTypeTransferedReturnVisit = NSLocalizedString(@"Transfered Return Visit", @"return visit type name when this call is transfered from another witness");
NSString * const CallReturnVisitTypeReturnVisit = NSLocalizedString(@"Return Visit", @"return visit type name");
NSString * const CallReturnVisitTypeStudy = NSLocalizedString(@"Study", @"return visit type name");
NSString * const CallReturnVisitTypeNotAtHome = NSLocalizedString(@"Not At Home", @"return visit type name");
#include "PSAddLocalizedString.h"

NSString * const SettingsBulkLiterature = @"bulkLiterature";
NSString * const BulkLiteratureDate = @"date";
NSString * const BulkLiteratureArray = @"literature";
NSString * const BulkLiteratureArrayCount = @"count";
NSString * const BulkLiteratureArrayTitle = @"title";
NSString * const BulkLiteratureArrayType = @"type";
NSString * const BulkLiteratureArrayName = @"name";
NSString * const BulkLiteratureArrayYear = @"year";
NSString * const BulkLiteratureArrayMonth = @"month";
NSString * const BulkLiteratureArrayDay = @"day";

NSString * const SettingsLastLattitude = @"lastLattitude";
NSString * const SettingsLastLongitude = @"lastLongitude";

NSString * const SettingsCalls = @"calls";
NSString * const SettingsDeletedCalls = @"deletedCalls";
NSString * const SettingsMagazinePlacements = @"magazinePlacements";

NSString * const SettingsLastCallStreetNumber = @"lastStreetNumber";
NSString * const SettingsLastCallApartmentNumber = @"lastApartmentNumber";
NSString * const SettingsLastCallStreet = @"lastStreet";
NSString * const SettingsLastCallCity = @"lastCity";
NSString * const SettingsLastCallState = @"lastState";
NSString * const SettingsCurrentButtonBarIndex = @"currentButtonBarIndex";

NSString * const SettingsTimeAlertSheetShown = @"timeAlertShown";
NSString * const SettingsStatisticsAlertSheetShown = @"statisticsAlertShown2";
NSString * const SettingsSecretaryEmailAddress = @"secretaryEmail";
NSString * const SettingsSecretaryEmailNotes = @"secretaryNotes";
NSString * const SettingsBulkLiteratureAlertSheetShown = @"bulkLiteratureAlertShown";
NSString * const SettingsExistingCallAlertSheetShown = @"existingCallAlertShown";

NSString * const SettingsMetadata = @"metadata";
NSString * const SettingsOtherMetadata = @"otherMetadata";
NSString * const SettingsMetadataName = @"name";
NSString * const SettingsMetadataType = @"type";
NSString * const SettingsMetadataValue = @"value";
NSString * const SettingsMetadataData = @"data";

NSString * const SettingsPreferredMetadata = @"preferredMetadata";
NSString * const SettingsSortedByMetadata = @"sortedByMetadata";


NSString * const SettingsMainAlertSheetShown = @"mainAlertShown2";

NSString * const SettingsMonthDisplayCount = @"monthDisplaycount";

NSString * const SettingsMultipleUsersCurrentUser = @"currentUser";
NSString * const SettingsMultipleUsers = @"multipleUsers";
NSString * const SettingsMultipleUsersName = @"name";

NSString * const SettingsTimeStartDate = @"timeStartDate";
NSString * const SettingsRBCTimeStartDate = @"rbcTimeStartDate";
NSString * const SettingsTimeEntries = @"timeEntries";
NSString * const SettingsRBCTimeEntries = @"quickBuildEntries";
NSString * const SettingsTimeEntryDate = @"date";
NSString * const SettingsTimeEntryMinutes = @"minutes";


NSString * const SettingsDonated = @"donated";
NSString * const SettingsFirstView = @"firstView";
NSString * const SettingsSecondView = @"secondView";
NSString * const SettingsThirdView = @"thirdView";
NSString * const SettingsFourthView = @"fourthView";

NSString * const SettingsPublisherType = @"publisherType";

#include "PSRemoveLocalizedString.h"
NSString * const PublisherTypePublisher = NSLocalizedString(@"Publisher", @"publisher type selected in the More->Settings->Publisher Type setting");
NSString * const PublisherTypeAuxilliaryPioneer = NSLocalizedString(@"Auxilliary Pioneer", @"publisher type selected in the More->Settings->Publisher Type setting");
NSString * const PublisherTypePioneer = NSLocalizedString(@"Pioneer", @"publisher type selected in the More->Settings->Publisher Type setting");
NSString * const PublisherTypeSpecialPioneer = NSLocalizedString(@"Special Pioneer", @"publisher type selected in the More->Settings->Publisher Type setting");
NSString * const PublisherTypeTravelingServant = NSLocalizedString(@"Traveling Servant", @"publisher type selected in the More->Settings->Publisher Type setting");
#include "PSAddLocalizedString.h"

@implementation Settings

@synthesize settings;
@synthesize userSettings;

+ (Settings *)sharedInstance
{
    @synchronized(self) 
	{
        if(instance == nil) 
		{
            instance = [[self alloc] init]; // assignment not done here
			[instance readData];
        }
    }

    return instance;
}

- (void)dealloc
{
	[super dealloc];
}

+ (id)initWithZone:(NSZone *)zone
{
    @synchronized(self) 
	{
        if(instance == nil) 
		{
            instance = [super allocWithZone:zone];
            return instance;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (NSString *)filename
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"records.plist"];
}

- (void)moveSettingsForKey:(NSString *)item user:(NSMutableDictionary *)user
{
	NSObject *object = [self.settings objectForKey:item];
	if(object)
	{
		// move the calls to the user account;
		NSObject *userObject = [user objectForKey:item];
		if(userObject)
		{
			// if the user has an array type, then add to it, otherwise replace it... :(
			if([userObject isKindOfClass:[NSArray class]] && [object isKindOfClass:[NSArray class]])
			{
				NSMutableArray *userArray = (NSMutableArray *)userObject;
				NSMutableArray *array = (NSMutableArray *)object;
				[userArray addObjectsFromArray:array];
			}
			else
			{
				[user setObject:object forKey:item];
			}
		}
		else
		{
			[user setObject:object forKey:item];
		}
		
		// remove the object from the main settings
		[self.settings removeObjectForKey:item];
	}
}

- (NSMutableDictionary *)findUserNamed:(NSString *)username
{
	NSMutableArray *users = [self.settings objectForKey:SettingsMultipleUsers];
	
	for(NSMutableDictionary *user in users)
	{
		if([[user objectForKey:SettingsMultipleUsersName] isEqualToString:username])
		{
			return user;
		}
	}
	
	return nil;
}
	
- (NSMutableDictionary *)findOrCreateUserNamed:(NSString *)username
{
	NSMutableDictionary *user = [self findUserNamed:username];
	if(user)
		return user;
	
	// we did not find one, so create a user for this username
	user = [NSMutableDictionary dictionaryWithObjectsAndKeys:username, SettingsMultipleUsersName, nil];
	NSMutableArray *users = [self.settings objectForKey:SettingsMultipleUsers];
	[users addObject:user];
	return user;
}

- (void)changeSettingsToUser:(NSString *)username save:(BOOL)save
{
	NSMutableDictionary *user = [self findOrCreateUserNamed:username];
	
	self.userSettings = user;
	[self.settings setObject:username forKey:SettingsMultipleUsersCurrentUser];
	if(save)
		[self saveData];
}

- (BOOL)hasOldData
{
	return	[self.settings objectForKey:SettingsCalls] ||
			[self.settings objectForKey:SettingsDeletedCalls] ||
			[self.settings objectForKey:SettingsBulkLiterature] ||
			[self.settings objectForKey:SettingsOtherMetadata] ||
			[self.settings objectForKey:SettingsMetadata] ||
			[self.settings objectForKey:SettingsPreferredMetadata] ||
			[self.settings objectForKey:SettingsMonthDisplayCount] ||
			[self.settings objectForKey:SettingsTimeStartDate] ||
			[self.settings objectForKey:SettingsRBCTimeStartDate] ||
			[self.settings objectForKey:SettingsTimeEntries] ||
			[self.settings objectForKey:SettingsRBCTimeEntries] ||
			[self.settings objectForKey:SettingsPublisherType];
}

- (void)readData
{
	VERY_VERBOSE(NSLog(@"readData");)
#if 1
	NSData *data = [[NSData alloc] initWithContentsOfFile:[self filename]];
	NSString *err = nil;
	NSPropertyListFormat format;
	self.settings = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&err];
	[data release];
	if(err)
	{
		NSLog(@"%@", err);
	}
#else
	self.settings = [[[NSMutableDictionary alloc] initWithContentsOfFile:[self filename]] autorelease];
#endif
	if(self.settings == nil)
	{
		self.settings = [[[NSMutableDictionary alloc] init] autorelease];
	}
	else
	{
//		VERBOSE(NSLog(@"restored data from file:\n%@", self.settings);)
	}

	
	NSArray *users = [self.settings objectForKey:SettingsMultipleUsers];
	NSString *currentUser = [self.settings objectForKey:SettingsMultipleUsersCurrentUser];
	NSMutableDictionary *user;
	BOOL save = NO;
	
	if(currentUser == nil || users == nil || [self hasOldData])
	{
		save = YES;
		if(currentUser == nil)
		{
			currentUser = NSLocalizedString(@"Default User", @"Multiple Users: the default user name when the user has not entered a name for themselves");
			int i = 0;
			// if this user exists, make another one.
			while([self findUserNamed:currentUser] != nil)
			{
				currentUser = [NSString stringWithFormat:@"%@ %u", currentUser, i];
				i++;
			}
			[self.settings setObject:currentUser forKey:SettingsMultipleUsersCurrentUser];
		}
		
		if(users == nil)
		{
			users = [NSMutableArray array];
			[self.settings setObject:users forKey:SettingsMultipleUsers];
		}
		user = [self findOrCreateUserNamed:currentUser];

		// this is the old storage method, 
		//move settings around...
		[self moveSettingsForKey:SettingsMetadata user:user];
		[self moveSettingsForKey:SettingsPreferredMetadata user:user];
		[self moveSettingsForKey:SettingsOtherMetadata user:user];
		[self moveSettingsForKey:SettingsSortedByMetadata user:user];
		
		[self moveSettingsForKey:SettingsCalls user:user];
		[self moveSettingsForKey:SettingsDeletedCalls user:user];
		[self moveSettingsForKey:SettingsBulkLiterature user:user];
		[self moveSettingsForKey:SettingsMonthDisplayCount user:user];
		[self moveSettingsForKey:SettingsTimeStartDate user:user];
		[self moveSettingsForKey:SettingsRBCTimeStartDate user:user];
		[self moveSettingsForKey:SettingsTimeEntries user:user];
		[self moveSettingsForKey:SettingsRBCTimeEntries user:user];
		[self moveSettingsForKey:SettingsPublisherType user:user];
	}
	
	[self changeSettingsToUser:currentUser save:save];
}

- (void)saveData
{
	VERY_VERBOSE(NSLog(@"saveData");)
	[self.settings writeToFile:[self filename] atomically: YES];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

+ (void)formatStreetNumber:(NSString *)houseNumber apartment:(NSString *)apartmentNumber street:(NSString *)street city:(NSString *)city state:(NSString *)state topLine:(NSMutableString *)top bottomLine:(NSMutableString *)bottom
{
	if(top)
		[top setString:@""];
	if(bottom)
		[bottom setString:@""];

	if(top)
	{
		if(houseNumber && [houseNumber length] && apartmentNumber && [apartmentNumber length] && street && [street length])
			[top appendFormat:NSLocalizedString(@"%@ #%@ %@ ", @"House number, apartment number and Street represented by %1$@ as the house number, %2$@ as the apartment number, notice the # before it that will be there as 'number ...' and then %3$@ as the street name"), houseNumber, apartmentNumber, street];
		else if(houseNumber && [houseNumber length] && street && [street length])
			[top appendFormat:NSLocalizedString(@"%@ %@", @"House number and Street represented by %1$@ as the house number and %2$@ as the street name"), houseNumber, street];
		else if(houseNumber && [houseNumber length] && apartmentNumber && [apartmentNumber length])
			[top appendFormat:NSLocalizedString(@"%@ #%@", @"House number and apartment number represented by %1$@ as the house number and %2$@ as the apartment number"), houseNumber, apartmentNumber];
		else if(houseNumber && [houseNumber length])
			[top appendFormat:houseNumber];
		else if(street && [street length] && apartmentNumber && [apartmentNumber length])
			[top appendFormat:NSLocalizedString(@"#%@ %@", @"Apartment Number and street name represented by %1$@ as the apartment number and %2$@ as the street name"), apartmentNumber, street];
		else if(street && [street length])
			[top appendFormat:street];
		else if(apartmentNumber && [apartmentNumber length])
			[top appendFormat:apartmentNumber];
	}
	if(bottom)
	{
		if(city != nil && [city length])
		{
			[bottom appendFormat:@"%@", city];
		}
		if(state != nil && [state length])
		{
			[bottom appendFormat:@", %@", state];
		}
	}
}



- (BOOL)respondsToSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"%s respondsToSelector: %s", __FILE__, selector);)
    return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"%s methodSignatureForSelector: %s", __FILE__, selector);)
    return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    VERY_VERBOSE(NSLog(@"%s forwardInvocation: %s", __FILE__, [invocation selector]);)
    [super forwardInvocation:invocation];
}



@end

