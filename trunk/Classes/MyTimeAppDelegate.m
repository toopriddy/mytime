//
//  MyTimeAppDelegate.m
//  MyTime
//
//  Created by Brent Priddy on 7/22/08.
//  Copyright PG Software 2008. All rights reserved.
//

#import "MyTimeAppDelegate.h"
#import "SortedCallsViewDataSourceProtocol.h"
#import "CallsSortedByStreetViewDataSource.h"
#import "CallsSortedByCityViewDataSource.h"
#import "CallsSortedByDateViewDataSource.h"
#import "CallsSortedByNameViewDataSource.h"
#import "CallsSortedByStudyViewDataSource.h"
#import "SortedCallsViewController.h"
#import "StatisticsViewController.h"
#import "HourViewController.h"
#import "SettingsViewController.h"
#import "BulkLiteraturePlacementViewContoller.h"
#import "MapViewController.h"
#import "Settings.h"

@implementation MyTimeAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize callToImport;
@synthesize settingsToRestore;

- init 
{
	if(self = [super init]) 
	{
		// initialize  to nil
		window = nil;
		tabBarController = nil;
	}
	return self;
}

- (void)dealloc {
	[window release];
	[tabBarController release];
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

				self.callToImport = [NSKeyedUnarchiver unarchiveObjectWithData:dataStore];
				[dataStore release];
				DEBUG(NSLog(@"%@", callToImport);)

				if(self.callToImport == nil)
					break;

				handled = YES;
				_actionSheetType = ADD_CALL;
				UIActionSheet *alertSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"You are trying to import a call into MyTime, are you sure you want to do this?", @"")
																		 delegate:self
																cancelButtonTitle:NSLocalizedString(@"Cancel", @"cancel")
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

				self.settingsToRestore = [NSKeyedUnarchiver unarchiveObjectWithData:dataStore];
				[dataStore release];
				DEBUG(NSLog(@"%@", self.settingsToRestore);)

				if(self.settingsToRestore == nil)
					break;

				handled = YES;
				_actionSheetType = RESTORE_BACKUP;
				UIActionSheet *alertSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"You are trying to restore all MyTime data from a backup, are you sure you want to do this?  THIS WILL DELETE ALL OF YOUR CURRENT DATA", @"")
																		 delegate:self
																cancelButtonTitle:NSLocalizedString(@"Cancel", @"cancel")
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
		alertSheet.title = [NSString stringWithFormat:NSLocalizedString(@"MyTime opened with invalid URL", @"")];
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
					NSMutableArray *calls = [[[Settings sharedInstance] settings] objectForKey:SettingsCalls];
					[calls addObject:[NSMutableDictionary dictionaryWithDictionary:callToImport]];
					[[Settings sharedInstance] saveData];
					self.callToImport = nil;
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


- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
	[[Settings sharedInstance] readData];
	[[Settings sharedInstance] saveData];

    // Set up the portraitWindow and content view
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	// Create a tabbar controller and an array to contain the view controllers
	tabBarController = [[UITabBarController alloc] init];
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

	// CALLS SORTED BY NAME
	CallsSortedByNameViewDataSource *nameSortedDataSource = [[[CallsSortedByNameViewDataSource alloc] init] autorelease];
	SortedCallsViewController *nameViewController = [[[SortedCallsViewController alloc] initWithDataSource:nameSortedDataSource] autorelease];
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:nameViewController] autorelease]];

	// CALLS SORTED BY NAME
	CallsSortedByStudyViewDataSource *studySortedDataSource = [[[CallsSortedByStudyViewDataSource alloc] init] autorelease];
	SortedCallsViewController *studyViewController = [[[SortedCallsViewController alloc] initWithDataSource:studySortedDataSource] autorelease];
	[localViewControllersArray addObject:[[[UINavigationController alloc] initWithRootViewController:studyViewController] autorelease]];

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
	SettingsViewController *settingsViewController = [[[SettingsViewController alloc] init] autorelease];
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
	[[Settings sharedInstance] saveData];


	// set the tab bar controller view controller array to the localViewControllersArray
	tabBarController.viewControllers = array;
	tabBarController.delegate = self;
	if([settings objectForKey:SettingsCurrentButtonBarIndex])
	{
		tabBarController.selectedIndex = [[settings objectForKey:SettingsCurrentButtonBarIndex] intValue];
	}
	
	// set the window subview as the tab bar controller
	[window addSubview:tabBarController.view];
	
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
}

- (void)tabBarController:(UITabBarController *)theTabBarController didSelectViewController:(UIViewController *)viewController
{
	NSMutableDictionary *settings = [[Settings sharedInstance] settings];
	[settings setObject:[NSNumber numberWithInt:theTabBarController.selectedIndex] forKey:SettingsCurrentButtonBarIndex];
	[[Settings sharedInstance] saveData];
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
