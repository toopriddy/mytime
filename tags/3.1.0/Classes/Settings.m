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
#import "MTCall.h"
#import "MTReturnVisit.h"
#import "PSLocalization.h"
#import "PSUrlString.h"
#import "NSData+PSCompress.h"
#import "MetadataCustomViewController.h"
#import "NSManagedObjectContext+PriddySoftware.h"
static Settings *instance = nil;

NSString * const CallName = @"name";
NSString * const CallStreetNumber = @"streetNumber";
NSString * const CallApartmentNumber = @"apartmentNumber";
NSString * const CallStreet = @"street";
NSString * const CallCity = @"city";
NSString * const CallState = @"state";
NSString * const CallLattitudeLongitude = @"latLong";
NSString * const CallLocationType = @"locationType";

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
NSString * const SettingsCurrentButtonBarName = @"currentButtonBarName";

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
NSString * const SettingsBackupEmailDontIncludeAttachment = @"backupDontIncludeAttachment";
NSString * const SettingsBackupEmailUncompressedLink = @"backupUncompressedLink";

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
NSString * const NotAtHomeTerritoryNotes = @"notes";
NSString * const NotAtHomeTerritoryStreetName = @"name";
NSString * const NotAtHomeTerritoryStreetDate = @"date";
NSString * const NotAtHomeTerritoryStreetNotes = @"notes";
NSString * const NotAtHomeTerritoryCity = @"city";
NSString * const NotAtHomeTerritoryState = @"state";
NSString * const NotAtHomeTerritoryHouses = @"houses";
NSString * const NotAtHomeTerritoryHouseNumber = @"houseNumber";
NSString * const NotAtHomeTerritoryHouseApartment = @"apartment";
NSString * const NotAtHomeTerritoryHouseNotes = @"notes";
NSString * const NotAtHomeTerritoryHouseAttempts = @"attempts";

NSString * const SettingsStatisticsAdjustments = @"statisticsAdjustments";

NSString * const SettingsPublisherType = @"publisherType";

NSString *const UserDefaultsClearMapCache = @"clearMapCache";
NSString *const UserDefaultsEmailBackupInstantly = @"emailBackupInstantly";
NSString *const UserDefaultsRemovePasscode = @"removePasscode";




//NSString *const SettingsNotificationUserChanged = @"settingsNotificationUserChanged";


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

+ (BOOL)isInitialized
{
    @synchronized(self) 
	{
        return instance != nil; 
    }
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

	NSMutableString *string = [[NSMutableString alloc] initWithString:@"<html><body>"];
	[string appendString:NSLocalizedString(@"You are able to restore all of your MyTime data as of the sent date of this email if you click on the link below while viewing this email from your iPhone/iTouch. Please make sure that at the end of this email there is a \"VERIFICATION CHECK:\" right after the link, it verifies that all data is contained within this email<br><br>WARNING: CLICKING ON THE LINK BELOW WILL DELETE YOUR CURRENT DATA AND RESTORE FROM THE BACKUP<br><br>", @"This is the body of the email that is sent when you go to More->Settings->Email Backup")];
	
	// attach the real records file
	NSDictionary *settings = [[Settings sharedInstance] settings];
	if(![settings objectForKey:SettingsBackupEmailDontIncludeAttachment])
	{
		[mailView addAttachmentData:[[NSFileManager defaultManager] contentsAtPath:[Settings filename]] mimeType:@"mytime/plist" fileName:@"backup.mytimedata"];
	}
	
	NSString *emailAddress = [settings objectForKey:SettingsBackupEmailAddress];
	if(emailAddress && emailAddress.length)
	{
		[mailView setToRecipients:[emailAddress componentsSeparatedByString:@" "]];
	}
	// now add the url that will allow importing
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:settings];
	if(![settings objectForKey:SettingsBackupEmailUncompressedLink])
	{	
		data = [data compress];
		[string appendString:@"<a href=\"mytime://mytime/restoreCompressedBackup?"];
	}
	else
	{
		[string appendString:@"<a href=\"mytime://mytime/restoreBackup?"];
	}

	
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
	[string appendString:@"</body></html>"];
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
		[dateFormatter setDateFormat:@"EEE, d/M/yyy h:mma"];
	}
	else
	{
		[dateFormatter setDateFormat:NSLocalizedString(@"EEE, M/d/yyy h:mma", @"localized date string string using http://unicode.org/reports/tr35/tr35-4.html#Date_Format_Patterns as a guide to how to format the date")];
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
	[string appendString:@"<br>\n"];

	return string;
}

NSString *emailFormattedStringForNotAtHomeTerritory(NSDictionary *territory)
{
	NSMutableString *string = [NSMutableString string];
	[string appendString:[NSString stringWithFormat:@"<h3>%@: %@</h3>\n", NSLocalizedString(@"Territory Name/Number", @"used as a label when emailing not at homes"), [territory objectForKey:NotAtHomeTerritoryName]]];
	[string appendString:[NSString stringWithFormat:@"%@: %@<br>\n", NSLocalizedString(@"City", @"used as a label when emailing not at homes"), [territory objectForKey:NotAtHomeTerritoryCity]]];
	[string appendString:[NSString stringWithFormat:@"%@: %@<br>\n", NSLocalizedString(@"State or Country", @"used as a label when emailing not at homes"), [territory objectForKey:NotAtHomeTerritoryState]]];
	NSString *notes = [territory objectForKey:NotAtHomeTerritoryNotes];
	if([notes length])
	{
		notes = [notes stringByReplacingOccurrencesOfString:@" " withString:@"&nbsp;"];
		notes = [notes stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
		[string appendString:notes];
		[string appendFormat:@"<br><br>\n"];
	}
	[string appendString:[NSString stringWithFormat:@"<h4>%@:</h4>\n", NSLocalizedString(@"Streets", @"used as a label when emailing not at homes")]];
	for(NSMutableDictionary *street in [[territory objectForKey:NotAtHomeTerritoryStreets] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor psSortDescriptorWithKey:NotAtHomeTerritoryStreetName ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
																														[NSSortDescriptor psSortDescriptorWithKey:NotAtHomeTerritoryStreetDate ascending:YES], nil]])
	{
		[string appendString:[NSString stringWithFormat:@"<h4>%@: %@</h4>\n", NSLocalizedString(@"Street", @"used as a label when emailing not at homes"), [street objectForKey:NotAtHomeTerritoryStreetName]]];
		NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:[[street objectForKey:NotAtHomeTerritoryStreetDate] timeIntervalSinceReferenceDate]];	
		// create dictionary entry for This Return Visit
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
		if([[[NSLocale currentLocale] localeIdentifier] isEqualToString:@"en_GB"])
		{
			[dateFormatter setDateFormat:@"EEE, d/M/yyy h:mma"];
		}
		else
		{
			[dateFormatter setDateFormat:NSLocalizedString(@"EEE, M/d/yyy h:mma", @"localized date string string using http://unicode.org/reports/tr35/tr35-4.html#Date_Format_Patterns as a guide to how to format the date")];
		}
		
		[string appendString:[NSString stringWithFormat:@"%@<br>\n", [dateFormatter stringFromDate:date]]];
		[dateFormatter release];
		[date release];
		NSString *notes = [street objectForKey:NotAtHomeTerritoryStreetNotes];
		if([notes length])
		{
			notes = [notes stringByReplacingOccurrencesOfString:@" " withString:@"&nbsp;"];
			notes = [notes stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
			[string appendString:notes];
			[string appendFormat:@"<br><br>\n"];
		}
		
		[string appendString:[NSString stringWithFormat:@"<h4>%@:</h4>\n", NSLocalizedString(@"Houses", @"used as a label when emailing not at homes")]];
		for(NSMutableDictionary *house in [[street objectForKey:NotAtHomeTerritoryHouses] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor psSortDescriptorWithKey:NotAtHomeTerritoryHouseNumber ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
																													   [NSSortDescriptor psSortDescriptorWithKey:NotAtHomeTerritoryHouseApartment ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], nil]])
		{
			NSMutableString *top = [[NSMutableString alloc] init];
			[Settings formatStreetNumber:[house objectForKey:NotAtHomeTerritoryHouseNumber]
							   apartment:[house objectForKey:NotAtHomeTerritoryHouseApartment]
								 topLine:top];
			
			[string appendString:[NSString stringWithFormat:@"<b>%@: %@</b><br>\n", NSLocalizedString(@"House Number", @"used as a label when emailing not at homes"), top]];
			[top release];
			NSString *notes = [house objectForKey:NotAtHomeTerritoryHouseNotes];
			if([notes length])
			{
				notes = [notes stringByReplacingOccurrencesOfString:@" " withString:@"&nbsp;"];
				notes = [notes stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
				[string appendString:notes];
				[string appendFormat:@"<br>\n"];
			}
			[string appendString:[NSString stringWithFormat:@"%@:<br>\n", NSLocalizedString(@"Attempts", @"used as a label when emailing not at homes")]];
			for(NSDate *attempt in [[[house objectForKey:NotAtHomeTerritoryHouseAttempts] sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator])
			{
				NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:[attempt timeIntervalSinceReferenceDate]];	
				// create dictionary entry for This Return Visit
				NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
				[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
				if([[[NSLocale currentLocale] localeIdentifier] isEqualToString:@"en_GB"])
				{
					[dateFormatter setDateFormat:@"EEE, d/M/yyy h:mma"];
				}
				else
				{
					[dateFormatter setDateFormat:NSLocalizedString(@"EEE, M/d/yyy h:mma", @"localized date string string using http://unicode.org/reports/tr35/tr35-4.html#Date_Format_Patterns as a guide to how to format the date")];
				}
				[string appendString:[NSString stringWithFormat:@" %@<br>\n", [dateFormatter stringFromDate:date]]];
				[date release];
				[dateFormatter release];
			}
		}
	}
	[string appendString:@"<br><br>\n"];
	return string;
}

NSString *emailFormattedStringForCall(NSDictionary *call) 
{
	if(![call isKindOfClass:[NSDictionary class]])
	{
		return @"";
	}
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
	[string appendString:[NSString stringWithFormat:@"%@:<br>%@<br>%@<br>\n", NSLocalizedString(@"Address", @"Address label for call"), top, bottom]];
	[top release];
	[bottom release];
	top = nil;
	bottom = nil;
	
	NSString *latLong = [call objectForKey:CallLattitudeLongitude];
	if(latLong != nil && ![latLong isEqualToString:@"nil"])
	{
		NSArray *stringArray = [latLong componentsSeparatedByString:@", "];
		if(stringArray.count == 2)
		{
			[string appendFormat:@"%@, %@<br>\n", [NSDecimalNumber decimalNumberWithString:[stringArray objectAtIndex:0]], [NSDecimalNumber decimalNumberWithString:[stringArray objectAtIndex:1]]];
		}
	}
	NSString *lookupType = [call objectForKey:CallLocationType];
	if(lookupType == nil)
		lookupType = CallLocationTypeGoogleMaps;
	[string appendFormat:@"%@<br>\n", [[NSBundle mainBundle] localizedStringForKey:lookupType value:lookupType table:nil]];
	
	// Add Metadata
	// they had an array of publications, lets check them too
	NSArray *metadata = [[call objectForKey:CallMetadata] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor psSortDescriptorWithKey:CallMetadataName ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
																					   [NSSortDescriptor psSortDescriptorWithKey:CallMetadataValue ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], nil]];
	for(NSDictionary *entry in metadata)
	{
		// METADATA
		NSString *name = [entry objectForKey:CallMetadataName];
		value = [entry objectForKey:CallMetadataValue];
		[string appendString:[NSString stringWithFormat:@"%@: %@<br>\n", [[PSLocalization localizationBundle] localizedStringForKey:name value:name table:@""], value]];
	}
	[string appendString:@"\n"];
	
	NSArray *returnVisits = [[call objectForKey:CallReturnVisits] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"date" ascending:NO]]];
		
	for(NSDictionary *visit in returnVisits)
	{
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
		// lets translate the initial visit which is classified as a return visit into an Initial Visit
		if(visit == [returnVisits lastObject])
		{
			if([value isEqualToString:CallReturnVisitTypeReturnVisit])
			{
				value = CallReturnVisitTypeInitialVisit;
			}
		}
		[string appendString:[NSString stringWithFormat:@"%@: %@<br>\n", [[PSLocalization localizationBundle] localizedStringForKey:value value:value table:@""], formattedDateString]];
		[string appendString:[NSString stringWithFormat:@"%@:<br>\n", NSLocalizedString(@"Notes", @"Call Metadata")]];
		NSString *notes = [visit objectForKey:CallReturnVisitNotes];
		if([notes length])
		{
			notes = [notes stringByReplacingOccurrencesOfString:@" " withString:@"&nbsp;"];
			notes = [notes stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
			[string appendString:notes];
			[string appendString:@"<br>\n"];
		}
		
		// Publications
		for(NSDictionary *publication in [visit objectForKey:CallReturnVisitPublications])
		{
			[string appendString:[NSString stringWithFormat:@"%@<br>\n", [publication objectForKey:CallReturnVisitPublicationTitle]]];
		}
		[string appendString:@"<br>\n"];
	}
	return string;
}

NSString *emailFormattedStringForSettings()
{
	NSMutableString *string = [[NSMutableString alloc] initWithString:@"<html><body>"];
	NSDictionary *settings = [[Settings sharedInstance] settings];
	
	NSArray *allUserSettings = [settings objectForKey:SettingsMultipleUsers];
	for(NSDictionary *userSettings in [allUserSettings sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:SettingsMultipleUsersName ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]])
	{
		// the specific user
		[string appendString:[NSString stringWithFormat:NSLocalizedString(@"<h1>Backup data for %@:</h1>\n", @"label for sending a printable email backup.  this label is in the body of the email"), [userSettings objectForKey:SettingsMultipleUsersName]]];
		
		// calls
		[string appendString:NSLocalizedString(@"<h2>Calls:</h2>\n", @"label for sending a printable email backup.  this label is in the body of the email")];
		for(NSDictionary *call in [[userSettings objectForKey:SettingsCalls] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor psSortDescriptorWithKey:CallStreet ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
																										  [NSSortDescriptor psSortDescriptorWithKey:CallStreetNumber ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
																										  [NSSortDescriptor psSortDescriptorWithKey:CallApartmentNumber ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
																										  [NSSortDescriptor psSortDescriptorWithKey:CallCity ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
																										  [NSSortDescriptor psSortDescriptorWithKey:CallState ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
																										  [NSSortDescriptor psSortDescriptorWithKey:CallName ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], nil]])
		{
			[string appendString:emailFormattedStringForCall(call)];
		}
		
		// hours
		[string appendString:NSLocalizedString(@"<h2>Hours:</h2>\n", @"label for sending a printable email backup.  this label is in the body of the email")];
		for(NSDictionary *timeEntry in [[userSettings objectForKey:SettingsTimeEntries] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor psSortDescriptorWithKey:SettingsTimeEntryDate ascending:NO], 
																													                          [NSSortDescriptor psSortDescriptorWithKey:SettingsTimeEntryMinutes ascending:NO], nil]])
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
		for(NSDictionary *bulkPlacement in [[userSettings objectForKey:SettingsBulkLiterature] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:BulkLiteratureDate ascending:NO]]])
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
				[dateFormatter setDateFormat:NSLocalizedString(@"EEE, M/d/yyy h:mma", @"localized date string string using http://unicode.org/reports/tr35/tr35-4.html#Date_Format_Patterns as a guide to how to format the date")];
			}
			[string appendString:[NSString stringWithFormat:@"%@:<br>\n", [dateFormatter stringFromDate:date]]];
			for(NSDictionary *publication in [bulkPlacement objectForKey:BulkLiteratureArray])
			{
				NSString *name = [publication objectForKey:BulkLiteratureArrayTitle];
				int count = [[publication objectForKey:BulkLiteratureArrayCount] intValue];
				NSString *type = [publication objectForKey:BulkLiteratureArrayType];
				if([type isEqualToString:PublicationTypeMagazine] ||
				   [type isEqualToString:PublicationTypeTwoMagazine])
				{
					[string appendString:[NSString stringWithFormat:NSLocalizedString(@"%d: %@", @"Short form of Bulk Magazine Placements for the Watchtower and Awake '%d: %@'"), count, name]];
				}
				else
				{
					if(count == 1)
					{
						type = [[PSLocalization localizationBundle] localizedStringForKey:type value:type table:nil];
						[string appendString:[NSString stringWithFormat:NSLocalizedString(@"%d %@: %@", @"'1 Brochure: The Trinity' with the format '%d %@: %@', the %@ represents the Magazine, Book, or Brochure type and the %d represents the count of publications"), count, type, name]];
					}
					else
					{	
						type = [MTPublication pluralFormForPublicationType:type];
						type = [[PSLocalization localizationBundle] localizedStringForKey:type value:type table:nil];
						[string appendString:[NSString stringWithFormat:NSLocalizedString(@"%d %@: %@", @"'1 Brochure: The Trinity' with the format '%d %@: %@', the %@ represents the Magazine, Book, or Brochure type and the %d represents the count of publications"), count, type, name]];
					}
				}
				[string appendString:@"<br>\n"];
			}
			[string appendString:@"<br>\n"];
		}
		
		// not at home
		
		[string appendFormat:@"<h2>%@:</h2>\n", NSLocalizedString(@"Territories", @"View title for the previously named 'Not At Homes' but it is representing the user's territory now")];
		for(NSDictionary *territory in [userSettings objectForKey:SettingsNotAtHomeTerritories])
		{
			[string appendString:emailFormattedStringForNotAtHomeTerritory(territory)];
		}
		
		[string appendFormat:@"<h2>%@:</h2>\n", NSLocalizedString(@"Additional Information", @"Title for email section for the \"Additional Information\" info")];
		NSString *keys[2] = {SettingsPreferredMetadata, SettingsOtherMetadata};
		NSString *names[2];
		names[0] = NSLocalizedString(@"Information Always Shown", @"Title in the 'Additional Information' for the entries that will always show in every call");
		names[1] = NSLocalizedString(@"Other Information", @"Title in the 'Additional Information' for the entries that can be added per call");
		
		for(int i = 0; i < 2; i++)
		{
			[string appendFormat:@"  <h3>%@:</h3>\n", names[i]];
			for(NSDictionary *type in [[userSettings objectForKey:keys[i]] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:SettingsMetadataName ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]])
			{
				NSString *localizedNameForMetadataType(MetadataType type);
				int typeValue = [[type objectForKey:SettingsMetadataType] intValue];
				[string appendFormat:@"    %@:%@<br>\n", [type objectForKey:SettingsMetadataName], localizedNameForMetadataType(typeValue)];
				if(typeValue == CHOICE)
				{
					[string appendString:@"    <ul>\n"];
					for(NSString *choice in [[type objectForKey:SettingsMetadataData] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)])
					{
						[string appendFormat:@"      <li>%@</li>\n", choice];
					}
					[string appendString:@"    </ul>\n"];
				}
			}	
		}		
		
		// STATISTICS ADJUSTMENTS
		[string appendFormat:@"<h2>%@:</h2>\n", NSLocalizedString(@"Statistics Adjustments", @"Title for email section for the data that the user changed in the statistics view")];
		NSDictionary *statisticsAdjustments = [userSettings objectForKey:SettingsStatisticsAdjustments]; 
		NSArray *statisticsAdjustmentCategories = [[statisticsAdjustments allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
		NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
		for(NSDictionary *adjustmentCategory in statisticsAdjustmentCategories)
		{
			NSDictionary *adjustments = [statisticsAdjustments objectForKey:adjustmentCategory];
			NSArray *adjustmentKeys = [[adjustments allKeys] sortedArrayUsingSelector:@selector(compare:)];
			for(NSString *timestamp in adjustmentKeys)
			{
				NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
				[dateComponents setMonth:([timestamp intValue] % 100)];
				[dateComponents setYear:([timestamp intValue] / 100)];
				NSDate *date = [gregorian dateFromComponents:dateComponents];
				[string appendFormat:@"  %@: %@: %@<br>\n", adjustmentCategory, date, [adjustments objectForKey:timestamp]];
				[dateComponents release];
			}
		}
	}	
	[string appendString:@"</body></html>"];
	
	return [string autorelease];
}

+ (MFMailComposeViewController *)sendPrintableEmailBackup
{
	MFMailComposeViewController *mailView = [[[MFMailComposeViewController alloc] init] autorelease];
	[mailView setSubject:NSLocalizedString(@"MyTime Application Printable Backup", @"Email subject line for the email that has a printable version of the mytime data")];
	
	NSDictionary *settings = [[Settings sharedInstance] settings];
	
	NSString *emailAddress = [settings objectForKey:SettingsBackupEmailAddress];
	if(emailAddress && emailAddress.length)
	{
		[mailView setToRecipients:[emailAddress componentsSeparatedByString:@" "]];
	}
	
	[mailView setMessageBody:emailFormattedStringForSettings() isHTML:YES];
	return mailView;
}

+ (NSString *)filename
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"records.plist"];
}

+ (NSString *)outOfWayFilename
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"oldrecords.plist"];
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
//	if(save)
//		[self saveData];
	
//	[[NSNotificationCenter defaultCenter] postNotificationName:SettingsNotificationUserChanged object:self];
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
	NSData *data = [[NSData alloc] initWithContentsOfFile:[Settings filename]];
	NSString *err = nil;
	NSPropertyListFormat format;
	self.settings = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&err];
	[data release];
	if(err)
	{
		NSLog(@"%@", err);
	}
#else
	self.settings = [[[NSMutableDictionary alloc] initWithContentsOfFile:[Settings filename]] autorelease];
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
	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Settings SAVE should not be called" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
	[errorAlert release];
	
//	[self.settings writeToFile:[Settings filename] atomically: YES];
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

+ (void)formatStreetNumber:(NSString *)houseNumber apartment:(NSString *)apartmentNumber topLine:(NSMutableString *)top
{
	[Settings formatStreetNumber:houseNumber 
					   apartment:apartmentNumber 
						  street:nil 
						 topLine:top];
}

+ (void)formatStreetNumber:(NSString *)houseNumber apartment:(NSString *)apartmentNumber street:(NSString *)street topLine:(NSMutableString *)top
{
	[Settings formatStreetNumber:houseNumber 
					   apartment:apartmentNumber 
						  street:street 
							city:nil 
						   state:nil 
						 topLine:top 
					  bottomLine:nil];
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
			[top appendString:houseNumber];
		else if(street && [street length] && apartmentNumber && [apartmentNumber length])
			[top appendFormat:NSLocalizedString(@"#%@ %@", @"Apartment Number and street name represented by %1$@ as the apartment number and %2$@ as the street name"), apartmentNumber, street];
		else if(street && [street length])
			[top appendString:street];
		else if(apartmentNumber && [apartmentNumber length])
			[top appendString:apartmentNumber];
	}
	if(bottom)
	{
		if(city && city.length && state && state.length)
			[bottom appendFormat:NSLocalizedString(@"%@, %@", @"City and state(or country) as represented in an address (usually right under the house number and street)"), city, state];
		else if(city && city.length)
			[bottom appendString:city];
		else if(state && state.length)
			[bottom appendString:state];
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

