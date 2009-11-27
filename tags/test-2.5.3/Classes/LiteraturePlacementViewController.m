//
//  LiteraturePlacementViewController.m
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

#import "LiteraturePlacementViewController.h"
#import "UITableViewTitleAndValueCell.h"
#import "DatePickerViewController.h"
#import "PublicationViewController.h"
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
 */

@implementation LiteraturePlacementViewController

@synthesize tableView;
@synthesize placements;
@synthesize delegate;
@synthesize selectedIndexPath;


- (id)init
{
	return([self initWithPlacements:nil]);
}

- (id)initWithPlacements:(NSMutableDictionary *)thePlacements
{
	if ([super init]) 
	{
		self.placements = [NSMutableDictionary dictionaryWithDictionary:thePlacements];
		
		NSMutableArray *literature = [placements objectForKey:BulkLiteratureArray];
		if(literature == nil)
		{
			literature = [NSMutableArray array];
			[placements setObject:literature forKey:BulkLiteratureArray];
		}
		
		if([placements objectForKey:BulkLiteratureDate] == nil)
			[placements setObject:[NSDate date] forKey:BulkLiteratureDate];
		
		self.hidesBottomBarWhenPushed = YES;
		 
		// set the title, and tab bar images from the dataSource
		// object. 
		self.title = NSLocalizedString(@"Placements", @"View Title and ButtonBar Title for the Day's Bulk Placed Publications");
	}
	return self;
}


- (void)dealloc 
{
	tableView.delegate = nil;
	tableView.dataSource = nil;
	self.tableView = nil;
	self.placements = nil;
	self.selectedIndexPath = nil;
	
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return(YES);
}

- (void)navigationControlDone:(id)sender 
{
	NSLog(@"navigationControlDone:");
	if(delegate)
	{
		[delegate literaturePlacementViewControllerDone:self];
	}

	[[self navigationController] popViewControllerAnimated:YES];
}

- (void)loadView 
{
	// create a new table using the full application frame
	// we'll ask the datasource which type of table to use (plain or grouped)
	self.tableView = [[[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] 
												  style:UITableViewStyleGrouped] autorelease];
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
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(navigationControlDone:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:NO];
	self.navigationItem.hidesBackButton = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
	[tableView flashScrollIndicators];
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}


-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	selectedIndexPath = nil;
	// force the tableview to load
	[tableView reloadData];
}


/******************************************************************
 *
 *   TABLE DELEGATE FUNCTIONS
 *
 ******************************************************************/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return(2);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DEBUG(NSLog(@"numberOfRowsInSection:%d", section);)
	if(section == 0) // Date
	{
		return(1);
	}
	// literature placements plus an add entry
	return([[placements objectForKey:BulkLiteratureArray] count] + 1);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    VERBOSE(NSLog(@"LiteraturePlacementView tableView: titleForHeaderInSection:%d", section);)
	
	if(section == 1)
	{
		return(NSLocalizedString(@"Placements:", @"Placements Group title for the Day's Bulk Literature Placements"));
	}

    return(@"");
} 

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int row = [indexPath row];
	int section = [indexPath section];
    VERBOSE(NSLog(@"tableView: cellForRow:%d ", row);)
	UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[tableView dequeueReusableCellWithIdentifier:@"HourTableCell"];
	if (cell == nil) 
	{
		cell = [[[UITableViewTitleAndValueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HourTableCell"] autorelease];
	}
	else
	{
		[cell setValue:@""];
		[cell setTitle:@""];
	}


    VERBOSE(NSLog(@"LiteraturePlacementView preferencesTable: cellForRow:%d inGroup:%d", row, section);)
	if(section == 0)
	{
		NSDate *date = [[[NSDate alloc] initWithTimeIntervalSinceReferenceDate:[[placements objectForKey:BulkLiteratureDate] timeIntervalSinceReferenceDate]] autorelease];	
		// create dictionary entry for This Return Visit
		[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
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
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		[cell setTitle:[dateFormatter stringFromDate:date]];
	}
	else
	{
		if(row == [[placements objectForKey:BulkLiteratureArray] count])
		{
			[cell setValue:NSLocalizedString(@"Add placed publications", @"Action Button in the Day's Bulk Literature Placement View called 'Add placed publications'")];
		}
		else
		{
			NSMutableDictionary *entry = [[placements objectForKey:BulkLiteratureArray] objectAtIndex:row];
			NSString *name = [entry objectForKey:BulkLiteratureArrayTitle];
			name = [[PSLocalization localizationBundle] localizedStringForKey:name value:name table:@""];
			int count = [[entry objectForKey:BulkLiteratureArrayCount] intValue];
			NSString *type = [entry objectForKey:BulkLiteratureArrayType];
			type = [[PSLocalization localizationBundle] localizedStringForKey:type value:type table:@""];
			if([type isEqualToString:NSLocalizedString(@"Magazine", @"Publication Type name")])
			{
				[cell setTitle:[NSString stringWithFormat:NSLocalizedString(@"%d: %@", @"Short form of Bulk Magazine Placements for the Watchtower and Awake '%d: %@'"), count, name]];
			}
			else
			{
				if(count == 1)
				{
					[cell setTitle:[NSString stringWithFormat:NSLocalizedString(@"%d %@: %@", @"Singular form of '1 Brochure: The Trinity' with the format '%d %@: %@', the %@ represents the Magazine, Book, or Brochure type and the %d represents the count of publications"), count, type, name]];
				}
				else
				{	
					[cell setTitle:[NSString stringWithFormat:NSLocalizedString(@"%d %@s: %@", @"Plural form of '2 Brochures: The Trinity' with the format '%d %@s: %@' notice the 's' in the middle for the plural form, the %@ represents the Magazine, Book, or Brochure type and the %d represents the count of publications"), count, type, name]];
				}
			}
		}
	}
	return(cell);
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    int section = [indexPath section];
    DEBUG(NSLog(@"tableRowSelected: didSelectRowAtIndexPath row%d", row);)
	self.selectedIndexPath = indexPath;

	switch(section)
	{
		case 0:
		{
			DatePickerViewController *viewController = [[[DatePickerViewController alloc] initWithDate:[placements objectForKey:BulkLiteratureDate]] autorelease];
			viewController.delegate = self;

			[[self navigationController] pushViewController:viewController animated:YES];
			return;
		}
		case 1:
		{
			PublicationViewController *viewController;
			if(row == [[placements objectForKey:BulkLiteratureArray] count])
			{
				// make the new call view 
				viewController = [[[PublicationViewController alloc] initShowingCount:YES] autorelease];
			}
			else
			{
				NSMutableDictionary *entry = [[placements objectForKey:BulkLiteratureArray] objectAtIndex:row];
				viewController = [[[PublicationViewController alloc] initWithPublication: [entry objectForKey:BulkLiteratureArrayName]
																	   year: [[entry objectForKey:BulkLiteratureArrayYear] intValue]
																	  month: [[entry objectForKey:BulkLiteratureArrayMonth] intValue]
																		day: [[entry objectForKey:BulkLiteratureArrayDay] intValue]
																  showCount: YES
																	 number: [[entry objectForKey:BulkLiteratureArrayCount] intValue]] autorelease];
			}
			viewController.delegate = self;
			[[self navigationController] pushViewController:viewController animated:YES];
			return;
		}
	}
}

- (void)tableView:(UITableView *)theTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    int section = [indexPath section];
    DEBUG(NSLog(@"tableView: commitEditingStyle section=%d row=%d", section, row);)
	switch(editingStyle)
	{
		case UITableViewCellEditingStyleInsert:
			[tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
			[self tableView:tableView didSelectRowAtIndexPath:indexPath];
			break;
			
		case UITableViewCellEditingStyleDelete:
			DEBUG(NSLog(@"table: deleteRow: %d", [indexPath row]);)
			if([indexPath row] < [[placements objectForKey:BulkLiteratureArray] count])
			{
				[[placements objectForKey:BulkLiteratureArray] removeObjectAtIndex:[indexPath row]];

				[[Settings sharedInstance] saveData];
				[theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
			}
			else
			{
				[theTableView reloadData];
			}
			break;
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return([indexPath section] == 1);
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int section = [indexPath section];	
	int row = [indexPath row];
	if(section == 1)
	{
		if(row == [[placements objectForKey:BulkLiteratureArray] count])
			return(UITableViewCellEditingStyleInsert);
		else
			return(UITableViewCellEditingStyleDelete);
	}
	return(UITableViewCellEditingStyleNone);
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	if([indexPath section] == 1 && 
	   [indexPath row] != [[placements objectForKey:BulkLiteratureArray] count])
		return(UITableViewCellAccessoryDisclosureIndicator);
	else
		return(UITableViewCellAccessoryNone);
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


- (NSMutableDictionary *)placements
{
	return([[placements retain] autorelease]);
}



/******************************************************************
 *
 *   PUBLICATION VIEW CALLBACKS
 *
 ******************************************************************/
- (void)publicationViewControllerDone:(PublicationViewController *)publicationViewController
{
    DEBUG(NSLog(@"LiteraturePlacementView addNewPublicationSaveAction:");)
    NSMutableDictionary *publication;
	BOOL newRow = NO;
    if([selectedIndexPath row] == [[placements objectForKey:BulkLiteratureArray] count])
    {
        VERBOSE(NSLog(@"creating a new publication entry and adding it");)
        // if we are adding a publication then create the NSDictionary and add it to the end
        // of the publications array
        publication = [[[NSMutableDictionary alloc] init] autorelease];
        [[placements objectForKey:BulkLiteratureArray] addObject:publication];
		newRow = YES;
    }
	else
	{
        publication = [[[NSMutableDictionary alloc] init] autorelease];
        [[placements objectForKey:BulkLiteratureArray] replaceObjectAtIndex:[selectedIndexPath row] withObject:publication ];
	}

	DEBUG(NSLog(@"EditingPlacements %@",placements);)
	PublicationPickerView *picker = [publicationViewController publicationPicker];
    [publication setObject:[picker publication] forKey:BulkLiteratureArrayName];
    [publication setObject:[picker publicationTitle] forKey:BulkLiteratureArrayTitle];
    [publication setObject:[picker publicationType] forKey:BulkLiteratureArrayType];
    [publication setObject:[[[NSNumber alloc] initWithInt:[picker year]] autorelease] forKey:BulkLiteratureArrayYear];
    [publication setObject:[[[NSNumber alloc] initWithInt:[picker month]] autorelease] forKey:BulkLiteratureArrayMonth];
    [publication setObject:[[[NSNumber alloc] initWithInt:[picker day]] autorelease] forKey:BulkLiteratureArrayDay];
    [publication setObject:[[[NSNumber alloc] initWithInt:publicationViewController.countPicker.number] autorelease] forKey:BulkLiteratureArrayCount];

    VERBOSE(NSLog(@"publication is = %@", publication);)

	if(newRow)
	{
		[tableView beginUpdates];
			[tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:selectedIndexPath] withRowAnimation:UITableViewRowAnimationRight];
		[tableView endUpdates];
	}
	else
	{
		[tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
		[tableView reloadData];
	}
}




/******************************************************************
 *
 *   DATE PICKER VIEW CALLBACKS
 *
 ******************************************************************/

- (void)datePickerViewControllerDone:(DatePickerViewController *)datePickerViewController
{
    DEBUG(NSLog(@"CallView datePickerViewControllerDone:");)
    VERBOSE(NSLog(@"date is now = %@", [datePickerViewController date]);)

    [placements setObject:[datePickerViewController date] forKey:BulkLiteratureDate];
    
	[tableView reloadData];
}

@end