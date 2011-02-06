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
#import "MovableTableViewIndex.h"
#import "PSLocalization.h"
#import "MTCall.h"
#import "MTUser.h"
#import "MTDisplayRule.h"
#import "MTReturnVisit.h"
#import "MTPublication.h"
#import "MTAdditionalInformation.h"

@interface SortedCallsViewController ()
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSFetchedResultsController *searchFetchedResultsController;
@property (nonatomic, retain) MTCall *editingCall;
@property (nonatomic, retain) UISearchDisplayController *mySearchDisplayController;
@property (nonatomic, retain) UILabel *footerLabel;

@end

@implementation SortedCallsViewController

@synthesize tableView = tableView_;
@synthesize dataSource;
@synthesize indexPath;
@synthesize emptyView;
@synthesize editingCall;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize searchFetchedResultsController = searchFetchedResultsController_;
@synthesize savedSearchTerm;
@synthesize savedScopeButtonIndex;
@synthesize searchWasActive;
@synthesize mySearchDisplayController;
@synthesize footerLabel = footerLabel_;

- (void)updateEmptyView
{
	if(reloadData_)
	{
		reloadData_ = NO;
		[self.tableView reloadData];
		if(self.searchWasActive)
		{
			[self.searchDisplayController.searchResultsTableView reloadData];
		}
	}
	
	if(self.fetchedResultsController.fetchedObjects.count == 0)
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
	else
	{
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		self.tableView.scrollEnabled = YES;
		[self.emptyView.view removeFromSuperview];
		self.emptyView = nil;
	}
}


- (void)addCallCanceled
{
	[self dismissModalViewControllerAnimated:YES];
	[self.managedObjectContext deleteObject:self.editingCall];
	self.editingCall = nil;
}

- (void)callViewController:(CallViewController *)callViewController newCallDone:(MTCall *)call
{
	[self dismissModalViewControllerAnimated:YES];
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

- (void)reloadTableFromSourceChange
{
	fetchedResultsController_.delegate = nil;
	[fetchedResultsController_ release];
	fetchedResultsController_ = nil;
	searchFetchedResultsController_.delegate = nil;
	[searchFetchedResultsController_ release];
	searchFetchedResultsController_ = nil;
	
	reloadData_ = YES;
}

- (id)initWithDataSource:(id<SortedCallsViewDataSourceProtocol>)theDataSource 
{
	if ([self init]) 
	{
		coreDataHasChangeContentBug = !isIOS4OrGreater();
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
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableFromSourceChange) name:MTNotificationUserChanged object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableFromSourceChange) name:MTNotificationDisplayRuleChanged object:nil];
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
	self.searchWasActive = [self.searchDisplayController isActive];
	self.savedSearchTerm = [self.searchDisplayController.searchBar text];
	self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
	
	fetchedResultsController_.delegate = nil;
	[fetchedResultsController_ release];
	fetchedResultsController_ = nil;
	searchFetchedResultsController_.delegate = nil;
	[searchFetchedResultsController_ release];
	searchFetchedResultsController_ = nil;
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

	UISearchBar *searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44.0)] autorelease];
	searchBar.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	searchBar.scopeButtonTitles = [NSArray arrayWithObjects:NSLocalizedString(@"Name", @"Name label for Call in editing mode"), NSLocalizedString(@"Address", @"Address label for call"), NSLocalizedString(@"Notes", @"Call Metadata"), NSLocalizedString(@"All", @"search button in the sorted calls view to search through all of the call information"), nil];
//	searchBar.delegate = self;
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	self.tableView.tableHeaderView = searchBar;
	
	self.footerLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0 , 0 , 320 , 60)] autorelease];
	self.tableView.tableFooterView = self.footerLabel;
	self.footerLabel.font = [UIFont systemFontOfSize:20];
	self.footerLabel.textColor = [UIColor grayColor];
	self.footerLabel.textAlignment = UITextAlignmentCenter;
	
	self.mySearchDisplayController = [[[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self] autorelease];
	self.mySearchDisplayController.delegate = self;
	self.mySearchDisplayController.searchResultsDataSource = self;
	self.mySearchDisplayController.searchResultsDelegate = self;
	
	searching = NO;

	// set the autoresizing mask so that the table will always fill the view
	self.tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	
	// set the cell separator to a single straight line.
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.tableView.sectionIndexMinimumDisplayRowCount = 6;

	// set the tableview delegate to this object and the datasource to the datasource which has already been set
	self.tableView.delegate = self;
	self.tableView.dataSource = self;

	
	// set the tableview as the controller view
	self.view = self.tableView;
}

- (void)viewWillDisappear:(BOOL)animated
{
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	self.indexPath = nil;
	int callCount = self.fetchedResultsController.fetchedObjects.count;
	if(callCount == 1)
		self.footerLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%u Call", @"This is the label that is at the bottom of the sorted calls view showing you how many calls you have (if there is a single call... this is the single version of the text)"), callCount];
	else
		self.footerLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%u Calls", @"This is the label that is at the bottom of the sorted calls view showing you how many calls you have  (if there is a more than one call... this is the plural version of the text)"), callCount];
	
	[self updateEmptyView];
}

- (void)viewDidAppear:(BOOL)animated 
{
	[super viewDidAppear:animated];

	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	[self.tableView flashScrollIndicators];
	DEBUG(NSLog(@"%s: viewDidAppear", __FILE__);)
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}



#pragma mark -
#pragma mark Table view methods

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
	return tableView == tableView_ ? self.fetchedResultsController : self.searchFetchedResultsController;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return([CallTableCell height]);
}

// the user selected a row in the table.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath 
{
	// make the keyboard disappear when you click on any row
	[self.tableView.tableHeaderView resignFirstResponder];

	// create a custom navigation bar button and set it to always say "back"
	UIBarButtonItem *temporaryBarButtonItem = [[[UIBarButtonItem alloc] init] autorelease];
	temporaryBarButtonItem.title = NSLocalizedString(@"All Calls", @"cancel button");
	self.navigationItem.backBarButtonItem = temporaryBarButtonItem;

	
	// get the element that is represented by the selected row.
	MTCall *call = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:newIndexPath];
	
	CallViewController *controller = [[[CallViewController alloc] initWithCall:call newCall:NO] autorelease];
	controller.delegate = self;
	
	self.indexPath = newIndexPath;

	// push the element view controller onto the navigation stack to display it
	[[self navigationController] pushViewController:controller animated:YES];
}

- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController configureCell:(UITableViewCell *)theCell atIndexPath:(NSIndexPath *)theIndexPath
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
	cell.call = [fetchedResultsController objectAtIndexPath:theIndexPath];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)theIndexPath
{
	CallTableCell *cell = (CallTableCell *)[theTableView dequeueReusableCellWithIdentifier:@"CallTableCell"];
	if (cell == nil) 
	{
		cell = [[[CallTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CallTableCell"] autorelease];
	}

    [self fetchedResultsController:[self fetchedResultsControllerForTableView:theTableView] configureCell:cell atIndexPath:theIndexPath];
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    NSInteger count = [[[self fetchedResultsControllerForTableView:tableView] sections] count];
    
    return count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    NSInteger numberOfRows = 0;
	NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:tableView];
	NSArray *sections = fetchController.sections;
    if(sections.count > 0) 
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    
    return numberOfRows;
	
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	// Display the types' names as section headings.
	//    return [[[fetchedResultsController sections] objectAtIndex:section] valueForKey:@"name"];

	NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:tableView];
	NSArray *sections = fetchController.sections;
	if(sections.count > 0) 
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
		NSString *name;
		if(( name = [self.dataSource sectionNameForIndex:[[sectionInfo name] intValue]]))
		{
			return name;
		}
		
		return [sectionInfo name];
	}
	return nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
	if(tableView == self.tableView)
	{
		NSMutableArray *array = [NSMutableArray arrayWithObject:@"{search}"];
		NSArray *alternateIndexTitles = [self.dataSource sectionIndexTitles];
		if(alternateIndexTitles)
		{
			[array addObjectsFromArray:alternateIndexTitles];
		}
		else
		{
			[array addObjectsFromArray:[self.fetchedResultsController sectionIndexTitles]];
		}

		return array;
	}
	else
	{
		return [self.searchFetchedResultsController sectionIndexTitles];
	}
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index 
{
	if(tableView == self.tableView)
	{
		if([title isEqualToString:@"{search}"])
		{
			[tableView scrollRectToVisible:[[tableView tableHeaderView] bounds] animated:NO];
			return -1;
		}
		index--;
	}
	NSArray *alternateIndexTitles = [self.dataSource sectionIndexTitles];
	if(alternateIndexTitles)
	{
		NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:tableView];
		int i = 0;
		int ret = 0;
		for(id<NSFetchedResultsSectionInfo> sectionInfo in fetchController.sections)
		{
			if([[sectionInfo name] intValue] <= index)
			{
				ret = i;
			}
			i++;
		}
		return ret;
	}
	return [[self fetchedResultsControllerForTableView:tableView] sectionForSectionIndexTitle:title atIndex:index];
}

#pragma mark -
#pragma mark Content Filtering
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	self.searchFetchedResultsController.delegate = nil;
	self.searchFetchedResultsController = nil;
	self.savedScopeButtonIndex = scope;
}


#pragma mark -
#pragma mark Search Bar 
- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView;
{
	self.searchFetchedResultsController.delegate = nil;
	self.searchFetchedResultsController = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString 
							   scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] 
							   scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
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

- (NSFetchedResultsController *)newFetchedResultsControllerWithSearch:(NSString *)searchString
{
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
	if(searchString.length)
	{
		switch(self.savedScopeButtonIndex)
		{
			case 0: // Name
				[predicateArray addObject:[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchString]];
				break;
			case 1: // Address
				[predicateArray addObject:[NSPredicate predicateWithFormat:@"street CONTAINS[cd] %@", searchString]];
				[predicateArray addObject:[NSPredicate predicateWithFormat:@"city CONTAINS[cd] %@", searchString]];
				[predicateArray addObject:[NSPredicate predicateWithFormat:@"state CONTAINS[cd] %@", searchString]];
				[predicateArray addObject:[NSPredicate predicateWithFormat:@"houseNumber CONTAINS[cd] %@", searchString]];
				[predicateArray addObject:[NSPredicate predicateWithFormat:@"apartmentNumber CONTAINS[cd] %@", searchString]];
				break;
			case 2: // Notes
				[predicateArray addObject:[NSPredicate predicateWithFormat:@"SUBQUERY(returnVisits, $s, $s.notes CONTAINS[cd] %@).@count > 0", searchString]];
				break;
			case 3: // All
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
				break;
		}
		
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
    
    [fetchRequest release];
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) 
	{
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return aFetchedResultsController;
}    

- (NSFetchedResultsController *)fetchedResultsController 
{
    if (fetchedResultsController_ != nil) 
	{
        return fetchedResultsController_;
    }
	fetchedResultsController_ = [self newFetchedResultsControllerWithSearch:nil];
	return [[fetchedResultsController_ retain] autorelease];
}	

- (NSFetchedResultsController *)searchFetchedResultsController 
{
    if (searchFetchedResultsController_ != nil) 
	{
        return searchFetchedResultsController_;
    }
	searchFetchedResultsController_ = [self newFetchedResultsControllerWithSearch:self.searchDisplayController.searchBar.text];
	return [[searchFetchedResultsController_ retain] autorelease];
}	


#pragma mark -
#pragma mark Fetched results controller delegate


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller 
{
	if(!coreDataHasChangeContentBug)
	{
		UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
		[tableView beginUpdates];
	}
}


- (void)controller:(NSFetchedResultsController *)controller 
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex 
	 forChangeType:(NSFetchedResultsChangeType)type 
{
	if(!coreDataHasChangeContentBug)
	{
		UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
		
		switch(type) 
		{
			case NSFetchedResultsChangeInsert:
				[tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
				break;
				
			case NSFetchedResultsChangeDelete:
				[tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
				break;
		}
	}
}


- (void)controller:(NSFetchedResultsController *)controller 
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)theIndexPath 
	 forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath 
{
	if(!coreDataHasChangeContentBug)
	{
		UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
		
		switch(type) 
		{
			case NSFetchedResultsChangeInsert:
				[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
				break;
				
			case NSFetchedResultsChangeDelete:
				[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:theIndexPath] withRowAnimation:UITableViewRowAnimationFade];
				break;
				
			case NSFetchedResultsChangeUpdate:
				[self fetchedResultsController:controller configureCell:[tableView cellForRowAtIndexPath:theIndexPath] atIndexPath:theIndexPath];
				break;
				
			case NSFetchedResultsChangeMove:
				[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:theIndexPath] withRowAnimation:UITableViewRowAnimationFade];
				[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
				break;
		}
	}
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller 
{
	UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
	if(coreDataHasChangeContentBug)
	{
		[tableView reloadData];
	}
	else
	{
		[tableView endUpdates];
		int callCount = self.fetchedResultsController.fetchedObjects.count;
		if(callCount == 1)
			self.footerLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%u Call", @"This is the label that is at the bottom of the sorted calls view showing you how many calls you have (if there is a single call... this is the single version of the text)"), callCount];
		else
			self.footerLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%u Calls", @"This is the label that is at the bottom of the sorted calls view showing you how many calls you have  (if there is a more than one call... this is the plural version of the text)"), callCount];
	}
	if(tableView == self.tableView)
	{
		[self updateEmptyView];
	}
}

@end
