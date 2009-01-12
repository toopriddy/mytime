//
//  MetadataCustomViewController.m
//  MyTime
//
//  Created by Brent Priddy on 10/22/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//

#import "MetadataCustomViewController.h"
#import "PublicationViewController.h"
#import "Settings.h"
#import "UITableViewTextFieldCell.h"

static MetadataInformation commonInformation[] = {
	{AlternateLocalizedString(@"Email", @"Call Metadata"), EMAIL}
,	{AlternateLocalizedString(@"Phone", @"Call Metadata"), PHONE}
,	{AlternateLocalizedString(@"String", @"Call Metadata"), STRING}
,	{AlternateLocalizedString(@"Notes", @"Call Metadata"), NOTES}
,	{AlternateLocalizedString(@"Number", @"Call Metadata"), NUMBER}
,	{AlternateLocalizedString(@"Date/Time", @"Call Metadata"), DATE}
,	{AlternateLocalizedString(@"URL", @"Call Metadata"), URL}
};

#define ARRAY_SIZE(a) (sizeof(a)/sizeof(a[0]))

@interface MetadataCustomViewController ()
@property (nonatomic,retain) UITableView *theTableView;
@end

@implementation MetadataCustomViewController

@synthesize delegate;
@synthesize theTableView;
@synthesize name = _name;

- (id) init
{
	if ([super init]) 
	{
		_name = nil;

		_selected = -1;
		// set the title, and tab bar images from the dataSource
		self.title = NSLocalizedString(@"Custom", @"Title for field in the Additional Information for the user to create their own additional information field");
	}
	return self;
}

- (void)dealloc 
{
	self.theTableView.delegate = nil;
	self.theTableView.dataSource = nil;

	self.theTableView = nil;
	self.name = nil;

	self.delegate = nil;
	
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return(YES);
}

- (void)navigationControlDone:(id)sender
{
	if(delegate && _selected >= 0)
	{
		[delegate metadataCustomViewControllerDone:self];
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

	self.name = [[[UITableViewTextFieldCell alloc] init] autorelease];
	_name.delegate = self;
	_name.textField.keyboardType = UIKeyboardTypeEmailAddress;
	_name.textField.placeholder = NSLocalizedString(@"Enter Name Here", @"Custom Information Placeholder before the user enters in what they want to call this field, like 'Son's name' or whatever");
	_name.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	
	// add DONE button
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(navigationControlDone:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:NO];

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
		[_name.textField resignFirstResponder];
		
		if(_selected >= 0 && _selected != row)
		{
			[[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_selected inSection:section]] setAccessoryType:UITableViewCellAccessoryNone];
		}
		
		_selected = row;
		
		self.navigationItem.rightBarButtonItem.enabled = _selected >= 0 && _name.textField.text.length;
		
		[[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:(_selected == row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone)];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (BOOL)tableViewTextFieldCell:(UITableViewTextFieldCell *)cell shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	int length = _name.textField.text.length;
	if(string.length == 0)
	{
		length -= range.length;
	}
	else
	{
		length -= range.length + string.length;
	}
	self.navigationItem.rightBarButtonItem.enabled = _selected >= 0 && length;
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
			return ARRAY_SIZE(commonInformation);
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
			return(self.name);
		}
		
		case 1:
		{
			UITableViewCell *cell = (UITableViewCell *)[theTableView dequeueReusableCellWithIdentifier:@"typeCell"];
			if(cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"typeCell"] autorelease];
			}
			
			[cell setText:[[NSBundle mainBundle] localizedStringForKey:commonInformation[row].name value:commonInformation[row].name table:@""]];
			cell.accessoryType = _selected == row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
			
			return cell;
		}
		default:
			return nil;
	}
}

- (MetadataType)type
{
	int index = _selected >= 0 ? _selected : 0;
	return commonInformation[index].type;
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






