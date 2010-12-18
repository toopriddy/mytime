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
#import "MTReturnVisit.h"
#import "MTPublication.h"
#import "MTAdditionalInformation.h"

@interface SortedCallsViewController ()
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) MTCall *editingCall;
@property (nonatomic, retain) UISearchDisplayController *mySearchDisplayController;
@end

@implementation SortedCallsViewController

@synthesize tableView;
@synthesize dataSource;
@synthesize indexPath;
@synthesize emptyView;
@synthesize editingCall;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize savedSearchTerm;
@synthesize savedScopeButtonIndex;
@synthesize searchWasActive;
@synthesize mySearchDisplayController;

- (void)updateEmptyView
{
	if(reloadData_)
	{
		reloadData_ = NO;
		self.fetchedResultsController = nil;
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
	[self.managedObjectContext deleteObject:self.editingCall];
	self.editingCall = nil;
}

- (void)navigationControlAdd:(id)sender
{
	self.editingCall = [MTCall insertInManagedObjectContext:self.managedObjectContext];
	[self.editingCall initializeNewCall];

	CallViewController *controller = [[[CallViewController alloc] initWithCall:editingCall newCall:YES] autorelease];
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
	self.mySearchDisplayController.delegate = nil;
	self.mySearchDisplayController.searchResultsDataSource = nil;
	self.mySearchDisplayController.searchResultsDelegate = nil;
	self.mySearchDisplayController = nil;
	self.tableView.delegate = nil;
	self.tableView.dataSource = nil;
	self.tableView = nil;
	self.emptyView = nil;
	[ovController release];
}

- (void)dealloc 
{
	self.editingCall = nil;
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

- (void)viewDidDisappear:(BOOL)animated
{
    // save the state of the search UI so that it can be restored if the view is re-created
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	[self removeViewMembers];
}

- (void)viewDidLoad
{
	// restore search settings if they were saved in didReceiveMemoryWarning.
    if (self.savedSearchTerm)
	{
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
}

- (void)loadView 
{	
	// create a new table using the full application frame
	// we'll ask the datasource which type of table to use (plain or grouped)
	self.tableView = [[[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] 
														  style:[dataSource tableViewStyle]] autorelease];

	UISearchBar *searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44.0)] autorelease];
	searchBar.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
//	searchBar.delegate = self;
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	tableView.tableHeaderView = searchBar;

	self.mySearchDisplayController = [[[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self] autorelease];
	self.mySearchDisplayController.delegate = self;
	self.mySearchDisplayController.searchResultsDataSource = self;
	self.mySearchDisplayController.searchResultsDelegate = self;
	
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



#pragma mark -
#pragma mark Table view methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return([CallTableCell height]);
}

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    NSInteger count = [[self.fetchedResultsController sections] count];
    
//	if(count == 0) 
	{
//		count = 1;
	}
	
    return count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    NSInteger numberOfRows = 0;
	
    if([[self.fetchedResultsController sections] count] > 0) 
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
#pragma mark Content Filtering
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	self.fetchedResultsController.delegate = nil;
	self.fetchedResultsController = nil;
	
#if 0	
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
	for (Product *product in listContent)
	{
		if ([scope isEqualToString:@"All"] || [product.type isEqualToString:scope])
		{
			NSComparisonResult result = [product.name compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
            if (result == NSOrderedSame)
			{
				[self.filteredListContent addObject:product];
            }
		}
	}
#endif
}


#pragma mark -
#pragma mark Search Bar 
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
	self.fetchedResultsController.delegate = nil;
	self.fetchedResultsController = nil;
	[self.tableView reloadData];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString 
							   scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] 
							   scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


#pragma mark -
#pragma mark Fetched results controller
- (void)addPredicatesForEntity:(NSEntityDescription *)entity forSearch:(NSString *)searchString predicateArray:(NSMutableArray *)predicateArray path:(NSString *)path
{
	NSDictionary *attributesByName = [entity attributesByName];
	for(NSString *attributeName in [attributesByName allKeys])
	{
		NSAttributeDescription *attributeDescription = [attributesByName objectForKey:attributeName];
		if(attributeDescription.attributeType == NSStringAttributeType  && !attributeDescription.isTransient)
		{
			NSString *fullAttributePath = path.length ? [NSString stringWithFormat:@"%@.%@", path, attributeName] : attributeName;
			[predicateArray addObject:[NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", fullAttributePath, searchString]];
		}
	}
}

- (void)addPredicatesForCollectionEntity:(NSEntityDescription *)entity forSearch:(NSString *)searchString predicateArray:(NSMutableArray *)predicateArray path:(NSString *)path
{
	NSDictionary *attributesByName = [entity attributesByName];
	for(NSString *attributeName in [attributesByName allKeys])
	{
		NSAttributeDescription *attributeDescription = [attributesByName objectForKey:attributeName];
		if(attributeDescription.attributeType == NSStringAttributeType && !attributeDescription.isTransient)
		{
			[predicateArray addObject:[NSPredicate predicateWithFormat:@"SUBQUERY(%K, $s, $s.%K CONTAINS[cd] %@).@count > 0", path, attributeName, searchString]];
		}
	}
}


- (NSFetchedResultsController *)fetchedResultsController 
{
    if (fetchedResultsController_ != nil) 
	{
        return fetchedResultsController_;
    }
    
	NSArray *sortDescriptors = [dataSource sortDescriptors];
	NSPredicate *filterPredicate = [dataSource predicate];
	
	// when we filter then we use a NSCompoundPredicate
    /*
     Set up the fetched results controller.
	 */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
	NSEntityDescription *callEntity = [MTCall entityInManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:callEntity];
	
	NSMutableArray *predicateArray = [NSMutableArray array];
	NSString *searchString = self.searchDisplayController.searchBar.text;
	if(searchString.length)
	{
		// Base call strings
		[self addPredicatesForEntity:[MTCall entityInManagedObjectContext:self.managedObjectContext] 
						   forSearch:searchString 
					  predicateArray:predicateArray 
								path:nil];
		// return visits
		[self addPredicatesForCollectionEntity:[MTReturnVisit entityInManagedObjectContext:self.managedObjectContext] 
									 forSearch:searchString 
								predicateArray:predicateArray 
										  path:@"returnVisits"];
#if 0
		// return visits's publications
		[self addPredicatesForCollectionEntity:[MTPublication entityInManagedObjectContext:self.managedObjectContext] 
									 forSearch:searchString 
								predicateArray:predicateArray 
										  path:@"returnVisits.publications"];
#endif
		// additionalInformation
		[self addPredicatesForCollectionEntity:[MTAdditionalInformation entityInManagedObjectContext:self.managedObjectContext] 
									 forSearch:searchString 
								predicateArray:predicateArray 
										  path:@"additionalInformation"];
		
		// finally add the filter predicate for this view
		if(filterPredicate)
		{
			filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:filterPredicate, [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray], nil]];
		}
		else
		{
			filterPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray];
		}
	}
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
	[self updateEmptyView];
}


/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */


@end
