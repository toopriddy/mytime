//
//  PublicationTypeViewController.m
//  MyTime
//
//  Created by Brent Priddy on 10/22/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//

#import "PublicationTypeViewController.h"
#import "PublicationViewController.h"
#import "Settings.h"
#import "UITableViewTextFieldCell.h"

@interface PublicationTypeViewController ()
@property (nonatomic,retain) UITableView *theTableView;
@end

@implementation PublicationTypeViewController

@synthesize delegate;
@synthesize theTableView;

- (id) init;
{
	if ([super init]) 
	{
		theTableView = nil;
		delegate = nil;
		
		// set the title, and tab bar images from the dataSource
		// object. 
		self.title = NSLocalizedString(@"Select Type", @"Publication Type title");
	}
	return self;
}

- (void)dealloc 
{
	self.theTableView.delegate = nil;
	self.theTableView.dataSource = nil;

	self.theTableView = nil;

	self.delegate = nil;
	
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return(YES);
}

- (void)loadView 
{
	// create a new table using the full application frame
	// we'll ask the datasource which type of table to use (plain or grouped)
	self.theTableView = [[[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] 
														  style:UITableViewStyleGrouped] autorelease];
	
	// set the autoresizing mask so that the table will always fill the view
	theTableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	
	// set the tableview delegate to this object and the datasource to the datasource which has already been set
	theTableView.delegate = self;
	theTableView.dataSource = self;
	
	// set the tableview as the controller view
	self.view = self.theTableView;

	[self.theTableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	// force the tableview to load
	[self.theTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
	[theTableView flashScrollIndicators];
	[theTableView deselectRowAtIndexPath:[theTableView indexPathForSelectedRow] animated:YES];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    int section = [indexPath section];
    DEBUG(NSLog(@"tableRowSelected: tableRowSelected section=%d row=%d", section, row);)
	NSString *filter = @"";
	
	switch(row)
	{
		// ALL
		case 0:
			filter = nil;
			break;
		// PublicationTypeMagazine @"Magazine"
		case 1:
			filter = PublicationTypeMagazine;
			break;
		// PublicationTypeBook @"Book"
		case 2:
			filter = PublicationTypeBook;
			break;
		// PublicationTypeCampaignTract @"Campaign Tract"
		case 3:
			filter = PublicationTypeCampaignTract;
			break;
		// PublicationTypeBrochure @"Brochure"
		case 4:
			filter = PublicationTypeBrochure;
			break;
		// PublicationTypeDVDBible @"Bible DVD"
		case 5:
			filter = PublicationTypeDVDBible;
			break;
		// PublicationTypeDVDBook @"DVD"
		case 6:
			filter = PublicationTypeDVDBook;
			break;
		// PublicationTypeDVDNotCount @"DVD Not Counted"
		case 7:
			filter = PublicationTypeDVDNotCount;
			break;
		// PublicationTypeTract @"Tract"
		case 8:
			filter = PublicationTypeTract;
			break;
	}
	// make the new call view 
	if([PublicationPickerView areTherePublicationsForFilter:filter])
	{
		PublicationViewController *p = [[[PublicationViewController alloc] initShowingCount:NO filteredToType:filter] autorelease];
		p.delegate = self;

		[[self navigationController] pushViewController:p animated:YES];
	}
	else
	{
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (void)publicationViewControllerDone:(PublicationViewController *)publicationViewController;
{
	if(delegate)
	{
		[delegate publicationViewControllerDone:publicationViewController];
	}

	[[self navigationController] popToViewController:(UIViewController *)delegate animated:YES];
}

// UITableViewDataSource methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  
{
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section 
{
	// ALL
	// PublicationTypeDVDBible @"Bible DVD"
	// PublicationTypeDVDBook @"DVD"
	// PublicationTypeDVDNotCount @"DVD Not Counted"
	// PublicationTypeBook @"Book"
	// PublicationTypeBrochure @"Brochure"
	// PublicationTypeMagazine @"Magazine"
	// PublicationTypeTract @"Tract"
	// PublicationTypeCampaignTract @"Special"

	return 9;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int row = [indexPath row];
	int section = [indexPath section];
    VERBOSE(NSLog(@"tableView: cellForRow:%d inSection:%d", row, section);)
	
	UITableViewCell *cell = (UITableViewCell *)[theTableView dequeueReusableCellWithIdentifier:@"typeCell"];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"typeCell"] autorelease];
	}
	
    switch(row)
    {
		case 0:
			[cell setText:NSLocalizedString(@"All Publications", @"all publicaitons label for publication type")];
			break;
		// PublicationTypeMagazine @"Magazine"
		case 1:
			[cell setText:[[NSBundle mainBundle] localizedStringForKey:PublicationTypeMagazine value:PublicationTypeMagazine table:@""]];
			break;
		// PublicationTypeBook @"Book"
		case 2:
			[cell setText:[[NSBundle mainBundle] localizedStringForKey:PublicationTypeBook value:PublicationTypeBook table:@""]];
			break;
		// PublicationTypeCampaignTract @"Campaign Tract"
		case 3:
			[cell setText:[[NSBundle mainBundle] localizedStringForKey:PublicationTypeCampaignTract value:PublicationTypeCampaignTract table:@""]];
			break;
		// PublicationTypeBrochure @"Brochure"
		case 4:
			[cell setText:[[NSBundle mainBundle] localizedStringForKey:PublicationTypeBrochure value:PublicationTypeBrochure table:@""]];
			break;
		// PublicationTypeDVDBible @"Bible DVD"
		case 5:
			[cell setText:[[NSBundle mainBundle] localizedStringForKey:PublicationTypeDVDBible value:PublicationTypeDVDBible table:@""]];
			break;
		// PublicationTypeDVDBook @"DVD"
		case 6:
			[cell setText:[[NSBundle mainBundle] localizedStringForKey:PublicationTypeDVDBook value:PublicationTypeDVDBook table:@""]];
			break;
		// PublicationTypeDVDNotCount @"DVD Not Counted"
		case 7:
			[cell setText:[[NSBundle mainBundle] localizedStringForKey:PublicationTypeDVDNotCount value:PublicationTypeDVDNotCount table:@""]];
			break;
		// PublicationTypeTract @"Tract"
		case 8:
			[cell setText:[[NSBundle mainBundle] localizedStringForKey:PublicationTypeTract value:PublicationTypeTract table:@""]];
			break;
    }
	return(cell);
}


//
//
// UITableViewDelegate methods
//
//

// NONE

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






