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
#import "SortedCallsViewController.h"
#import "MetadataSortedCallsViewController.h"
#import "StatisticsViewController.h"
#import "NotAtHomeViewController.h"
#import "HourViewController.h"
#import "SettingsTableViewController.h"
#import "BulkLiteraturePlacementViewContoller.h"
#import "MapViewController.h"
#import "Settings.h"
#import "Geocache.h"
#import <objc/runtime.h>
#import "PSLocalization.h"
#import "SecurityViewController.h"

@implementation MyTimeAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize callToImport;
@synthesize settingsToRestore;
@synthesize securityNavigationController;

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
	self.callToImport = nil;
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

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if (!url) 
	{  
		return NO; 
	}
//	sleep(20); 
//#warning this should not be released!!!

    NSString *URLString = [url absoluteString];
	NSLog(@"%@", URLString);

	NSString *path = [url path];
	NSString *data = [url query];
	BOOL handled = NO;
	if(path && data)
	{
		if([@"/addCall" isEqualToString:[url path]])
		{
			do 
			{
				NSData *dataStore = allocNSDataFromNSStringByteString(data);
				if(dataStore == nil)
					break;
				@try
				{
					self.callToImport = [NSKeyedUnarchiver unarchiveObjectWithData:dataStore];
				}
				@catch (NSException *e) 
				{
					NSLog(@"%@", e);
				}
				[dataStore release];
				DEBUG(NSLog(@"%@", callToImport);)

				if(self.callToImport == nil)
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
		if([@"/restoreBackup" isEqualToString:[url path]])
		{
			do 
			{
				NSData *dataStore = allocNSDataFromNSStringByteString(data);
				if(dataStore == nil)
					break;

				@try
				{
					self.settingsToRestore = [NSKeyedUnarchiver unarchiveObjectWithData:dataStore];
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
		alertSheet.title = [NSString stringWithFormat:NSLocalizedString(@"MyTime opened with invalid URL", @"This message is displayed when someone clicks on a link in an email or a webpage which will open up mytime to either add a transfered call or restore from a backup")];
		[alertSheet show];
	}
    return YES;
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
					NSMutableDictionary *newCall = [NSMutableDictionary dictionaryWithDictionary:callToImport];
					
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
					[calls addObject:newCall];
					[[Settings sharedInstance] saveData];
					self.callToImport = nil;

					UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
					[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
					alertSheet.title = [NSString stringWithFormat:NSLocalizedString(@"Please quit mytime to complete the import/restore.", @"This message is displayed after a successful import of a call or a restore of a backup")];
					[alertSheet show];
					break;
				}
				// cancel
				case 1:
				{
					self.callToImport = nil;
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
					NSMutableDictionary *settings = [[Settings sharedInstance] settings];
					[settings removeAllObjects];
					[settings addEntriesFromDictionary:self.settingsToRestore];
					[[Settings sharedInstance] saveData];
					self.settingsToRestore = nil;

					UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
					[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
					alertSheet.title = [NSString stringWithFormat:NSLocalizedString(@"Please quit mytime to complete the import/restore.", @"This message is displayed after a successful import of a call or a restore of a backup")];
					[alertSheet show];
					break;
				}
				// cancel
				case 1:
				{
					self.callToImport = nil;
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
	[self.securityNavigationController dismissModalViewControllerAnimated:YES];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// always save data before quitting
	[[Settings sharedInstance] saveData];
}


- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
#if 0	
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
#endif
//	application.networkActivityIndicatorVisible = NO;

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
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
		
    // Set up the portraitWindow and content view
	self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

	if([defaults boolForKey:UserDefaultsEmailBackupInstantly])
	{
		[defaults setBool:NO forKey:UserDefaultsEmailBackupInstantly];
		MFMailComposeViewController *mailView = [Settings sendEmailBackup];
		mailView.mailComposeDelegate = self;
		self.securityNavigationController = [[[UINavigationController alloc] init] autorelease];
		[self.window addSubview:self.securityNavigationController.view];
		// make the window visible
		[window makeKeyAndVisible];

		[self.securityNavigationController presentModalViewController:mailView animated:YES];
		return;
	}
	
	// Create a tabbar controller and an array to contain the view controllers
	self.tabBarController = [[[UITabBarController alloc] init] autorelease];
	NSMutableArray *localViewControllersArray = [[[NSMutableArray alloc] initWithCapacity:4] autorelease];
	
	// setup the 4 view controllers for the different data representations
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
	StatisticsViewController *statisticsViewController = [[[StatisticsViewController alloc] init] autorelease];
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
#if 0
	// NOT AT HOMES
	NotAtHomeViewController *notAtHomeViewController = [[[NotAtHomeViewController alloc] init] autorelease];
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:notAtHomeViewController] autorelease]];
#endif	
	// BULK LITERATURE
	BulkLiteraturePlacementViewContoller *bulkLiteraturePlacementViewContoller = [[[BulkLiteraturePlacementViewContoller alloc] init] autorelease];
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:bulkLiteraturePlacementViewContoller] autorelease]];
	
	// ALL CALLS WEB VIEW
	MapViewController *mapViewController = [[[MapViewController alloc] initWithTitle:NSLocalizedString(@"Mapped Calls", @"Mapped calls view title")] autorelease];
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:mapViewController] autorelease]];

	// QUICK BUILD HOURS
	HourViewController *quickBuildHourViewController = [[[HourViewController alloc] initForQuickBuild:YES] autorelease];
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:quickBuildHourViewController] autorelease]];

	// SETTINGS
	SettingsTableViewController *settingsViewController = [[[SettingsTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:settingsViewController] autorelease]];

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
	if([settings objectForKey:SettingsCurrentButtonBarIndex])
	{
		int index = [[settings objectForKey:SettingsCurrentButtonBarIndex] intValue];
		if(index < array.count)
		{
			tabBarController.selectedViewController = [array objectAtIndex:index];
		}
	}
	self.securityNavigationController = [[[UINavigationController alloc] initWithRootViewController:tabBarController] autorelease];
	self.securityNavigationController.navigationBarHidden = YES;

	// set the window subview as the tab bar controller
	[window addSubview:self.securityNavigationController.view];
	
	// make the window visible
	[window makeKeyAndVisible];
	
	if([settings objectForKey:SettingsMainAlertSheetShown] == nil)
	{
		[settings setObject:@"" forKey:SettingsMainAlertSheetShown];
		[[Settings sharedInstance] saveData];

		UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
		[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
		alertSheet.title = NSLocalizedString(@"Please visit mytime.googlecode.com to see the FAQ and feature requests.\nA lot of work has been put into MyTime, if you find this application useful then you are welcome to donate.  Is English not your native language and you want to help to translate? Email me (look in the More view and Settings)", @"Information for the user to know what is going on with this and new releases");
		[alertSheet show];
	}

	// kick off the Geocache lookup
	[[Geocache sharedInstance] setWindow:window];

	if([defaults boolForKey:UserDefaultsRemovePasscode])
	{
		[defaults setBool:NO forKey:UserDefaultsRemovePasscode];
		[settings removeObjectForKey:SettingsPasscode];
		[[Settings sharedInstance] saveData];
	}
		
	NSString *passcode = [settings objectForKey:SettingsPasscode];
		
		
	if(passcode.length)
	{
		SecurityViewController *securityView = [[[SecurityViewController alloc] initWithNibName:@"SecurityView" bundle:[NSBundle mainBundle]] autorelease];
		securityView.promptText = NSLocalizedString(@"Enter Passcode", @"Prompt to enter a passcode to gain access to MyTime");
		securityView.shouldConfirm = NO;
		securityView.passcode = passcode;
		securityView.delegate = self;
		[self.securityNavigationController presentModalViewController:securityView animated:NO];
	}
}

- (void)securityViewControllerDone:(SecurityViewController *)viewController authenticated:(BOOL)authenticated
{
	if(authenticated)
	{
		[self.securityNavigationController dismissModalViewControllerAnimated:YES];
	}
	else
	{
		exit(0);
	}
}

- (void)tabBarController:(UITabBarController *)theTabBarController didSelectViewController:(UIViewController *)viewController
{
	NSMutableDictionary *settings = [[Settings sharedInstance] settings];
	[settings setObject:[NSNumber numberWithInt:[theTabBarController.viewControllers indexOfObject:viewController]] forKey:SettingsCurrentButtonBarIndex];
	// this is slowing things down so I am removing it
	//	[[Settings sharedInstance] saveData];
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

#if 0
#pragma mark UITableViewIndex Added Methods
 
static BOOL tableViewIndexMoveIn(id self, SEL _cmd) 
{
	UIView *index = (UIView *)self;
	
	[UIView beginAnimations:nil context:nil];
	index.center = CGPointMake(index.center.x - 30, index.center.y);
	[UIView commitAnimations];
	
    return YES;
}
 
static BOOL tableViewIndexMoveOut(id self, SEL _cmd) 
{
	UIView *index = (UIView *)self;
	
	[UIView beginAnimations:nil context:nil];
	index.center = CGPointMake(index.center.x + 30, index.center.y);
	[UIView commitAnimations];
	
    return YES;
}
#endif
- (BOOL)respondsToSelector:(SEL)selector
{
	BOOL ret = [super respondsToSelector:selector];
    VERY_VERBOSE(NSLog(@"%s respondsToSelector: %s ? %s", __FILE__, selector, ret ? "YES" : "NO");)
    return ret;
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
