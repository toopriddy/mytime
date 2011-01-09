//
//  ReturnVisitTypeViewController.m
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

#import "ReturnVisitTypeViewController.h"
#import "MTReturnVisit.h"
#import "PSLocalization.h"

@interface ReturnVisitTypeViewController ()
@property (nonatomic,retain) UITableView *theTableView;
@property (nonatomic,retain) UITableViewCell *initialVisitCell;
@property (nonatomic,retain) UITableViewCell *returnVisitCell;
@property (nonatomic,retain) UITableViewCell *studyCell;
@property (nonatomic,retain) UITableViewCell *notAtHomeCell;
@property (nonatomic,retain) UITableViewCell *transferedInitialVisitCell;
@property (nonatomic,retain) UITableViewCell *transferedReturnVisitCell;
@property (nonatomic,retain) UITableViewCell *transferedStudyCell;
@property (nonatomic,retain) UITableViewCell *transferedNotAtHomeCell;
@end

@implementation ReturnVisitTypeViewController

@synthesize delegate;
@synthesize theTableView;
@synthesize type;
@synthesize initialVisitCell;
@synthesize returnVisitCell;
@synthesize studyCell;
@synthesize notAtHomeCell;
@synthesize transferedInitialVisitCell;
@synthesize transferedReturnVisitCell;
@synthesize transferedStudyCell;
@synthesize transferedNotAtHomeCell;


- (id) initWithType:(NSString *)callType isInitialVisit:(BOOL)isInitialVisitVar
{
	if ([super init]) 
	{
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

	self.initialVisitCell = nil;
    self.returnVisitCell = nil;
    self.studyCell = nil;
    self.notAtHomeCell = nil;
	self.transferedInitialVisitCell = nil;
    self.transferedReturnVisitCell = nil;
    self.transferedStudyCell = nil;
    self.transferedNotAtHomeCell = nil;

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
	UITableViewCell *unselected1 = initialVisitCell;
	UITableViewCell *unselected2 = returnVisitCell;
	UITableViewCell *unselected3 = studyCell;
	UITableViewCell *unselected4 = notAtHomeCell;
	UITableViewCell *unselected5 = transferedInitialVisitCell;
	UITableViewCell *unselected6 = transferedReturnVisitCell;
	UITableViewCell *unselected7 = transferedStudyCell;
	UITableViewCell *unselected8 = transferedNotAtHomeCell;
	
	if([newType isEqualToString:CallReturnVisitTypeInitialVisit])
	{
		selected = initialVisitCell;
		unselected1 = nil;
	}
	else if([newType isEqualToString:CallReturnVisitTypeReturnVisit])
	{
		selected = returnVisitCell;
		unselected2 = nil;
	}
	else if([newType isEqualToString:CallReturnVisitTypeStudy])
	{
		selected = studyCell;
		unselected3 = nil;
	}
	else if([newType isEqualToString:CallReturnVisitTypeNotAtHome])
	{
		selected = notAtHomeCell;
		unselected4 = nil;
	}
	else if([newType isEqualToString:CallReturnVisitTypeTransferedInitialVisit])
	{
		selected = transferedInitialVisitCell;
		unselected5 = nil;
	}
	else if([newType isEqualToString:CallReturnVisitTypeTransferedReturnVisit])
	{
		selected = transferedReturnVisitCell;
		unselected6 = nil;
	}
	else if([newType isEqualToString:CallReturnVisitTypeTransferedStudy])
	{
		selected = transferedStudyCell;
		unselected7 = nil;
	}
	else if([newType isEqualToString:CallReturnVisitTypeTransferedNotAtHome])
	{
		selected = transferedNotAtHomeCell;
		unselected8 = nil;
	}

	unselected1.accessoryType = UITableViewCellAccessoryNone;
	unselected2.accessoryType = UITableViewCellAccessoryNone;
	unselected3.accessoryType = UITableViewCellAccessoryNone;
	unselected4.accessoryType = UITableViewCellAccessoryNone;
	unselected5.accessoryType = UITableViewCellAccessoryNone;
	unselected6.accessoryType = UITableViewCellAccessoryNone;
	unselected7.accessoryType = UITableViewCellAccessoryNone;
	unselected8.accessoryType = UITableViewCellAccessoryNone;
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

	self.initialVisitCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"returnVisitCell1"] autorelease];
	initialVisitCell.textLabel.text = [[PSLocalization localizationBundle] localizedStringForKey:CallReturnVisitTypeInitialVisit value:CallReturnVisitTypeInitialVisit table:@""];
	initialVisitCell.accessoryType = UITableViewCellAccessoryCheckmark;
	initialVisitCell.selected = NO;
	
	self.returnVisitCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"returnVisitCell2"] autorelease];
	returnVisitCell.textLabel.text = [[PSLocalization localizationBundle] localizedStringForKey:CallReturnVisitTypeReturnVisit value:CallReturnVisitTypeReturnVisit table:@""];
	returnVisitCell.accessoryType = UITableViewCellAccessoryCheckmark;
	returnVisitCell.selected = NO;
	
	self.studyCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"returnVisitCell3"] autorelease];
	studyCell.textLabel.text = [[PSLocalization localizationBundle] localizedStringForKey:CallReturnVisitTypeStudy value:CallReturnVisitTypeStudy table:@""];
	studyCell.accessoryType = UITableViewCellAccessoryCheckmark;
	studyCell.selected = NO;
	
	self.notAtHomeCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"returnVisitCell4"] autorelease];
	notAtHomeCell.textLabel.text = [[PSLocalization localizationBundle] localizedStringForKey:CallReturnVisitTypeNotAtHome value:CallReturnVisitTypeNotAtHome table:@""];
	notAtHomeCell.accessoryType = UITableViewCellAccessoryCheckmark;
	notAtHomeCell.selected = NO;

	self.transferedInitialVisitCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"returnVisitCell5"] autorelease];
	transferedReturnVisitCell.textLabel.text = [[PSLocalization localizationBundle] localizedStringForKey:CallReturnVisitTypeTransferedInitialVisit value:CallReturnVisitTypeTransferedInitialVisit table:@""];
	transferedReturnVisitCell.accessoryType = UITableViewCellAccessoryCheckmark;
	transferedReturnVisitCell.selected = NO;
	
	self.transferedReturnVisitCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"returnVisitCell6"] autorelease];
	transferedReturnVisitCell.textLabel.text = [[PSLocalization localizationBundle] localizedStringForKey:CallReturnVisitTypeTransferedReturnVisit value:CallReturnVisitTypeTransferedReturnVisit table:@""];
	transferedReturnVisitCell.accessoryType = UITableViewCellAccessoryCheckmark;
	transferedReturnVisitCell.selected = NO;
	
	self.transferedStudyCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"returnVisitCell7"] autorelease];
	transferedStudyCell.textLabel.text = [[PSLocalization localizationBundle] localizedStringForKey:CallReturnVisitTypeTransferedStudy value:CallReturnVisitTypeTransferedStudy table:@""];
	transferedStudyCell.accessoryType = UITableViewCellAccessoryCheckmark;
	transferedStudyCell.selected = NO;

	self.transferedNotAtHomeCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"returnVisitCell8"] autorelease];
	transferedNotAtHomeCell.textLabel.text = [[PSLocalization localizationBundle] localizedStringForKey:CallReturnVisitTypeTransferedNotAtHome value:CallReturnVisitTypeTransferedNotAtHome table:@""];
	transferedNotAtHomeCell.accessoryType = UITableViewCellAccessoryCheckmark;
	transferedNotAtHomeCell.selected = NO;

	//make one be selected
	[self updateSelection:self.type];

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
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    int section = [indexPath section];
    DEBUG(NSLog(@"tableRowSelected: tableRowSelected section=%d row=%d", section, row);)
	switch(section)
	{
		case 0:
			switch(row)
			{
				case 0:
					[self updateSelection:CallReturnVisitTypeInitialVisit];
					break;
				case 1:
					[self updateSelection:CallReturnVisitTypeReturnVisit];
					break;
				case 2:
					[self updateSelection:CallReturnVisitTypeStudy];
					break;
				case 3:
					[self updateSelection:CallReturnVisitTypeNotAtHome];
					break;
			}
			break;
		case 1:
			switch(row)
			{
				case 0:
					[self updateSelection:CallReturnVisitTypeTransferedInitialVisit];
					break;
				case 1:
					[self updateSelection:CallReturnVisitTypeTransferedReturnVisit];
					break;
				case 2:
					[self updateSelection:CallReturnVisitTypeTransferedStudy];
					break;
				case 3:
					[self updateSelection:CallReturnVisitTypeTransferedNotAtHome];
					break;
			}
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
	return 2;
}


- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section 
{
	return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if(section == 1)
	{
		return NSLocalizedString(@"When Transfered To You:", @"This is the section title for transferred calls in the view that allows you to select a visit type for your call");
	}
	
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int row = [indexPath row];
	int section = [indexPath section];
    VERBOSE(NSLog(@"tableView: cellForRow:%d inSection:%d", row, section);)
    switch(section)
    {
		case 0:
			switch(row)
			{
				case 0:
					return(initialVisitCell);
				case 1:
					return(returnVisitCell);
				case 2:
					return(studyCell);
				case 3:
					return(notAtHomeCell);
			}
			break;
		case 1:
			switch(row)
			{
				case 0:
					return(transferedInitialVisitCell);
				case 1:
					return(transferedReturnVisitCell);
				case 2:
					return(transferedStudyCell);
				case 3:
					return(transferedNotAtHomeCell);
			}
			break;
	}
	return(nil);
}
@end
