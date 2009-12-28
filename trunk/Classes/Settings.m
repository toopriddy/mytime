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
#import "PSUrlString.h"

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

NSString * const SettingsQuickNotes = @"quickNotes";

NSString * const SettingsTimeStartDate = @"timeStartDate";
NSString * const SettingsRBCTimeStartDate = @"rbcTimeStartDate";
NSString * const SettingsTimeEntries = @"timeEntries";
NSString * const SettingsRBCTimeEntries = @"quickBuildEntries";
NSString * const SettingsTimeEntryDate = @"date";
NSString * const SettingsTimeEntryMinutes = @"minutes";

NSString * const SettingsPasscode = @"passcode";
NSString * const SettingsLastBackupDate = @"lastBackup";
NSString * const SettingsAutoBackupInterval = @"autoBackupInterval";
NSString * const SettingsBackupEmailAddress = @"backupAddress";


NSString * const SettingsDonated = @"donated";
NSString * const SettingsFirstView = @"firstView";
NSString * const SettingsSecondView = @"secondView";
NSString * const SettingsThirdView = @"thirdView";
NSString * const SettingsFourthView = @"fourthView";

NSString * const SettingsNotAtHomeTerritories = @"notAtHomes";
NSString * const NotAtHomeTerritoryName = @"name";
NSString * const NotAtHomeTerritoryOwnerId = @"ownerId";
NSString * const NotAtHomeTerritoryOwnerEmailId = @"ownerEmailId";
NSString * const NotAtHomeTerritoryOwnerEmailAddress = @"ownerEmailAddress";
NSString * const NotAtHomeTerritoryStreets = @"streets";
NSString * const NotAtHomeTerritoryStreetName = @"name";
NSString * const NotAtHomeTerritoryCity = @"city";
NSString * const NotAtHomeTerritoryState = @"state";
NSString * const NotAtHomeTerritoryHouses = @"houses";
NSString * const NotAtHomeTerritoryHouseNumber = @"houseNumber";
NSString * const NotAtHomeTerritoryHouseAttempts = @"attempts";


NSString * const SettingsPublisherType = @"publisherType";

NSString *const UserDefaultsClearMapCache = @"clearMapCache";
NSString *const UserDefaultsEmailBackupInstantly = @"emailBackupInstantly";
NSString *const UserDefaultsRemovePasscode = @"removePasscode";


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


+ (MFMailComposeViewController *)sendEmailBackup
{
	MFMailComposeViewController *mailView = [[[MFMailComposeViewController alloc] init] autorelease];
	[mailView setSubject:NSLocalizedString(@"MyTime Application Data Backup", @"Email subject line for the email that has your backup data in it")];

	NSMutableString *string = [[NSMutableString alloc] init];
	[string appendString:NSLocalizedString(@"You are able to restore all of your MyTime data as of the sent date of this email if you click on the link below while viewing this email from your iPhone/iTouch. Please make sure that at the end of this email there is a \"VERIFICATION CHECK:\" right after the link, it verifies that all data is contained within this email<br><br>WARNING: CLICKING ON THE LINK BELOW WILL DELETE YOUR CURRENT DATA AND RESTORE FROM THE BACKUP<br><br>", @"This is the body of the email that is sent when you go to More->Settings->Email Backup")];
	
	// attach the real records file
	[mailView addAttachmentData:[[NSFileManager defaultManager] contentsAtPath:[[Settings sharedInstance] filename]] mimeType:@"text/plist" fileName:@"records.plist"];
	NSDictionary *settings = [[Settings sharedInstance] settings];

	NSString *toEmailAddress = [settings objectForKey:SettingsBackupEmailAddress];
	if(toEmailAddress)
	{
		[mailView setToRecipients:[toEmailAddress componentsSeparatedByString:@" "]];
	}
	// now add the url that will allow importing
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:settings];
	[string appendString:@"<a href=\"mytime://mytime/restoreBackup?"];
	int length = data.length;
	unsigned char *bytes = (unsigned char *)data.bytes;
	for(int i = 0; i < length; ++i)
	{
		[string appendFormat:@"%02X", *bytes++];
	}
	[string appendString:@"\">"];
	[string appendString:NSLocalizedString(@"If you want to restore from your backup, click on this link from your iPhone/iTouch", @"This is the text that appears in the link of the email when you are wanting to restore from a backup.  this is the link that they press to open MyTime")];
	[string appendString:@"</a><br><br>"];
	[string appendString:NSLocalizedString(@"VERIFICATION CHECK: all data was contained in this email", @"This is a very important message that is at the end of the email used to transfer a call to another witness or if you are just emailing a backup to yourself, it verifies that all of the data is contained in the email, if it is not there then all of the data is not in the email and something bad happened :(")];

	[mailView setMessageBody:string isHTML:YES];
	[string release];
	
	return mailView;
}

NSString *emailFormattedStringForTimeEntry(NSDictionary *timeEntry)
{
	NSMutableString *string = [NSMutableString string];
	NSNumber *time = [timeEntry objectForKey:SettingsTimeEntryMinutes];
	NSDate *date = [[[NSDate alloc] initWithTimeIntervalSinceReferenceDate:[[timeEntry objectForKey:SettingsTimeEntryDate] timeIntervalSinceReferenceDate]] autorelease];	
	// create dictionary entry for This Return Visit
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	if([[[NSLocale currentLocale] localeIdentifier] isEqualToString:@"en_GB"])
	{
		[dateFormatter setDateFormat:@"EEE, d/M/yyy"];
	}
	else
	{
		[dateFormatter setDateFormat:NSLocalizedString(@"EEE, M/d/yyy", @"localized date string string using http://unicode.org/reports/tr35/tr35-4.html#Date_Format_Patterns as a guide to how to format the date")];
	}
	
	[string appendString:[NSString stringWithFormat:@"%@ ", [dateFormatter stringFromDate:date]]];
	
	int minutes = [time intValue];
	int hours = minutes / 60;
	minutes %= 60;
	if(hours && minutes)
		[string appendString:[NSString stringWithFormat:NSLocalizedString(@"%d %@ %d %@", @"You are localizing the time (I dont know if you need to even change this) as in '1 hour 34 minutes' or '2 hours 1 minute' %1$d is the hours number %2$@ is the label for hour(s) %3$d is the minutes number and 4$%@ is the label for minutes(s)"), hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours"), minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")]];
	else if(hours)
		[string appendString:[NSString stringWithFormat:@"%d %@", hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours")]];
	else if(minutes || minutes == 0)
		[string appendString:[NSString stringWithFormat:@"%d %@", minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")]];
	[string appendString:@"<br>"];

	return string;
}

+ (MFMailComposeViewController *)sendPrintableEmailBackup
{
	MFMailComposeViewController *mailView = [[[MFMailComposeViewController alloc] init] autorelease];
	[mailView setSubject:NSLocalizedString(@"MyTime Application Printable Backup", @"Email subject line for the email that has a printable version of the mytime data")];
	
	NSMutableString *string = [[NSMutableString alloc] init];
	NSDictionary *settings = [[Settings sharedInstance] settings];

	NSString *toEmailAddress = [settings objectForKey:SettingsBackupEmailAddress];
	if(toEmailAddress)
	{
		[mailView setToRecipients:[toEmailAddress componentsSeparatedByString:@" "]];
	}
	
	NSArray *allUserSettings = [settings objectForKey:SettingsMultipleUsers];
	for(NSDictionary *userSettings in allUserSettings)
	{
		// the specific user
		[string appendString:[NSString stringWithFormat:NSLocalizedString(@"<h1>Backup data for %@:</h1>\n", @"label for sending a printable email backup.  this label is in the body of the email"), [userSettings objectForKey:SettingsMultipleUsersName]]];
		
		// calls
		[string appendString:NSLocalizedString(@"<h2>Calls:</h2>\n", @"label for sending a printable email backup.  this label is in the body of the email")];
		for(NSDictionary *call in [userSettings objectForKey:SettingsCalls])
		{
			[string appendString:emailFormattedStringForCall(call)];
		}
		
		// hours
		[string appendString:NSLocalizedString(@"<h2>Hours:</h2>\n", @"label for sending a printable email backup.  this label is in the body of the email")];
		for(NSDictionary *timeEntry in [userSettings objectForKey:SettingsTimeEntries])
		{
			[string appendString:emailFormattedStringForTimeEntry(timeEntry)];
		}
		
		// quickbuild
		[string appendString:NSLocalizedString(@"<h2>RBC Hours:</h2>\n", @"label for sending a printable email backup.  this label is in the body of the email")];
		for(NSDictionary *timeEntry in [userSettings objectForKey:SettingsRBCTimeEntries])
		{
			[string appendString:emailFormattedStringForTimeEntry(timeEntry)];
		}
		
		// Bulk Placements
		[string appendString:NSLocalizedString(@"<h2>Bulk Placements:</h2>\n", @"label for sending a printable email backup.  this label is in the body of the email")];
		for(NSDictionary *bulkPlacement in [userSettings objectForKey:SettingsBulkLiterature])
		{
			NSDate *date = [[[NSDate alloc] initWithTimeIntervalSinceReferenceDate:[[bulkPlacement objectForKey:BulkLiteratureDate] timeIntervalSinceReferenceDate]] autorelease];	
			// create dictionary entry for This Return Visit
			NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
			[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
			if([[[NSLocale currentLocale] localeIdentifier] isEqualToString:@"en_GB"])
			{
				[dateFormatter setDateFormat:@"EEE, d/M/yyy h:mma"];
			}
			else
			{
				[dateFormatter setDateFormat:NSLocalizedString(@"EEE, M/d/yyy", @"localized date string string using http://unicode.org/reports/tr35/tr35-4.html#Date_Format_Patterns as a guide to how to format the date")];
			}
			[string appendString:[NSString stringWithFormat:@"%@:<br>", [dateFormatter stringFromDate:date]]];
			for(NSDictionary *publication in [bulkPlacement objectForKey:BulkLiteratureArray])
			{
				NSString *name = [publication objectForKey:BulkLiteratureArrayTitle];
				int count = [[publication objectForKey:BulkLiteratureArrayCount] intValue];
				NSString *type = [publication objectForKey:BulkLiteratureArrayType];
				if([type isEqualToString:NSLocalizedString(@"Magazine", @"Publication Type name")] ||
				   [type isEqualToString:NSLocalizedString(@"TwoMagazine", @"Publication Type name")])
				{
					[string appendString:[NSString stringWithFormat:NSLocalizedString(@"%d: %@", @"Short form of Bulk Magazine Placements for the Watchtower and Awake '%d: %@'"), count, name]];
				}
				else
				{
					if(count == 1)
					{
						[string appendString:[NSString stringWithFormat:NSLocalizedString(@"%d %@: %@", @"Singular form of '1 Brochure: The Trinity' with the format '%d %@: %@', the %@ represents the Magazine, Book, or Brochure type and the %d represents the count of publications"), count, type, name]];
					}
					else
					{	
						[string appendString:[NSString stringWithFormat:NSLocalizedString(@"%d %@s: %@", @"Plural form of '2 Brochures: The Trinity' with the format '%d %@s: %@' notice the 's' in the middle for the plural form, the %@ represents the Magazine, Book, or Brochure type and the %d represents the count of publications"), count, type, name]];
					}
				}
				[string appendString:@"<br>"];
			}
			[string appendString:@"<br>"];
		}
	}	
	[mailView setMessageBody:string isHTML:YES];
	[string release];
	return mailView;
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

NSString *emailFormattedStringForCall(NSDictionary *call) 
{
	NSMutableString *string = [NSMutableString string];
	NSString *value;
	[string appendString:[NSString stringWithFormat:@"<h3>%@: %@</h3>\n", NSLocalizedString(@"Name", @"Name label for Call in editing mode"), [call objectForKey:CallName]]];
	
	NSMutableString *top = [[NSMutableString alloc] init];
	NSMutableString *bottom = [[NSMutableString alloc] init];
	[Settings formatStreetNumber:[call objectForKey:CallStreetNumber]
	                   apartment:[call objectForKey:CallApartmentNumber]
					      street:[call objectForKey:CallStreet]
							city:[call objectForKey:CallCity]
						   state:[call objectForKey:CallState]
						 topLine:top 
				      bottomLine:bottom];
	[string appendString:[NSString stringWithFormat:@"%@:<br>%@<br>%@<br>", NSLocalizedString(@"Address", @"Address label for call"), top, bottom]];
	[top release];
	[bottom release];
	top = nil;
	bottom = nil;
	
	// Add Metadata
	// they had an array of publications, lets check them too
	NSMutableArray *metadata = [call objectForKey:CallMetadata];
	if(metadata != nil)
	{
		int j;
		int endMetadata = [metadata count];
		for(j = 0; j < endMetadata; ++j)
		{
			// METADATA
			NSMutableDictionary *entry = [metadata objectAtIndex:j];
			NSString *name = [entry objectForKey:CallMetadataName];
			value = [entry objectForKey:CallMetadataValue];
			[string appendString:[NSString stringWithFormat:@"%@: %@<br>", [[PSLocalization localizationBundle] localizedStringForKey:name value:name table:@""], value]];
		}
	}
	[string appendString:@"\n"];
	
	
	NSMutableArray *returnVisits = [call objectForKey:CallReturnVisits];
	NSMutableDictionary *visit;
	
	int i;
	int end = [returnVisits count];
	for(i = 0; i < end; ++i)
	{
		visit = [returnVisits objectAtIndex:i];
		
		// GROUP TITLE
		NSDate *date = [visit objectForKey:CallReturnVisitDate];	
		// create dictionary entry for This Return Visit
		NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
		if([[[NSLocale currentLocale] localeIdentifier] isEqualToString:@"en_GB"])
		{
			[dateFormatter setDateFormat:@"EEE, d/M/yyy h:mma"];
		}
		else
		{
			[dateFormatter setDateFormat:NSLocalizedString(@"EEE, M/d/yyy h:mma", @"localized date string string using http://unicode.org/reports/tr35/tr35-4.html#Date_Format_Patterns as a guide to how to format the date")];
		}
		NSString *formattedDateString = [NSString stringWithString:[dateFormatter stringFromDate:date]];			
		
		value = [visit objectForKey:CallReturnVisitType];
		if(value == nil || value.length == 0)
			value = CallReturnVisitTypeReturnVisit;
		[string appendString:[NSString stringWithFormat:@"%@: %@<br>", [[PSLocalization localizationBundle] localizedStringForKey:value value:value table:@""], formattedDateString]];
		[string appendString:[NSString stringWithFormat:@"%@:<br>%@<br>", NSLocalizedString(@"Notes", @"Call Metadata"), [visit objectForKey:CallReturnVisitNotes]]];
		
		// Publications
		if([visit objectForKey:CallReturnVisitPublications] != nil)
		{
			// they had an array of publications, lets check them too
			NSMutableArray *publications = [visit objectForKey:CallReturnVisitPublications];
			int j;
			int endPublications = [publications count];
			for(j = 0; j < endPublications; ++j)
			{
				NSDictionary *publication = [publications objectAtIndex:j];
				// PUBLICATION
				[string appendString:[NSString stringWithFormat:@"%@<br>", [publication objectForKey:CallReturnVisitPublicationTitle]]];
			}
		}
		[string appendString:@"<br>"];
	}
	return string;
}


