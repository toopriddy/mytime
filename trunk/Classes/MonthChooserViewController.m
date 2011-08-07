//
//  MonthChooserViewController.m
//  MyTime
//
//  Created by Brent Priddy on 10/22/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//
#import "MonthChooserViewController.h"
#import "PublicationViewController.h"
#import "UITableViewTextFieldCell.h"
#import "NotesViewController.h"
#import "UITableViewMultilineTextCell.h"
#import "MTUser.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "PSLocalization.h"

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
		self.title = NSLocalizedString(@"Email Report", @"Months to email Information title");
		self.hidesBottomBarWhenPushed = YES;
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
	MTUser *currentUser = [MTUser currentUser];
	if(isSmsAvaliable() && currentUser.sendReportUsingSmsValue)
	{
		_emailAddress.textField.text = [[MTUser currentUser] secretaryTelephoneNumber];
		_emailAddress.textField.keyboardType = UIKeyboardTypePhonePad;
		_emailAddress.textField.placeholder = NSLocalizedString(@"Secretary's Telephone", @"phone number for the congregation secretary");
		_emailAddress.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	}
	else
	{
		_emailAddress.textField.text = [[MTUser currentUser] secretaryEmailAddress];
		_emailAddress.textField.keyboardType = UIKeyboardTypeEmailAddress;
		_emailAddress.textField.placeholder = NSLocalizedString(@"Secretary's Email", @"email address for the congregation secretary");
		_emailAddress.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	}

	
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
	[super viewWillAppear:animated];
	// force the tableview to load
	[self.theTableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
	[theTableView deselectRowAtIndexPath:[theTableView indexPathForSelectedRow] animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[_emailAddress.textField resignFirstResponder];
}

- (void)notesViewControllerDone:(NotesViewController *)notesViewController
{
	[self.navigationController popToViewController:self animated:YES];
	MTUser *currentUser = [MTUser currentUser];
	currentUser.secretaryEmailNotes = notesViewController.textView.text;
	NSError *error = nil;
	if(![currentUser.managedObjectContext save:&error])
	{
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:self.navigationController error:error];
	}
		 
	[self.theTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    int section = [indexPath section];
    DEBUG(NSLog(@"tableRowSelected: tableRowSelected section=%d row=%d", section, row);)
	
	switch(section)
	{
		case 0:
		{
			switch(row)
			{
				case 1:
				{
					[_emailAddress.textField resignFirstResponder];
					// make the new call view 
					NotesViewController *p = [[[NotesViewController alloc] initWithNotes:[[MTUser currentUser] secretaryEmailNotes]] autorelease];

					p.delegate = self;

					[[self navigationController] pushViewController:p animated:YES];		
				}
			}
			break;
		}
		
		case 1:
		{
			[_emailAddress.textField resignFirstResponder];
			
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
			return 2;
		case 1:
			return [_months count];
		default:
			return 0;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int row = [indexPath row];
	int section = [indexPath section];
    VERBOSE(NSLog(@"tableView: heightForRowAtIndexPath: row=%d section=%d", row, section);)

	if(section == 0 && row == 1)
	{
		float height;
		height = [UITableViewMultilineTextCell heightForWidth:250 withText:[[MTUser currentUser] secretaryEmailNotes]];
		return(height);
	}
	if(row == -1)
		return(theTableView.sectionHeaderHeight);
	else
		return theTableView.rowHeight;
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
			switch(row)
			{
				case 0:
					return(self.emailAddress);
				case 1:
				{
					UITableViewMultilineTextCell *cell = (UITableViewMultilineTextCell *)[theTableView dequeueReusableCellWithIdentifier:@"NotesCell"];
					if(cell == nil)
					{
						cell = [[[UITableViewMultilineTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NotesCell"] autorelease];
					}
					NSString *notes = [[MTUser currentUser] secretaryEmailNotes];
					cell.selectionStyle = UITableViewCellSelectionStyleBlue;
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					if([notes length] == 0)
						[cell setText:NSLocalizedString(@"Add Notes", @"Return Visit Notes Placeholder text")];
					else
						[cell setText:notes];
					return cell;
				}
			}
		}
		
		case 1:
		{
			UITableViewCell *cell = (UITableViewCell *)[theTableView dequeueReusableCellWithIdentifier:@"typeCell"];
			if(cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"typeCell"] autorelease];
			}
			
			cell.textLabel.text = [_months objectAtIndex:row];
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






