//
//  SortedByStreetViewController.m
//  MyTime
//
//  Created by Brent Priddy on 7/24/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//

#import "SortedCallsViewDataSourceProtocol.h"
#import "SortedCallsViewController.h"
#import "CallTableCell.h"
#import "CallViewController.h"
#import "Settings.h"

@implementation SortedCallsViewController

@synthesize theTableView;
@synthesize dataSource;
@synthesize indexPath;

- (void)navigationControlAdd:(id)sender
{
	CallViewController *controller = [[[CallViewController alloc] init] autorelease];

	// create a custom navigation bar button and set it to always say "back"
	UIBarButtonItem *temporaryBarButtonItem = [[[UIBarButtonItem alloc] init] autorelease];
	temporaryBarButtonItem.title = NSLocalizedString(@"Cancel", @"Cancel button");
	self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
	controller.delegate = self;
	
	self.indexPath = nil;
	
	// push the element view controller onto the navigation stack to display it
	[[self navigationController] pushViewController:controller animated:YES];
//	[self presentModalViewController:<#(UIViewController *)modalViewController#> animated:<#(BOOL)animated#>
} 

- (id)initWithDataSource:(id<SortedCallsViewDataSourceProtocol,UITableViewDataSource>)theDataSource 
{
	if ([self init]) 
	{
		theTableView = nil;
		
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
	theTableView.delegate = nil;
	theTableView.dataSource = nil;
	[theTableView release];
	[dataSource release];
	[super dealloc];
}


- (void)loadView 
{	
	// create a new table using the full application frame
	// we'll ask the datasource which type of table to use (plain or grouped)
	UITableView *tableView = [[[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] 
														  style:[dataSource tableViewStyle]] autorelease];
	
	// set the autoresizing mask so that the table will always fill the view
	tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	
	// set the cell separator to a single straight line.
	tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	tableView.sectionIndexMinimumDisplayRowCount = 6;

	// set the tableview delegate to this object and the datasource to the datasource which has already been set
	tableView.delegate = self;
	tableView.dataSource = dataSource;
	
	// set the tableview as the controller view
	self.theTableView = tableView;
	self.view = tableView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return([CallTableCell height]);
}

-(void)viewWillAppear:(BOOL)animated
{
	self.indexPath = nil;
	
	// force the tableview to load
	[dataSource refreshData];
	[theTableView reloadData];
	
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated 
{
	[theTableView deselectRowAtIndexPath:[theTableView indexPathForSelectedRow] animated:YES];
	DEBUG(NSLog(@"%s: viewDidAppear", __FILE__);)
	
	[super viewDidAppear:animated];
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath 
{
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
