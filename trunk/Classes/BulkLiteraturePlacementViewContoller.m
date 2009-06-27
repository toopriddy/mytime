//
//  BulkLiteraturePlacementViewContoller.m
//  MyTime
//
//  Created by Brent Priddy on 8/15/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "BulkLiteraturePlacementViewContoller.h"
#import "UITableViewTitleAndValueCell.h"
#import "LiteraturePlacementViewController.h"
#import "Settings.h"
#import "PSLocalization.h"

/* NSMutableArray bulkLiterature
 *     NSMutableDictionary
 *            NSCalendarDate date
 *            NSArray literature
 *                   NSMutableDictionary
 *                          NSIteger count
 *							NSString title
 *							NSString name
 *							NSInteger year
 *							NSInteger month
 *							NSInteger day
 * these are the standard names for the elements in the Call NSMutableDictionary
extern NSString const * const SettingsBulkLiterature;
extern NSString const * const BulkLiteratureDate;
extern NSString const * const BulkLiteratureArray;
extern NSString const * const BulkLiteratureArrayCount;
extern NSString const * const BulkLiteratureArrayTitle;
extern NSString const * const BulkLiteratureArrayName;
extern NSString const * const BulkLiteratureArrayYear;
extern NSString const * const BulkLiteratureArrayMonth;
extern NSString const * const BulkLiteratureArrayDay;
 */


@implementation BulkLiteraturePlacementViewContoller

@synthesize tableView;
@synthesize entries;
@synthesize selectedIndexPath;

static int sortByDate(id v1, id v2, void *context)
{
	// ok, we need to compare the dates of the calls since we have
	// at least one call for each of 
	NSDate *date1 = [v1 objectForKey:BulkLiteratureDate];
	NSDate *date2 = [v2 objectForKey:BulkLiteratureDate];
	return(-[date1 compare:date2]);
}


// sort the time entries and remove the 3 month old entries
- (void)reloadData
{
	int i;
	NSArray *sortedArray = [entries sortedArrayUsingFunction:sortByDate context:NULL];
	[sortedArray retain];
	[self.entries setArray:sortedArray];
	[sortedArray release];
	
	// remove all entries that are older than 3 months
	// remove all entries that are older than 3 months
	NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
	[comps setMonth:-3];
	NSDate *now = [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:[NSDate date] options:0];
	int count = [entries count];
	for(i = 0; i < count; ++i)
	{
		DEBUG(NSLog(@"Comparing %d to %d", now, [[entries objectAtIndex:i] objectForKey:BulkLiteratureDate]);)
		if([now compare:[[self.entries objectAtIndex:i] objectForKey:BulkLiteratureDate]] > 0)
		{
			[self.entries removeObjectAtIndex:i];
			--i;
			count = [self.entries count];
		}
	}
	
	[tableView reloadData];
}

- (id)init
{
	if ([super init]) 
	{
		NSMutableDictionary *settings = [[Settings sharedInstance] userSettings];
		self.entries = [NSMutableArray arrayWithArray:[settings objectForKey:SettingsBulkLiterature]];
		[settings setObject:self.entries forKey:SettingsBulkLiterature];
		
		// set the title, and tab bar images from the dataSource
		// object. 
		self.title = NSLocalizedString(@"Bulk Placements", @"Title for Bulk Placements view");
		self.tabBarItem.image = [UIImage imageNamed:@"bulkPlacements.png"];
	}
	return self;
}


- (void)dealloc 
{
	tableView.delegate = nil;
	tableView.dataSource = nil;
	self.tableView = nil;
	
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)navigationControlAdd:(id)sender 
{
	LiteraturePlacementViewController *viewController = [[[LiteraturePlacementViewController alloc] init] autorelease];
	self.selectedIndexPath = nil;
	viewController.delegate = self;
	[[self navigationController] pushViewController:viewController animated:YES];
}

- (void)loadView 
{
	// create a new table using the full application frame
	// we'll ask the datasource which type of table to use (plain or grouped)
	self.tableView = [[[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] 
												  style:UITableViewStylePlain] autorelease];
	tableView.editing = YES;
	tableView.allowsSelectionDuringEditing = YES;
	
	// set the autoresizing mask so that the table will always fill the view
	tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	
	// set the tableview delegate to this object and the datasource to the datasource which has already been set
	tableView.delegate = self;
	tableView.dataSource = self;
	
	// set the tableview as the controller view
	self.view = tableView;

	// add + button
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																			 target:self
																			 action:@selector(navigationControlAdd:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:NO];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if(selectedIndexPath)
	{
		[tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
		selectedIndexPath = nil;
	}
	// force the tableview to load
	[self reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
	[tableView flashScrollIndicators];
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];

#if 0
	NSMutableDictionary *settings = [[Settings sharedInstance] userSettings];
	if([settings objectForKey:SettingsBulkLiteratureAlertSheetShown] == nil)
	{
		[settings setObject:@"" forKey:SettingsBulkLiteratureAlertSheetShown];
		[[Settings sharedInstance] saveData];
		
		UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
		[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
//		alertSheet.title = SLocalizedString(@"You can delete literature placement entries just like you can delete emails, podcasts and other things in 'tables' on the iPhone/iTouch: Swipe the row in the table from left to right and a delete button will pop up.", @"This is a note displayed when they first see the Bulk Literature Placement view");
		[alertSheet show];
		
	}
#endif	
}

- (void)literaturePlacementViewControllerDone:(LiteraturePlacementViewController *)literaturePlacementController 
{
	if(selectedIndexPath != nil)
	{
		[self.entries replaceObjectAtIndex:[selectedIndexPath row] withObject:[literaturePlacementController placements]];
		
	}
	else
	{
		[self.entries addObject:[literaturePlacementController placements]];
		
	}
	[self reloadData];

	// save the data
	[[Settings sharedInstance] saveData];
}

/******************************************************************
 *
 *   TABLE DELEGATE FUNCTIONS
 *
 ******************************************************************/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DEBUG(NSLog(@"numberOfRowsInTable:");)
	int count = [self.entries count];
    DEBUG(NSLog(@"numberOfRowsInTable: %d", count);)
	return(count);
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int row = [indexPath row];
    VERBOSE(NSLog(@"tableView: cellForRow:%d ", row);)
	UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[tableView dequeueReusableCellWithIdentifier:@"HourTableCell"];
	if (cell == nil) 
	{
		cell = [[[UITableViewTitleAndValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"HourTableCell"] autorelease];
	}
	else
	{
		[cell setValue:@""];
		[cell setTitle:@""];
	}

	NSMutableDictionary *entry = [self.entries objectAtIndex:row];


	NSDate *date = [[[NSDate alloc] initWithTimeIntervalSinceReferenceDate:[[entry objectForKey:SettingsTimeEntryDate] timeIntervalSinceReferenceDate]] autorelease];	
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
	[cell setTitle:[dateFormatter stringFromDate:date]];

	NSMutableArray *publications = [entry objectForKey:BulkLiteratureArray];
	int i;
	int count = [publications count];
	int number = 0;
	for(i = 0; i < count; ++i)
	{
		number += [[[publications objectAtIndex:i] objectForKey:BulkLiteratureArrayCount] intValue];
	}
	if(number == 1)
	{
		[cell setValue:[NSString stringWithFormat:NSLocalizedString(@"%d publication", @"1, singular publication, shown as '%d publication'"), number]];
	}
	else
	{
		[cell setValue:[NSString stringWithFormat:NSLocalizedString(@"%d publications", @"more than one publications, shown as '%d publications'"), number]];
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    DEBUG(NSLog(@"tableRowSelected: didSelectRowAtIndexPath row%d", row);)
	self.selectedIndexPath = indexPath;

	LiteraturePlacementViewController *viewController = [[[LiteraturePlacementViewController alloc] initWithPlacements:[self.entries objectAtIndex:[indexPath row]]] autorelease];
	viewController.delegate = self;

	[[self navigationController] pushViewController:viewController animated:YES];
}

- (void)tableView:(UITableView *)theTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    DEBUG(NSLog(@"table: deleteRow: %d", [indexPath row]);)
	[self.entries removeObjectAtIndex:[indexPath row]];
	[[Settings sharedInstance] saveData];
	[theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return(YES);
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return(UITableViewCellEditingStyleDelete);
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
