//
//  NotAtHomeViewController.m
//  MyTime
//
//  Created by Brent Priddy on 10/14/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "NotAtHomeViewController.h"
#import "NotAtHomeTerritoryViewController.h"
#import "MTTerritory.h"
#import "MTUser.h"
#import "MTSettings.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "PSLocalization.h"
#import "QuartzCore/CAGradientLayer.h"

@implementation NotAtHomeViewController
@synthesize emptyView;
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize temporaryTerritory;

- (void)notAtHomeDetailCanceled
{
	[self.managedObjectContext deleteObject:self.temporaryTerritory];
	self.temporaryTerritory = nil;
	[self dismissModalViewControllerAnimated:YES];
}

- (void)navigationControlAdd:(id)sender
{
	self.temporaryTerritory = [MTTerritory insertInManagedObjectContext:self.managedObjectContext];
	self.temporaryTerritory.user = [MTUser currentUser];
	MTSettings *settings = [MTSettings settings];
	self.temporaryTerritory.state = settings.lastState;
	self.temporaryTerritory.city = settings.lastCity;
	
	NotAtHomeTerritoryViewController *controller = [[[NotAtHomeTerritoryViewController alloc] initWithTerritory:self.temporaryTerritory newTerritory:YES] autorelease];
	controller.tag = -1;
	controller.delegate = self;

	// push the element view controller onto the navigation stack to display it
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];

	// create a custom navigation bar button and set it to always say "back"
	UIBarButtonItem *temporaryBarButtonItem = [[[UIBarButtonItem alloc] init] autorelease];
	temporaryBarButtonItem.title = NSLocalizedString(@"Cancel", @"Cancel button");
	
	controller.title = NSLocalizedString(@"Add New Territory", @"Title for the a new territory in the Territories view");
	[self presentModalViewController:navigationController animated:YES];
	[temporaryBarButtonItem setAction:@selector(notAtHomeDetailCanceled)];
	[temporaryBarButtonItem setTarget:self];
	controller.navigationItem.leftBarButtonItem = temporaryBarButtonItem;
} 

- (void)notAtHomeTerritoryViewControllerDone:(NotAtHomeTerritoryViewController *)notAtHomeTerritoryViewController
{
	if(notAtHomeTerritoryViewController.tag >= 0)
	{
		[[self navigationController] popViewControllerAnimated:YES];
	}
	else
	{
		[self dismissModalViewControllerAnimated:YES];
		self.temporaryTerritory = nil;
	}
	NSError *error = nil;
	if(![self.managedObjectContext save:&error])
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
}

- (void)loadView
{
	[super loadView];
	self.tableView.allowsSelectionDuringEditing = YES;
	self.tableView.editing = YES;
}

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
			self.emptyView.imageView.image = [UIImage imageNamed:@"not-at-homeBig.png"];
			self.emptyView.mainLabel.text = NSLocalizedString(@"No Territories", @"Text that appears at the Not-At-Homes view when there are no entries configured");
			self.emptyView.subLabel.text = NSLocalizedString(@"Tap + to add a not-at-home territory", @"Text that appears at the Not-At-Homes view when there are no entries configured");
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

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self updateEmptyView];
}

- (void)userChanged
{
	fetchedResultsController_.delegate = nil;
	[fetchedResultsController_ release];
	fetchedResultsController_ = nil;
	reloadData_ = YES;
}

- (id)init
{
	if ([super init]) 
	{
		coreDataHasChangeContentBug = !isIOS4OrGreater();
		// set the title, and tab bar images from the dataSource
		// object. 
		self.title = NSLocalizedString(@"Territories", @"View title for the previously named 'Not At Homes' but it is representing the user's territory now");
		self.tabBarItem.image = [UIImage imageNamed:@"not-at-home.png"];
		UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																				 target:self
																				 action:@selector(navigationControlAdd:)] autorelease];
		[self.navigationItem setRightBarButtonItem:button animated:NO];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userChanged) name:MTNotificationUserChanged object:nil];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[fetchedResultsController_ release];
	fetchedResultsController_ = nil;
	self.emptyView = nil;
	self.temporaryTerritory = nil;

	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return(YES);
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath 
{
	MTTerritory *territory = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.textLabel.text = territory.name;
	cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark -
#pragma mark Table view DataSource 
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
	NSString *identifier = @"NotAtHomeTerritoryCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
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
		if(![context save:&error])
		{
			[NSManagedObjectContext presentErrorDialog:error];
		}
	}   
}

#pragma mark -
#pragma mark Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
	MTTerritory *territory = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	
	NotAtHomeTerritoryViewController *controller = [[[NotAtHomeTerritoryViewController alloc] initWithTerritory:territory] autorelease];
	controller.tag = row;
	controller.delegate = self;
	
	// push the element view controller onto the navigation stack to display it
	[[self navigationController] pushViewController:controller animated:YES];
}


#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController 
{
    if (fetchedResultsController_ != nil) 
	{
        return fetchedResultsController_;
    }
    
	MTUser *currentUser = [MTUser currentUser];
    /*
     Set up the fetched results controller.
	 */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    [fetchRequest setEntity:[MTTerritory entityInManagedObjectContext:self.managedObjectContext]];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"user == %@", currentUser]];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"name", @"date", nil]];
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:[NSSortDescriptor psSortDescriptorWithKey:@"date" ascending:YES], [NSSortDescriptor psSortDescriptorWithKey:@"name" ascending:NO], nil];
    
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
				[self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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
