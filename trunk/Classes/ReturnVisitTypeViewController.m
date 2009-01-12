//
//  ReturnVisitTypeViewController.m
//  MyTime
//
//  Created by Brent Priddy on 10/13/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//

#import "ReturnVisitTypeViewController.h"
#import "Settings.h"
#import "UITableViewTextFieldCell.h"

@interface ReturnVisitTypeViewController ()
@property (nonatomic,retain) UITableView *theTableView;
@property (nonatomic,retain) UITableViewCell *returnVisitCell;
@property (nonatomic,retain) UITableViewCell *studyCell;
@property (nonatomic,retain) UITableViewCell *notAtHomeCell;
@end

@implementation ReturnVisitTypeViewController

@synthesize delegate;
@synthesize theTableView;
@synthesize type;
@synthesize returnVisitCell;
@synthesize studyCell;
@synthesize notAtHomeCell;


- (id) initWithType:(NSString *)callType isInitialVisit:(BOOL)isInitialVisitVar
{
	if ([super init]) 
	{
		theTableView = nil;
		delegate = nil;
		returnVisitCell = nil;
		studyCell = nil;
		notAtHomeCell = nil;
		isInitialVisit = isInitialVisitVar;
		
		// set the title, and tab bar images from the dataSource
		// object. 
		self.title = NSLocalizedString(@"Visit Type", @"Return Visit Type title");

		self.type = callType;
	}
	return self;
}

- (void)dealloc 
{
	self.theTableView.delegate = nil;
	self.theTableView.dataSource = nil;

	self.theTableView = nil;

    self.returnVisitCell = nil;
    self.studyCell = nil;
    self.notAtHomeCell = nil;

    self.type = nil;

	self.delegate = nil;
	
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return(YES);
}

- (void)updateSelection:(const NSString *)newType
{
	UITableViewCell *selected = nil;
	UITableViewCell *unselected1 = returnVisitCell;
	UITableViewCell *unselected2 = studyCell;
	UITableViewCell *unselected3 = notAtHomeCell;
	
	if([newType isEqualToString:(NSString *)CallReturnVisitTypeReturnVisit])
	{
		selected = returnVisitCell;
		unselected1 = nil;
	}
	else if([newType isEqualToString:(NSString *)CallReturnVisitTypeStudy])
	{
		selected = studyCell;
		unselected2 = nil;
	}
	else if([newType isEqualToString:(NSString *)CallReturnVisitTypeNotAtHome])
	{
		selected = notAtHomeCell;
		unselected3 = nil;
	}

	unselected1.accessoryType = UITableViewCellAccessoryNone;
	unselected2.accessoryType = UITableViewCellAccessoryNone;
	unselected3.accessoryType = UITableViewCellAccessoryNone;
	selected.accessoryType = UITableViewCellAccessoryCheckmark;

	self.type = [NSString stringWithString:(NSString *)newType];
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

	self.returnVisitCell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"returnVisitCell"] autorelease];
	if(isInitialVisit)
		returnVisitCell.text = NSLocalizedString(@"Initial Visit", @"This is used to signify the first visit which is not counted as a return visit.  This is in the view where you get to pick the visit type");
	else
		returnVisitCell.text = [[NSBundle mainBundle] localizedStringForKey:(NSString *)CallReturnVisitTypeReturnVisit value:(NSString *)CallReturnVisitTypeReturnVisit table:@""];
	returnVisitCell.accessoryType = UITableViewCellAccessoryCheckmark;
	returnVisitCell.selected = NO;
	
	self.studyCell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"returnVisitCell"] autorelease];
	studyCell.text = [[NSBundle mainBundle] localizedStringForKey:(NSString *)CallReturnVisitTypeStudy value:(NSString *)CallReturnVisitTypeReturnVisit table:@""];
	studyCell.accessoryType = UITableViewCellAccessoryCheckmark;
	studyCell.selected = NO;
	
	self.notAtHomeCell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"returnVisitCell"] autorelease];
	notAtHomeCell.text = [[NSBundle mainBundle] localizedStringForKey:(NSString *)CallReturnVisitTypeNotAtHome value:(NSString *)CallReturnVisitTypeReturnVisit table:@""];
	notAtHomeCell.accessoryType = UITableViewCellAccessoryCheckmark;
	notAtHomeCell.selected = NO;

	//make one be selected
	[self updateSelection:self.type];

	[self.theTableView reloadData];
}




-(void)viewWillAppear:(BOOL)animated
{
	// force the tableview to load
	[self.theTableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    int section = [indexPath section];
    DEBUG(NSLog(@"tableRowSelected: tableRowSelected section=%d row=%d", section, row);)
	switch(section)
	{
		case 0:
			[self updateSelection:CallReturnVisitTypeReturnVisit];
			break;
		case 1:
			[self updateSelection:CallReturnVisitTypeStudy];
			break;
		case 2:
			[self updateSelection:CallReturnVisitTypeNotAtHome];
			break;
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if(delegate)
	{
		[delegate returnVisitTypeViewControllerDone:self];
	}

	[[self navigationController] popViewControllerAnimated:YES];
}

// UITableViewDataSource methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  
{
	return 3;
}


- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section 
{
	return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int row = [indexPath row];
	int section = [indexPath section];
    VERBOSE(NSLog(@"tableView: cellForRow:%d inSection:%d", row, section);)
    switch(section)
    {
		case 0:
			return(returnVisitCell);
		case 1:
			return(studyCell);
		case 2:
			return(notAtHomeCell);
    }
	return(nil);
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






