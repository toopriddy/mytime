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

@interface MyTimeAppDelegate ()
- (void)displaySecurityViewController;
@end

@implementation MyTimeAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize dataToImport;
@synthesize settingsToRestore;
@synthesize modalNavigationController;

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
		[[[Settings sharedInstance] settings] setObject:[NSDate date] forKey:SettingsLastBackupDate];
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

- (void)checkAutoBackup
{
	NSMutableDictionary *settings = [[Settings sharedInstance] settings];
	NSDate *lastBackupDate = [settings objectForKey:SettingsLastBackupDate];
	NSDate *dateLimit = nil;
	NSNumber *backupInterval = [settings objectForKey:SettingsAutoBackupInterval];
	if(backupInterval && [backupInterval floatValue] > 0)
	{
		// subtract the number of days from now
		dateLimit = [NSDate dateWithTimeIntervalSinceNow:-([backupInterval floatValue] * 60 * 60 * 24)];
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
	[[Settings sharedInstance] saveData];

	// since we are going into the background, show the security view (that way when going into the background
	// the OS will screenshot the security view when restoring... this will hide sensitive info)
	[self displaySecurityViewController];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// always save data before quitting
	[[Settings sharedInstance] saveData];
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
		MFMailComposeViewController *mailView = [Settings sendEmailBackup];
		mailView.mailComposeDelegate = self;
		self.modalNavigationController = [[[UINavigationController alloc] init] autorelease];

		[self.window addSubview:self.modalNavigationController.view];
		// make the window visiblebel
		[window makeKeyAndVisible];

		[self.modalNavigationController presentModalViewController:mailView animated:YES];
		forceEmail = YES;
		return;
	}

	[self initializeMyTimeViews];
}

- (void)displaySecurityViewController
{
	NSString *passcode = [[[Settings sharedInstance] settings] objectForKey:SettingsPasscode];
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
	HourViewController *hourViewController = [[[HourViewController alloc] initForQuickBuild:NO] autorelease];
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
	HourViewController *quickBuildHourViewController = [[[HourViewController alloc] initForQuickBuild:YES] autorelease];
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
	NSMutableDictionary *settings = [[Settings sharedInstance] settings];
	UIViewController *controller;
	controller = [self removeControllerFromArray:localViewControllersArray withName:[settings objectForKey:SettingsFirstView]];
	if(controller)
		[array addObject:controller];
	controller = [self removeControllerFromArray:localViewControllersArray withName:[settings objectForKey:SettingsSecondView]];
	if(controller)
		[array addObject:controller];
	controller = [self removeControllerFromArray:localViewControllersArray withName:[settings objectForKey:SettingsThirdView]];
	if(controller)
		[array addObject:controller];
	controller = [self removeControllerFromArray:localViewControllersArray withName:[settings objectForKey:SettingsFourthView]];
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
	[settings setObject:controller.title forKey:SettingsFirstView];
	controller = [array objectAtIndex:1];
	[settings setObject:controller.title forKey:SettingsSecondView];
	controller = [array objectAtIndex:2];
	[settings setObject:controller.title forKey:SettingsThirdView];
	controller = [array objectAtIndex:3];
	[settings setObject:controller.title forKey:SettingsFourthView];

	// set the tab bar controller view controller array to the localViewControllersArray
	tabBarController.viewControllers = array;
	tabBarController.delegate = self;
	tabBarController.moreNavigationController.delegate = self;
	if([settings objectForKey:SettingsCurrentButtonBarName])
	{
		NSArray *nameArray = [array valueForKeyPath:@"topViewController.title"];
		NSUInteger index = [nameArray indexOfObject:[settings objectForKey:SettingsCurrentButtonBarName]];
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
		[settings removeObjectForKey:SettingsPasscode];
		[[Settings sharedInstance] saveData];
	}
	
	NSString *passcode = [settings objectForKey:SettingsPasscode];
	
	if(_actionSheetType == NORMAL_STARTUP)
	{
		if([settings objectForKey:SettingsMainAlertSheetShown] == nil)
		{
			[settings setObject:@"" forKey:SettingsMainAlertSheetShown];
			[[Settings sharedInstance] saveData];

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
	NSMutableDictionary *settings = [[Settings sharedInstance] settings];
	if(viewController != self.tabBarController.moreNavigationController)
	{
		[settings setObject:viewController.title forKey:SettingsCurrentButtonBarName];
	}
	else
	{
		[settings setObject:@"MoreViewController" forKey:SettingsCurrentButtonBarName];
	}
}

- (void)tabBarController:(UITabBarController *)theTabBarController didSelectViewController:(UIViewController *)viewController
{
	NSMutableDictionary *settings = [[Settings sharedInstance] settings];
	if(viewController != self.tabBarController.moreNavigationController)
	{
		[settings setObject:viewController.title forKey:SettingsCurrentButtonBarName];
	}
	else
	{
		[settings setObject:@"MoreViewController" forKey:SettingsCurrentButtonBarName];
	}
}

- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
	if(changed)
	{
		NSMutableDictionary *settings = [[Settings sharedInstance] settings];
		UIViewController *controller;
		
		controller = [viewControllers objectAtIndex:0];
		[settings setObject:controller.title forKey:SettingsFirstView];
		controller = [viewControllers objectAtIndex:1];
		[settings setObject:controller.title forKey:SettingsSecondView];
		controller = [viewControllers objectAtIndex:2];
		[settings setObject:controller.title forKey:SettingsThirdView];
		controller = [viewControllers objectAtIndex:3];
		[settings setObject:controller.title forKey:SettingsFourthView];
		
		[[Settings sharedInstance] saveData];
	}
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