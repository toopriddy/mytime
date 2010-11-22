//
//  SortedByStreetViewController.m
//  MyTime
//
//  Created by Brent Priddy on 7/24/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "SortedCallsViewDataSourceProtocol.h"
#import "SortedCallsViewController.h"
#import "CallTableCell.h"
#import "CallViewController.h"
#import "Settings.h"
#import "MovableTableViewIndex.h"
#import "PSLocalization.h"
#import "MTCall.h"
#import "MTUser.h"


@interface SortedCallsViewController ()
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@end

@implementation SortedCallsViewController

@synthesize tableView;
@synthesize dataSource;
@synthesize indexPath;
@synthesize emptyView;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize fetchedResultsController = fetchedResultsController_;

- (void)updateEmptyView
{
	if(reloadData_)
	{
		reloadData_ = NO;
		[self.tableView reloadData];
	}
	
	if([self numberOfSectionsInTableView:nil] > 1 || [self tableView:nil numberOfRowsInSection:0])
	{
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		self.tableView.scrollEnabled = YES;
		[self.emptyView.view removeFromSuperview];
		self.emptyView = nil;
	}
	else
	{
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		self.tableView.scrollEnabled = NO;
		if(self.emptyView == nil)
		{
			self.emptyView = [[[EmptyListViewController alloc] initWithNibName:@"EmptyListView" bundle:nil] autorelease];
			self.emptyView.view.frame = self.tableView.bounds;
			self.emptyView.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@Big.png", [self.dataSource tabBarImageName]]];
			self.emptyView.mainLabel.text = NSLocalizedString(@"No Calls", @"Text that appears at the sorted call views when there are no entries configured");
			if([self.dataSource showAddNewCall])
			{
				self.emptyView.subLabel.text = NSLocalizedString(@"Tap + to add a call", @"Text that appears at the sorted call views when there are no entries configured");
			}
			else
			{
				self.emptyView.subLabel.text = NSLocalizedString(@"Use another call view to add a call", @"Text that appears at the sorted call views when there are no entries configured");
			}

			[self.view addSubview:self.emptyView.view];
		}
	}
}


- (void)addCallCanceled
{
	[self dismissModalViewControllerAnimated:YES];
#warning we should delete the call that was not added
}

- (void)navigationControlAdd:(id)sender
{
	MTCall *call = [MTCall insertInManagedObjectContext:self.managedObjectContext];
	call.user = [MTUser currentUser];
	[call initializeNewCall];
	CallViewController *controller = [[[CallViewController alloc] initWithCall:call newCall:YES] autorelease];
	controller.delegate = self;
	self.indexPath = nil;
	
	// push the element view controller onto the navigation stack to display it
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
	[self presentModalViewController:navigationController animated:YES];
	
	// create a custom navigation bar button and set it to always say "back"
	UIBarButtonItem *temporaryBarButtonItem = [[[UIBarButtonItem alloc] init] autorelease];
	temporaryBarButtonItem.title = NSLocalizedString(@"Cancel", @"Cancel button");
	
	[temporaryBarButtonItem setAction:@selector(addCallCanceled)];
	[temporaryBarButtonItem setTarget:self];
	controller.navigationItem.leftBarButtonItem = temporaryBarButtonItem;
} 

- (void)userChanged
{
	[fetchedResultsController_ release];
	fetchedResultsController_ = nil;
	reloadData_ = YES;
}

- (id)initWithDataSource:(id<SortedCallsViewDataSourceProtocol>)theDataSource 
{
	if ([self init]) 
	{
		tableView = nil;
		
		indexPath = nil;
		
		// retain the data source
		self.dataSource = theDataSource;
		
		// set the title, and tab bar images from the dataSource
		// object. 
		self.title = [dataSource name];
		self.tabBarItem.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", [self.dataSource tabBarImageName]]];

		// only show the add new call button if they want to
		if([theDataSource showAddNewCall])
		{
			UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																					 target:self
																					 action:@selector(navigationControlAdd:)] autorelease];
			[self.navigationItem setRightBarButtonItem:button animated:NO];
		}
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userChanged) name:MTNotificationUserChanged object:nil];
	}
	return self;
}

- (void)removeViewMembers
{
	self.tableView.delegate = nil;
	self.tableView.dataSource = nil;
	self.tableView = nil;
	self.emptyView = nil;
	[ovController release];
}

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self removeViewMembers];
	[dataSource release];
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

- (void)loadView 
{	
	// create a new table using the full application frame
	// we'll ask the datasource which type of table to use (plain or grouped)
	self.tableView = [[[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] 
														  style:[dataSource tableViewStyle]] autorelease];

	searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44.0)] autorelease];
	searchBar.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	searchBar.delegate = self;
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	tableView.tableHeaderView = searchBar;

	searching = NO;

	// set the autoresizing mask so that the table will always fill the view
	tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	
	// set the cell separator to a single straight line.
	tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	tableView.sectionIndexMinimumDisplayRowCount = 6;

	// set the tableview delegate to this object and the datasource to the datasource which has already been set
	tableView.delegate = self;
	tableView.dataSource = self;

	
	// set the tableview as the controller view
	self.view = tableView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[tableView.tableHeaderView resignFirstResponder];
}

#pragma mark -
#pragma mark Search Bar 

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar 
{
	//This method is called again when the user clicks back from teh detail view.
	//So the overlay is displayed on the results, which is something we do not want to happen.
	if(searching)
		return;

// move the index out of the way
	for ( UIView *view in tableView.subviews ) 
	{
		if ( [view respondsToSelector:@selector(moveIndexOut)] ) 
		{
			MovableTableViewIndex *index = (MovableTableViewIndex *)view;
			[index moveIndexOut];
		}
	}
		
	//Add the overlay view.
	if(ovController == nil)
	{
		ovController = [[OverlayViewController alloc] init];
	}
	
	CGFloat yaxis = self.navigationController.navigationBar.frame.size.height;
	CGFloat width = self.view.frame.size.width;
	CGFloat height = self.view.frame.size.height;
	
	//Parameters x = origion on x-axis, y = origon on y-axis.
	CGRect frame = CGRectMake(0, yaxis, width, height);
	ovController.view.frame = frame;	
	ovController.view.backgroundColor = [UIColor blackColor];
	ovController.view.alpha = 0.5;
	
	ovController.delegate = self;
	
	[tableView insertSubview:ovController.view aboveSubview:self.parentViewController.view];
	
	tableView.sectionIndexMinimumDisplayRowCount = NSIntegerMax;
	searching = YES;
	tableView.scrollEnabled = NO;

	savedLeftButton = [self.navigationItem.leftBarButtonItem retain];
	self.navigationItem.leftBarButtonItem = nil;
	savedHidesBackButton = self.navigationItem.hidesBackButton;
	self.navigationItem.hidesBackButton = YES;
	//Add the done button.
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
											   initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
											   target:self action:@selector(overlayViewControllerDone:)] autorelease];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText 
{
#warning fix me!
//	[dataSource filterUsingSearchText:searchText];

	if(searchText.length > 0) 
	{
		[ovController.view removeFromSuperview];
		searching = YES;
		tableView.scrollEnabled = YES;
	}
	else 
	{
		[self.tableView insertSubview:ovController.view aboveSubview:self.parentViewController.view];
		
		searching = NO;
		tableView.scrollEnabled = NO;
	}
	
	[self.tableView reloadData];
}

- (void)overlayViewControllerDone:(OverlayViewController *)overlay 
{
	searchBar.text = @"";
	[searchBar resignFirstResponder];

	// move the index back
	for ( UIView *view in tableView.subviews ) 
	{
		if ( [view respondsToSelector:@selector(moveIndexIn)] ) 
		{
			MovableTableViewIndex *index = (MovableTableViewIndex *)view;
			[index moveIndexIn];
		}
	}	
	searching = NO;
	tableView.scrollEnabled = YES;

	// only show the add new call button if they want to
	if([dataSource showAddNewCall])
	{
		UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																				 target:self
																				 action:@selector(navigationControlAdd:)] autorelease];
		[self.navigationItem setRightBarButtonItem:button animated:NO];
	}
	if(savedLeftButton)
	{
		self.navigationItem.leftBarButtonItem = savedLeftButton;
		[savedLeftButton release];
		savedLeftButton = nil;
	}
	self.navigationItem.hidesBackButton = savedHidesBackButton;

	
	tableView.sectionIndexMinimumDisplayRowCount = 6;
	[ovController.view removeFromSuperview];
	[ovController release];
	ovController = nil;
	
	[dataSource filterUsingSearchText:@""];
	[tableView reloadData];
}






- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return([CallTableCell height]);
}

- (void)viewWillDisappear:(BOOL)animated
{
//	self.title = [dataSource name];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

//	self.title = [dataSource title];
	self.indexPath = nil;
	
	// force the tableview to load
	[tableView reloadData];

	[self updateEmptyView];
}

- (void)viewDidAppear:(BOOL)animated 
{
	[super viewDidAppear:animated];

	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
	[tableView flashScrollIndicators];
	DEBUG(NSLog(@"%s: viewDidAppear", __FILE__);)
}

//
//
// CallViewControllerDelegate methods
// 
//
- (void)callViewController:(CallViewController *)callViewController deleteCall:(NSMutableDictionary *)call keepInformation:(BOOL)keepInformation
{
	if(indexPath)
	{
//		[dataSource deleteCallAtIndexPath:indexPath keepInformation:keepInformation];
	}
}

- (void)callViewController:(CallViewController *)callViewController restoreCall:(NSMutableDictionary *)call
{
	if(indexPath)
	{
//		[dataSource restoreCallAtIndexPath:indexPath];
	}
}


- (void)callViewController:(CallViewController *)callViewController saveCall:(NSMutableDictionary *)call
{
	if(self.indexPath != nil)
	{
//		[dataSource setCall:call forIndexPath:indexPath];
//		[[Settings sharedInstance] saveData];
	}
	else
	{
//		[dataSource addCall:call];
//		[[Settings sharedInstance] saveData];
	}
}

//
//
// UITableViewDelegate methods
//
//
// the user selected a row in the table.
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath 
{
	[tableView.tableHeaderView resignFirstResponder];

	// create a custom navigation bar button and set it to always say "back"
	UIBarButtonItem *temporaryBarButtonItem = [[[UIBarButtonItem alloc] init] autorelease];
	temporaryBarButtonItem.title = NSLocalizedString(@"All Calls", @"cancel button");
	self.navigationItem.backBarButtonItem = temporaryBarButtonItem;

	// get the element that is represented by the selected row.
	MTCall *call = [self.fetchedResultsController objectAtIndexPath:newIndexPath];
	
	CallViewController *controller = [[[CallViewController alloc] initWithCall:call newCall:NO] autorelease];
	controller.delegate = self;
	
	self.indexPath = newIndexPath;

	// push the element view controller onto the navigation stack to display it
	[[self navigationController] pushViewController:controller animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)configureCell:(UITableViewCell *)theCell atIndexPath:(NSIndexPath *)theIndexPath
{
	CallTableCell *cell = (CallTableCell *)theCell;
	// configure cell contents
	// all the rows should show the disclosure indicator
	if ([dataSource showDisclosureIcon])
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	if([dataSource useNameAsMainLabel])
	{
		[cell useNameAsMainLabel];
	}
	else
	{
		[cell useStreetAsMainLabel];
	}
	cell.call = [self.fetchedResultsController objectAtIndexPath:theIndexPath];
}


- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)theIndexPath
{
	CallTableCell *cell = (CallTableCell *)[theTableView dequeueReusableCellWithIdentifier:@"CallTableCell"];
	if (cell == nil) 
	{
		cell = [[[CallTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CallTableCell"] autorelease];
	}

    [self configureCell:cell atIndexPath:theIndexPath];
	return cell;
}


#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    NSInteger count = [[self.fetchedResultsController sections] count];
    
	if (count == 0) 
	{
		count = 1;
	}
	
    return count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    NSInteger numberOfRows = 0;
	
    if ([[self.fetchedResultsController sections] count] > 0) 
	{
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    
    return numberOfRows;
	
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	// Display the types' names as section headings.
	//    return [[[fetchedResultsController sections] objectAtIndex:section] valueForKey:@"name"];
	
	if (self.fetchedResultsController.sections.count > 0) 
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
		return [sectionInfo name];
	}
	return nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
	return [self.fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index 
{
	return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
#if 0
	if([title isEqualToString:@"{search}"])
	{
		[tableView scrollRectToVisible:[[tableView tableHeaderView] bounds] animated:NO];
		return -1;
	}
	return [callsSorter sectionForSectionIndexTitle:title atIndex:index];
#endif
}


#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController 
{
    if (fetchedResultsController_ != nil) 
	{
        return fetchedResultsController_;
    }
    
	NSArray *sortDescriptors = [dataSource sortDescriptors];
	NSPredicate *filterPredicate = [dataSource predicate];
//	MTUser *currentUser = [MTUser currentUser];
	
	// when we filter then we use a NSCompoundPredicate
    /*
     Set up the fetched results controller.
	 */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    [fetchRequest setEntity:[MTCall entityInManagedObjectContext:self.managedObjectContext]];
	[fetchRequest setPredicate:filterPredicate];
	
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																								managedObjectContext:self.managedObjectContext 
																								  sectionNameKeyPath:[dataSource sectionNameKeyPath] 
																										   cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    
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
       atIndexPath:(NSIndexPath *)theIndexPath 
	 forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath 
{
    UITableView *theTableView = self.tableView;
    
    switch(type) 
	{
        case NSFetchedResultsChangeInsert:
            [theTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:theIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[theTableView cellForRowAtIndexPath:theIndexPath] atIndexPath:theIndexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:theIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [theTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
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
