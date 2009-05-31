//
//  MetadataEditorViewController.m
//  MyTime
//
//  Created by Brent Priddy on 8/15/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "MetadataEditorViewController.h"
#import "Settings.h"
#import "PSLocalization.h"

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
@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, retain) UITableView *theTableView;
@property (nonatomic, assign) UIDatePicker *datePicker;
@property (nonatomic, assign) NumberedPickerView *numberPicker;
@property (nonatomic, assign) UITextView *textView;

@end

@implementation MetadataEditorViewController
@synthesize textFieldCell = _textFieldCell;
@synthesize delegate = _delegate;
@synthesize datePicker = _datePicker;
@synthesize numberPicker = _numberPicker;
@synthesize containerView = _containerView;
@synthesize theTableView = _theTableView;
@synthesize textView = _textView;

- (id) initWithName:(NSString *)name type:(MetadataType)type data:(NSObject *)data value:(NSString *)value;
{
	if ([super init]) 
	{
		_type = type;
		_firstResponder = nil;
		
		switch(type)
		{
			case PHONE:
			{
				self.title = name;
				
				self.textFieldCell = [[[UITableViewTextFieldCell alloc] init] autorelease];
				[_textFieldCell.textField setKeyboardType:UIKeyboardTypePhonePad];
				_textFieldCell.textField.text = value;
				_textFieldCell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
				_textFieldCell.nextKeyboardResponder = [[[MetadataSaveAndDone alloc] initWithController:self] autorelease];
				_textFieldCell.textField.returnKeyType = UIReturnKeyDone;
				_firstResponder = _textFieldCell.textField;
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
				_textFieldCell.textField.returnKeyType = UIReturnKeyDone;
				_firstResponder = _textFieldCell.textField;
				break;
			}

			case URL:
			{
				self.title = name;
				
				self.textFieldCell = [[[UITableViewTextFieldCell alloc] init] autorelease];
				[_textFieldCell.textField setKeyboardType:UIKeyboardTypeURL];
				_textFieldCell.textField.text = value;
				_textFieldCell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
				_textFieldCell.nextKeyboardResponder = [[[MetadataSaveAndDone alloc] initWithController:self] autorelease];
				_textFieldCell.textField.returnKeyType = UIReturnKeyDone;
				_firstResponder = _textFieldCell.textField;
				break;
			}

			case STRING:
			{
				self.title = name;
				
				self.textFieldCell = [[[UITableViewTextFieldCell alloc] init] autorelease];
				[_textFieldCell.textField setKeyboardType:UIKeyboardTypeDefault];
				_textFieldCell.textField.text = value;
				_textFieldCell.textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
				_textFieldCell.nextKeyboardResponder = [[[MetadataSaveAndDone alloc] initWithController:self] autorelease];
				_firstResponder = _textFieldCell;
				_textFieldCell.textField.returnKeyType = UIReturnKeyDone;
				_firstResponder = _textFieldCell.textField;
				break;
			}
			case NOTES:
			{
				self.title = name;
				
				self.textView = [[[UITextView alloc] init] autorelease];
				[_textView setKeyboardType:UIKeyboardTypeDefault];
				_textView.text = value;
				_firstResponder = _textView;
				break;
			}
			case NUMBER:
			{
				self.title = name;
				self.numberPicker = [[NumberedPickerView alloc] initWithFrame:CGRectZero
																		  min:0
																		  max:1000
																	   number:[(NSNumber *)data intValue]
																singularTitle:name
																		title:name];
				break;
			}
			case DATE:
			{
				self.title = name;
				self.datePicker = [[[UIDatePicker alloc] initWithFrame:CGRectZero] autorelease];
				_datePicker.datePickerMode = UIDatePickerModeDateAndTime;
				_datePicker.date = (NSDate *)data;
				{
					NSArray *views = _datePicker.subviews;
					UIPickerView *picker = (UIPickerView*)[views objectAtIndex:0];
					[picker setSoundsEnabled:NO];
				}
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
	if(_firstResponder)
		[_firstResponder becomeFirstResponder];
}

- (void)loadView 
{
	switch(_type)
	{
		case NUMBER:
		case DATE:
		{
			// create a new table using the full application frame
			// we'll ask the datasource which type of table to use (plain or grouped)
			self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
			
			// set the autoresizing mask so that the table will always fill the view
			self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
			
			// make a picker for the publications
			CGRect pickerRect = [self.view bounds];
			if(_type == NUMBER)
			{
				pickerRect.size.height = [_numberPicker sizeThatFits:CGSizeZero].height;
				
				_numberPicker.frame = pickerRect;
				_numberPicker.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
				_numberPicker.autoresizesSubviews = YES;
				[self.view addSubview:_numberPicker];
			}
			else
			{
				pickerRect.size.height = [_datePicker sizeThatFits:CGSizeZero].height;
				
				_datePicker.frame = pickerRect;
				_datePicker.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
				_datePicker.autoresizesSubviews = YES;
				[self.view addSubview:_datePicker];
			}
			pickerRect.origin.y += pickerRect.size.height;
			pickerRect.size.height = [self.view bounds].size.height - pickerRect.size.height;

			UIImageView *v = [[[UIImageView alloc] initWithFrame:pickerRect] autorelease];
			v.backgroundColor = [UIColor colorWithRed:40.0/256.0 green:42.0/256.0 blue:56.0/256.0 alpha:1.0];
			v.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
			[self.view addSubview: v];
			break;
		}
		case NOTES:
		{
			// create a new table using the full application frame
			// we'll ask the datasource which type of table to use (plain or grouped)
			self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
			// set the autoresizing mask so that the table will always fill the view
			self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
			
			// make a picker for the publications
			CGRect textViewRect = [self.view bounds];
			if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
			{
				textViewRect.size.height -= 160;
			}
			else
			{
				textViewRect.size.height = 200;
			}
			_textView.frame = textViewRect;
			[self.view setBackgroundColor:[UIColor whiteColor]];
			[self.view addSubview:_textView];
			break;
		}
		default:
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
		}
	}
	
	// add DONE button
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(navigationControlDone:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:NO];
	[self performSelector:@selector(setResponder) withObject:nil afterDelay:0.1];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	// force the tableview to load
	[self.theTableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
	[_theTableView deselectRowAtIndexPath:[_theTableView indexPathForSelectedRow] animated:YES];
	[_theTableView flashScrollIndicators];
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
		case URL:
		case STRING:
			return _textFieldCell.textField.text;
		case NOTES:
			return _textView.text;
		case DATE:
			return _datePicker.date;
		case NUMBER:
			return [NSNumber numberWithInt:_numberPicker.number];
	}
	return nil;
}

- (NSString *)value
{
	switch(_type)
	{
		case PHONE:
		case EMAIL:
		case URL:
		case STRING:
			return _textFieldCell.textField.text;
		case NOTES:
			return _textView.text;
		case DATE:
		{
			NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
			[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
			if([[[NSLocale currentLocale] localeIdentifier] isEqualToString:@"en_GB"])
			{
				[dateFormatter setDateFormat:@"EEE, d/M/yyy h:mma"];
			}
			else
			{
				[dateFormatter setDateFormat:NSLocalizedString(@"EEE, M/d/yyy h:mma", @"localized date string string using http://unicode.org/reports/tr35/tr35-4.html#Date_Format_Patterns as a guide to how to format the date")];
			}
			NSDate *date = _datePicker.date;
			return [NSString stringWithString:[dateFormatter stringFromDate:date]];			
		}
		case NUMBER:
			return [NSString stringWithFormat:@"%d", _numberPicker.number];
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






