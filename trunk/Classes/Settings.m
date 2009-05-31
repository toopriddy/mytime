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

NSString const * const CallName = @"name";
NSString const * const CallStreetNumber = @"streetNumber";
NSString const * const CallApartmentNumber = @"apartmentNumber";
NSString const * const CallStreet = @"street";
NSString const * const CallCity = @"city";
NSString const * const CallState = @"state";
NSString const * const CallLattitudeLongitude = @"latLong";
NSString const * const CallLocationType = @"locationType";
NSString const * const CallLocationTypeManual = AlternateLocalizedString(@"Manually pick Location", @"Label for picking the location lookup type");
NSString const * const CallLocationTypeGoogleMaps = AlternateLocalizedString(@"Locate using google Maps", @"Label for picking the location lookup type");
NSString const * const CallLocationTypeDoNotShow = AlternateLocalizedString(@"Do not show in map", @"Label for picking the location lookup type when they do not want the return visit to show up in the map");

NSString const * const CallMetadata = @"metadata";
NSString const * const CallMetadataName = @"name";
NSString const * const CallMetadataType = @"type";
NSString const * const CallMetadataData = @"data";
NSString const * const CallMetadataValue = @"value";
NSString const * const CallReturnVisits = @"returnVisits";
NSString const * const CallReturnVisitNotes = @"notes";
NSString const * const CallReturnVisitDate = @"date";
NSString const * const CallReturnVisitType = @"type";
NSString const * const CallReturnVisitPublications = @"publications";
NSString const * const CallReturnVisitPublicationTitle = @"title";
NSString const * const CallReturnVisitPublicationType = @"type";
NSString const * const CallReturnVisitPublicationName = @"name";
NSString const * const CallReturnVisitPublicationYear = @"year";
NSString const * const CallReturnVisitPublicationMonth = @"month";
NSString const * const CallReturnVisitPublicationDay = @"day";

extern NSString const * const CallReturnVisitTypeTransferedStudy;
extern NSString const * const CallReturnVisitTypeTransferedNotAtHome;
extern NSString const * const CallReturnVisitTypeTransferedReturnVisit;

NSString const * const CallReturnVisitTypeTransferedStudy = AlternateLocalizedString(@"Transfered Study", @"return visit type name when this call is transfered from another witness");
NSString const * const CallReturnVisitTypeTransferedNotAtHome = AlternateLocalizedString(@"Transfered Not At Home", @"return visit type name when this call is transfered from another witness");
NSString const * const CallReturnVisitTypeTransferedReturnVisit = AlternateLocalizedString(@"Transfered Return Visit", @"return visit type name when this call is transfered from another witness");
NSString const * const CallReturnVisitTypeReturnVisit = AlternateLocalizedString(@"Return Visit", @"return visit type name");
NSString const * const CallReturnVisitTypeStudy = AlternateLocalizedString(@"Study", @"return visit type name");
NSString const * const CallReturnVisitTypeNotAtHome = AlternateLocalizedString(@"Not At Home", @"return visit type name");

NSString const * const SettingsBulkLiterature = @"bulkLiterature";
NSString const * const BulkLiteratureDate = @"date";
NSString const * const BulkLiteratureArray = @"literature";
NSString const * const BulkLiteratureArrayCount = @"count";
NSString const * const BulkLiteratureArrayTitle = @"title";
NSString const * const BulkLiteratureArrayType = @"type";
NSString const * const BulkLiteratureArrayName = @"name";
NSString const * const BulkLiteratureArrayYear = @"year";
NSString const * const BulkLiteratureArrayMonth = @"month";
NSString const * const BulkLiteratureArrayDay = @"day";

NSString const * const SettingsLastLattitude = @"lastLattitude";
NSString const * const SettingsLastLongitude = @"lastLongitude";

NSString const * const SettingsCalls = @"calls";
NSString const * const SettingsDeletedCalls = @"deletedCalls";
NSString const * const SettingsMagazinePlacements = @"magazinePlacements";

NSString const * const SettingsLastCallStreetNumber = @"lastStreetNumber";
NSString const * const SettingsLastCallApartmentNumber = @"lastApartmentNumber";
NSString const * const SettingsLastCallStreet = @"lastStreet";
NSString const * const SettingsLastCallCity = @"lastCity";
NSString const * const SettingsLastCallState = @"lastState";
NSString const * const SettingsCurrentButtonBarIndex = @"currentButtonBarIndex";

NSString const * const SettingsTimeAlertSheetShown = @"timeAlertShown";
NSString const * const SettingsStatisticsAlertSheetShown = @"statisticsAlertShown2";
NSString const * const SettingsSecretaryEmailAddress = @"secretaryEmail";
NSString const * const SettingsSecretaryEmailNotes = @"secretaryNotes";
NSString const * const SettingsBulkLiteratureAlertSheetShown = @"bulkLiteratureAlertShown";
NSString const * const SettingsExistingCallAlertSheetShown = @"existingCallAlertShown";

NSString const * const SettingsMetadata = @"metadata";
NSString const * const SettingsMetadataName = @"name";
NSString const * const SettingsMetadataType = @"type";
NSString const * const SettingsMetadataValue = @"value";
NSString const * const SettingsMetadataData = @"data";


NSString const * const SettingsMainAlertSheetShown = @"mainAlertShown2";

NSString const * const SettingsMonthDisplayCount = @"monthDisplaycount";

NSString const * const SettingsTimeStartDate = @"timeStartDate";
NSString const * const SettingsRBCTimeStartDate = @"rbcTimeStartDate";
NSString const * const SettingsTimeEntries = @"timeEntries";
NSString const * const SettingsRBCTimeEntries = @"quickBuildEntries";
NSString const * const SettingsTimeEntryDate = @"date";
NSString const * const SettingsTimeEntryMinutes = @"minutes";


NSString const * const SettingsDonated = @"donated";
NSString const * const SettingsFirstView = @"firstView";
NSString const * const SettingsSecondView = @"secondView";
NSString const * const SettingsThirdView = @"thirdView";
NSString const * const SettingsFourthView = @"fourthView";

NSString const * const SettingsPublisherType = @"publisherType";

NSString const * const PublisherTypePublisher = AlternateLocalizedString(@"Publisher", @"publisher type selected in the More->Settings->Publisher Type setting");
NSString const * const PublisherTypeAuxilliaryPioneer = AlternateLocalizedString(@"Auxilliary Pioneer", @"publisher type selected in the More->Settings->Publisher Type setting");
NSString const * const PublisherTypePioneer = AlternateLocalizedString(@"Pioneer", @"publisher type selected in the More->Settings->Publisher Type setting");
NSString const * const PublisherTypeSpecialPioneer = AlternateLocalizedString(@"Special Pioneer", @"publisher type selected in the More->Settings->Publisher Type setting");
NSString const * const PublisherTypeTravelingServent = AlternateLocalizedString(@"Traveling Servent", @"publisher type selected in the More->Settings->Publisher Type setting");


@implementation Settings

@synthesize settings;


+ (Settings *)sharedInstance
{
    @synchronized(self) 
	{
        if(instance == nil) 
		{
            instance = [[self alloc] init]; // assignment not done here
			instance.settings = nil;
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

- (void)readData
{
	VERY_VERBOSE(NSLog(@"readData");)
	[settings release];
	settings = [[NSMutableDictionary alloc] initWithContentsOfFile:[self filename]];
	if(settings == nil)
	{
		settings = [[NSMutableDictionary alloc] init];
	}
	else
	{
//		VERBOSE(NSLog(@"restored data from file:\n%@", settings);)
	}
}

- (void)saveData
{
	VERY_VERBOSE(NSLog(@"saveData");)
	[settings writeToFile:[self filename] atomically: YES];
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

