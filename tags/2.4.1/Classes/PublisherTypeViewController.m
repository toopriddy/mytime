//
//  PublisherTypeViewController.m
//  MyTime
//
//  Created by Brent Priddy on 10/13/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "PublisherTypeViewController.h"
#import "Settings.h"
#import "PSLocalization.h"

@interface PublisherTypeViewController ()
@property (nonatomic,retain) UITableView *theTableView;
@property (nonatomic,retain) UITableViewCell *publisher;
@property (nonatomic,retain) UITableViewCell *auxiliaryPioneer;
@property (nonatomic,retain) UITableViewCell *pioneer;
@property (nonatomic,retain) UITableViewCell *specialPioneer;
@property (nonatomic,retain) UITableViewCell *travelingServant;
@end

@implementation PublisherTypeViewController

@synthesize delegate;
@synthesize theTableView;
@synthesize type;
@synthesize publisher;
@synthesize auxiliaryPioneer;
@synthesize pioneer;
@synthesize specialPioneer;
@synthesize travelingServant;


- (id) initWithType:(NSString *)publisherType
{
	if ([super init]) 
	{
		// set the title, and tab bar images from the dataSource
		// object. 
		self.title = NSLocalizedString(@"Visit Type", @"Return Visit Type title");

		self.type = publisherType;
	}
	return self;
}

- (void)dealloc 
{
	self.theTableView.delegate = nil;
	self.theTableView.dataSource = nil;

	self.theTableView = nil;

    self.publisher = nil;
    self.auxiliaryPioneer = nil;
    self.pioneer = nil;
    self.specialPioneer = nil;
    self.travelingServant = nil;

    self.type = nil;

	self.delegate = nil;
	
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return(YES);
}

- (void)updateSelection:(NSString *)newType
{
	UITableViewCell *selected = nil;
	UITableViewCell *unselected1 = publisher;
	UITableViewCell *unselected2 = auxiliaryPioneer;
	UITableViewCell *unselected3 = pioneer;
	UITableViewCell *unselected4 = specialPioneer;
	UITableViewCell *unselected5 = travelingServant;
	
	if([newType isEqualToString:PublisherTypePublisher])
	{
		selected = publisher;
		unselected1 = nil;
	}
	else if([newType isEqualToString:PublisherTypeAuxilliaryPioneer])
	{
		selected = auxiliaryPioneer;
		unselected2 = nil;
	}
	else if([newType isEqualToString:PublisherTypePioneer])
	{
		selected = pioneer;
		unselected3 = nil;
	}
	else if([newType isEqualToString:PublisherTypeSpecialPioneer])
	{
		selected = specialPioneer;
		unselected4 = nil;
	}
	else if([newType isEqualToString:PublisherTypeTravelingServant])
	{
		selected = travelingServant;
		unselected5 = nil;
	}

	unselected1.accessoryType = UITableViewCellAccessoryNone;
	unselected2.accessoryType = UITableViewCellAccessoryNone;
	unselected3.accessoryType = UITableViewCellAccessoryNone;
	unselected4.accessoryType = UITableViewCellAccessoryNone;
	unselected5.accessoryType = UITableViewCellAccessoryNone;
	selected.accessoryType = UITableViewCellAccessoryCheckmark;

	self.type = [NSString stringWithString:newType];
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

	self.publisher = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"publicationTypeCell"] autorelease];
	publisher.textLabel.text = [[PSLocalization localizationBundle] localizedStringForKey:PublisherTypePublisher value:PublisherTypePublisher table:@""];
	publisher.accessoryType = UITableViewCellAccessoryCheckmark;
	publisher.selected = NO;
	
	self.auxiliaryPioneer = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"publicationTypeCell"] autorelease];
	auxiliaryPioneer.textLabel.text = [[PSLocalization localizationBundle] localizedStringForKey:PublisherTypeAuxilliaryPioneer value:PublisherTypeAuxilliaryPioneer table:@""];
	auxiliaryPioneer.accessoryType = UITableViewCellAccessoryCheckmark;
	auxiliaryPioneer.selected = NO;

	self.pioneer = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"publicationTypeCell"] autorelease];
	pioneer.textLabel.text = [[PSLocalization localizationBundle] localizedStringForKey:PublisherTypePioneer value:PublisherTypePioneer table:@""];
	pioneer.accessoryType = UITableViewCellAccessoryCheckmark;
	pioneer.selected = NO;

	self.specialPioneer = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"publicationTypeCell"] autorelease];
	specialPioneer.textLabel.text = [[PSLocalization localizationBundle] localizedStringForKey:PublisherTypeSpecialPioneer value:PublisherTypeSpecialPioneer table:@""];
	specialPioneer.accessoryType = UITableViewCellAccessoryCheckmark;
	specialPioneer.selected = NO;

	self.travelingServant = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"publicationTypeCell"] autorelease];
	travelingServant.textLabel.text = [[PSLocalization localizationBundle] localizedStringForKey:PublisherTypeTravelingServant value:PublisherTypeTravelingServant table:@""];
	travelingServant.accessoryType = UITableViewCellAccessoryCheckmark;
	travelingServant.selected = NO;

	//make one be selected
	[self updateSelection:self.type];

	[self.theTableView reloadData];
}


- (void)viewDidAppear:(BOOL)animated
{
	[theTableView flashScrollIndicators];
	[theTableView deselectRowAtIndexPath:[theTableView indexPathForSelectedRow] animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
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
			[self updateSelection:PublisherTypePublisher];
			break;
		case 1:
			[self updateSelection:PublisherTypeAuxilliaryPioneer];
			break;
		case 2:
			[self updateSelection:PublisherTypePioneer];
			break;
		case 3:
			[self updateSelection:PublisherTypeSpecialPioneer];
			break;
		case 4:
			[self updateSelection:PublisherTypeTravelingServant];
			break;
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if(delegate)
	{
		[delegate publisherTypeViewControllerDone:self];
	}

	[[self navigationController] popViewControllerAnimated:YES];
}

// UITableViewDataSource methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  
{
	return 5;
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
			return publisher;
		case 1:
			return auxiliaryPioneer;
		case 2:
			return pioneer;
		case 3:
			return specialPioneer;
		case 4:
			return travelingServant;
    }
	return nil;
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






