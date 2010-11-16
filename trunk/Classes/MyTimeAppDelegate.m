//
//  MyTimeAppDelegate.m
//  MyTime
//
//  Created by Brent Priddy on 7/22/08.
//  Copyright Priddy Software, LLC 2008. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "MyTimeAppDelegate.h"
#import "SortedCallsViewDataSourceProtocol.h"
#import "CallsSortedByStreetViewDataSource.h"
#import "CallsSortedByCityViewDataSource.h"
#import "CallsSortedByDateViewDataSource.h"
#import "CallsSortedByNameViewDataSource.h"
#import "CallsSortedByStudyViewDataSource.h"
#import "CallsSortedByFilterDataSource.h"
#import "DeletedCallsSortedByStreetViewDataSource.h"
#import "SortedCallsViewController.h"
#import "MetadataSortedCallsViewController.h"
#import "StatisticsTableViewController.h"
//#import "StatisticsViewController.h"
#import "NotAtHomeViewController.h"
#import "HourViewController.h"
#import "SettingsTableViewController.h"
#import "BulkLiteraturePlacementViewContoller.h"
#import "MapViewController.h"
#import "TutorialViewController.h"
#import "Settings.h"
#import "Geocache.h"
#import <objc/runtime.h>
#import "PSLocalization.h"
#import "SecurityViewController.h"
#import "NSData+PSCompress.h"
#import "MTSettings.h"
#import "MTUser.h"
#import "MTCall.h"
#import "MTReturnVisit.h"
#import "MTBulkPlacement.h"
#import "MTPublication.h"
#import "MTAdditionalInformation.h"
#import "MTAdditionalInformationType.h"
#import "MTMultipleChoice.h"
#import "MTPresentation.h"
#import "MTStatisticsAdjustment.h"
#import "MTTerritory.h"
#import "MTTerritoryStreet.h"
#import "MTTerritoryHouse.h"
#import "MTTerritoryHouseAttempt.h"
#import "MTTimeType.h"
#import "MTTimeEntry.h"
#import "MetadataCustomViewController.h"
#import "NSManagedObjectContext+PriddySoftware.h"

@interface MyTimeAppDelegate ()
- (void)displaySecurityViewController;
+ (NSString *)storeFileAndPath;

@end

@implementation MyTimeAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize dataToImport;
@synthesize settingsToRestore;
@synthesize modalNavigationController;
@synthesize managedObjectContext;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;
@synthesize hud;

+ (MyTimeAppDelegate *)sharedInstance
{
	return (MyTimeAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (id)init 
{
	if(self = [super init]) 
	{
		[PSLocalization initalizeCustomLocalization];
	}
	
	return self;
}

- (void)dealloc 
{
	self.window = nil;
	self.tabBarController = nil;
	self.dataToImport = nil;
	self.settingsToRestore = nil;
	self.hud = nil;
	
	[super dealloc];
}

NSData *allocNSDataFromNSStringByteString(NSString *data)
{
	int length = data.length;
	if(length & 1 != 0)
	{
		// odd number of bytes
		return nil;
	}
	char hi;
	char lo;
	BOOL failed = NO;
	char *buffer = malloc(length/2);
	char *ptr = buffer;
	for (int i = 0; i < length;)
	{
		hi = [data characterAtIndex:i++];
		lo = [data characterAtIndex:i++];
		if(!isnumber(hi))
		{
			if(!ishexnumber(hi))
			{
				failed = YES;
				break;
			}
			else
			{
				hi = hi - 'A' + 10;
			}
		}
		else
		{
			hi = hi - '0';
		}
		if(!isnumber(lo))
		{
			if(!ishexnumber(lo))
			{
				failed = YES;
				break;
			}
			else
			{
				lo = lo - 'A' + 10;
			}
		}
		else
		{
			lo = lo - '0';
		}
		*ptr++ = (hi << 4) | lo;
	}
	
	if(failed)
	{
		free(buffer);
		return nil;
	}
	return [[NSData alloc] initWithBytesNoCopy:buffer length:length/2 freeWhenDone:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(alertViewTutorials)
	{
		alertViewTutorials = NO;
		if(buttonIndex == 0)
		{
			self.tabBarController.selectedViewController = self.tabBarController.moreNavigationController;
			[self.tabBarController setSelectedViewController:_tutorialViewController];
		}
	}
	else
	{
		exit(0);
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)button
{

	switch(_actionSheetType)
	{
		case ADD_CALL:
			switch(button)
			{
				//import
				case 0:
				{
					NSMutableArray *calls = [[[Settings sharedInstance] userSettings] objectForKey:SettingsCalls];
					NSMutableDictionary *newCall = [NSMutableDictionary dictionaryWithDictionary:dataToImport];
					
					// change all return visits to be transferrs so that we dont count the other person's work
					for(NSMutableDictionary *visit in [newCall objectForKey:CallReturnVisits])
					{
						NSString *type = [visit objectForKey:CallReturnVisitType];
						if(type == nil || [type isEqualToString:CallReturnVisitTypeReturnVisit])
						{
							[visit setObject:CallReturnVisitTypeTransferedReturnVisit forKey:CallReturnVisitType];
						}
						else if([type isEqualToString:CallReturnVisitTypeNotAtHome])
						{
							[visit setObject:CallReturnVisitTypeTransferedNotAtHome forKey:CallReturnVisitType];
						}
						else if([type isEqualToString:CallReturnVisitTypeStudy])
						{
							[visit setObject:CallReturnVisitTypeTransferedStudy forKey:CallReturnVisitType];
						}
					}
					if(calls == nil)
					{
						calls = [NSMutableArray array];
						[[[Settings sharedInstance] userSettings] setObject:calls forKey:SettingsCalls];
					}
					[calls addObject:newCall];
					[[Settings sharedInstance] saveData];
					self.dataToImport = nil;

					UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
					[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
					alertSheet.title = NSLocalizedString(@"Please quit mytime to complete the import/restore.", @"This message is displayed after a successful import of a call or a restore of a backup");
					[alertSheet show];
					break;
				}
				// cancel
				case 1:
				{
					self.dataToImport = nil;
					break;
				}
			}
			break;
		case ADD_NOT_AT_HOME_TERRITORY:
			switch(button)
			{
					//import
				case 0:
				{
					NSMutableArray *territories = [[[Settings sharedInstance] userSettings] objectForKey:SettingsNotAtHomeTerritories];
					NSMutableDictionary *newTerritory = [NSMutableDictionary dictionaryWithDictionary:dataToImport];
					
					if(territories == nil)
					{
						territories = [NSMutableArray array];
						[[[Settings sharedInstance] userSettings] setObject:territories forKey:SettingsNotAtHomeTerritories];
					}
					
					[territories addObject:newTerritory];
					[[Settings sharedInstance] saveData];
					self.dataToImport = nil;
					
					UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
					[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
					alertSheet.title = NSLocalizedString(@"Please quit mytime to complete the import/restore.", @"This message is displayed after a successful import of a call or a restore of a backup");
					[alertSheet show];
					break;
				}
					// cancel
				case 1:
				{
					self.dataToImport = nil;
					break;
				}
			}
			break;
		case RESTORE_BACKUP:
			switch(button)
			{
				//import
				case 0:
				{
					[self.settingsToRestore writeToFile:[Settings filename] atomically: YES];
					self.settingsToRestore = nil;
					if([Settings isInitialized])
					{
						UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
						alertSheet.delegate = self;
						[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
						alertSheet.title = NSLocalizedString(@"Backup restored, press OK to quit mytime. You will have to restart to use your restored data", @"This message is displayed after a successful import of a call or a restore of a backup");
						[alertSheet show];
					}
					else
					{
						UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
						[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
						alertSheet.title = NSLocalizedString(@"MyTime backup restored.", @"This message is displayed after a successful restore of a backup");
						[alertSheet show];
						[self initializeMyTimeViews];
					}
					break;
				}
				// cancel
				case 1:
				{
					self.dataToImport = nil;
					// dont reinit the views if they are still in existance
					if(tabBarController == nil)
						[self initializeMyTimeViews];
					break;
				}
			}
			break;
		case AUTO_BACKUP:
			switch(button)
			{
				// dont email backup
				case 0:
				{
					[[[Settings sharedInstance] settings] setObject:[NSDate date] forKey:SettingsLastBackupDate];
					break;
				}
				// send email backup
				case 1:
				{
					MFMailComposeViewController *mailView = [Settings sendEmailBackup];
					mailView.mailComposeDelegate = self;
					[self.modalNavigationController.visibleViewController presentModalViewController:mailView animated:YES];
					break;
				}
			}
			break;
	}
}

- (UIViewController *)removeControllerFromArray:(NSMutableArray *)array withName:(NSString *)name
{
	UIViewController *controller;
	int i;
	if(![name isKindOfClass:[NSString class]])
		return(nil);
		
	for(i = 0; i < [array count]; i++)
	{
		controller = [array objectAtIndex:i];
		if([name isEqualToString:controller.title])
		{
			[controller retain];
			[array removeObjectAtIndex:i];
			return([controller autorelease]);
		}
	}
	return(nil);
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	controller.mailComposeDelegate = nil;
	if(result == MFMailComposeResultSent)
	{
		MTSettings *settings = [MTSettings settings];
		[settings setLastBackupDate:[NSDate date]];
		NSError *error = nil;
		if (![settings.managedObjectContext save:&error]) 
		{
			[NSManagedObjectContext presentErrorDialog:error];
			abort();
		}
	}

	if(forceEmail)
	{
		forceEmail = NO;
		// for some reason the MFMailComposeViewController is crashing when the email is not getting sent and the dismiss is not animated
		[controller retain];
		[controller autorelease];
		[self.modalNavigationController dismissModalViewControllerAnimated:NO];
		[self.modalNavigationController.view removeFromSuperview];
		self.modalNavigationController = nil;
		[self initializeMyTimeViews];
	}
	else
	{
		[controller dismissModalViewControllerAnimated:YES];
	}

}

- (void)hudWasHidden
{
}

NSString *emailFormattedStringForCoreDataTimeEntry(MTTimeEntry *timeEntry)
{
	NSMutableString *string = [NSMutableString string];

	NSDate *date = [[[NSDate alloc] initWithTimeIntervalSinceReferenceDate:[timeEntry.date timeIntervalSinceReferenceDate]] autorelease];	
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
	
	int minutes = timeEntry.minutesValue;
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

NSString *emailFormattedStringForCoreDataNotAtHomeTerritory(MTTerritory *territory)
{
	NSMutableString *string = [NSMutableString string];
	[string appendString:[NSString stringWithFormat:@"<h3>%@: %@</h3>\n", NSLocalizedString(@"Territory Name/Number", @"used as a label when emailing not at homes"), territory.name]];
	[string appendString:[NSString stringWithFormat:@"%@: %@<br>\n", NSLocalizedString(@"City", @"used as a label when emailing not at homes"), territory.city]];
	[string appendString:[NSString stringWithFormat:@"%@: %@<br>\n", NSLocalizedString(@"State or Country", @"used as a label when emailing not at homes"), territory.state]];
	NSString *notes = territory.notes;
	if([notes length])
	{
		notes = [notes stringByReplacingOccurrencesOfString:@" " withString:@"&nbsp;"];
		notes = [notes stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
		[string appendString:notes];
		[string appendFormat:@"<br><br>\n"];
	}
	[string appendString:[NSString stringWithFormat:@"<h4>%@:</h4>\n", NSLocalizedString(@"Streets", @"used as a label when emailing not at homes")]];
	
	NSArray *streets = [territory.managedObjectContext fetchObjectsForEntityName:[MTTerritoryStreet entityName]
															   propertiesToFetch:nil 
															 withSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
																				  [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES], nil]
																   withPredicate:@"territory == %@", territory];
	for(MTTerritoryStreet *street in streets)
	{
		[string appendString:[NSString stringWithFormat:@"<h4>%@: %@</h4>\n", NSLocalizedString(@"Street", @"used as a label when emailing not at homes"), street.name]];
		// create dictionary entry for This Return Visit
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
		if([[[NSLocale currentLocale] localeIdentifier] isEqualToString:@"en_GB"])
		{
			[dateFormatter setDateFormat:@"EEE, d/M/yyy"];
		}
		else
		{
			[dateFormatter setDateFormat:NSLocalizedString(@"EEE, M/d/yyy", @"localized date string string using http://unicode.org/reports/tr35/tr35-4.html#Date_Format_Patterns as a guide to how to format the date")];
		}
		
		[string appendString:[NSString stringWithFormat:@"%@<br>\n", [dateFormatter stringFromDate:street.date]]];
		[dateFormatter release];
		NSString *notes = street.notes;
		if([notes length])
		{
			notes = [notes stringByReplacingOccurrencesOfString:@" " withString:@"&nbsp;"];
			notes = [notes stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
			[string appendString:notes];
			[string appendFormat:@"<br><br>\n"];
		}
		
		[string appendString:[NSString stringWithFormat:@"<h4>%@:</h4>\n", NSLocalizedString(@"Houses", @"used as a label when emailing not at homes")]];
		NSArray *houses = [territory.managedObjectContext fetchObjectsForEntityName:[MTTerritoryHouse entityName]
																   propertiesToFetch:nil 
																 withSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
																					  [NSSortDescriptor sortDescriptorWithKey:@"apartment" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], nil]
																	   withPredicate:@"street == %@", street];
		for(MTTerritoryHouse *house in houses)
		{
			NSMutableString *top = [[NSMutableString alloc] init];
			[Settings formatStreetNumber:house.number
							   apartment:house.apartment
								 topLine:top];
			
			[string appendString:[NSString stringWithFormat:@"<b>%@: %@</b><br>\n", NSLocalizedString(@"House Number", @"used as a label when emailing not at homes"), top]];
			[top release];
			NSString *notes = house.notes;
			if([notes length])
			{
				notes = [notes stringByReplacingOccurrencesOfString:@" " withString:@"&nbsp;"];
				notes = [notes stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
				[string appendString:notes];
				[string appendFormat:@"<br>\n"];
			}
			[string appendString:[NSString stringWithFormat:@"%@:<br>\n", NSLocalizedString(@"Attempts", @"used as a label when emailing not at homes")]];
			for(MTTerritoryHouseAttempt *attempt in house.attempts)
			{
				// create dictionary entry for This Return Visit
				NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
				[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
				if([[[NSLocale currentLocale] localeIdentifier] isEqualToString:@"en_GB"])
				{
					[dateFormatter setDateFormat:@"EEE, d/M/yyy"];
				}
				else
				{
					[dateFormatter setDateFormat:NSLocalizedString(@"EEE, M/d/yyy", @"localized date string string using http://unicode.org/reports/tr35/tr35-4.html#Date_Format_Patterns as a guide to how to format the date")];
				}
				[string appendString:[NSString stringWithFormat:@" %@<br>\n", [dateFormatter stringFromDate:attempt.date]]];
				[dateFormatter release];
			}
		}
	}
	[string appendString:@"<br><br>\n"];
	return string;
}

NSString *emailFormattedStringForCoreDataCall(MTCall *call) 
{
	NSMutableString *string = [NSMutableString string];
	NSString *value;
	[string appendString:[NSString stringWithFormat:@"<h3>%@: %@</h3>\n", NSLocalizedString(@"Name", @"Name label for Call in editing mode"), call.name]];
	
	NSMutableString *top = [[NSMutableString alloc] init];
	NSMutableString *bottom = [[NSMutableString alloc] init];
	[Settings formatStreetNumber:call.houseNumber
	                   apartment:call.apartmentNumber
					      street:call.street
							city:call.city
						   state:call.state
						 topLine:top 
				      bottomLine:bottom];
	[string appendString:[NSString stringWithFormat:@"%@:<br>%@<br>%@<br>\n", NSLocalizedString(@"Address", @"Address label for call"), top, bottom]];
	[top release];
	[bottom release];
	top = nil;
	bottom = nil;
	
	if(call.locationAquiredValue)
	{
		[string appendFormat:@"%@, %@<br>\n", call.lattitude, call.longitude];
	}
	NSString *lookupType = call.locationLookupType;
	[string appendFormat:@"%@<br>\n", [[NSBundle mainBundle] localizedStringForKey:lookupType value:lookupType table:nil]];
	
	// Add Metadata
	// they had an array of publications, lets check them too
	// Publications
	NSArray *additionalInformations = [call.managedObjectContext fetchObjectsForEntityName:[MTAdditionalInformation entityName]
															   propertiesToFetch:nil 
															 withSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"type.name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
																				  [NSSortDescriptor sortDescriptorWithKey:@"value" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], nil]
																   withPredicate:@"call == %@", call];
	for(MTAdditionalInformation *additionalInformation in additionalInformations)
	{
		// METADATA
		NSString *name = additionalInformation.type.name;
		value = additionalInformation.value;
		[string appendString:[NSString stringWithFormat:@"%@: %@<br>\n", [[PSLocalization localizationBundle] localizedStringForKey:name value:name table:@""], value]];
	}
	[string appendString:@"\n"];
	
	NSArray *returnVisits = [call.managedObjectContext fetchObjectsForEntityName:[MTReturnVisit entityName]
															   propertiesToFetch:nil 
															 withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO] ]
																   withPredicate:@"(call == %@)", call];
	
	for(MTReturnVisit *visit in returnVisits)
	{
		// GROUP TITLE
		NSDate *date = visit.date;
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
		
		value = visit.type;
		if(value == nil || value.length == 0)
			value = CallReturnVisitTypeReturnVisit;
		[string appendString:[NSString stringWithFormat:@"%@: %@<br>\n", [[PSLocalization localizationBundle] localizedStringForKey:value value:value table:@""], formattedDateString]];
		[string appendString:[NSString stringWithFormat:@"%@:<br>\n", NSLocalizedString(@"Notes", @"Call Metadata")]];
		NSString *notes = visit.notes;
		if([notes length])
		{
			notes = [notes stringByReplacingOccurrencesOfString:@" " withString:@"&nbsp;"];
			notes = [notes stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
			[string appendString:notes];
			[string appendString:@"<br>\n"];
		}
		
		// Publications
		NSArray *publications = [call.managedObjectContext fetchObjectsForEntityName:[MTPublication entityName]
															  propertiesToFetch:nil 
															withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)] ]
																  withPredicate:@"returnVisit == %@", visit];
		for(MTPublication *publication in publications)
		{
			[string appendString:[NSString stringWithFormat:@"%@<br>\n", publication.title]];
		}
		[string appendString:@"<br>\n"];
	}
	return string;
}

NSString *emailFormattedStringForCoreDataSettings()
{
	NSMutableString *string = [[NSMutableString alloc] initWithString:@"<html><body>"];
	NSManagedObjectContext *managedObjectContext = [[MyTimeAppDelegate sharedInstance] managedObjectContext];
	
	NSArray *users = [managedObjectContext fetchObjectsForEntityName:[MTUser entityName]
															propertiesToFetch:nil 
														  withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)] ]
																withPredicate:nil];
	for(MTUser *user in users)
	{
		// the specific user
		[string appendString:[NSString stringWithFormat:NSLocalizedString(@"<h1>Backup data for %@:</h1>\n", @"label for sending a printable email backup.  this label is in the body of the email"), user.name]];
		
		// calls
		[string appendString:NSLocalizedString(@"<h2>Calls:</h2>\n", @"label for sending a printable email backup.  this label is in the body of the email")];
		NSArray *calls = [managedObjectContext fetchObjectsForEntityName:[MTCall entityName]
													   propertiesToFetch:nil 
													 withSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"street" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
																		  [NSSortDescriptor sortDescriptorWithKey:@"houseNumber" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
																		  [NSSortDescriptor sortDescriptorWithKey:@"apartmentNumber" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
																		  [NSSortDescriptor sortDescriptorWithKey:@"city" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
																		  [NSSortDescriptor sortDescriptorWithKey:@"state" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
																		  [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], nil]
														   withPredicate:@"(user == %@) AND (deleted == NO)", user];
		for(MTCall *call in calls)
		{
			[string appendString:emailFormattedStringForCoreDataCall(call)];
		}
		
		// hours
		[string appendString:NSLocalizedString(@"<h2>Hours:</h2>\n", @"label for sending a printable email backup.  this label is in the body of the email")];
		NSArray *hoursTimeEntries = [managedObjectContext fetchObjectsForEntityName:[MTTimeEntry entityName]
																propertiesToFetch:nil 
															  withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO] ]
																	withPredicate:@"type == %@", [MTTimeType hoursTypeForUser:user]];
		for(MTTimeEntry *timeEntry in hoursTimeEntries)
		{
			[string appendString:emailFormattedStringForCoreDataTimeEntry(timeEntry)];
		}
		
		// quickbuild
		[string appendString:NSLocalizedString(@"<h2>RBC Hours:</h2>\n", @"label for sending a printable email backup.  this label is in the body of the email")];
		NSArray *rbcTimeEntries = [managedObjectContext fetchObjectsForEntityName:[MTTimeEntry entityName]
																propertiesToFetch:nil 
															  withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO] ]
																	withPredicate:@"type == %@", [MTTimeType rbcTypeForUser:user]];
		for(MTTimeEntry *timeEntry in rbcTimeEntries)
		{
			[string appendString:emailFormattedStringForCoreDataTimeEntry(timeEntry)];
		}
		
		// Bulk Placements
		[string appendString:NSLocalizedString(@"<h2>Bulk Placements:</h2>\n", @"label for sending a printable email backup.  this label is in the body of the email")];
		NSArray *bulkPlacements = [managedObjectContext fetchObjectsForEntityName:[MTBulkPlacement entityName]
																propertiesToFetch:nil 
															  withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO] ]
																	withPredicate:@"user == %@", user];
		for(MTBulkPlacement *bulkPlacement in bulkPlacements)
		{
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
			[string appendString:[NSString stringWithFormat:@"%@:<br>\n", [dateFormatter stringFromDate:bulkPlacement.date]]];
			
			NSArray *publications = [managedObjectContext fetchObjectsForEntityName:[MTPublication entityName]
																  propertiesToFetch:nil 
																withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)] ]
																	  withPredicate:@"bulkPlacement == %@", bulkPlacement];
			for(MTPublication *publication in publications)
			{
				NSString *name = publication.title;
				int count = publication.countValue;
				NSString *type = publication.type;
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
				[string appendString:@"<br>\n"];
			}
			[string appendString:@"<br>\n"];
		}
		
		// not at home
		[string appendFormat:@"<h2>%@:</h2>\n", NSLocalizedStringWithDefaultValue(@"Not At Home Territory", @"", [NSBundle mainBundle], @"Not At Home", @"This would normally be \"Not At Home\" representing the list of houses you did not meet someone at, but there is confusion between not at home territories and not at home return visit types.  I added the Territory word to make them seperate, but you do not have to include the word \"Territory\" in your translation.  label for sending a printable email backup.  this label is in the body of the email")];
		NSArray *territories = [managedObjectContext fetchObjectsForEntityName:[MTTerritory entityName]
															 propertiesToFetch:nil 
														   withSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], 
																				[NSSortDescriptor sortDescriptorWithKey:@"city" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], 
																				[NSSortDescriptor sortDescriptorWithKey:@"state" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], nil]
																 withPredicate:@"user == %@", user];
		for(MTTerritory *territory in territories)
		{
			[string appendString:emailFormattedStringForCoreDataNotAtHomeTerritory(territory)];
		}

		[string appendFormat:@"<h2>%@:</h2>\n", NSLocalizedString(@"Additional Information", @"Title for email section for the \"Additional Information\" info")];

		NSString *names[2];
		names[0] = NSLocalizedString(@"Information Always Shown", @"Title in the 'Additional Information' for the entries that will always show in every call");
		names[1] = NSLocalizedString(@"Other Information", @"Title in the 'Additional Information' for the entries that can be added per call");
		
		for(int i = 0; i < 2; i++)
		{
			[string appendFormat:@"  <h3>%@:</h3>\n", names[i]];
			NSArray *additionalInformation = [managedObjectContext fetchObjectsForEntityName:[MTAdditionalInformationType entityName]
																		   propertiesToFetch:nil 
																		 withSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], 
																							  [NSSortDescriptor sortDescriptorWithKey:@"type" ascending:YES], nil]
																			   withPredicate:(i == 0 ? @"user == %@ AND alwaysShown == YES AND hidden == NO" : @"user == %@ AND alwaysShown == NO AND hidden == NO"), user];
			
			for(MTAdditionalInformationType *type in additionalInformation)
			{
				NSString *localizedNameForMetadataType(MetadataType type);
				
				[string appendFormat:@"    %@:%@<br>\n", type.name, localizedNameForMetadataType(type.typeValue)];
				if(type.typeValue == CHOICE)
				{
					NSArray *multipleChoices = [managedObjectContext fetchObjectsForEntityName:[MTMultipleChoice entityName]
																			 propertiesToFetch:nil 
																		   withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]
																				 withPredicate:@"type == %@", type];
					[string appendString:@"    <ul>\n"];
					for(MTMultipleChoice *choice in multipleChoices)
					{
						[string appendFormat:@"      <li>%@</li>\n", choice.name];
					}
					[string appendString:@"    </ul>\n"];
				}
			}	
		}	
		
		// STATISTICS ADJUSTMENTS
		[string appendFormat:@"<h2>%@:</h2>\n", NSLocalizedString(@"Statistics Adjustments", @"Title for email section for the data that the user changed in the statistics view")];
		NSArray *statisticsAdjustments = [managedObjectContext fetchObjectsForEntityName:[MTStatisticsAdjustment entityName]
																	   propertiesToFetch:nil 
																	 withSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"type" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
																						  [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], nil]
																		   withPredicate:@"user == %@", user];
		for(MTStatisticsAdjustment *adjustment in statisticsAdjustments)
		{
			NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
			[dateComponents setMonth:(adjustment.timestampValue % 99)];
			[dateComponents setYear:(adjustment.timestampValue / 100)];
			[string appendFormat:@"  %@: %@: %@<br>\n", adjustment.type, [dateComponents date], adjustment.adjustment];
		}
		
	}
	[string appendString:@"</body></html>"];
	
	return [string autorelease];
}

+ (MFMailComposeViewController *)sendPrintableEmailBackup
{
	MFMailComposeViewController *mailView = [[[MFMailComposeViewController alloc] init] autorelease];
	[mailView setSubject:NSLocalizedString(@"MyTime Application Printable Backup", @"Email subject line for the email that has a printable version of the mytime data")];
	
	// attach the real records file
	MTSettings *settings = [MTSettings settings];
	NSString *emailAddress = settings.backupEmail;
	if(emailAddress && emailAddress.length)
	{
		[mailView setToRecipients:[emailAddress componentsSeparatedByString:@" "]];
	}
	
	[mailView setMessageBody:emailFormattedStringForCoreDataSettings() isHTML:YES];
	return mailView;
}


+ (MFMailComposeViewController *)sendEmailBackup
{
	MFMailComposeViewController *mailView = [[[MFMailComposeViewController alloc] init] autorelease];
	[mailView setSubject:NSLocalizedString(@"MyTime Application Data Backup", @"Email subject line for the email that has your backup data in it")];
	
	NSMutableString *string = [[NSMutableString alloc] initWithString:@"<html><body>"];
	[string appendString:NSLocalizedString(@"You are able to restore all of your MyTime data as of the sent date of this email if you click on the link below while viewing this email from your iPhone/iTouch. Please make sure that at the end of this email there is a \"VERIFICATION CHECK:\" right after the link, it verifies that all data is contained within this email<br><br>WARNING: CLICKING ON THE LINK BELOW WILL DELETE YOUR CURRENT DATA AND RESTORE FROM THE BACKUP<br><br>", @"This is the body of the email that is sent when you go to More->Settings->Email Backup")];
	
	// attach the real records file
	MTSettings *settings = [MTSettings settings];
	if(settings.backupShouldIncludeAttachment)
	{
		[mailView addAttachmentData:[[NSFileManager defaultManager] contentsAtPath:[[self class] storeFileAndPath]] mimeType:@"mytime/sqlite" fileName:@"backup.mytimedb"];
	}
	
	NSString *emailAddress = settings.backupEmail;
	if(emailAddress && emailAddress.length)
	{
		[mailView setToRecipients:[emailAddress componentsSeparatedByString:@" "]];
	}
	// now add the url that will allow importing
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:settings];
	if(settings.backupShouldCompressLink)
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

NSString *emailFormattedStringForSettings();

- (void)verifyCoreDataConversion
{
	NSString *old = emailFormattedStringForSettings();
	NSString *new = emailFormattedStringForCoreDataSettings();
	if(![old isEqualToString:new])
	{
//		[old writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"old"] atomically:NO encoding:NSUTF8StringEncoding error:nil];
//		[new writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"new"] atomically:NO encoding:NSUTF8StringEncoding error:nil];
		NSLog(@"Verification Failed");

#warning need to make something that displays to the user a dialog and send an email to me		
	}
}

- (void)convertToCoreDataStoreTask
{
	double steps = 1;
	[managedObjectContext_ release];
	managedObjectContext_ = nil;
	NSMutableDictionary *settings = [[Settings sharedInstance] settings];
	
	[self.managedObjectContext processPendingChanges];
	[[self.managedObjectContext undoManager] disableUndoRegistration];
	MTSettings *mtSettings = [MTSettings settings];
	
	[[NSUserDefaults standardUserDefaults] setObject:[settings objectForKey:SettingsCurrentButtonBarName] forKey:SettingsCurrentButtonBarName];
	
	steps = 1 + 9*[[settings objectForKey:SettingsMultipleUsers] count];
		
	mtSettings.currentUser = [settings objectForKey:SettingsMultipleUsersCurrentUser];
	
	// PASSCODE
	mtSettings.passcode = [settings objectForKey:SettingsPasscode];
	
	// BACKUP
	mtSettings.autobackupInterval = [settings objectForKey:SettingsAutoBackupInterval];
	mtSettings.lastBackupDate = [settings objectForKey:SettingsLastBackupDate];
	mtSettings.backupEmail = [settings objectForKey:SettingsBackupEmailAddress];
	mtSettings.backupShouldCompressLinkValue = ![[settings objectForKey:SettingsBackupEmailUncompressedLink] boolValue];
	mtSettings.backupShouldIncludeAttachmentValue = ![[settings objectForKey:SettingsBackupEmailDontIncludeAttachment] boolValue];
	mtSettings.firstViewTitle = [settings objectForKey:SettingsFirstView];
	mtSettings.secondViewTitle = [settings objectForKey:SettingsSecondView];
	mtSettings.thirdViewTitle = [settings objectForKey:SettingsThirdView];
	mtSettings.fourthViewTitle = [settings objectForKey:SettingsFourthView];
	
	// POPUPS
	mtSettings.timeAlertSheetShownValue = [settings objectForKey:SettingsTimeAlertSheetShown] != nil;
	mtSettings.statisticsAlertSheetShownValue = [settings objectForKey:SettingsStatisticsAlertSheetShown] != nil;
	mtSettings.mainAlertSheetShownValue = [settings objectForKey:SettingsMainAlertSheetShown] != nil;
	mtSettings.bulkLiteratureAlertSheetShownValue = [settings objectForKey:SettingsBulkLiteratureAlertSheetShown] != nil;
	mtSettings.existingCallAlertSheetShownValue = [settings objectForKey:SettingsExistingCallAlertSheetShown] != nil;

	mtSettings.lastLattitude = [settings objectForKey:SettingsLastLattitude];
	mtSettings.lastLongitude = [settings objectForKey:SettingsLastLongitude];

	mtSettings.lastHouseNumber = [settings objectForKey:SettingsLastCallStreetNumber];
	mtSettings.lastApartmentNumber = [settings objectForKey:SettingsLastCallApartmentNumber];
	mtSettings.lastStreet = [settings objectForKey:SettingsLastCallStreet];
	mtSettings.lastCity = [settings objectForKey:SettingsLastCallCity];
	mtSettings.lastState = [settings objectForKey:SettingsLastCallState];
	
	NSError *error = nil;
	if (![self.managedObjectContext save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
	self.hud.progress = self.hud.progress + 1.0/steps;
	

	for(NSDictionary *user in [settings objectForKey:SettingsMultipleUsers])
	{
		MTUser *mtUser = [MTUser getOrCreateUserWithName:[user objectForKey:SettingsMultipleUsersName]];
	
		// SECRETARY SETTINGS
		mtUser.secretaryEmailAddress = [settings objectForKey:SettingsSecretaryEmailAddress];
		mtUser.secretaryEmailNotes = [settings objectForKey:SettingsSecretaryEmailNotes];
		
		if([user objectForKey:SettingsPublisherType])
			mtUser.publisherType = [user objectForKey:SettingsPublisherType];
		if([user objectForKey:SettingsMonthDisplayCount])
			mtUser.monthDisplayCount = [user objectForKey:SettingsMonthDisplayCount];
		if([user objectForKey:SettingsSortedByMetadata])
			mtUser.selectedSortByAdditionalInformation = [user objectForKey:SettingsSortedByMetadata];
		
		// METADATA
		double metadataOrder = 100;
		for(NSDictionary *metadata in [user objectForKey:SettingsOtherMetadata])
		{
			MTAdditionalInformationType *mtAdditionalInformationType = [MTAdditionalInformationType insertInManagedObjectContext:self.managedObjectContext];
			mtAdditionalInformationType.typeValue = [[metadata objectForKey:SettingsMetadataType] intValue];
			if(mtAdditionalInformationType.typeValue == CHOICE)
			{
				for(NSString *choice in [metadata objectForKey:SettingsMetadataData])
				{
					MTMultipleChoice *mtChoice = [MTMultipleChoice insertInManagedObjectContext:self.managedObjectContext];
					mtChoice.type = mtAdditionalInformationType;
					mtChoice.name = choice;
				}
			}
			mtAdditionalInformationType.orderValue = metadataOrder;
			mtAdditionalInformationType.alwaysShownValue = NO;
			mtAdditionalInformationType.name = [metadata objectForKey:SettingsMetadataName];
			mtAdditionalInformationType.user = mtUser;
			metadataOrder += 100;
		}
		metadataOrder = 100;
		for(NSDictionary *metadata in [user objectForKey:SettingsPreferredMetadata])
		{
			MTAdditionalInformationType *mtAdditionalInformationType = [MTAdditionalInformationType insertInManagedObjectContext:self.managedObjectContext];
			mtAdditionalInformationType.typeValue = [[metadata objectForKey:SettingsMetadataType] intValue];
			if(mtAdditionalInformationType.typeValue == CHOICE)
			{
				for(NSString *choice in [metadata objectForKey:SettingsMetadataData])
				{
					MTMultipleChoice *mtChoice = [MTMultipleChoice insertInManagedObjectContext:self.managedObjectContext];
					mtChoice.type = mtAdditionalInformationType;
					mtChoice.name = choice;
				}
			}
			mtAdditionalInformationType.orderValue = metadataOrder;
			mtAdditionalInformationType.alwaysShownValue = YES;
			mtAdditionalInformationType.name = [metadata objectForKey:SettingsMetadataName];
			mtAdditionalInformationType.user = mtUser;
			metadataOrder += 100;
		}

		error = nil;
		if (![self.managedObjectContext save:&error]) 
		{
			[NSManagedObjectContext presentErrorDialog:error];
		}
		self.hud.progress = self.hud.progress + 1.0/steps;
		
		// BULK PLACEMENTS
		for(NSDictionary *bulkPlacement in [user objectForKey:SettingsBulkLiterature])
		{
			MTBulkPlacement *mtBulkPlacement = [MTBulkPlacement insertInManagedObjectContext:self.managedObjectContext];
			mtBulkPlacement.user = mtUser;
			mtBulkPlacement.date = [bulkPlacement objectForKey:BulkLiteratureDate];
			
			for(NSDictionary *placement in [bulkPlacement objectForKey:BulkLiteratureArray])
			{
				MTPublication *mtPublication = [MTPublication insertInManagedObjectContext:self.managedObjectContext];
				mtPublication.bulkPlacement = mtBulkPlacement;
				mtPublication.countValue = [[placement objectForKey:BulkLiteratureArrayCount] intValue];
				mtPublication.title = [placement objectForKey:BulkLiteratureArrayTitle];
				mtPublication.type = [placement objectForKey:BulkLiteratureArrayType];
				mtPublication.name = [placement objectForKey:BulkLiteratureArrayName];
				mtPublication.yearValue = [[placement objectForKey:BulkLiteratureArrayYear] intValue];
				mtPublication.monthValue = [[placement objectForKey:BulkLiteratureArrayMonth] intValue];
				mtPublication.dayValue = [[placement objectForKey:BulkLiteratureArrayDay] intValue];
			}
		}

		error = nil;
		if (![self.managedObjectContext save:&error]) 
		{
			[NSManagedObjectContext presentErrorDialog:error];
		}
		self.hud.progress = self.hud.progress + 1.0/steps;
	
		// CALLS
		NSString *callArray[2] = {SettingsCalls, SettingsDeletedCalls};
		for(int i = 0; i < 2; i++)
		{
			int count = 0;
			for(NSDictionary *call in [user objectForKey:callArray[i]])
			{
				count++;
				MTCall *mtCall = [MTCall insertInManagedObjectContext:self.managedObjectContext];
				mtCall.user = mtUser;
				mtCall.houseNumber = [call objectForKey:CallStreetNumber];
				mtCall.apartmentNumber = [call objectForKey:CallApartmentNumber];
				mtCall.street = [call objectForKey:CallStreet];
				mtCall.city = [call objectForKey:CallCity];
				mtCall.state = [call objectForKey:CallState];
				mtCall.deletedValue = i == 1;
				mtCall.name = [call objectForKey:CallName];
				NSString *latLong = [call objectForKey:CallLattitudeLongitude];
				if(latLong == nil)
				{
					mtCall.locationAquiredValue = NO;
					mtCall.locationAquisitionAttemptedValue = NO;
				}
				else if([latLong isEqualToString:@"nil"])
				{
					mtCall.locationAquiredValue = NO;
					mtCall.locationAquisitionAttemptedValue = YES;
				}
				else
				{
					NSArray *stringArray = [latLong componentsSeparatedByString:@", "];
					if(stringArray.count == 2)
					{
						mtCall.lattitude = [NSDecimalNumber decimalNumberWithString:[stringArray objectAtIndex:0]];
						mtCall.longitude = [NSDecimalNumber decimalNumberWithString:[stringArray objectAtIndex:1]];
						mtCall.locationAquisitionAttemptedValue = YES;
						mtCall.locationAquiredValue = YES;
					}
					else
					{
						// something was malformed... look it up again
						mtCall.locationAquiredValue = NO;
						mtCall.locationAquisitionAttemptedValue = NO;
					}

				}
				if([call objectForKey:CallLocationType])
					mtCall.locationLookupType = [call objectForKey:CallLocationType];
				
				// RETURN VISITS
				for(NSDictionary *returnVisit in [call objectForKey:CallReturnVisits])
				{
					MTReturnVisit *mtReturnVisit = [MTReturnVisit insertInManagedObjectContext:self.managedObjectContext];
					mtReturnVisit.call = mtCall;
					mtReturnVisit.date = [returnVisit objectForKey:CallReturnVisitDate];
					mtReturnVisit.notes = [returnVisit objectForKey:CallReturnVisitNotes];
					if([returnVisit objectForKey:CallReturnVisitType])
						mtReturnVisit.type = [returnVisit objectForKey:CallReturnVisitType];
					// PUBLICATIONS
					for(NSDictionary *publication in [returnVisit objectForKey:CallReturnVisitPublications])
					{
						MTPublication *mtPublication = [MTPublication insertInManagedObjectContext:self.managedObjectContext];
						mtPublication.returnVisit = mtReturnVisit;
						mtPublication.dayValue = [[publication objectForKey:CallReturnVisitPublicationDay] intValue];
						mtPublication.monthValue = [[publication objectForKey:CallReturnVisitPublicationMonth] intValue];
						mtPublication.yearValue = [[publication objectForKey:CallReturnVisitPublicationYear] intValue];
						mtPublication.name = [publication objectForKey:CallReturnVisitPublicationName];
						mtPublication.title = [publication objectForKey:CallReturnVisitPublicationTitle];
						mtPublication.type = [publication objectForKey:CallReturnVisitPublicationType];
						mtPublication.countValue = 1;
					}
				}

				// ADDITIONAL INFORMATION
				for(NSDictionary *additionalInformation in [call objectForKey:CallMetadata])
				{
					MTAdditionalInformation *mtAdditionalInformation = [MTAdditionalInformation insertInManagedObjectContext:self.managedObjectContext];

					mtAdditionalInformation.call = mtCall;
					MTAdditionalInformationType *mtAdditionalInformationType = [MTAdditionalInformationType additionalInformationType:[[additionalInformation objectForKey:CallMetadataType] intValue] 
																																 name:[additionalInformation objectForKey:CallMetadataName] 
																																 user:mtUser];
					if(mtAdditionalInformationType == nil)
					{
						// we need to create one of these... this happens when the user deleted the additional information but calls still use it
						mtAdditionalInformationType = [MTAdditionalInformationType insertAdditionalInformationType:[[additionalInformation objectForKey:SettingsMetadataType] intValue] 
																											  name:[additionalInformation objectForKey:SettingsMetadataName]
																											  user:mtUser];
						mtAdditionalInformationType.hiddenValue = YES;
						if(mtAdditionalInformationType.typeValue == CHOICE)
						{
							for(NSString *choice in [additionalInformation objectForKey:SettingsMetadataData])
							{
								MTMultipleChoice *mtMultipleChoice = [MTMultipleChoice insertInManagedObjectContext:self.managedObjectContext];
								mtMultipleChoice.name = choice;
								mtMultipleChoice.type = mtAdditionalInformationType;
							}
						}
					}
					mtAdditionalInformation.type = mtAdditionalInformationType;

					// since the CallMetadataData field had a meaning based on the type, we have to convert the different types
					mtAdditionalInformation.value = [additionalInformation objectForKey:CallMetadataValue];
					switch(mtAdditionalInformationType.typeValue)
					{
						case PHONE:
						case EMAIL:
						case URL:
						case STRING:
						case NOTES:
						case CHOICE:
							break;
						case SWITCH:
							mtAdditionalInformation.booleanValue = [[additionalInformation objectForKey:CallMetadataData] boolValue];
							break;
						case DATE:
							mtAdditionalInformation.date = [additionalInformation objectForKey:CallMetadataData];
							break;
						case NUMBER:
							mtAdditionalInformation.numberValue = [[additionalInformation objectForKey:CallMetadataData] intValue];
							break;
					}
				}
				
				error = nil;
				if (![self.managedObjectContext save:&error]) 
				{
					[NSManagedObjectContext presentErrorDialog:error];
				}
			}			
		}

		error = nil;
		if (![self.managedObjectContext save:&error]) 
		{
			[NSManagedObjectContext presentErrorDialog:error];
		}
		self.hud.progress = self.hud.progress + 1.0/steps;
	
		// QUICK NOTES
		for(NSString *note in [user objectForKey:SettingsQuickNotes])
		{
			MTPresentation *mtPresentation = [MTPresentation insertInManagedObjectContext:self.managedObjectContext];
			mtPresentation.notes = note;
			mtPresentation.user = mtUser;
			mtPresentation.downloadedValue = NO;
		}

		error = nil;
		if (![self.managedObjectContext save:&error]) 
		{
			[NSManagedObjectContext presentErrorDialog:error];
		}
		self.hud.progress = self.hud.progress + 1.0/steps;
	
		// TERRITORY
		for(NSDictionary *territory in [user objectForKey:SettingsNotAtHomeTerritories])
		{
			MTTerritory *mtTerritory = [MTTerritory insertInManagedObjectContext:self.managedObjectContext];
			mtTerritory.name = [territory objectForKey:NotAtHomeTerritoryName];
			mtTerritory.city = [territory objectForKey:NotAtHomeTerritoryCity];
			mtTerritory.state = [territory objectForKey:NotAtHomeTerritoryState];
			mtTerritory.notes = [territory objectForKey:NotAtHomeTerritoryNotes];
			mtTerritory.ownerId = [territory objectForKey:NotAtHomeTerritoryOwnerId];
			mtTerritory.ownerEmailId = [territory objectForKey:NotAtHomeTerritoryOwnerEmailId];
			mtTerritory.ownerEmailAddress = [territory objectForKey:NotAtHomeTerritoryOwnerEmailAddress];
			mtTerritory.user = mtUser;
			for(NSDictionary *street in [territory objectForKey:NotAtHomeTerritoryStreets])
			{
				MTTerritoryStreet *mtStreet = [MTTerritoryStreet insertInManagedObjectContext:self.managedObjectContext];
				mtStreet.name = [street objectForKey:NotAtHomeTerritoryStreetName];
				mtStreet.date = [street objectForKey:NotAtHomeTerritoryStreetDate];
				mtStreet.notes = [street objectForKey:NotAtHomeTerritoryStreetNotes];
				mtStreet.territory = mtTerritory;
				for(NSDictionary *house in [street objectForKey:NotAtHomeTerritoryHouses])
				{
					MTTerritoryHouse *mtHouse = [MTTerritoryHouse insertInManagedObjectContext:self.managedObjectContext];
					mtHouse.number = [house objectForKey:NotAtHomeTerritoryHouseNumber];
					mtHouse.apartment = [house objectForKey:NotAtHomeTerritoryHouseApartment];
					mtHouse.notes = [house objectForKey:NotAtHomeTerritoryHouseNotes];
					mtHouse.street = mtStreet;
					for(NSDate *attempt in [house objectForKey:NotAtHomeTerritoryHouseAttempts])
					{
						MTTerritoryHouseAttempt *mtAttempt = [MTTerritoryHouseAttempt insertInManagedObjectContext:self.managedObjectContext];
						mtAttempt.date = attempt;
						mtAttempt.house = mtHouse;
					}
				}
			}
		}

		error = nil;
		if (![self.managedObjectContext save:&error]) 
		{
			[NSManagedObjectContext presentErrorDialog:error];
		}
		self.hud.progress = self.hud.progress + 1.0/steps;
	
		// HOURS
		MTTimeType *hours = [MTTimeType hoursTypeForUser:mtUser];
		hours.startTimerDate = [user objectForKey:SettingsTimeStartDate];
		for(NSDictionary *timeEntry in [user objectForKey:SettingsTimeEntries])
		{
			MTTimeEntry *mtTimeEntry = [MTTimeEntry insertInManagedObjectContext:self.managedObjectContext];
			mtTimeEntry.type = hours;
			mtTimeEntry.date = [timeEntry objectForKey:SettingsTimeEntryDate];
			mtTimeEntry.minutesValue = [[timeEntry objectForKey:SettingsTimeEntryMinutes] intValue];
		}
		
		error = nil;
		if (![self.managedObjectContext save:&error]) 
		{
			[NSManagedObjectContext presentErrorDialog:error];
		}
		self.hud.progress = self.hud.progress + 1.0/steps;

		// RBC HOURS
		MTTimeType *rbc = [MTTimeType rbcTypeForUser:mtUser];
		rbc.startTimerDate = [user objectForKey:SettingsRBCTimeStartDate];
		for(NSDictionary *timeEntry in [user objectForKey:SettingsRBCTimeEntries])
		{
			MTTimeEntry *mtTimeEntry = [MTTimeEntry insertInManagedObjectContext:self.managedObjectContext];
			mtTimeEntry.date = [timeEntry objectForKey:SettingsTimeEntryDate];
			mtTimeEntry.minutesValue = [[timeEntry objectForKey:SettingsTimeEntryMinutes] intValue];
			mtTimeEntry.type = rbc;
		}
		
		error = nil;
		if (![self.managedObjectContext save:&error]) 
		{
			[NSManagedObjectContext presentErrorDialog:error];
		}
		self.hud.progress = self.hud.progress + 1.0/steps;

		// STATISTICS ADJUSTMENTS
		NSDictionary *statisticsAdjustments = [user objectForKey:SettingsStatisticsAdjustments]; 
		for(NSString *adjustmentCategory in statisticsAdjustments)
		{
			NSDictionary *adjustments = [statisticsAdjustments objectForKey:adjustmentCategory];
			for(NSString *timestamp in adjustments)
			{
				MTStatisticsAdjustment *mtAdjustment = [MTStatisticsAdjustment insertInManagedObjectContext:self.managedObjectContext];
				mtAdjustment.timestampValue = [timestamp intValue];
				mtAdjustment.type = adjustmentCategory;
				mtAdjustment.adjustmentValue = [[adjustments objectForKey:timestamp] intValue];
				mtAdjustment.user = mtUser;
			}
		}
		
		error = nil;
		if (![self.managedObjectContext save:&error]) 
		{
			[NSManagedObjectContext presentErrorDialog:error];
		}
		self.hud.progress = self.hud.progress + 1.0/steps;
	}

	// make sure the current user is initalized
	[MTUser currentUser];
	
	
	[[self managedObjectContext] processPendingChanges];
	[[[self managedObjectContext] undoManager] enableUndoRegistration];

	[self verifyCoreDataConversion];
	
	
	[managedObjectContext_ release];
	managedObjectContext_ = nil;

	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"convertedToCoreData"];
	[self performSelector:@selector(initializeMyTimeViews) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
	[self.hud performSelector:@selector(done) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
}

- (BOOL)convertToCoreDataStore
{
	if([[[NSUserDefaults standardUserDefaults] objectForKey:@"convertedToCoreData"] boolValue])
	{
		return NO;
	}

	// The hud will disable all input on the view (use the higest view possible in the view hierarchy)
    self.hud = [[MBProgressHUD alloc] initWithView:window];
	
    // Set determinate mode
    hud.mode = MBProgressHUDModeDeterminate;
    hud.delegate = self;
    hud.labelText = @"Converting Data File";
    [self.window addSubview:hud];
	
    // Show the HUD while the provided method executes in a new thread
    [hud showWhileExecuting:@selector(convertToCoreDataStoreTask) onTarget:self withObject:nil animated:YES];
	
	return YES;
}




- (void)checkAutoBackup
{
	MTSettings *settings = [MTSettings settings];
	NSDate *lastBackupDate = settings.lastBackupDate;
	NSDate *dateLimit = nil;
	int autobackupInterval = settings.autobackupIntervalValue;
	if(autobackupInterval)
	{
		// subtract the number of days from now
		dateLimit = [NSDate dateWithTimeIntervalSinceNow:-(autobackupInterval * 60 * 60 * 24)];
	}
	if(lastBackupDate == nil || (dateLimit && lastBackupDate == [lastBackupDate earlierDate:dateLimit]) )
	{
		_actionSheetType = AUTO_BACKUP;
		UIActionSheet *alertSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"It has been a while since you did an email backup, want to do it now? It just takes 2 seconds.", @"This is the message the user is presented with when they have not backed up their mytime data ever, or they are past their autobackup interval")
																 delegate:self
														cancelButtonTitle:nil
												   destructiveButtonTitle:NSLocalizedString(@"I don't want to backup", @"button to not send the email backup.  I want to have this to have the sense of sounding very bad, like: I dont care about my data, dont backup")
														otherButtonTitles:NSLocalizedString(@"Send email backup", @"button to send the email backup"), nil] autorelease];
		
		alertSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
		[alertSheet showInView:window];
	}
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// always save data before quitting
    NSError *error = nil;
    if (managedObjectContext_ != nil) 
	{
        if ([managedObjectContext_ hasChanges] && ![managedObjectContext_ save:&error]) 
		{
			[NSManagedObjectContext presentErrorDialog:error];
        } 
    }
	
	// since we are going into the background, show the security view (that way when going into the background
	// the OS will screenshot the security view when restoring... this will hide sensitive info)
	[self displaySecurityViewController];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// always save data before quitting
    NSError *error = nil;
    if (managedObjectContext_ != nil) 
	{
        if ([managedObjectContext_ hasChanges] && ![managedObjectContext_ save:&error]) 
		{
			[NSManagedObjectContext presentErrorDialog:error];
        } 
    }
}

- (void)commonApplicationInitialization
{
	// dynamically add a method to UITableViewIndex that lets us move around the index
	Class tvi = NSClassFromString(@"UITableViewIndex");
	if ( class_addMethod(tvi, @selector(moveIndexIn), (IMP)tableViewIndexMoveIn, "v@:") ) 
	{
		NSLog(@"Added method moveIndexIn to UITableViewIndex");
	} 
	else 
	{
		NSLog(@"Error adding method moveIndexIn to UITableViewIndex");
	}
	if ( class_addMethod(tvi, @selector(moveIndexOut), (IMP)tableViewIndexMoveOut, "v@:") ) 
	{
		NSLog(@"Added method moveIndexIn to UITableViewIndex");
	} 
	else 
	{
		NSLog(@"Error adding method moveIndexIn to UITableViewIndex");
	}
	
	//	application.networkActivityIndicatorVisible = NO;
	
    // Set up the portraitWindow and content view
	self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	[window makeKeyAndVisible];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	NSURL *url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
	if(url)
	{
		[self commonApplicationInitialization];
		[self application:application handleOpenURL:url];
	}
	[self applicationDidFinishLaunching:application];
	
	return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
	static int debounce = 0;
    if (!url || debounce++ == 1)  // only cause this to skip when opening a backup from startup
	{  
		return NO; 
	}
	BOOL handled = NO;
	NSString *path = [url path];

	if([url isFileURL])
	{
		NSString *extension = [path pathExtension];
		if([extension isEqualToString:@"mytimedata"])
		{
			NSString *err = nil;
			NSPropertyListFormat format;
			NSData *data = [[NSData alloc] initWithContentsOfFile:path];
			self.settingsToRestore = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&err];
			[data release];
			if(err == nil && 
			   format == kCFPropertyListXMLFormat_v1_0 &&
			   self.settingsToRestore != nil)
			{
				DEBUG(NSLog(@"%@", self.settingsToRestore);)
				
				handled = YES;
				_actionSheetType = RESTORE_BACKUP;
				UIActionSheet *alertSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"You are trying to restore all MyTime data from a backup, are you sure you want to do this?  THIS WILL DELETE ALL OF YOUR CURRENT DATA", @"This message gets displayed when the user is trying to restore from a backup from the email program")
																		 delegate:self
																cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
														   destructiveButtonTitle:NSLocalizedString(@"Restore from Backup", @"Yes restore from the backup please")
																otherButtonTitles:nil] autorelease];
				
				alertSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
				[alertSheet showInView:window];
			}
		}
		else
		{
			// other types of files go here
		}
		if(!handled)
		{
			UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
			[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
			alertSheet.title = NSLocalizedString(@"MyTime opened with invalid file", @"This message is displayed when someone clicks on a file to open mytime in an email or a webpage which will open up mytime to either add a transfered call or restore from a backup");
			[alertSheet show];
		}
	}
	else
	{
		NSString *data = [url query];
		if(path && data)
		{
			if([@"/addCall" isEqualToString:path])
			{
				do 
				{
					NSData *dataStore = allocNSDataFromNSStringByteString(data);
					if(dataStore == nil)
						break;
					@try
					{
						self.dataToImport = [NSKeyedUnarchiver unarchiveObjectWithData:dataStore];
					}
					@catch (NSException *e) 
					{
						NSLog(@"%@", e);
					}
					[dataStore release];
					DEBUG(NSLog(@"%@", dataToImport);)
					
					if(self.dataToImport == nil)
						break;
					
					handled = YES;
					_actionSheetType = ADD_CALL;
					UIActionSheet *alertSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"You are trying to import a call into MyTime, are you sure you want to do this?", @"This message gets displayed when the user is trying to add a call from an email when the call was transferred from another iphone/itouch")
																			 delegate:self
																	cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
															   destructiveButtonTitle:NSLocalizedString(@"Yes, add call", @"Transferr this call from another user")
																	otherButtonTitles:nil] autorelease];
					
					alertSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
					[alertSheet showInView:window];
				} while (false);
			}
			if([@"/addNotAtHomeTerritory" isEqualToString:path])
			{
				do 
				{
					NSData *dataStore = allocNSDataFromNSStringByteString(data);
					if(dataStore == nil)
						break;
					@try
					{
						self.dataToImport = [NSKeyedUnarchiver unarchiveObjectWithData:dataStore];
					}
					@catch (NSException *e) 
					{
						NSLog(@"%@", e);
					}
					[dataStore release];
					DEBUG(NSLog(@"%@", dataToImport);)
					
					if(self.dataToImport == nil)
						break;
					
					handled = YES;
					_actionSheetType = ADD_NOT_AT_HOME_TERRITORY;
					UIActionSheet *alertSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"You are trying to import a not at home territory into MyTime, are you sure you want to do this?", @"This message gets displayed when the user is trying to add a not at home territory from an email when the call was transferred from another iphone/itouch")
																			 delegate:self
																	cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
															   destructiveButtonTitle:NSLocalizedString(@"Yes, add territory", @"Transferr this call from another user")
																	otherButtonTitles:nil] autorelease];
					
					alertSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
					[alertSheet showInView:window];
				} while (false);
			}
			BOOL compressed;
			if((compressed = [@"/restoreCompressedBackup" isEqualToString:path]) ||
			   [@"/restoreBackup" isEqualToString:path])
			{
				do 
				{
					NSData *dataStore = allocNSDataFromNSStringByteString(data);
					if(dataStore == nil)
						break;
					
					@try
					{
						NSData *theData = compressed ? [dataStore decompress] : dataStore;
						self.settingsToRestore = [NSKeyedUnarchiver unarchiveObjectWithData:theData];
					}
					@catch (NSException *e) 
					{
						UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
						alertSheet.title = [NSString stringWithFormat:@"%@", e];
						[alertSheet show];
						
					}
					[dataStore release];
					DEBUG(NSLog(@"%@", self.settingsToRestore);)
					
					if(self.settingsToRestore == nil)
						break;
					
					handled = YES;
					_actionSheetType = RESTORE_BACKUP;
					UIActionSheet *alertSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"You are trying to restore all MyTime data from a backup, are you sure you want to do this?  THIS WILL DELETE ALL OF YOUR CURRENT DATA", @"This message gets displayed when the user is trying to restore from a backup from the email program")
																			 delegate:self
																	cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
															   destructiveButtonTitle:NSLocalizedString(@"Restore from Backup", @"Yes restore from the backup please")
																	otherButtonTitles:nil] autorelease];
					
					alertSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
					[alertSheet showInView:window];
				} while (false);
			}
		}
		if(!handled)
		{
			UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
			[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
			alertSheet.title = NSLocalizedString(@"MyTime opened with invalid URL", @"This message is displayed when someone clicks on a link in an email or a webpage which will open up mytime to either add a transfered call or restore from a backup");
			[alertSheet show];
		}
	}	
    return YES;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
	if(self.window == nil)
	{
		[self commonApplicationInitialization];
	}

	// break out early so that we can restore the backup with no memory allocated
	if(_actionSheetType == RESTORE_BACKUP)
	{
		return;
	}
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
	BOOL exists = [fileManager fileExistsAtPath:[@"~/Documents/MapMicrosoft VirtualEarth.sqlite" stringByExpandingTildeInPath]];
	if(exists)
		[fileManager removeItemAtPath:[@"~/Documents/MapMicrosoft VirtualEarth.sqlite" stringByExpandingTildeInPath] error:nil];
#if 0		
	if([defaults boolForKey:UserDefaultsClearMapCache])
	{
		[defaults setBool:NO forKey:UserDefaultsClearMapCache];
		NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
		BOOL exists = [fileManager fileExistsAtPath:[@"~/Documents/MapMicrosoft VirtualEarth.sqlite" stringByExpandingTildeInPath]];
		if(exists && ![fileManager removeItemAtPath:[@"~/Documents/MapMicrosoft VirtualEarth.sqlite" stringByExpandingTildeInPath] error:nil])
		{
			UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
			[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
			alertSheet.title = NSLocalizedString(@"Could not delete map cache", @"More->Settings->Delete map cache: error message if the map cache could not be deleted");
			[alertSheet show];
		}
		else
		{
			UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
			[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
			alertSheet.title = NSLocalizedString(@"Map cache has been deleted", @"Confirmation message about the map data being deleted");
			[alertSheet show];
		}
	}
#endif		
	if([defaults boolForKey:UserDefaultsEmailBackupInstantly])
	{
		[defaults setBool:NO forKey:UserDefaultsEmailBackupInstantly];
		MFMailComposeViewController *mailView = [MyTimeAppDelegate sendEmailBackup];
		mailView.mailComposeDelegate = self;
		self.modalNavigationController = [[[UINavigationController alloc] init] autorelease];

		[self.window addSubview:self.modalNavigationController.view];
		// make the window visible
		[window makeKeyAndVisible];

		[self.modalNavigationController presentModalViewController:mailView animated:YES];
		forceEmail = YES;
		return;
	}
	
	if([self convertToCoreDataStore])
	{
		return;
	}

	[self initializeMyTimeViews];
}

- (void)displaySecurityViewController
{
	NSString *passcode = [[MTSettings settings] passcode];
	if(passcode.length && !displayingSecurityViewController)
	{
		displayingSecurityViewController = YES;
		SecurityViewController *securityView = [[[SecurityViewController alloc] initWithNibName:@"SecurityView" bundle:[NSBundle mainBundle]] autorelease];
		securityView.promptText = NSLocalizedString(@"Enter Passcode", @"Prompt to enter a passcode to gain access to MyTime");
		securityView.shouldConfirm = NO;
		securityView.passcode = passcode;
		securityView.delegate = self;
		[self.modalNavigationController.visibleViewController presentModalViewController:securityView animated:NO];
	}
}

- (void)initializeMyTimeViews
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	// Create a tabbar controller and an array to contain the view controllers
	self.tabBarController = [[[UITabBarController alloc] init] autorelease];
	NSMutableArray *localViewControllersArray = [[[NSMutableArray alloc] initWithCapacity:4] autorelease];
	
	// CALLS SORTED BY STREET
	CallsSortedByStreetViewDataSource *streetSortedDataSource = [[[CallsSortedByStreetViewDataSource alloc] init] autorelease];
	SortedCallsViewController *streetViewController = [[[SortedCallsViewController alloc] initWithDataSource:streetSortedDataSource] autorelease];
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:streetViewController] autorelease]];

	// CALLS SORTED BY DATE
	CallsSortedByDateViewDataSource *dateSortedDataSource = [[[CallsSortedByDateViewDataSource alloc] init] autorelease];
	SortedCallsViewController *dateViewController = [[[SortedCallsViewController alloc] initWithDataSource:dateSortedDataSource] autorelease];
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:dateViewController] autorelease]];

	// HOURS
	HourViewController *hourViewController = [[[HourViewController alloc] initWithTimeTypeName:[[MTTimeType hoursType] name]] autorelease];
	hourViewController.managedObjectContext = self.managedObjectContext;
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:hourViewController] autorelease]];

	// STATISTICS
	StatisticsTableViewController *statisticsViewController = [[[StatisticsTableViewController alloc] init] autorelease];
//	StatisticsViewController *statisticsViewController = [[[StatisticsViewController alloc] init] autorelease];
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:statisticsViewController] autorelease]];

	// CALLS SORTED BY CITY
	CallsSortedByCityViewDataSource *citySortedDataSource = [[[CallsSortedByCityViewDataSource alloc] init] autorelease];
	SortedCallsViewController *cityViewController = [[[SortedCallsViewController alloc] initWithDataSource:citySortedDataSource] autorelease];
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:cityViewController] autorelease]];

	// CALLS SORTED BY METADATA
	CallsSortedByFilterDataSource *filterSortedDataSource = [[[CallsSortedByFilterDataSource alloc] init] autorelease];
	MetadataSortedCallsViewController *filterViewController = [[[MetadataSortedCallsViewController alloc] initWithDataSource:filterSortedDataSource] autorelease];
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:filterViewController] autorelease]];
	
	// CALLS SORTED BY NAME
	CallsSortedByNameViewDataSource *nameSortedDataSource = [[[CallsSortedByNameViewDataSource alloc] init] autorelease];
	SortedCallsViewController *nameViewController = [[[SortedCallsViewController alloc] initWithDataSource:nameSortedDataSource] autorelease];
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:nameViewController] autorelease]];
	
	// CALLS SORTED BY STUDY
	CallsSortedByStudyViewDataSource *studySortedDataSource = [[[CallsSortedByStudyViewDataSource alloc] init] autorelease];
	SortedCallsViewController *studyViewController = [[[SortedCallsViewController alloc] initWithDataSource:studySortedDataSource] autorelease];
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:studyViewController] autorelease]];

	// Deleted Calls
	DeletedCallsSortedByStreetViewDataSource *deletedCallsStreetSortedDataSource = [[[DeletedCallsSortedByStreetViewDataSource alloc] init] autorelease];
	SortedCallsViewController *deletedCallsStreetViewController = [[[SortedCallsViewController alloc] initWithDataSource:deletedCallsStreetSortedDataSource] autorelease];
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:deletedCallsStreetViewController] autorelease]];
	
	// ALL CALLS WEB VIEW
	MapViewController *mapViewController = [[[MapViewController alloc] initWithTitle:NSLocalizedString(@"Mapped Calls", @"Mapped calls view title")] autorelease];
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:mapViewController] autorelease]];
	
	// NOT AT HOMES
	NotAtHomeViewController *notAtHomeViewController = [[[NotAtHomeViewController alloc] init] autorelease];
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:notAtHomeViewController] autorelease]];
	
	// BULK LITERATURE
	BulkLiteraturePlacementViewContoller *bulkLiteraturePlacementViewContoller = [[[BulkLiteraturePlacementViewContoller alloc] init] autorelease];
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:bulkLiteraturePlacementViewContoller] autorelease]];
	
	// QUICK BUILD HOURS
	HourViewController *quickBuildHourViewController = [[[HourViewController alloc] initWithTimeTypeName:[[MTTimeType rbcType] name]] autorelease];
	quickBuildHourViewController.managedObjectContext = self.managedObjectContext;
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:quickBuildHourViewController] autorelease]];

	// TUTORIAL
	TutorialViewController *tutorialViewController = [[[TutorialViewController alloc] init] autorelease];
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:tutorialViewController] autorelease]];
	_tutorialViewController = tutorialViewController;
	
	// SETTINGS
	SettingsTableViewController *settingsViewController = [[[SettingsTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
	UINavigationController *settingsNavigationController = [[[UINavigationController alloc] initWithRootViewController:settingsViewController] autorelease];
	[localViewControllersArray addObject:settingsNavigationController];
	
	
	// get the buttons that we should show in the button bar
	NSMutableArray *array = [NSMutableArray array];
	MTSettings *settings = [MTSettings settings];
	UIViewController *controller;
	controller = [self removeControllerFromArray:localViewControllersArray withName:settings.firstViewTitle];
	if(controller)
		[array addObject:controller];
	controller = [self removeControllerFromArray:localViewControllersArray withName:settings.secondViewTitle];
	if(controller)
		[array addObject:controller];
	controller = [self removeControllerFromArray:localViewControllersArray withName:settings.thirdViewTitle];
	if(controller)
		[array addObject:controller];
	controller = [self removeControllerFromArray:localViewControllersArray withName:settings.fourthViewTitle];
	if(controller)
		[array addObject:controller];

	[array addObjectsFromArray:localViewControllersArray];
#if 0
	// to put settings at the top of the more list
	if([array indexOfObject:settingsNavigationController] > 4)
	{
		[array removeObject:settingsNavigationController];
		[array insertObject:settingsNavigationController atIndex:4];
    }
#endif
	controller = [array objectAtIndex:0];
	settings.firstViewTitle = controller.title;
	controller = [array objectAtIndex:1];
	settings.secondViewTitle = controller.title;
	controller = [array objectAtIndex:2];
	settings.thirdViewTitle = controller.title;
	controller = [array objectAtIndex:3];
	settings.fourthViewTitle = controller.title;
	NSError *error = nil;
	if (![settings.managedObjectContext save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
		abort();
	}
	
	
	// set the tab bar controller view controller array to the localViewControllersArray
	tabBarController.viewControllers = array;
	tabBarController.delegate = self;
	tabBarController.moreNavigationController.delegate = self;
	[[NSUserDefaults standardUserDefaults] objectForKey:SettingsCurrentButtonBarName];

	if([[NSUserDefaults standardUserDefaults] objectForKey:SettingsCurrentButtonBarName])
	{
		NSArray *nameArray = [array valueForKeyPath:@"topViewController.title"];
		NSUInteger index = [nameArray indexOfObject:[[NSUserDefaults standardUserDefaults] objectForKey:SettingsCurrentButtonBarName]];
		if(index != NSNotFound)
		{
			UIViewController *viewController = [array objectAtIndex:index];
			if(viewController)
			{
				tabBarController.selectedViewController = viewController;
			}
		}
	}

	self.modalNavigationController = [[[UINavigationController alloc] initWithRootViewController:tabBarController] autorelease];
	self.modalNavigationController.navigationBarHidden = YES;
	
	// set the window subview as the tab bar controller
	[window addSubview:self.modalNavigationController.view];

	// make the window visible
	[window makeKeyAndVisible];
	
	if([defaults boolForKey:UserDefaultsRemovePasscode])
	{
		[defaults setBool:NO forKey:UserDefaultsRemovePasscode];
		settings.passcode = nil;
		NSError *error = nil;
		if (![settings.managedObjectContext save:&error]) 
		{
			[NSManagedObjectContext presentErrorDialog:error];
			abort();
		}
	}
	
	NSString *passcode = settings.passcode;
	
	if(_actionSheetType == NORMAL_STARTUP)
	{
		if(!settings.mainAlertSheetShownValue)
		{
			settings.mainAlertSheetShownValue = YES;
			NSError *error = nil;
			if (![settings.managedObjectContext save:&error]) 
			{
				[NSManagedObjectContext presentErrorDialog:error];
				abort();
			}
			
			UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
			alertSheet.delegate = self;
			alertViewTutorials = YES;
			[alertSheet addButtonWithTitle:NSLocalizedString(@"Tutorials", @"Button to take the user directly to the tutorials view from the first popup in mytime")];
			[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
			alertSheet.title = NSLocalizedString(@"Please visit mytime.googlecode.com to see the FAQ and feature requests.\nA lot of work has been put into MyTime, if you find this application useful then you are welcome to donate.  Is English not your native language and you want to help to translate? Email me (look in the More view and Settings)", @"Information for the user to know what is going on with this and new releases");
			[alertSheet show];
		}
		else 
		{
			if(!passcode.length)
			{
				[self checkAutoBackup];
			}
		}
	}

	// kick off the Geocache lookup
	[[Geocache sharedInstance] setWindow:window];

	[self displaySecurityViewController];
}

- (void)securityViewControllerDone:(SecurityViewController *)viewController authenticated:(BOOL)authenticated
{
	displayingSecurityViewController = NO;
	if(authenticated)
	{
		[viewController dismissModalViewControllerAnimated:YES];
		[self checkAutoBackup];
	}
	else
	{
		exit(0);
	}
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if(viewController != self.tabBarController.moreNavigationController)
	{
		[[NSUserDefaults standardUserDefaults] setObject:viewController.title forKey:SettingsCurrentButtonBarName];
	}
	else
	{
		[[NSUserDefaults standardUserDefaults] setObject:@"MoreViewController" forKey:SettingsCurrentButtonBarName];
	}
}

- (void)tabBarController:(UITabBarController *)theTabBarController didSelectViewController:(UIViewController *)viewController
{
	if(viewController != self.tabBarController.moreNavigationController)
	{
		[[NSUserDefaults standardUserDefaults] setObject:viewController.title forKey:SettingsCurrentButtonBarName];
	}
	else
	{
		[[NSUserDefaults standardUserDefaults] setObject:@"MoreViewController" forKey:SettingsCurrentButtonBarName];
	}
}

- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
	if(changed)
	{
		MTSettings *settings = [MTSettings settings];
		UIViewController *controller;
		
		controller = [viewControllers objectAtIndex:0];
		settings.firstViewTitle = controller.title;
		controller = [viewControllers objectAtIndex:1];
		settings.secondViewTitle = controller.title;
		controller = [viewControllers objectAtIndex:2];
		settings.thirdViewTitle = controller.title;
		controller = [viewControllers objectAtIndex:3];
		settings.fourthViewTitle = controller.title;
		
		NSError *error = nil;
		if (![settings.managedObjectContext save:&error]) 
		{
			[NSManagedObjectContext presentErrorDialog:error];
			abort();
		}
	}
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}

+ (NSString *)storeFileAndPath
{
	return [[MyTimeAppDelegate applicationDocumentsDirectory] stringByAppendingPathComponent: @"MyTime.sqlite"];
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel 
{
    if (managedObjectModel_ != nil) 
	{
        return managedObjectModel_;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"MyTime" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator 
{
    
    if (persistentStoreCoordinator_ != nil) 
	{
        return persistentStoreCoordinator_;
    }
    
    NSURL *storeURL = [NSURL fileURLWithPath:[[self class] storeFileAndPath]];
    
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType 
												   configuration:nil 
															 URL:storeURL 
														 options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil] 
														   error:&error]) 
	{
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
		[NSManagedObjectContext presentErrorDialog:error];
    }    
	
    return persistentStoreCoordinator_;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
+ (NSString *)applicationDocumentsDirectory 
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark UITableViewIndex Added Methods
static BOOL tableViewIndexMoveIn(id self, SEL _cmd) 
{
	UIView *index = (UIView *)self;
	
	[UIView beginAnimations:nil context:nil];
	index.center = CGPointMake(index.center.x - index.bounds.size.width, index.center.y);
	[UIView commitAnimations];
	
    return YES;
}
 
static BOOL tableViewIndexMoveOut(id self, SEL _cmd) 
{
	UIView *index = (UIView *)self;
	
	[UIView beginAnimations:nil context:nil];
	index.center = CGPointMake(index.center.x + index.bounds.size.width, index.center.y);
	[UIView commitAnimations];
	
    return YES;
}

@end
