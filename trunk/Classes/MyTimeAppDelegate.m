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
#import "MetadataViewController.h"
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
#import "MTDisplayRule.h"
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
#import "MTFilter.h"
#import "MetadataCustomViewController.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "UIAlertViewQuitter.h"

BOOL isIOS4OrGreater(void)
{
	static BOOL result = NO;
	static BOOL initalized = NO;
	if(!initalized)
	{
		initalized = YES;
		NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare: @"4.0" options: NSNumericSearch];
		if (order == NSOrderedSame || order == NSOrderedDescending) 
		{
			result = YES;
		} 
		else 
		{
			result = NO;
		}
	}
	return result;
}

BOOL isSmsAvaliable(void)
{
#if TARGET_IPHONE_SIMULATOR
	return YES;
#else	
    Class messageClass = NSClassFromString(@"MFMessageComposeViewController");
    
    if(messageClass != nil) 
	{
        // Check whether the current device is configured for sending SMS messages
        if([messageClass canSendText]) 
		{
            return YES;
		}
	}
	return NO;
#endif	
}


@interface MyTimeAppDelegate ()
- (void)displaySecurityViewController;
+ (NSString *)storeFileAndPath;
- (MFMailComposeViewController *)sendCoreDataConvertFailureEmail;
- (MTCall *)createCoreDataCallWithUser:(MTUser *)mtUser call:(NSDictionary *)call deleted:(BOOL)deleted;
- (MTTerritory *)createCoreDataTerritoryWithUser:(MTUser *)mtUser territory:(NSDictionary *)territory;

@end

@implementation MyTimeAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize dataToImport;
@synthesize settingsToRestore;
@synthesize fileToRestore;
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
	if((length & 1) != 0)
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
	if(buttonIndex == 0)
	{
		self.tabBarController.selectedViewController = self.tabBarController.moreNavigationController;
		[self.tabBarController setSelectedViewController:_tutorialViewController];
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
					MTCall *mtCall = [self createCoreDataCallWithUser:[MTUser currentUser] call:newCall deleted:NO];
					self.dataToImport = nil;

					// kick off the geocoder if not already done
					if(![mtCall.locationLookupType isEqualToString:CallLocationTypeManual])
					{
						[[Geocache sharedInstance] lookupCall:mtCall];
					}
					
					UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
					[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
					alertSheet.title = NSLocalizedString(@"Import successful", @"This message is displayed after a successful import of a call or a restore of a backup");
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
		case ADD_CORE_DATA_CALL:
			switch(button)
			{
					//import
				case 0:
				{
					MTCall *newCall = (MTCall *)[self.managedObjectContext managedObjectFromDictionary:dataToImport];
					
					// change all return visits to be transferrs so that we dont count the other person's work
					for(MTReturnVisit *visit in newCall.returnVisits)
					{
						NSString *type = visit.type;
						if(type == nil || [type isEqualToString:CallReturnVisitTypeReturnVisit])
						{
							visit.type = CallReturnVisitTypeTransferedReturnVisit;
						}
						else if([type isEqualToString:CallReturnVisitTypeInitialVisit])
						{
							visit.type = CallReturnVisitTypeTransferedInitialVisit;
						}
						else if([type isEqualToString:CallReturnVisitTypeNotAtHome])
						{
							visit.type = CallReturnVisitTypeTransferedNotAtHome;
						}
						else if([type isEqualToString:CallReturnVisitTypeStudy])
						{
							visit.type = CallReturnVisitTypeTransferedStudy;
						}
					}

					// fix the additional info types and move the temporary types that the other user had
					// below everything else
					MTUser *currentUser = [MTUser currentUser];
					for(MTAdditionalInformation *info in newCall.additionalInformation)
					{
						if(info.type)
						{
							info.type.orderValue = 1000 + info.type.orderValue;
							info.type.user = currentUser;
							info.type.hiddenValue = YES;
						}
					}

					// add the always shown additional information
					[newCall initializeNewCallWithoutReturnVisit];
					
					NSError *error = nil;
					if (![self.managedObjectContext save:&error]) 
					{
						NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
						[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:nil error:error];
					}
					
					// kick off the geocoder if not already done
					if(![newCall.locationLookupType isEqualToString:CallLocationTypeManual])
					{
						[[Geocache sharedInstance] lookupCall:newCall];
					}
					
					self.dataToImport = nil;
					
					UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
					[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
					alertSheet.title = NSLocalizedString(@"Import successful", @"This message is displayed after a successful import of a call or a restore of a backup");
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
					NSMutableDictionary *newTerritory = [NSMutableDictionary dictionaryWithDictionary:dataToImport];
										
					MTTerritory *mtTerritory = [self createCoreDataTerritoryWithUser:[MTUser currentUser] territory:newTerritory];
					
					// add the user to make it correct
					mtTerritory.user = [MTUser currentUser];
					
					NSError *error = nil;
					if (![self.managedObjectContext save:&error]) 
					{
						NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
						[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:nil error:error];
					}
					
					self.dataToImport = nil;
					
					UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
					[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
					alertSheet.title = NSLocalizedString(@"Import successful", @"This message is displayed after a successful import of a call or a restore of a backup");
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
		case ADD_CORE_DATA_NOT_AT_HOME_TERRITORY:
			switch(button)
			{
					//import
				case 0:
				{
					MTTerritory *territory = (MTTerritory *)[self.managedObjectContext managedObjectFromDictionary:dataToImport];

					// add the user to make it correct
					territory.user = [MTUser currentUser];
					
					NSError *error = nil;
					if (![self.managedObjectContext save:&error]) 
					{
						NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
						[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:nil error:error];
					}
					
					self.dataToImport = nil;
					
					UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
					[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
					alertSheet.title = NSLocalizedString(@"Import successful", @"This message is displayed after a successful import of a call or a restore of a backup");
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
					NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
					BOOL exists = [fileManager fileExistsAtPath:[[self class] storeFileAndPath]];
					if(exists && ![fileManager removeItemAtPath:[[self class] storeFileAndPath] error:nil])
					{
						NSLog(@"deleted file");
					}
					
					UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
					alertSheet.delegate = [[UIAlertViewQuitter alloc] init];
					[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
					alertSheet.title = NSLocalizedString(@"Backup restored, press OK to quit mytime. You will have to restart to use your restored data", @"This message is displayed after a successful import of a call or a restore of a backup");
					[alertSheet show];
					break;
				}
					// cancel
				case 1:
				{
					self.settingsToRestore = nil;
					// dont reinit the views if they are still in existance
					if(tabBarController == nil)
						[self initializeMyTimeViews];
					break;
				}
			}
			break;
		case RESTORE_CORE_DATA_BACKUP:
			switch(button)
			{
					//import
				case 0:
				{
					NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
					BOOL exists = [fileManager fileExistsAtPath:[[self class] storeFileAndPath]];
					if(exists && ![fileManager removeItemAtPath:[[self class] storeFileAndPath] error:nil])
					{
						NSLog(@"deleted file");
					}
					[fileManager moveItemAtPath:self.fileToRestore toPath:[[self class] storeFileAndPath] error:nil];
					self.fileToRestore = nil;
					
					UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
					alertSheet.delegate = [[UIAlertViewQuitter alloc] init];
					[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
					alertSheet.title = NSLocalizedString(@"Backup restored, press OK to quit mytime. You will have to restart to use your restored data", @"This message is displayed after a successful import of a call or a restore of a backup");
					[alertSheet show];
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
			_actionSheetType = NORMAL_STARTUP;
			switch(button)
			{
				// dont email backup
				case 0:
				{
					[[MTSettings settings] setLastBackupDate:[NSDate date]];
					break;
				}
				// send email backup
				case 1:
				{
					if([MFMailComposeViewController canSendMail] == NO)
					{
						UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
						alertSheet.title = NSLocalizedString(@"You must setup email on this device to be able to send an email.  Open the Mail application and setup your email account", @"This is a message displayed when the user does not have email setup on their iDevice");
						[alertSheet show];
						break;
					}
					MFMailComposeViewController *mailView = [MyTimeAppDelegate sendEmailBackup];
					mailView.mailComposeDelegate = self;
					[self.modalNavigationController.visibleViewController presentModalViewController:mailView animated:YES];
					break;
				}
			}
			break;
		case CONVERT_DATAFILE_FAILURE:
			switch(button)
			{
				case 0:
				{
					[self.hud hide:YES];

					forceEmail = YES;
					if([MFMailComposeViewController canSendMail] == NO)
					{
						UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
						alertSheet.title = NSLocalizedString(@"You must setup email on this device to be able to send an email.  Open the Mail application and setup your email account", @"This is a message displayed when the user does not have email setup on their iDevice");
						[alertSheet show];
						return;
					}
					MFMailComposeViewController *mailView = [self sendCoreDataConvertFailureEmail];
					mailView.mailComposeDelegate = self;

					self.modalNavigationController = [[[UINavigationController alloc] init] autorelease];
					
					[self.window addSubview:self.modalNavigationController.view];
					// make the window visible
					[window makeKeyAndVisible];
					
					[self.modalNavigationController presentModalViewController:mailView animated:YES];
					forceEmail = YES;
					break;
				}
				case 1:
				{
					[self initializeMyTimeViews];
					[self.hud hide:YES];
					break;
				}
			}
			break;
        default:
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
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:nil error:error];
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
		[dateFormatter setDateFormat:@"EEE, d/M/yyy h:mma"];
	}
	else
	{
		[dateFormatter setDateFormat:NSLocalizedString(@"EEE, M/d/yyy h:mma", @"localized date string string using http://unicode.org/reports/tr35/tr35-4.html#Date_Format_Patterns as a guide to how to format the date")];
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
															 withSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor psSortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
																				  [NSSortDescriptor psSortDescriptorWithKey:@"date" ascending:YES], nil]
																   withPredicate:@"territory == %@", territory];
	for(MTTerritoryStreet *street in streets)
	{
		[string appendString:[NSString stringWithFormat:@"<h4>%@: %@</h4>\n", NSLocalizedString(@"Street", @"used as a label when emailing not at homes"), street.name]];
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
		for(MTTerritoryHouse *house in [street.houses sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor psSortDescriptorWithKey:@"number" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
																				   [NSSortDescriptor psSortDescriptorWithKey:@"apartment" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], 
																				   [NSSortDescriptor psSortDescriptorWithKey:@"notes" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], 
																				   [NSSortDescriptor psSortDescriptorWithKey:@"hashedOrder" ascending:YES], nil]])
		{
			NSString *top = [MTCall topLineOfAddressWithHouseNumber:house.number apartmentNumber:house.apartment street:nil];
			
			[string appendString:[NSString stringWithFormat:@"<b>%@: %@</b><br>\n", NSLocalizedString(@"House Number", @"used as a label when emailing not at homes"), top]];
			NSString *notes = house.notes;
			if([notes length])
			{
				notes = [notes stringByReplacingOccurrencesOfString:@" " withString:@"&nbsp;"];
				notes = [notes stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
				[string appendString:notes];
				[string appendFormat:@"<br>\n"];
			}
			[string appendString:[NSString stringWithFormat:@"%@:<br>\n", NSLocalizedString(@"Attempts", @"used as a label when emailing not at homes")]];

			NSArray *attempts = [house.managedObjectContext fetchObjectsForEntityName:[MTTerritoryHouseAttempt entityName]
																	  propertiesToFetch:nil 
																	withSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor psSortDescriptorWithKey:@"date" ascending:NO], nil]
																		  withPredicate:@"house == %@", house];
			for(MTTerritoryHouseAttempt *attempt in attempts)
			{
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
	[string appendString:[NSString stringWithFormat:@"%@:<br>%@<br>%@<br>\n", NSLocalizedString(@"Address", @"Address label for call"), call.addressNumberAndStreet, call.addressCityAndState]];
	
	if(call.locationAquiredValue)
	{
		[string appendFormat:@"%@, %@<br>\n", call.lattitude, call.longitude];
	}
	NSString *lookupType = call.locationLookupType;
	[string appendFormat:@"%@<br>\n", [[PSLocalization localizationBundle] localizedStringForKey:lookupType value:lookupType table:nil]];
	
	// Add Metadata
	// they had an array of publications, lets check them too
	// Publications
	NSArray *additionalInformations = [call.managedObjectContext fetchObjectsForEntityName:[MTAdditionalInformation entityName]
															   propertiesToFetch:nil 
															 withSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor psSortDescriptorWithKey:@"type.name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
																				  [NSSortDescriptor psSortDescriptorWithKey:@"value" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], nil]
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
															 withSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor psSortDescriptorWithKey:@"date" ascending:NO], 
                                                                                  [NSSortDescriptor psSortDescriptorWithKey:@"notes" ascending:NO], 
                                                                                  [NSSortDescriptor psSortDescriptorWithKey:@"type" ascending:NO], 
                                                                                  nil]
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
															withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"order" ascending:YES] ]
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
														  withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)] ]
																withPredicate:nil];
	for(MTUser *user in users)
	{
		// the specific user
		[string appendString:[NSString stringWithFormat:NSLocalizedString(@"<h1>Backup data for %@:</h1>\n", @"label for sending a printable email backup.  this label is in the body of the email"), user.name]];
		
		// calls
		[string appendString:NSLocalizedString(@"<h2>Calls:</h2>\n", @"label for sending a printable email backup.  this label is in the body of the email")];
		NSArray *calls = [managedObjectContext fetchObjectsForEntityName:[MTCall entityName]
													   propertiesToFetch:nil 
													 withSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor psSortDescriptorWithKey:@"street" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
																		  [NSSortDescriptor psSortDescriptorWithKey:@"houseNumber" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
																		  [NSSortDescriptor psSortDescriptorWithKey:@"apartmentNumber" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
																		  [NSSortDescriptor psSortDescriptorWithKey:@"city" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
																		  [NSSortDescriptor psSortDescriptorWithKey:@"state" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
																		  [NSSortDescriptor psSortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], nil]
														   withPredicate:@"(user == %@) AND (deletedCall == NO)", user];
		for(MTCall *call in calls)
		{
			[string appendString:emailFormattedStringForCoreDataCall(call)];
		}
		
		// hours
		[string appendString:NSLocalizedString(@"<h2>Hours:</h2>\n", @"label for sending a printable email backup.  this label is in the body of the email")];
		NSArray *hoursTimeEntries = [managedObjectContext fetchObjectsForEntityName:[MTTimeEntry entityName]
																propertiesToFetch:nil 
															  withSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor psSortDescriptorWithKey:@"date" ascending:NO],
																											[NSSortDescriptor psSortDescriptorWithKey:@"minutes" ascending:NO], nil]
																	withPredicate:@"type == %@", [MTTimeType hoursTypeForUser:user]];
		for(MTTimeEntry *timeEntry in hoursTimeEntries)
		{
			[string appendString:emailFormattedStringForCoreDataTimeEntry(timeEntry)];
		}
		
		// quickbuild
		[string appendString:NSLocalizedString(@"<h2>RBC Hours:</h2>\n", @"label for sending a printable email backup.  this label is in the body of the email")];
		NSArray *rbcTimeEntries = [managedObjectContext fetchObjectsForEntityName:[MTTimeEntry entityName]
																propertiesToFetch:nil 
															  withSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor psSortDescriptorWithKey:@"date" ascending:NO],
																											[NSSortDescriptor psSortDescriptorWithKey:@"minutes" ascending:NO], nil ]
																	withPredicate:@"type == %@", [MTTimeType rbcTypeForUser:user]];
		for(MTTimeEntry *timeEntry in rbcTimeEntries)
		{
			[string appendString:emailFormattedStringForCoreDataTimeEntry(timeEntry)];
		}
		
		// Bulk Placements
		[string appendString:NSLocalizedString(@"<h2>Bulk Placements:</h2>\n", @"label for sending a printable email backup.  this label is in the body of the email")];
		NSArray *bulkPlacements = [managedObjectContext fetchObjectsForEntityName:[MTBulkPlacement entityName]
																propertiesToFetch:nil 
															  withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"date" ascending:NO] ]
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
				[dateFormatter setDateFormat:NSLocalizedString(@"EEE, M/d/yyy h:mma", @"localized date string string using http://unicode.org/reports/tr35/tr35-4.html#Date_Format_Patterns as a guide to how to format the date")];
			}
			[string appendString:[NSString stringWithFormat:@"%@:<br>\n", [dateFormatter stringFromDate:bulkPlacement.date]]];
			NSString *notes = bulkPlacement.notes;
			if(notes && notes.length)
			{
				notes = [notes stringByReplacingOccurrencesOfString:@" " withString:@"&nbsp;"];
				notes = [notes stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
				[string appendString:notes];
				[string appendString:@"<br>\n"];
			}
			
			NSArray *publications = [managedObjectContext fetchObjectsForEntityName:[MTPublication entityName]
																  propertiesToFetch:nil 
																withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"order" ascending:YES] ]
																	  withPredicate:@"bulkPlacement == %@", bulkPlacement];
			for(MTPublication *publication in publications)
			{
				NSString *name = publication.title;
				int count = publication.countValue;
				NSString *type = publication.type;
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
		
		// Territories
		[string appendFormat:@"<h2>%@:</h2>\n", NSLocalizedString(@"Territories", @"View title for the previously named 'Not At Homes' but it is representing the user's territory now")];
		NSArray *territories = [managedObjectContext fetchObjectsForEntityName:[MTTerritory entityName]
															 propertiesToFetch:nil 
														   withSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor psSortDescriptorWithKey:@"date" ascending:YES], nil]
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
																		 withSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor psSortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], 
																							  [NSSortDescriptor psSortDescriptorWithKey:@"type" ascending:YES], nil]
																			   withPredicate:(i == 0 ? @"user == %@ AND alwaysShown == YES AND hidden == NO" : @"user == %@ AND alwaysShown == NO AND hidden == NO"), user];
			
			for(MTAdditionalInformationType *type in additionalInformation)
			{
				NSString *localizedNameForMetadataType(MetadataType type);
				
				[string appendFormat:@"    %@:%@<br>\n", type.name, localizedNameForMetadataType(type.typeValue)];
				if(type.typeValue == CHOICE)
				{
					NSArray *multipleChoices = [managedObjectContext fetchObjectsForEntityName:[MTMultipleChoice entityName]
																			 propertiesToFetch:nil 
																		   withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]
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
																	 withSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor psSortDescriptorWithKey:@"type" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
																						  [NSSortDescriptor psSortDescriptorWithKey:@"timestamp" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], nil]
																		   withPredicate:@"user == %@", user];
		NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
		for(MTStatisticsAdjustment *adjustment in statisticsAdjustments)
		{
			NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
			[dateComponents setMonth:(adjustment.timestampValue % 100)];
			[dateComponents setYear:(adjustment.timestampValue / 100)];
			NSDate *date = [gregorian dateFromComponents:dateComponents];
			[string appendFormat:@"  %@: %@: %@<br>\n", adjustment.type, date, adjustment.adjustment];
			[dateComponents release];
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
	NSData *data = nil;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	// it could be that they are sending the original file because of a conversion failure, use the old file instead
	if([fileManager fileExistsAtPath:[Settings filename]])
	{
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
		data = [NSKeyedArchiver archivedDataWithRootObject:settings];
		if(![settings objectForKey:SettingsBackupEmailUncompressedLink])
		{	
			data = [data compress];
			[string appendString:@"<a href=\"mytime://mytime/restoreCompressedBackup?"];
		}
		else
		{
			[string appendString:@"<a href=\"mytime://mytime/restoreBackup?"];
		}
	}
	else
	{
		data = [fileManager contentsAtPath:[[self class] storeFileAndPath]];
		MTSettings *settings = [MTSettings settings];
		if(settings.backupShouldIncludeAttachmentValue)
		{
			[mailView addAttachmentData:data mimeType:@"mytime/sqlite" fileName:@"backup.mytimedb"];
		}
		NSString *emailAddress = settings.backupEmail;
		if(emailAddress && emailAddress.length)
		{
			[mailView setToRecipients:[emailAddress componentsSeparatedByString:@" "]];
		}
		// now add the url that will allow importing
		if(settings.backupShouldCompressLinkValue)
		{	
			data = [data compress];
			[string appendString:@"<a href=\"mytime://mytime/restoreCompressedCoreDataBackup?"];
		}
		else
		{
			[string appendString:@"<a href=\"mytime://mytime/restoreCoreDataBackup?"];
		}
		
		
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

- (MFMailComposeViewController *)sendCoreDataConvertFailureEmail
{
	MFMailComposeViewController *mailView = [[[MFMailComposeViewController alloc] init] autorelease];
	[mailView setSubject:NSLocalizedString(@"MyTime Data Convert Failure", @"Email subject line for the email that will be sent to me when there is a failure in the data conversion in the 4.0 version of mytime")];
	
	NSMutableString *string = [[NSMutableString alloc] initWithString:@"<html><body>"];
	[string appendString:NSLocalizedString(@"MyTime encountered an error translating your data to the new format.<br><br><b>Your old data is still safe</b>, I have included it in this email for the author of MyTime to fix.  The author of MyTime will try to respond quickly to your problem with a fixed data file for you to use.  <br><br>You <i>might</i> be able to use MyTime as is and see no loss of data; MyTime just detected a difference in your data between the old data file and the new one.  To be safe, dont depend on this.<br><br>", @"Email body for the email that will be sent to me when there is a failure in the data conversion in the 4.0 version of mytime")];
	
	// attach the old records file
	[mailView addAttachmentData:[[NSFileManager defaultManager] contentsAtPath:[Settings outOfWayFilename]] mimeType:@"mytime/plist" fileName:@"backup.mytimedata"];
	[mailView addAttachmentData:[[NSFileManager defaultManager] contentsAtPath:[[MyTimeAppDelegate applicationDocumentsDirectory] stringByAppendingPathComponent:@"new"]] mimeType:@"mytime/text" fileName:@"verifyNew.txt"];
	[mailView addAttachmentData:[[NSFileManager defaultManager] contentsAtPath:[[MyTimeAppDelegate applicationDocumentsDirectory] stringByAppendingPathComponent:@"old"]] mimeType:@"mytime/text" fileName:@"verifyOld.txt"];
	
	[mailView setToRecipients:[NSArray arrayWithObject:@"toopriddy@gmail.com"]];

	// now add the url that will allow importing
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[[Settings sharedInstance] settings]];
	data = [data compress];
	[string appendString:@"<a href=\"mytime://mytime/restoreCompressedBackup?"];
	
	int length = data.length;
	unsigned char *bytes = (unsigned char *)data.bytes;
	for(int i = 0; i < length; ++i)
	{
		[string appendFormat:@"%02X", *bytes++];
	}
	[string appendString:@"\">"];
	[string appendString:NSLocalizedString(@"Data file link", @"This is the text that appears in the link of the email when you are wanting to restore from a backup.  this is the link that they press to open MyTime")];
	[string appendString:@"</a><br><br>"];
	[string appendString:NSLocalizedString(@"VERIFICATION CHECK: all data was contained in this email", @"This is a very important message that is at the end of the email used to transfer a call to another witness or if you are just emailing a backup to yourself, it verifies that all of the data is contained in the email, if it is not there then all of the data is not in the email and something bad happened :(")];
	[string appendString:@"</body></html>"];
	[mailView setMessageBody:string isHTML:YES];
	[string release];
	
	return mailView;
}



NSString *emailFormattedStringForSettings();

- (BOOL)verifyCoreDataConversion
{
    hud.labelText = NSLocalizedString(@"Verifying Data File", @"this message is presented to the user when they are upgrading their MyTime and MyTime is converting their old database file to a new one");
	hud.detailsLabelText = NSLocalizedString(@"Please wait. Just a few more seconds...", @"this message is presented to the user when they are upgrading their MyTime and MyTime is converting their old database file to a new one");
	hud.progress = 0.0;
	NSString *old = emailFormattedStringForSettings();
	hud.progress = 0.5;
	NSString *new = emailFormattedStringForCoreDataSettings();
	hud.progress = 1.0;
	if(![old isEqualToString:new])
	{
		[old writeToFile:[[MyTimeAppDelegate applicationDocumentsDirectory] stringByAppendingPathComponent:@"old"] atomically:NO encoding:NSUTF8StringEncoding error:nil];
		[new writeToFile:[[MyTimeAppDelegate applicationDocumentsDirectory] stringByAppendingPathComponent:@"new"] atomically:NO encoding:NSUTF8StringEncoding error:nil];
		NSLog(@"Verification Failed");
		return NO;
	}
	return YES;
}

- (MTCall *)createCoreDataCallWithUser:(MTUser *)mtUser call:(NSDictionary *)call deleted:(BOOL)deleted
{
	NSError *error;
	MTCall *mtCall = [MTCall insertInManagedObjectContext:self.managedObjectContext];
	mtCall.user = mtUser;
	mtCall.houseNumber = [call objectForKey:CallStreetNumber];
	if(mtCall.houseNumber == nil)
		mtCall.houseNumber = @"";
	mtCall.apartmentNumber = [call objectForKey:CallApartmentNumber];
	if(mtCall.apartmentNumber == nil)
		mtCall.apartmentNumber = @"";
	mtCall.street = [call objectForKey:CallStreet];
	if(mtCall.street == nil)
		mtCall.street = @"";
	mtCall.city = [call objectForKey:CallCity];
	if(mtCall.city == nil)
		mtCall.city = @"";
	mtCall.state = [call objectForKey:CallState];
	if(mtCall.state == nil)
		mtCall.state = @"";
	mtCall.deletedCallValue = deleted;
	mtCall.name = [call objectForKey:CallName];
	if(mtCall.name == nil)
		mtCall.name = @"";
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
	NSArray *returnVisits = [[call objectForKey:CallReturnVisits] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"date" ascending:YES]]];
	BOOL first = YES;
	BOOL firstTransfer = YES;
	for(NSMutableDictionary *returnVisit in returnVisits)
	{
		MTReturnVisit *mtReturnVisit = [MTReturnVisit insertInManagedObjectContext:self.managedObjectContext];
		mtReturnVisit.date = [returnVisit objectForKey:CallReturnVisitDate];
		if(mtReturnVisit.date == nil)
			mtReturnVisit.date = [NSDate dateWithTimeIntervalSince1970:0];
		mtReturnVisit.call = mtCall;
		NSLog(@"%@", mtReturnVisit.date);
		mtReturnVisit.notes = [returnVisit objectForKey:CallReturnVisitNotes];
		if([returnVisit objectForKey:CallReturnVisitType])
			mtReturnVisit.type = [returnVisit objectForKey:CallReturnVisitType];

		// lets translate the initial visit which is classified as a return visit into an Initial Visit
		if(first)
		{
			first = NO;
			if([mtReturnVisit.type isEqualToString:CallReturnVisitTypeReturnVisit])
			{
				mtReturnVisit.type = CallReturnVisitTypeInitialVisit;
				// go ahead and adjust the Settings too to fix the errors in the Conversion comparison
				[returnVisit setObject:CallReturnVisitTypeInitialVisit forKey:CallReturnVisitType];
			}
		}
		// lets translate the transferred initial visit as well
		if(firstTransfer)
		{
			firstTransfer = NO;
			if([mtReturnVisit.type isEqualToString:CallReturnVisitTypeTransferedReturnVisit])
			{
				mtReturnVisit.type = CallReturnVisitTypeTransferedInitialVisit;
				// go ahead and adjust the Settings too to fix the errors in the Conversion comparison
				[returnVisit setObject:CallReturnVisitTypeTransferedInitialVisit forKey:CallReturnVisitType];
			}
		}
		// PUBLICATIONS
		for(NSDictionary *publication in [returnVisit objectForKey:CallReturnVisitPublications])
		{
			MTPublication *mtPublication = [MTPublication createPublicationForReturnVisit:mtReturnVisit];
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
					MTMultipleChoice *mtMultipleChoice = [MTMultipleChoice createMultipleChoiceForAdditionalInformationType:mtAdditionalInformationType];
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
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:nil error:error];
	}
	
	return mtCall;
}

- (MTTerritory *)createCoreDataTerritoryWithUser:(MTUser *)mtUser territory:(NSDictionary *)territory
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
	return mtTerritory;
}
- (void)convertToCoreDataStoreTask
{
//	double steps = 1;
	[managedObjectContext_ release];
	managedObjectContext_ = nil;
	NSMutableDictionary *settings = [[Settings sharedInstance] settings];
	
	NSManagedObjectContext *moc = self.managedObjectContext;
	[moc processPendingChanges];
	[[moc undoManager] disableUndoRegistration];
	MTSettings *mtSettings = [MTSettings settings];
	
	[[NSUserDefaults standardUserDefaults] setObject:[settings objectForKey:SettingsCurrentButtonBarName] forKey:SettingsCurrentButtonBarName];
	
//	steps = 1 + 9*[[settings objectForKey:SettingsMultipleUsers] count];
		
	// PASSCODE
	mtSettings.passcode = [settings objectForKey:SettingsPasscode];
	
	// BACKUP
	mtSettings.autobackupInterval = [settings objectForKey:SettingsAutoBackupInterval];
	mtSettings.lastBackupDate = [settings objectForKey:SettingsLastBackupDate];
	mtSettings.backupEmail = [settings objectForKey:SettingsBackupEmailAddress];
	mtSettings.backupShouldCompressLinkValue = ![[settings objectForKey:SettingsBackupEmailUncompressedLink] boolValue];
	mtSettings.backupShouldIncludeAttachmentValue = ![[settings objectForKey:SettingsBackupEmailDontIncludeAttachment] boolValue];
	if([[settings objectForKey:SettingsFirstView] isKindOfClass:[NSString class]])
	{
		mtSettings.firstViewTitle = [settings objectForKey:SettingsFirstView];
	}
	if([[settings objectForKey:SettingsSecondView] isKindOfClass:[NSString class]])
	{
		mtSettings.secondViewTitle = [settings objectForKey:SettingsSecondView];
	}
	if([[settings objectForKey:SettingsThirdView] isKindOfClass:[NSString class]])
	{
		mtSettings.thirdViewTitle = [settings objectForKey:SettingsThirdView];
	}
	if([[settings objectForKey:SettingsFourthView] isKindOfClass:[NSString class]])
	{
		mtSettings.fourthViewTitle = [settings objectForKey:SettingsFourthView];
	}
		
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
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:nil error:error];
	}

	double steps = 1.0;
	for(NSDictionary *user in [settings objectForKey:SettingsMultipleUsers])
	{
		steps++; // for metadata;
		steps += [(NSArray *)[user objectForKey:SettingsBulkLiterature] count];
		NSString *callArray[2] = {SettingsCalls, SettingsDeletedCalls};
		for(int i = 0; i < 2; i++)
		{
			steps += [(NSArray *)[user objectForKey:callArray[i]] count];
		}
		steps += [(NSArray *)[user objectForKey:SettingsQuickNotes] count];
		steps += [(NSArray *)[user objectForKey:SettingsNotAtHomeTerritories] count];
		steps += [(NSArray *)[user objectForKey:SettingsTimeEntries] count];
		steps += [(NSArray *)[user objectForKey:SettingsRBCTimeEntries] count];
		steps += [(NSArray *)[user objectForKey:SettingsStatisticsAdjustments] count];
	}

	self.hud.progress = self.hud.progress + 1.0/steps;

	
	for(NSMutableDictionary *user in [settings objectForKey:SettingsMultipleUsers])
	{
		MTUser *mtUser = [MTUser createUserInManagedObjectContext:moc];
		mtUser.name = [user objectForKey:SettingsMultipleUsersName];
	
		
		// FIX METADATA
		{
			[MTAdditionalInformationType initalizeOldStyleStorageDefaultAdditionalInformationTypesForUser:user];
		}		
		
		// DisplayRules
		[MTDisplayRule createDefaultDisplayRulesForUser:mtUser];

		// SECRETARY SETTINGS
		mtUser.secretaryEmailAddress = [settings objectForKey:SettingsSecretaryEmailAddress];
		mtUser.secretaryEmailNotes = [settings objectForKey:SettingsSecretaryEmailNotes];
		
		if([user objectForKey:SettingsPublisherType])
			mtUser.publisherType = [user objectForKey:SettingsPublisherType];
		if([user objectForKey:SettingsMonthDisplayCount])
			mtUser.monthDisplayCount = [user objectForKey:SettingsMonthDisplayCount];
		
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
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:nil error:error];
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
				MTPublication *mtPublication = [MTPublication createPublicationForBulkPlacement:mtBulkPlacement];
				mtPublication.countValue = [[placement objectForKey:BulkLiteratureArrayCount] intValue];
				mtPublication.title = [placement objectForKey:BulkLiteratureArrayTitle];
				mtPublication.type = [placement objectForKey:BulkLiteratureArrayType];
				mtPublication.name = [placement objectForKey:BulkLiteratureArrayName];
				mtPublication.yearValue = [[placement objectForKey:BulkLiteratureArrayYear] intValue];
				mtPublication.monthValue = [[placement objectForKey:BulkLiteratureArrayMonth] intValue];
				mtPublication.dayValue = [[placement objectForKey:BulkLiteratureArrayDay] intValue];
			}
			self.hud.progress = self.hud.progress + 1.0/steps;
		}

		error = nil;
		if (![self.managedObjectContext save:&error]) 
		{
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:nil error:error];
		}
	
		// CALLS
		NSString *callArray[2] = {SettingsCalls, SettingsDeletedCalls};
		for(int i = 0; i < 2; i++)
		{
			int count = 0;
			NSMutableArray *deleteArray = [NSMutableArray array];
			for(NSDictionary *call in [user objectForKey:callArray[i]])
			{
				count++;
				// there was someone who had an error with the webserver and the calls were corrupted, make sure things are correct
				if(![call isKindOfClass:[NSDictionary class]])
				{
					[deleteArray addObject:call];
				}
				else 
				{
					[self createCoreDataCallWithUser:mtUser call:call deleted:i == 1];
				}
				self.hud.progress = self.hud.progress + 1.0/steps;
			}			
			if(deleteArray.count)
			{
				[[user objectForKey:callArray[i]] removeObjectsInArray:deleteArray];
			}
		}

		error = nil;
		if (![self.managedObjectContext save:&error]) 
		{
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:nil error:error];
		}
	
		// QUICK NOTES
		for(NSString *note in [user objectForKey:SettingsQuickNotes])
		{
			MTPresentation *mtPresentation = [MTPresentation createPresentationInManagedObjectContext:self.managedObjectContext];
			mtPresentation.notes = note;
			mtPresentation.user = mtUser;
			mtPresentation.downloadedValue = NO;
			self.hud.progress = self.hud.progress + 1.0/steps;
		}

		error = nil;
		if (![self.managedObjectContext save:&error]) 
		{
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:nil error:error];
		}
	
		// TERRITORY
		for(NSDictionary *territory in [user objectForKey:SettingsNotAtHomeTerritories])
		{
			[self createCoreDataTerritoryWithUser:mtUser territory:territory];

			self.hud.progress = self.hud.progress + 1.0/steps;
		}

		error = nil;
		if (![self.managedObjectContext save:&error]) 
		{
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:nil error:error];
		}
	
		// HOURS
		MTTimeType *hours = [MTTimeType hoursTypeForUser:mtUser];
		hours.startTimerDate = [user objectForKey:SettingsTimeStartDate];
		for(NSDictionary *timeEntry in [user objectForKey:SettingsTimeEntries])
		{
			MTTimeEntry *mtTimeEntry = [MTTimeEntry insertInManagedObjectContext:self.managedObjectContext];
			mtTimeEntry.type = hours;
			mtTimeEntry.date = [timeEntry objectForKey:SettingsTimeEntryDate];
			mtTimeEntry.minutesValue = [[timeEntry objectForKey:SettingsTimeEntryMinutes] intValue];
			self.hud.progress = self.hud.progress + 1.0/steps;
		}
		
		error = nil;
		if (![self.managedObjectContext save:&error]) 
		{
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:nil error:error];
		}

		// RBC HOURS
		MTTimeType *rbc = [MTTimeType rbcTypeForUser:mtUser];
		rbc.startTimerDate = [user objectForKey:SettingsRBCTimeStartDate];
		for(NSDictionary *timeEntry in [user objectForKey:SettingsRBCTimeEntries])
		{
			MTTimeEntry *mtTimeEntry = [MTTimeEntry insertInManagedObjectContext:self.managedObjectContext];
			mtTimeEntry.date = [timeEntry objectForKey:SettingsTimeEntryDate];
			mtTimeEntry.minutesValue = [[timeEntry objectForKey:SettingsTimeEntryMinutes] intValue];
			mtTimeEntry.type = rbc;
			self.hud.progress = self.hud.progress + 1.0/steps;
		}
		
		error = nil;
		if (![self.managedObjectContext save:&error]) 
		{
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:nil error:error];
		}

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
			self.hud.progress = self.hud.progress + 1.0/steps;
		}
		
		error = nil;
		if (![self.managedObjectContext save:&error]) 
		{
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:nil error:error];
		}
	}

	mtSettings.currentUser = [MTUser userWithName:[settings objectForKey:SettingsMultipleUsersCurrentUser] inManagedObjectContext:[self managedObjectContext]];
	
	// make sure the current user is initalized
	[MTUser currentUser];
	
	
	[[self managedObjectContext] processPendingChanges];
	[[[self managedObjectContext] undoManager] enableUndoRegistration];

	BOOL worked = [self verifyCoreDataConversion];
	self.hud.progress = 1.0;
	
	
//	[managedObjectContext_ release];
//	managedObjectContext_ = nil;

	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:[Settings outOfWayFilename] error:nil];
	if(![fileManager moveItemAtPath:[Settings filename] toPath:[Settings outOfWayFilename] error:nil])
	{
//		[fileManager removeItemAtPath:[Settings filename] error:nil];
		NSLog(@"did not write file");
	}
	
	if(worked)
	{
		[self performSelector:@selector(initializeMyTimeViews) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
		[self.hud performSelector:@selector(done) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
	}
	else
	{
		[self performSelector:@selector(showErrorConvertingData) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
	}
}

- (void)showErrorConvertingData
{
	// display 
	_actionSheetType = CONVERT_DATAFILE_FAILURE;
	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"You have encountered a serious error when converting your old data file to the new format. The developer of MyTime can help you, press on the \"HELP!\" button below and email your datafile, he should be able to get back with you with a fixed data file.", @"This is the message you see when MyTime converts your data from the old format to the new one and has detected a failure") 
															  delegate:self 
													 cancelButtonTitle:NSLocalizedString(@"Ignore Fatal Error", @"button title the user sees when they have an error converting data") 
												destructiveButtonTitle:NSLocalizedString(@"HELP! Fix My Data!", @"button title the user sees when they have an error converting data")
													 otherButtonTitles:nil] autorelease];
	[actionSheet showInView:hud];
}

- (BOOL)convertToCoreDataStore
{
	if(![[NSFileManager defaultManager] fileExistsAtPath:[Settings filename]])
	{
		return NO;
	}

	// The hud will disable all input on the view (use the higest view possible in the view hierarchy)
    self.hud = [[MBProgressHUD alloc] initWithView:window];
	
    // Set determinate mode
    hud.mode = MBProgressHUDModeDeterminate;
    hud.delegate = self;
    hud.labelText = NSLocalizedString(@"Converting Data File", @"this message is presented to the user when they are upgrading their MyTime and MyTime is converting their old database file to a new one");
	hud.detailsLabelText = NSLocalizedString(@"Please wait. This might take a minute or two.", @"this message is presented to the user when they are upgrading their MyTime and MyTime is converting their old database file to a new one");
    [self.window addSubview:hud];

	// make sure that the data that is there is gone
	NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
	BOOL exists = [fileManager fileExistsAtPath:[[self class] storeFileAndPath]];
	if(exists && ![fileManager removeItemAtPath:[[self class] storeFileAndPath] error:nil])
	{
		NSLog(@"deleted file");
	}
	
    // Show the HUD while the provided method executes in a new thread
    [hud showWhileExecuting:@selector(convertToCoreDataStoreTask) onTarget:self withObject:nil animated:YES];
	
	return YES;
}




- (void)checkAutoBackup
{
	MTSettings *settings = [MTSettings settings];
	int autobackupInterval = settings.autobackupIntervalValue;
	if(autobackupInterval)
	{
		NSDate *lastBackupDate = settings.lastBackupDate;
		NSDate *dateLimit = [NSDate dateWithTimeIntervalSinceNow:-(autobackupInterval * 60 * 60 * 24)];
		// subtract the number of days from now
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	if(_actionSheetType != AUTO_BACKUP && !displayingSecurityViewController)
	{
		[self checkAutoBackup];
	}
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// always save data before quitting
    NSError *error = nil;
    if (managedObjectContext_ != nil) 
	{
        if ([managedObjectContext_ hasChanges] && ![managedObjectContext_ save:&error]) 
		{
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:nil error:error];
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
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:nil error:error];
        } 
    }
}

- (void)commonApplicationInitialization
{
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
		else if([extension isEqualToString:@"mytimedb"])
		{
			self.fileToRestore = path;
			handled = YES;
			_actionSheetType = RESTORE_CORE_DATA_BACKUP;
			UIActionSheet *alertSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"You are trying to restore all MyTime data from a backup, are you sure you want to do this?  THIS WILL DELETE ALL OF YOUR CURRENT DATA", @"This message gets displayed when the user is trying to restore from a backup from the email program")
																	 delegate:self
															cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
													   destructiveButtonTitle:NSLocalizedString(@"Restore from Backup", @"Yes restore from the backup please")
															otherButtonTitles:nil] autorelease];
			
			alertSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
			[alertSheet showInView:window];
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
			if([@"/addCoreDataCall" isEqualToString:path])
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
					_actionSheetType = ADD_CORE_DATA_CALL;
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
			if([@"/addCoreDataNotAtHomeTerritory" isEqualToString:path])
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
					_actionSheetType = ADD_CORE_DATA_NOT_AT_HOME_TERRITORY;
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
					{
						NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
						NSData *dataStore = allocNSDataFromNSStringByteString(data);
						[dataStore autorelease];
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
						DEBUG(NSLog(@"%@", self.settingsToRestore);)
						[pool drain];
					}					
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
			if((compressed = [@"/restoreCompressedCoreDataBackup" isEqualToString:path]) ||
			   [@"/restoreCoreDataBackup" isEqualToString:path])
			{
				do 
				{
					{
						NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
						NSData *dataStore = allocNSDataFromNSStringByteString(data);
						[dataStore autorelease];
						
						if(dataStore == nil)
							break;
						
						@try
						{
							NSData *theData = compressed ? [dataStore decompress] : dataStore;
							dataStore = theData;
						}
						@catch (NSException *e) 
						{
							UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
							alertSheet.title = [NSString stringWithFormat:@"%@", e];
							[alertSheet show];
							
						}
						self.fileToRestore = [NSTemporaryDirectory() stringByAppendingPathComponent:@"MyTime.sqlite"];
						[dataStore writeToFile:self.fileToRestore atomically:NO];
						
						[pool drain];
					}
					handled = YES;
					_actionSheetType = RESTORE_CORE_DATA_BACKUP;
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
		if([MFMailComposeViewController canSendMail] == NO)
		{
			UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
			alertSheet.title = NSLocalizedString(@"You must setup email on this device to be able to send an email.  Open the Mail application and setup your email account", @"This is a message displayed when the user does not have email setup on their iDevice");
			[alertSheet show];
			// make the window visible
			[window makeKeyAndVisible];
			return;
		}
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
	if(passcode.length && !displayingSecurityViewController && ![[NSUserDefaults standardUserDefaults] boolForKey:@"PSBypassPasscode"])
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

#define CURRENT_FIX_NUMBER 6
- (void)initializeMyTimeViews
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSPersistentStore *ps = [self.persistentStoreCoordinator.persistentStores objectAtIndex:0];
	NSDictionary *metadata = [self.persistentStoreCoordinator metadataForPersistentStore:ps];
	if([[metadata valueForKey:@"PSDisplayRuleFix"] intValue] != CURRENT_FIX_NUMBER)
	{
		NSMutableDictionary *newMetadata = [[metadata mutableCopy] autorelease];
		[MTDisplayRule fixDisplayRules:self.managedObjectContext];

		[MTCall fixCalls:self.managedObjectContext];

		NSError *error;
		if (![self.managedObjectContext save:&error]) 
		{
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:nil error:error];
		}
		else
		{
			[newMetadata setValue:[NSNumber numberWithInt:CURRENT_FIX_NUMBER] forKey:@"PSDisplayRuleFix"];
			[self.persistentStoreCoordinator setMetadata:newMetadata forPersistentStore:ps];
		}
	}
	[MTAdditionalInformationType fixAdditionalInformationTypes:self.managedObjectContext];

	
	// Create a tabbar controller and an array to contain the view controllers
	self.tabBarController = [[[UITabBarController alloc] init] autorelease];
	NSMutableArray *localViewControllersArray = [[[NSMutableArray alloc] initWithCapacity:4] autorelease];
	
	// CALLS SORTED BY METADATA
	CallsSortedByFilterDataSource *filterSortedDataSource = [[[CallsSortedByFilterDataSource alloc] init] autorelease];
	MetadataSortedCallsViewController *filterViewController = [[[MetadataSortedCallsViewController alloc] initWithDataSource:filterSortedDataSource] autorelease];
	filterViewController.managedObjectContext = self.managedObjectContext;
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:filterViewController] autorelease]];
	
	// MAPPED CALLS
	MapViewController *mapViewController = [[[MapViewController alloc] initWithTitle:NSLocalizedString(@"Mapped Calls", @"Mapped calls view title")] autorelease];
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:mapViewController] autorelease]];
	
	// HOURS
	HourViewController *hourViewController = [[[HourViewController alloc] initWithTimeTypeName:[[MTTimeType hoursType] name]] autorelease];
	hourViewController.managedObjectContext = self.managedObjectContext;
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:hourViewController] autorelease]];

	// STATISTICS
	StatisticsTableViewController *statisticsViewController = [[[StatisticsTableViewController alloc] init] autorelease];
//	StatisticsViewController *statisticsViewController = [[[StatisticsViewController alloc] init] autorelease];
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:statisticsViewController] autorelease]];

	// CALLS SORTED BY STREET
	CallsSortedByStreetViewDataSource *streetSortedDataSource = [[[CallsSortedByStreetViewDataSource alloc] init] autorelease];
	SortedCallsViewController *streetViewController = [[[SortedCallsViewController alloc] initWithDataSource:streetSortedDataSource] autorelease];
	streetViewController.managedObjectContext = self.managedObjectContext;
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:streetViewController] autorelease]];
	
	// CALLS SORTED BY CITY
	CallsSortedByCityViewDataSource *citySortedDataSource = [[[CallsSortedByCityViewDataSource alloc] init] autorelease];
	SortedCallsViewController *cityViewController = [[[SortedCallsViewController alloc] initWithDataSource:citySortedDataSource] autorelease];
	cityViewController.managedObjectContext = self.managedObjectContext;
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:cityViewController] autorelease]];

	// CALLS SORTED BY DATE
	CallsSortedByDateViewDataSource *dateSortedDataSource = [[[CallsSortedByDateViewDataSource alloc] init] autorelease];
	SortedCallsViewController *dateViewController = [[[SortedCallsViewController alloc] initWithDataSource:dateSortedDataSource] autorelease];
	dateViewController.managedObjectContext = self.managedObjectContext;
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:dateViewController] autorelease]];
	
	// CALLS SORTED BY NAME
	CallsSortedByNameViewDataSource *nameSortedDataSource = [[[CallsSortedByNameViewDataSource alloc] init] autorelease];
	SortedCallsViewController *nameViewController = [[[SortedCallsViewController alloc] initWithDataSource:nameSortedDataSource] autorelease];
	nameViewController.managedObjectContext = self.managedObjectContext;
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:nameViewController] autorelease]];
	
	// CALLS SORTED BY STUDY
	CallsSortedByStudyViewDataSource *studySortedDataSource = [[[CallsSortedByStudyViewDataSource alloc] init] autorelease];
	SortedCallsViewController *studyViewController = [[[SortedCallsViewController alloc] initWithDataSource:studySortedDataSource] autorelease];
	studyViewController.managedObjectContext = self.managedObjectContext;
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:studyViewController] autorelease]];

	// Deleted Calls
	DeletedCallsSortedByStreetViewDataSource *deletedCallsStreetSortedDataSource = [[[DeletedCallsSortedByStreetViewDataSource alloc] init] autorelease];
	SortedCallsViewController *deletedCallsStreetViewController = [[[SortedCallsViewController alloc] initWithDataSource:deletedCallsStreetSortedDataSource] autorelease];
	deletedCallsStreetViewController.managedObjectContext = self.managedObjectContext;
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:deletedCallsStreetViewController] autorelease]];

	// NOT AT HOMES
	NotAtHomeViewController *notAtHomeViewController = [[[NotAtHomeViewController alloc] init] autorelease];
	notAtHomeViewController.managedObjectContext = self.managedObjectContext;
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:notAtHomeViewController] autorelease]];
	
	// BULK LITERATURE
	BulkLiteraturePlacementViewContoller *bulkLiteraturePlacementViewContoller = [[[BulkLiteraturePlacementViewContoller alloc] init] autorelease];
	bulkLiteraturePlacementViewContoller.managedObjectContext = self.managedObjectContext;
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
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:nil error:error];
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
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:nil error:error];
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
				NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:nil error:error];
			}
			
			UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
			alertSheet.delegate = self;
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
		[theTabBarController.moreNavigationController popToRootViewControllerAnimated:NO];
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
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:nil error:error];
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
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:nil error:error];
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
