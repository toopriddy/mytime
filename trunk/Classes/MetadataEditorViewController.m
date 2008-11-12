//
//  MetadataEditorViewController.m
//  MyTime
//
//  Created by Brent Priddy on 8/15/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import "MetadataEditorViewController.h"
#import "Settings.h"

@interface UIPickerView (soundsEnabled)
- (void)setSoundsEnabled:(BOOL)fp8;
@end

@interface MetadataSaveAndDone : UIResponder <UITextFieldDelegate>
{
	MetadataEditorViewController *viewController;
}
@property (nonatomic,assign) MetadataEditorViewController *viewController;

- (id)initWithController:(MetadataEditorViewController *)theViewController;
@end

@implementation MetadataSaveAndDone

@synthesize viewController;

- (void)dealloc
{
	self.viewController = nil;
	[super dealloc];
}

- (id)initWithController:(MetadataEditorViewController *)theViewController;
{
	[super init];
	self.viewController = theViewController;
	return(self);
}

- (BOOL)becomeFirstResponder 
{
	[viewController navigationControlDone:nil];
	return NO;
}
@end


@interface MetadataEditorViewController ()
@property (nonatomic, retain) UITableViewTextFieldCell *textFieldCell;
@property (nonatomic, retain) UIDatePicker *datePicker;
@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, retain) UITableView *theTableView;

@end

@implementation MetadataEditorViewController
@synthesize textFieldCell = _textFieldCell;
@synthesize delegate = _delegate;
@synthesize datePicker = _datePicker;
@synthesize containerView = _containerView;
@synthesize theTableView = _theTableView;

- (id) initWithName:(NSString *)name type:(MetadataType)type data:(NSObject *)data value:(NSString *)value;
{
	if ([super init]) 
	{
		_type = type;
		
		switch(type)
		{
			case PHONE:
			{
				self.title = name;
				
				self.textFieldCell = [[[UITableViewTextFieldCell alloc] init] autorelease];
				[_textFieldCell.textField setKeyboardType:UIKeyboardTypePhonePad];
				_textFieldCell.textField.text = value;
				_textFieldCell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
				_firstResponder = _textFieldCell;
				_textFieldCell.nextKeyboardResponder = [[[MetadataSaveAndDone alloc] initWithController:self] autorelease];
				_textFieldCell.textField.returnKeyType = UIReturnKeyDone;
				break;
			}
			
			case EMAIL:
			{
				self.title = name;
				
				self.textFieldCell = [[[UITableViewTextFieldCell alloc] init] autorelease];
				[_textFieldCell.textField setKeyboardType:UIKeyboardTypeEmailAddress];
				_textFieldCell.textField.text = value;
				_textFieldCell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
				_textFieldCell.nextKeyboardResponder = [[[MetadataSaveAndDone alloc] initWithController:self] autorelease];
				_firstResponder = _textFieldCell;
				_textFieldCell.textField.returnKeyType = UIReturnKeyDone;
				break;
			}
		}
	}
	return self;
}

- (void)dealloc 
{
	self.containerView = nil;
	self.datePicker = nil;
	self.delegate = nil;

	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return(NO);
}

- (void)navigationControlDone:(id)sender 
{
	VERBOSE(NSLog(@"navigationControlDone:");)
	if(_delegate)
	{
		[_delegate metadataEditorViewControllerDone:self];
	}
	[[self navigationController] popViewControllerAnimated:YES];
}

- (void)setResponder
{
	[_textFieldCell.textField becomeFirstResponder];
}

- (void)loadView 
{
	// create a new table using the full application frame
	// we'll ask the datasource which type of table to use (plain or grouped)
	self.theTableView = [[[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] 
														  style:UITableViewStyleGrouped] autorelease];
	
	// set the autoresizing mask so that the table will always fill the view
	_theTableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	
	// set the tableview delegate to this object and the datasource to the datasource which has already been set
	_theTableView.delegate = self;
	_theTableView.dataSource = self;
	
	// set the tableview as the controller view
	self.view = self.theTableView;

	[self.theTableView reloadData];

	// add DONE button
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(navigationControlDone:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:NO];

	[self performSelector:@selector(setResponder) withObject:nil afterDelay:0.1];
}

-(void)viewWillAppear:(BOOL)animated
{
	// force the tableview to load
	[self.theTableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
	[_theTableView deselectRowAtIndexPath:[_theTableView indexPathForSelectedRow] animated:YES];
}


// UITableViewDataSource methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  
{
	return 1;
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
	
	return(_textFieldCell);
}


- (NSObject *)data
{
	switch(_type)
	{
		case PHONE:
		case EMAIL:
			return _textFieldCell.textField.text;
			break;
	}
	return nil;
}

- (NSString *)value
{
	switch(_type)
	{
		case PHONE:
		case EMAIL:
			return _textFieldCell.textField.text;
			break;
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






