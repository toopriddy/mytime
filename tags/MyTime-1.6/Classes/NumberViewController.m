//
//  PublicationViewController.m
//  MyTime
//
//  Created by Brent Priddy on 8/9/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import "NumberViewController.h"
#import "Settings.h"

@implementation NumberViewController
@synthesize numberPicker;
@synthesize containerView;
@synthesize delegate;



- (id) initWithTitle:(NSString *)title singularLabel:(NSString *)singularLabel label:(NSString *)label number:(int)number min:(int)min max:(int)max;
{
	if ([super init]) 
	{
		containerView = nil;
		numberPicker = nil;
		delegate = nil;
		
		// set the title, and tab bar images from the dataSource
		// object. 
		self.title = title;

		self.numberPicker = [[NumberedPickerView alloc] initWithFrame:CGRectZero
																  min:min
																  max:max
															   number:number
														singularTitle:singularLabel
															    title:label];
	}
	return self;
}

- (void)dealloc 
{
	self.containerView = nil;
	self.numberPicker = nil;
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
		[delegate numberViewControllerDone:self];
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
	pickerRect.size.height = [numberPicker sizeThatFits:CGSizeZero].height;
	
	numberPicker.frame = pickerRect;
	numberPicker.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
	numberPicker.autoresizesSubviews = YES;
	[containerView addSubview: numberPicker];

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


- (int)count
{
    VERY_VERBOSE(NSLog(@"PublicationView count");)
	
	if(numberPicker)
		return([numberPicker number]);
	else
		return(0);
}










//
//
// UITableViewDelegate methods
//
//

// NONE

- (BOOL)respondsToSelector:(SEL)selector
{
	BOOL ret = [super respondsToSelector:selector];
    VERY_VERBOSE(NSLog(@"%s respondsToSelector: %s ? %s", __FILE__, selector, ret ? "YES" : "NO");)
    return ret;
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


