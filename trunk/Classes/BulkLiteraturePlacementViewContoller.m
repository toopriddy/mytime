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
#import "MTUser.h"
#import "MTPublication.h"
#import "NSManagedObjectContext+PriddySoftware.h"
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

@synthesize selectedIndexPath;
@synthesize emptyView;
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize temporaryBulkPlacement;

- (void)updateEmptyView
{
	if(reloadData_)
	{
		reloadData_ = NO;
		[self.tableView reloadData];
	}
	
	if(self.fetchedResultsController.fetchedObjects.count == 0)
	{
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		self.tableView.scrollEnabled = NO;
		if(self.emptyView == nil)
		{
			self.emptyView = [[[EmptyListViewController alloc] initWithNibName:@"EmptyListView" bundle:nil] autorelease];
			self.emptyView.view.frame = self.tableView.bounds;
			self.emptyView.imageView.image = [UIImage imageNamed:@"bulkPlacementsBig.png"];
			self.emptyView.mainLabel.text = NSLocalizedString(@"No Placements", @"Text that appears at the Bulk placements view when there are no entries configured");
			self.emptyView.subLabel.text = NSLocalizedString(@"Tap + to add street witnessing placements", @"Text that appears at the bulk placements view when there are no entries configured");
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
	reloadData_ = YES;
}

- (id)init
{
	if ([super init]) 
	{
		// set the title, and tab bar images from the dataSource
		// object. 
		coreDataHasChangeContentBug = !isIOS4OrGreater();
		self.title = NSLocalizedString(@"Bulk Placements", @"Title for Bulk Placements view");
		self.tabBarItem.image = [UIImage imageNamed:@"bulkPlacements.png"];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userChanged) name:MTNotificationUserChanged object:nil];
	}
	return self;
}

- (void)removeViewMembers
{
	fetchedResultsController_.delegate = nil;
	[fetchedResultsController_ release];
	fetchedResultsController_ = nil;
	self.emptyView = nil;
}

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self removeViewMembers];
	self.selectedIndexPath = nil;
	self.temporaryBulkPlacement = nil;
	self.managedObjectContext = nil;

	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
	fetchedResultsController_.delegate = nil;
	[fetchedResultsController_ release];
	fetchedResultsController_ = nil;
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	[self removeViewMembers];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)literaturePlacementCanceled
{
	[self.temporaryBulkPlacement.managedObjectContext deleteObject:self.temporaryBulkPlacement];
	self.temporaryBulkPlacement = nil;
	[self dismissModalViewControllerAnimated:YES];
}

- (void)navigationControlAdd:(id)sender 
{
	self.temporaryBulkPlacement = [MTBulkPlacement insertInManagedObjectContext:self.managedObjectContext];
	self.temporaryBulkPlacement.user = [MTUser currentUser];
	LiteraturePlacementViewController *controller = [[[LiteraturePlacementViewController alloc] initWithBulkPlacement:self.temporaryBulkPlacement] autorelease];
	self.selectedIndexPath = nil;
	controller.delegate = self;

	// push the element view controller onto the navigation stack to display it
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
	[self presentModalViewController:navigationController animated:YES];
	
	// create a custom navigation bar button and set it to always say "back"
	UIBarButtonItem *temporaryBarButtonItem = [[[UIBarButtonItem alloc] init] autorelease];
	temporaryBarButtonItem.title = NSLocalizedString(@"Cancel", @"Cancel button");
	
	[temporaryBarButtonItem setAction:@selector(literaturePlacementCanceled)];
	[temporaryBarButtonItem setTarget:self];
	controller.navigationItem.leftBarButtonItem = temporaryBarButtonItem;
}


- (void)loadView
{
	[super loadView];
	self.tableView.allowsSelectionDuringEditing = YES;
	self.tableView.editing = YES;
	
	// add + button
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																			 target:self
																			 action:@selector(navigationControlAdd:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:NO];
	
}
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if(self.selectedIndexPath)
	{
		[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
		self.selectedIndexPath = nil;
	}
	[self updateEmptyView];
}

- (void)literaturePlacementViewControllerDone:(LiteraturePlacementViewController *)literaturePlacementController 
{
	if(selectedIndexPath != nil)
	{
		// existing entry
		[[self navigationController] popViewControllerAnimated:YES];
	}
	else
	{
		// new entry
		[[self navigationController] dismissModalViewControllerAnimated:YES];
	}

	// save the data
	NSError *error = nil;
	if(![self.managedObjectContext save:&error])
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
}

- (void)configureCell:(UITableViewTitleAndValueCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	MTBulkPlacement *bulkPlacement = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	
	NSDate *date = [[[NSDate alloc] initWithTimeIntervalSinceReferenceDate:[bulkPlacement.date timeIntervalSinceReferenceDate]] autorelease];	
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
	
	int number = 0;
	for(MTPublication *publication in bulkPlacement.publications)
	{
		if([PublicationTypeTwoMagazine isEqualToString:publication.type])
		{
			number += [publication.count intValue] * 2;
		}
		else
		{
			number += [publication.count intValue];
		}
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
}

#pragma mark -
#pragma mark Table view data source

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
	NSString *CellIdentifier = @"BulkPlacementCell";
	
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
	self.selectedIndexPath = indexPath;
	MTBulkPlacement *bulkPlacement = [self.fetchedResultsController objectAtIndexPath:indexPath];
	LiteraturePlacementViewController *viewController = [[[LiteraturePlacementViewController alloc] initWithBulkPlacement:bulkPlacement] autorelease];
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
    [fetchRequest setEntity:[MTBulkPlacement entityInManagedObjectContext:self.managedObjectContext]];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"user == %@", [MTUser currentUser]]];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:[NSSortDescriptor psSortDescriptorWithKey:@"date" ascending:NO], nil];
    
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
	if(!coreDataHasChangeContentBug)
	{
		[self.tableView beginUpdates];
	}
}


- (void)controller:(NSFetchedResultsController *)controller 
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex 
	 forChangeType:(NSFetchedResultsChangeType)type 
{
	if(!coreDataHasChangeContentBug)
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
}


- (void)controller:(NSFetchedResultsController *)controller 
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath 
	 forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath 
{
	if(!coreDataHasChangeContentBug)
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
				[self configureCell:(UITableViewTitleAndValueCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
				break;
				
			case NSFetchedResultsChangeMove:
				[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
				[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
				break;
		}
	}
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller 
{
	if(coreDataHasChangeContentBug)
	{
		[self.tableView reloadData];
	}
	else
	{
		[self.tableView endUpdates];
	}
	[self updateEmptyView];
}

@end
