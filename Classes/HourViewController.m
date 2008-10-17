//
//  HourViewController.m
//  MyTime
//
//  Created by Brent Priddy on 8/11/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import "HourViewController.h"
#import "TimePickerViewController.h"
#import "Settings.h"
#import "UITableViewTitleAndValueCell.h"

@implementation HourViewController

@synthesize tableView;
@synthesize timeEntries;
@synthesize selectedIndexPath;

static int sortByDate(id v1, id v2, void *context)
{
	// ok, we need to compare the dates of the calls since we have
	// at least one call for each of 
	NSDate *date1 = [v1 objectForKey:SettingsTimeEntryDate];
	NSDate *date2 = [v2 objectForKey:SettingsTimeEntryDate];
	return(-[date1 compare:date2]);
}


// sort the time entries and remove the 13 month old entries
- (void)reloadData
{
	NSArray *sortedArray = [timeEntries sortedArrayUsingFunction:sortByDate context:NULL];
	[sortedArray retain];
	[timeEntries setArray:sortedArray];
	[sortedArray release];

	// remove all entries that are older than 13 months
	NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
	[comps setMonth:-13];
	NSDate *now = [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:[NSDate date] options:0];
	int count = [timeEntries count];
	int i;
	for(i = 0; i < count; ++i)
	{
		VERBOSE(NSLog(@"Comparing %d to %d", now, [[timeEntries objectAtIndex:i] objectForKey:SettingsTimeEntryDate]);)
		if([now compare:[[timeEntries objectAtIndex:i] objectForKey:SettingsTimeEntryDate]] > 0)
		{
			[timeEntries removeObjectAtIndex:i];
			--i;
			count = [timeEntries count];
		}
	}
	[tableView reloadData];
}


- (id)initForQuickBuild:(BOOL)quickBuild
{
	if ([super init]) 
	{
		tableView = nil;
		timeEntries = nil;
		selectedIndexPath = nil;

		_quickBuild = quickBuild;
		NSString *timeEntriesName = (NSString *)(quickBuild ? SettingsQuickBuildTimeEntries : SettingsTimeEntries);

		NSMutableDictionary *settings = [[Settings sharedInstance] settings];
		self.timeEntries = [[NSMutableArray alloc] initWithArray:[settings objectForKey:timeEntriesName]];
		[settings setObject:timeEntries forKey:timeEntriesName];
		
		
		// set the title, and tab bar images from the dataSource
		// object. 
		if(quickBuild)
		{
			self.title = NSLocalizedString(@"Quick Build", @"'Quick Build Hours' ButtonBar View text, Label for the amount of hours spent doing quick builds");
			self.tabBarItem.image = [UIImage imageNamed:@"build.png"];
		}
		else
		{
			self.title = NSLocalizedString(@"Hours", @"'Hours' ButtonBar View text, Label for the amount of hours spend in the ministry, and Expanded name when on the More view");
			self.tabBarItem.image = [UIImage imageNamed:@"timer.png"];
		}
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
	return(YES);
}

- (void)navigationControlAdd:(id)sender 
{
	TimePickerViewController *viewController = [[[TimePickerViewController alloc] init] autorelease];
	self.selectedIndexPath = nil;
	viewController.delegate = self;
	[[self navigationController] pushViewController:viewController animated:YES];
}

- (void)updatePrompt
{
	if(!_quickBuild)
	{
		NSDate *date = [[[Settings sharedInstance] settings] objectForKey:SettingsTimeStartDate];
		if(date)
		{
			[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
			NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		#warning fix me
		//	  [dateFormatter setDateFormat:NSLocalizedString(@"%a %b %d", @"Calendar format where %a is an abbreviated weekday %b is an abbreviated month and %d is the day of the month as a decimal number")]];
			[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
			[dateFormatter setTimeStyle:NSDateFormatterShortStyle];			 

			[self.navigationItem setPrompt:[NSString stringWithFormat:NSLocalizedString(@"Time started at: %@", @"Hours view prompt when you press the start time button"), [dateFormatter stringFromDate:date]]];
		}
		else
		{	
			[self.navigationItem setPrompt:nil];
		}
	}
}

- (void)navigationControlStartTime:(id)sender 
{
	[[[Settings sharedInstance] settings] setObject:[NSDate date] forKey:SettingsTimeStartDate];
	[[Settings sharedInstance] saveData];
	// add Stop Time button
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Stop Time", @"'Stop Time' navigation bar action button")
																style:UIBarButtonItemStyleDone
															   target:self
															   action:@selector(navigationControlStopTime:)] autorelease];
	[self.navigationItem setLeftBarButtonItem:button animated:YES];
	[self updatePrompt];
}

- (void)navigationControlStopTime:(id)sender 
{
	NSMutableDictionary *settings = [[Settings sharedInstance] settings];
	// we found a saved start date, lets see how much time there was between then and now
	NSDate *date = [[[NSDate alloc] initWithTimeIntervalSinceReferenceDate:[[settings objectForKey:SettingsTimeStartDate] timeIntervalSinceReferenceDate]] autorelease];	
	NSDate *now = [NSDate date];
	
	int minutes = [now timeIntervalSinceDate:date]/60.0;
	if(minutes > 0)
	{
		NSMutableDictionary *entry = [[[NSMutableDictionary alloc] init] autorelease];

		[entry setObject:date forKey:SettingsTimeEntryDate];
		[entry setObject:[[[NSNumber alloc] initWithInt:minutes] autorelease] forKey:SettingsTimeEntryMinutes];
		[timeEntries insertObject:entry atIndex:0];
	
		[tableView reloadData];
	}
	[settings removeObjectForKey:SettingsTimeStartDate];
	[[Settings sharedInstance] saveData];


	// add Start Time button
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Start Time", @"'Start Time' navigation bar action button")
																style:UIBarButtonItemStylePlain
															   target:self
															   action:@selector(navigationControlStartTime:)] autorelease];
	[self.navigationItem setLeftBarButtonItem:button animated:YES];
	[self updatePrompt];
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

	if(!_quickBuild)
	{
		if([[[Settings sharedInstance] settings] objectForKey:SettingsTimeStartDate] == nil)
		{
			// add Start Time button
			UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Start Time", @"'Start Time' navigation bar action button")
																		style:UIBarButtonItemStylePlain
																	   target:self
																	   action:@selector(navigationControlStartTime:)] autorelease];
			[self.navigationItem setLeftBarButtonItem:button animated:NO];
		}
		else
		{
			// add Stop Time button
			UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Stop Time", @"'Stop Time' navigation bar action button")
																		style:UIBarButtonItemStyleDone
																	   target:self
																	   action:@selector(navigationControlStopTime:)] autorelease];
			[self.navigationItem setLeftBarButtonItem:button animated:NO];
		}
	}
	[self updatePrompt];
}

-(void)viewWillAppear:(BOOL)animated
{
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
#if 0
	NSMutableDictionary *settings = [[Settings sharedInstance] settings];
	if([settings objectForKey:SettingsTimeAlertSheetShown] == nil)
	{
		[settings setObject:@"" forKey:SettingsTimeAlertSheetShown];
		[[Settings sharedInstance] saveData];
		
		UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
		[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
//		alertSheet.title = SLocalizedString(@"You can delete time entries just like you can delete emails, podcasts and other things in 'tables' on the iPhone/iTouch: Swipe the row in the table from left to right and a delete button will pop up.", @"This is a note displayed when they first see the Time view");
		[alertSheet show];
		
	}
#endif	
}

- (void)timePickerViewControllerDone:(TimePickerViewController *)timePickerController 
{
	if(selectedIndexPath != nil)
	{
		VERBOSE(NSLog(@"date is = %@, minutes %d", [timePickerController date], [timePickerController minutes]);)
		// existing entry
		NSMutableDictionary *entry = [self.timeEntries objectAtIndex:[selectedIndexPath row]];

		[entry setObject:[timePickerController date] forKey:SettingsTimeEntryDate];
		[entry setObject:[[[NSNumber alloc] initWithInt:[timePickerController minutes]] autorelease] forKey:SettingsTimeEntryMinutes];
		
		[self reloadData];

		// save the data
		[[Settings sharedInstance] saveData];
	}
	else
	{
		// new entry
		VERBOSE(NSLog(@"date is = %@, minutes %d", [timePickerController date], [timePickerController minutes]);)

		NSMutableDictionary *entry = [[[NSMutableDictionary alloc] init] autorelease];

		[entry setObject:[timePickerController date] forKey:SettingsTimeEntryDate];
		[entry setObject:[[[NSNumber alloc] initWithInt:[timePickerController minutes]] autorelease] forKey:SettingsTimeEntryMinutes];
		[timeEntries insertObject:entry atIndex:0];
		
		[self reloadData];

		// save the data
		[[Settings sharedInstance] saveData];
	}
}

/******************************************************************
 *
 *   TABLE DELEGATE FUNCTIONS
 *
 ******************************************************************/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DEBUG(NSLog(@"numberOfRowsInTable:");)
	int count = [timeEntries count];
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

	if(row >= [timeEntries count])
		return(NULL);
	NSMutableDictionary *entry = [timeEntries objectAtIndex:row];

	NSNumber *time = [entry objectForKey:SettingsTimeEntryMinutes];


	NSDate *date = [[[NSDate alloc] initWithTimeIntervalSinceReferenceDate:[[entry objectForKey:SettingsTimeEntryDate] timeIntervalSinceReferenceDate]] autorelease];	
	// create dictionary entry for This Return Visit
	[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
#warning fix me
//	  [dateFormatter setDateFormat:NSLocalizedString(@"%a %b %d", @"Calendar format where %a is an abbreviated weekday %b is an abbreviated month and %d is the day of the month as a decimal number")]];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];			 

	[cell setTitle:[dateFormatter stringFromDate:date]];



	int minutes = [time intValue];
	int hours = minutes / 60;
	minutes %= 60;
	if(hours && minutes)
		[cell setValue:[NSString stringWithFormat:NSLocalizedString(@"%d %@ %d %@", @"You are localizing the time (I dont know if you need to even change this) as in '1 hour 34 minutes' or '2 hours 1 minute' %1$d is the hours number %2$@ is the label for hour(s) %3$d is the minutes number and 4$%@ is the label for minutes(s)"), hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours"), minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")]];
	else if(hours)
		[cell setValue:[NSString stringWithFormat:@"%d %@", hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours")]];
	else if(minutes)
		[cell setValue:[NSString stringWithFormat:@"%d %@", minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")]];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    DEBUG(NSLog(@"tableRowSelected: didSelectRowAtIndexPath row%d", row);)
	self.selectedIndexPath = indexPath;
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
	[timeEntries removeObjectAtIndex:[indexPath row]];
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
