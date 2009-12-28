//
//  NotAtHomeViewController.m
//  MyTime
//
//  Created by Brent Priddy on 10/14/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//
#import "NotAtHomeViewController.h"
#import "NotAtHomeTerritoryDetailViewController.h"
#import "Settings.h"
#import "PSLocalization.h"
@implementation NotAtHomeViewController

- (NSMutableArray *)entries
{
	if(entries == nil)
	{
		NSMutableDictionary *userSettings = [[Settings sharedInstance] userSettings];
		entries = [[userSettings objectForKey:SettingsNotAtHomeTerritories] retain];
		if(entries == nil)
		{
			entries = [[NSMutableArray alloc] init];
			[userSettings setObject:entries forKey:SettingsNotAtHomeTerritories];
		}
	}
	
	return entries;
}

- (void)navigationControlAdd:(id)sender
{
	NotAtHomeTerritoryDetailViewController *controller = [[[NotAtHomeTerritoryDetailViewController alloc] init] autorelease];

	// create a custom navigation bar button and set it to always say "back"
	UIBarButtonItem *temporaryBarButtonItem = [[[UIBarButtonItem alloc] init] autorelease];
	temporaryBarButtonItem.title = NSLocalizedString(@"Cancel", @"Cancel button");
	self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
	controller.delegate = self;
	
	// push the element view controller onto the navigation stack to display it
	[[self navigationController] pushViewController:controller animated:YES];
	//	[self presentModalViewController:<#(UIViewController *)modalViewController#> animated:<#(BOOL)animated#>
} 

- (void)notAtHomeTerritoryDetailViewControllerDone:(NotAtHomeTerritoryDetailViewController *)notAtHomeTerritoryDetailViewController
{
}

- (id)init
{
	if ([super init]) 
	{
		// set the title, and tab bar images from the dataSource
		// object. 
		self.title = NSLocalizedString(@"Not At Home", @"Title for Not At Homes view");
//		self.tabBarItem.image = [UIImage imageNamed:@"notAtHomes.png"];
		UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																				 target:self
																				 action:@selector(navigationControlAdd:)] autorelease];
		[self.navigationItem setRightBarButtonItem:button animated:NO];
	}
	return self;
}

- (void)dealloc
{
	[entries release];
	entries = nil;
	
	[super dealloc];
}

/******************************************************************
 *
 *   TABLE DELEGATE FUNCTIONS
 *
 ******************************************************************/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DEBUG(NSLog(@"numberOfRowsInTable:");)
	int count = self.entries.count;
    DEBUG(NSLog(@"numberOfRowsInTable: %d", count);)
	return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int row = [indexPath row];
    VERBOSE(NSLog(@"tableView: cellForRow:%d ", row);)
	NSString *identifier = @"NotAtHomeTerritoryCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
	}
	NSMutableArray *theEntries = self.entries;

	if(row >= theEntries.count)
		return nil;
	NSMutableDictionary *entry = [theEntries objectAtIndex:row];
	
	cell.textLabel.text = [entry objectForKey:NotAtHomeTerritoryName];

	return cell;
}

#if 0
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    DEBUG(NSLog(@"tableRowSelected: didSelectRowAtIndexPath row%d", row);)
	self.selectedIndexPath = indexPath;
	NSString *timeEntriesName = _quickBuild ? SettingsRBCTimeEntries : SettingsTimeEntries;
	NSMutableArray *timeEntries = [[[Settings sharedInstance] userSettings] objectForKey:timeEntriesName];
	NSMutableDictionary *entry = [timeEntries objectAtIndex:row];
	
	NSNumber *minutes = [entry objectForKey:SettingsTimeEntryMinutes];
	NSDate *date = [entry objectForKey:SettingsTimeEntryDate];
	
	[self retain];
	TimePickerViewController *viewController = [[[TimePickerViewController alloc] initWithDate:date minutes:[minutes intValue]] autorelease];
	
	viewController.delegate = self;
	[[self navigationController] pushViewController:viewController animated:YES];
}

- (void)tableView:(UITableView *)theTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    DEBUG(NSLog(@"table: deleteRow: %d", [indexPath row]);)
	NSString *timeEntriesName = _quickBuild ? SettingsRBCTimeEntries : SettingsTimeEntries;
	NSMutableArray *timeEntries = [[[Settings sharedInstance] userSettings] objectForKey:timeEntriesName];
	[timeEntries removeObjectAtIndex:[indexPath row]];
	[[Settings sharedInstance] saveData];
	[theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}
#endif

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
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
