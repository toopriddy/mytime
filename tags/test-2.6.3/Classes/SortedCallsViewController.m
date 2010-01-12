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

@implementation SortedCallsViewController

@synthesize tableView;
@synthesize dataSource;
@synthesize indexPath;
@synthesize emptyView;

- (void)updateEmptyView
{
	if([self.dataSource numberOfSectionsInTableView:nil] > 1 || [self.dataSource tableView:nil numberOfRowsInSection:0])
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
			self.emptyView.imageView.image = [self.dataSource tabBarImage];
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
}

- (void)navigationControlAdd:(id)sender
{
	CallViewController *controller = [[[CallViewController alloc] init] autorelease];
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

- (id)initWithDataSource:(id<SortedCallsViewDataSourceProtocol,UITableViewDataSource>)theDataSource 
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
		self.tabBarItem.image = [dataSource tabBarImage];

		// only show the add new call button if they want to
		if([theDataSource showAddNewCall])
		{
			UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																					 target:self
																					 action:@selector(navigationControlAdd:)] autorelease];
			[self.navigationItem setRightBarButtonItem:button animated:NO];
		}
	}
	return self;
}


- (void)dealloc 
{
	self.emptyView = nil;
	[ovController release];
	tableView.delegate = nil;
	tableView.dataSource = nil;
	[tableView release];
	[dataSource release];
	[super dealloc];
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
	tableView.dataSource = dataSource;

	
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
	[dataSource filterUsingSearchText:searchText];

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
	[dataSource refreshData];
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
		[dataSource deleteCallAtIndexPath:indexPath keepInformation:keepInformation];
	}
}

- (void)callViewController:(CallViewController *)callViewController saveCall:(NSMutableDictionary *)call
{
	if(self.indexPath != nil)
	{
		[dataSource setCall:call forIndexPath:indexPath];
		[[Settings sharedInstance] saveData];
	}
	else
	{
		[dataSource addCall:call];
		[[Settings sharedInstance] saveData];
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
	NSMutableDictionary *call = [dataSource callForIndexPath:newIndexPath];
	
	CallViewController *controller = [[[CallViewController alloc] initWithCall:call] autorelease];
	controller.delegate = self;
	
	self.indexPath = newIndexPath;

	// push the element view controller onto the navigation stack to display it
	[[self navigationController] pushViewController:controller animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
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
