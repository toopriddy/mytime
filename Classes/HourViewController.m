//
//  HourViewController.m
//  MyTime
//
//  Created by Brent Priddy on 8/11/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "HourViewController.h"
#import "TimePickerViewController.h"
#import "Settings.h"
#import "UITableViewTitleAndValueCell.h"
#import "PSLocalization.h"
#import "MTTimeEntry.h"
#import "MTUser.h"
#import "MTTimeType.h"
#import "NSManagedObjectContext+PriddySoftware.h"

@interface HourViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation HourViewController

@synthesize tableView = tableView_;
@synthesize selectedIndexPath;
@synthesize emptyView;
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize type = type_;

- (void)updateEmptyView
{
	
	if(self.fetchedResultsController.fetchedObjects.count == 0)
	{
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		self.tableView.scrollEnabled = NO;
		if(self.emptyView == nil)
		{
			self.emptyView = [[[EmptyListViewController alloc] initWithNibName:@"EmptyListView" bundle:nil] autorelease];
			self.emptyView.view.frame = self.tableView.bounds;
			self.emptyView.imageView.image = [UIImage imageNamed:[self.type.imageFileName stringByAppendingString:@"Big"]];
			
			self.emptyView.mainLabel.text = NSLocalizedString(@"No Hours", @"Text that appears at the Hours view when there are no entries configured");
			self.emptyView.subLabel.text = NSLocalizedString(@"Tap + to add hours", @"Text that appears at the Hours view when there are no entries configured");
			[self.view addSubview:self.emptyView.view];
		}
	}
	else
	{
		self.tableView.scrollEnabled = YES;
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		[self.emptyView.view removeFromSuperview];
		self.emptyView = nil;
	}
}

- (void)userChanged
{
	[fetchedResultsController_ release];
	fetchedResultsController_ = nil;
}

- (id)initWithTimeTypeName:(NSString *)typeName
{
	if ([super init]) 
	{
		self.type = [MTTimeType timeTypeWithName:typeName];
		self.title = self.type.name;
		self.tabBarItem.image = [UIImage imageNamed:self.type.imageFileName];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userChanged) name:SettingsNotificationUserChanged object:[Settings sharedInstance]];
	}
	return self;
}


- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.tableView.delegate = nil;
	self.tableView.dataSource = nil;
	self.tableView = nil;
	self.emptyView = nil;
	
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


- (void)modalViewControllerCanceled
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)navigationControlAdd:(id)sender 
{
	TimePickerViewController *controller = [[[TimePickerViewController alloc] init] autorelease];
	self.selectedIndexPath = nil;
	controller.delegate = self;
	
	// push the element view controller onto the navigation stack to display it
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
	[self presentModalViewController:navigationController animated:YES];
	
	// create a custom navigation bar button and set it to always say "back"
	UIBarButtonItem *temporaryBarButtonItem = [[[UIBarButtonItem alloc] init] autorelease];
	temporaryBarButtonItem.title = NSLocalizedString(@"Cancel", @"Cancel button");
	
	[temporaryBarButtonItem setAction:@selector(modalViewControllerCanceled)];
	[temporaryBarButtonItem setTarget:self];
	controller.navigationItem.leftBarButtonItem = temporaryBarButtonItem;
}

- (void)updatePrompt
{
	NSDate *date = self.type.startTimerDate;
	if(date)
	{
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

		[self.navigationItem setPrompt:[NSString stringWithFormat:NSLocalizedString(@"Time started at: %@", @"Hours view prompt when you press the start time button"), [dateFormatter stringFromDate:date]]];
	}
	else
	{	
		[self.navigationItem setPrompt:nil];
	}
}

- (void)navigationControlStartTime:(id)sender 
{
	self.type.startTimerDate = [NSDate date];
	NSError *error = nil;
	if (![self.managedObjectContext save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
		abort();
	}
	
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
	// we found a saved start date, lets see how much time there was between then and now
	NSDate *date = self.type.startTimerDate;	
	NSDate *now = [NSDate date];
	
	int minutes = [now timeIntervalSinceDate:date]/60.0;
	if(minutes > 0)
	{
		MTTimeEntry *timeEntry = [NSEntityDescription insertNewObjectForEntityForName:[[[self.fetchedResultsController fetchRequest] entity] name] 
															   inManagedObjectContext:self.managedObjectContext];
		timeEntry.minutes = [NSNumber numberWithInt:minutes];
		timeEntry.date = date;
		timeEntry.type = self.type;
	}
	self.type.startTimerDate = nil;
	NSError *error = nil;
	if (![self.managedObjectContext save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
		abort();
	}


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
	self.tableView.editing = YES;
	self.tableView.allowsSelectionDuringEditing = YES;
	
	// set the autoresizing mask so that the table will always fill the view
	self.tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	
	// set the tableview delegate to this object and the datasource to the datasource which has already been set
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	
	// set the tableview as the controller view
	self.view = self.tableView;

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
		[self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
		selectedIndexPath = nil;
	}

	if(self.type.startTimerDate == nil)
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
	[self updatePrompt];
	[self updateEmptyView];
}

- (void)viewDidAppear:(BOOL)animated
{
	[self.tableView flashScrollIndicators];
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)timePickerViewControllerDone:(TimePickerViewController *)timePickerController 
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
	
	if(selectedIndexPath != nil)
	{
		VERBOSE(NSLog(@"date is = %@, minutes %d", [timePickerController date], [timePickerController minutes]);)
		MTTimeEntry *timeEntry = [self.fetchedResultsController objectAtIndexPath:selectedIndexPath];
	
		timeEntry.minutes = [NSNumber numberWithInt:[timePickerController minutes]];
		timeEntry.date = [timePickerController date];

		// Save the context.
		NSError *error = nil;
		if (![context save:&error]) 
		{
			[NSManagedObjectContext presentErrorDialog:error];
		}
		
		[[self navigationController] popViewControllerAnimated:YES];
	}
	else
	{
		// new entry
		VERBOSE(NSLog(@"date is = %@, minutes %d", [timePickerController date], [timePickerController minutes]);)

		
		// Create a new instance of the entity managed by the fetched results controller.
		NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
		MTTimeEntry *timeEntry = [NSEntityDescription insertNewObjectForEntityForName:[entity name] 
															   inManagedObjectContext:context];
		timeEntry.minutes = [NSNumber numberWithInt:[timePickerController minutes]];
		timeEntry.date = [timePickerController date];
		timeEntry.type = self.type;
		
		// Save the context.
		NSError *error = nil;
		if (![context save:&error]) 
		{
			[NSManagedObjectContext presentErrorDialog:error];
		}
		
		[self dismissModalViewControllerAnimated:YES];
	}
}

- (void)configureCell:(UITableViewTitleAndValueCell *)cell atIndexPath:(NSIndexPath *)indexPath 
{
	MTTimeEntry *timeEntry = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
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
	
	[cell setTitle:[dateFormatter stringFromDate:timeEntry.date]];
	
	
	
	int minutes = [timeEntry.minutes intValue];
	int hours = minutes / 60;
	minutes %= 60;
	if(hours && minutes)
		[cell setValue:[NSString stringWithFormat:NSLocalizedString(@"%d %@ %d %@", @"You are localizing the time (I dont know if you need to even change this) as in '1 hour 34 minutes' or '2 hours 1 minute' %1$d is the hours number %2$@ is the label for hour(s) %3$d is the minutes number and 4$%@ is the label for minutes(s)"), hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours"), minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")]];
	else if(hours)
		[cell setValue:[NSString stringWithFormat:@"%d %@", hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours")]];
	else if(minutes || minutes == 0)
		[cell setValue:[NSString stringWithFormat:@"%d %@", minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")]];
	else
		[cell setValue:@""];
}




/******************************************************************
 *
 *   TABLE DELEGATE FUNCTIONS
 *
 ******************************************************************/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [[self.fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *CellIdentifier = @"HourTableCell";

	UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) 
	{
		cell = [[[UITableViewTitleAndValueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (editingStyle == UITableViewCellEditingStyleDelete) 
	{
        // Delete the managed object for the given index path
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) 
		{
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
		
		// display the "no entries" picture
		[self updateEmptyView];
    }   
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    DEBUG(NSLog(@"tableRowSelected: didSelectRowAtIndexPath row%d", row);)
	self.selectedIndexPath = indexPath;
	MTTimeEntry *timeEntry = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	
	TimePickerViewController *viewController = [[[TimePickerViewController alloc] initWithDate:timeEntry.date minutes:[timeEntry.minutes intValue]] autorelease];
	viewController.delegate = self;
	[[self navigationController] pushViewController:viewController animated:YES];
}



#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController 
{
    if (fetchedResultsController_ != nil) 
	{
        return fetchedResultsController_;
    }
    
    /*
     Set up the fetched results controller.
	 */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TimeEntry" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"type == %@", self.type]];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																								managedObjectContext:self.managedObjectContext 
																								  sectionNameKeyPath:nil 
																										   cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
    
    NSError *error = nil;
    if (![fetchedResultsController_ performFetch:&error]) 
	{
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return fetchedResultsController_;
}    


#pragma mark -
#pragma mark Fetched results controller delegate


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller 
{
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller 
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex 
	 forChangeType:(NSFetchedResultsChangeType)type 
{
    
    switch(type) 
	{
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller 
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath 
	 forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath 
{
    
    UITableView *tableView = self.tableView;
    
    switch(type) 
	{
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller 
{
    [self.tableView endUpdates];
}


/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

@end
