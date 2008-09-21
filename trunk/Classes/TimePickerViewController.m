//
//  TimePickerViewController.m
//  MyTime
//
//  Created by Brent Priddy on 8/11/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import "TimePickerViewController.h"
#import "Settings.h"

@implementation TimePickerViewController
@synthesize datePicker;
@synthesize timePicker;
@synthesize containerView;
@synthesize delegate;

#define AlternateLocalizedString(a, b) (a)

- (id) init
{
    return([self initWithDate:[NSDate date] minutes:0]);
}


- (id) initWithDate:(NSDate *)date minutes:(int)minutes
{
	if ([super init]) 
	{
		containerView = nil;
		timePicker = nil;
		datePicker = nil;
		delegate = nil;
		
		// set the title, and tab bar images from the dataSource
		// object.
        
		self.hidesBottomBarWhenPushed = YES;
		 
		self.title = NSLocalizedString(@"Select Time", @"Select Time Title for adding hours of field service to a particular day");

		self.datePicker = [[[UIDatePicker alloc] initWithFrame:CGRectZero] autorelease];
		datePicker.datePickerMode = UIDatePickerModeDate;
		datePicker.date = date;
		self.timePicker = [[[UIDatePicker alloc] initWithFrame:CGRectZero] autorelease];
		timePicker.datePickerMode = UIDatePickerModeCountDownTimer;
		timePicker.countDownDuration = minutes*60;
	}
	return self;
}

- (void)dealloc 
{
	self.containerView = nil;
	self.datePicker = nil;
	self.timePicker = nil;
	self.delegate = nil;

	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return(YES);
}

- (void)navigationControlDone:(id)sender 
{
	VERBOSE(NSLog(@"navigationControlDone:");)
	if(delegate)
	{
		[delegate timePickerViewControllerDone:self];
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

	timePicker.frame = pickerRect;
	timePicker.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
	timePicker.autoresizesSubviews = YES;
	[containerView addSubview: timePicker];

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

- (int)minutes
{
    return(timePicker.countDownDuration/60);
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