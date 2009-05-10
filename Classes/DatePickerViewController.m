//
//  DatePickerViewController.m
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

#import "DatePickerViewController.h"
#import "Settings.h"

@interface UIPickerView (soundsEnabled)
- (void)setSoundsEnabled:(BOOL)fp8;
@end

@implementation DatePickerViewController
@synthesize datePicker;
@synthesize containerView;
@synthesize delegate;



- (id) init
{
    return([self initWithDate:[NSDate date]]);
}


- (id) initWithDate:(NSDate *)date
{
	if ([super init]) 
	{
		containerView = nil;
		datePicker = nil;
		delegate = nil;
		
		// set the title, and tab bar images from the dataSource
		// object.
        
//		self.hidesBottomBarWhenPushed = YES;
		 
		self.title = NSLocalizedString(@"Select Date", @"Title for the view where you Pick A Date");

		self.datePicker = [[[UIDatePicker alloc] initWithFrame:CGRectZero] autorelease];
		datePicker.datePickerMode = UIDatePickerModeDateAndTime;
		datePicker.date = date;
		NSArray *views = datePicker.subviews;
		UIPickerView *picker = (UIPickerView*)[views objectAtIndex:0];
		[picker setSoundsEnabled:NO];
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
	if(delegate)
	{
		[delegate datePickerViewControllerDone:self];
	}
	[[self navigationController] popViewControllerAnimated:YES];
}

- (void)loadView 
{
	// create a new table using the full application frame
	// we'll ask the datasource which type of table to use (plain or grouped)
	self.containerView = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
	
	// set the autoresizing mask so that the table will always fill the view
	containerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	
	// make a picker for the publications
	CGRect pickerRect = [containerView bounds];
	pickerRect.size.height = [datePicker sizeThatFits:CGSizeZero].height;
	
	datePicker.frame = pickerRect;
	datePicker.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
	datePicker.autoresizesSubviews = YES;
	[containerView addSubview: datePicker];

	pickerRect.origin.y += pickerRect.size.height;
	pickerRect.size.height = [containerView bounds].size.height - pickerRect.size.height;

	UIImageView *v = [[[UIImageView alloc] initWithFrame:pickerRect] autorelease];
	v.backgroundColor = [UIColor colorWithRed:40.0/256.0 green:42.0/256.0 blue:56.0/256.0 alpha:1.0];
	v.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	[containerView addSubview: v];

	self.view = containerView;
	
	// add DONE button
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(navigationControlDone:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:NO];
}

// date
- (NSDate *)date
{
    return(datePicker.date);
}


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