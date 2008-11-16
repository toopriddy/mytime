//
//  MonthChooserViewController.m
//  MyTime
//
//  Created by Brent Priddy on 10/22/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import "MonthChooserViewController.h"
#import "PublicationViewController.h"
#import "Settings.h"
#import "UITableViewTextFieldCell.h"

@interface MonthChooserViewController ()
@property (nonatomic,retain) UITableView *theTableView;
@end

@implementation MonthChooserViewController

@synthesize delegate;
@synthesize theTableView;
@synthesize months = _months;
@synthesize selected = _selected;
@synthesize emailAddress = _emailAddress;

- (id) initWithMonths:(NSArray *)months
{
	if ([super init]) 
	{
		_countSelected = 0;
		_emailAddress = nil;
		
		NSString *month;
		self.months = months;
		self.selected = [NSMutableArray arrayWithCapacity:[months count]];
		for(month in months)
		{
			[_selected addObject:[NSNumber numberWithBool:NO]];
		}
		// set the title, and tab bar images from the dataSource
		self.title = NSLocalizedString(@"Email Statistics", @"Months to email Information title");
	}
	return self;
}

- (void)dealloc 
{
	self.theTableView.delegate = nil;
	self.theTableView.dataSource = nil;

	self.theTableView = nil;
	self.months = nil;
	self.selected = nil;
	self.emailAddress = nil;

	self.delegate = nil;
	
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return(YES);
}

- (void)navigationControlEmail:(id)sender
{
	if(delegate && _selected)
	{
		[delegate monthChooserViewControllerSendEmail:self];
	}
	[[self navigationController] popViewControllerAnimated:YES];
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

	self.emailAddress = [[[UITableViewTextFieldCell alloc] init] autorelease];
	_emailAddress.delegate = self;
	_emailAddress.textField.text = [[[Settings sharedInstance] settings] objectForKey:SettingsSecretaryEmailAddress];
	_emailAddress.textField.placeholder = NSLocalizedString(@"Secretary's email address", @"email address for the congregation secretary");
	_emailAddress.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	
	// add + button
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", @"Send button like the send button in the email program, to send your field service activity report to the congregation secretary") 
	                                                            style:UIBarButtonItemStyleDone
															   target:self
															   action:@selector(navigationControlEmail:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:NO];
	self.navigationItem.rightBarButtonItem.enabled = NO;
	// set the tableview as the controller view
	self.view = self.theTableView;

	[self.theTableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
	// force the tableview to load
	[self.theTableView reloadData];
	
}

-(void)viewDidAppear:(BOOL)animated
{
	[theTableView deselectRowAtIndexPath:[theTableView indexPathForSelectedRow] animated:YES];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    int section = [indexPath section];
    DEBUG(NSLog(@"tableRowSelected: tableRowSelected section=%d row=%d", section, row);)
	
	if(section == 1)
	{
		BOOL value = [[_selected objectAtIndex:row] boolValue];
		if(value)
			_countSelected++;
		else
			_countSelected--;
		
		self.navigationItem.rightBarButtonItem.enabled = _countSelected && _emailAddress.textField.text.length;

		[_selected replaceObjectAtIndex:row withObject:[NSNumber numberWithBool:!value]];
		
		[[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:[[_selected objectAtIndex:row] boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}
- (BOOL)tableViewTextFieldCell:(UITableViewTextFieldCell *)cell shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	int length = _emailAddress.textField.text.length;
	if(string.length == 0)
	{
		length -= range.length;
	}
	else
	{
		length -= range.length + string.length;
	}
	self.navigationItem.rightBarButtonItem.enabled = _countSelected && length;
	return YES;
}


// UITableViewDataSource methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  
{
	return 2;
}


- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section 
{
	switch(section)
	{
		case 0:
			return 1;
		case 1:
			return [_months count];
		default:
			return 0;
	}
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int row = [indexPath row];
	int section = [indexPath section];
    VERBOSE(NSLog(@"tableView: cellForRow:%d inSection:%d", row, section);)
	
	switch(section)
	{
		case 0:
		{
			return(self.emailAddress);
		}
		
		case 1:
		{
			UITableViewCell *cell = (UITableViewCell *)[theTableView dequeueReusableCellWithIdentifier:@"typeCell"];
			if(cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"typeCell"] autorelease];
			}
			
			[cell setText:[_months objectAtIndex:row]];
			cell.accessoryType = [[_selected objectAtIndex:row] boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
			
			return cell;
		}
		default:
			return nil;
	}
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






