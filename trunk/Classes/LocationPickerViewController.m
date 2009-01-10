//
//  LocationPickerViewController.m
//  MyTime
//
//  Created by Brent Priddy on 10/13/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import "LocationPickerViewController.h"
#import "Settings.h"
#import "UITableViewTextFieldCell.h"

@interface LocationPickerViewController ()
@property (nonatomic, retain) UITableView *theTableView;
@property (nonatomic, retain) UITableViewCell *manualCell;
@property (nonatomic, retain) UITableViewCell *googleMapsCell;
@property (nonatomic, retain) NSMutableDictionary *call;
@end

@implementation LocationPickerViewController

@synthesize delegate;
@synthesize theTableView;
@synthesize type;
@synthesize manualCell;
@synthesize googleMapsCell;
@synthesize call;

- (id) initWithCall:(NSMutableDictionary *)theCall
{
	if ([super init]) 
	{
		self.call = theCall;
		
		// set the title, and tab bar images from the dataSource
		// object. 
		self.title = NSLocalizedString(@"Location", @"Select Location informatio type Type title");

		if([call objectForKey:CallLocationType] == nil)
		{
			[call setObject:CallLocationTypeGoogleMaps forKey:CallLocationType];
		}
		self.type = [call objectForKey:CallLocationType];
	}
	return self;
}

- (void)dealloc 
{
	self.theTableView.delegate = nil;
	self.theTableView.dataSource = nil;

	self.theTableView = nil;

    self.googleMapsCell = nil;
    self.manualCell = nil;

    self.type = nil;

	self.delegate = nil;
	
	[super dealloc];
}

- (void)updateSelection:(const NSString *)newType
{
	UITableViewCell *selected = nil;
	UITableViewCell *unselected1 = manualCell;
	UITableViewCell *unselected2 = googleMapsCell;
	
	if([newType isEqualToString:(NSString *)CallLocationTypeGoogleMaps])
	{
		selected = googleMapsCell;
		unselected2 = nil;
	}
	else if([newType isEqualToString:(NSString *)CallLocationTypeManual])
	{
		selected = manualCell;
		unselected1 = nil;
	}

	unselected1.accessoryType = UITableViewCellAccessoryNone;
	unselected2.accessoryType = UITableViewCellAccessoryNone;
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

	self.googleMapsCell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"googleMapsCell"] autorelease];
	googleMapsCell.text = [[NSBundle mainBundle] localizedStringForKey:(NSString *)CallLocationTypeGoogleMaps value:(NSString *)CallLocationTypeGoogleMaps table:@""];
	googleMapsCell.accessoryType = UITableViewCellAccessoryCheckmark;
	googleMapsCell.selected = NO;
	
	self.manualCell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"returnVisitCell"] autorelease];
	manualCell.text = [[NSBundle mainBundle] localizedStringForKey:(NSString *)CallLocationTypeManual value:(NSString *)CallLocationTypeManual table:@""];
	manualCell.accessoryType = UITableViewCellAccessoryCheckmark;
	manualCell.selected = NO;
	

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
			[self updateSelection:CallLocationTypeGoogleMaps];
			break;
		case 1:
			[self updateSelection:CallLocationTypeManual];
			break;
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if(delegate)
	{
		[delegate locationPickerViewControllerDone:self];
	}

	[[self navigationController] popViewControllerAnimated:YES];
}

// UITableViewDataSource methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  
{
	return 2;
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
			return(googleMapsCell);
		case 1:
			return(manualCell);
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






