//
//  PublicationViewController.m
//  MyTime
//
//  Created by Brent Priddy on 8/9/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import "PublicationViewController.h"
#import "Settings.h"

@implementation PublicationViewController
@synthesize publicationPicker;
@synthesize countPicker;
@synthesize containerView;
@synthesize delegate;

#define AlternateLocalizedString(a, b) (a)

- (id) init
{
    return([self initShowingCount:NO]);
}


- (id) initShowingCount:(BOOL)doShowCount
{
    // initalize the data to the current date
	NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit) fromDate:[NSDate date]];
    // set the default publication to be the watchtower this month and year
	int month = [dateComponents month];
	int year = [dateComponents year];
    int day = 1;

    return([self initWithPublication:[PublicationPickerView watchtower] year:year month:month day:day showCount:doShowCount number:0]);
}

// initialize this view given the curent configuration
- (id) initWithPublication: (NSString *)publication year: (int)year month: (int)month day: (int)day
{
    return([self initWithPublication:publication year:year month:month day:day showCount:NO number:0]);
}


- (id) initWithPublication: (NSString *)publication year: (int)year month: (int)month day: (int)day showCount:(BOOL)doShowCount number:(int)number
{
	if ([super init]) 
	{
		showCount = doShowCount;
		containerView = nil;
		publicationPicker = nil;
		countPicker = nil;
		delegate = nil;
		
		// set the title, and tab bar images from the dataSource
		// object. 
		self.title = NSLocalizedString(@"Select Publication", @"'Select Publication' Publication Picker title");
		self.tabBarItem.image = [UIImage imageNamed:@"statistics.png"];
//		self.hidesBottomBarWhenPushed = YES;
		 

		self.publicationPicker = [[[PublicationPickerView alloc] initWithFrame:CGRectZero publication:publication year:year month:month day:day] autorelease];
		
		if(showCount)
		{
			self.countPicker = [[NumberedPickerView alloc] initWithFrame:CGRectZero
																	 min:1
																	 max:200
																  number:number
														   singularTitle:NSLocalizedString(@"Publication", @"singular 'Publication' label for Number Picker; this is the label that is beside the number in the picker")
																   title:NSLocalizedString(@"Publications", @"'Publications' label for Number Picker; this is the label that is beside the number in the picker")];
		}
	}
	return self;
}

- (void)dealloc 
{
	self.containerView = nil;
	self.publicationPicker = nil;
	self.countPicker = nil;
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
		[delegate publicationViewControllerDone:self];
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
	pickerRect.size.height = [publicationPicker sizeThatFits:CGSizeZero].height;
	
	publicationPicker.frame = pickerRect;
	publicationPicker.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
	publicationPicker.autoresizesSubviews = YES;
	[containerView addSubview: publicationPicker];

	pickerRect.origin.y += pickerRect.size.height;
	pickerRect.size.height = [containerView bounds].size.height - pickerRect.size.height;


	if(showCount)
	{
#if 0
#define LABEL_HEIGHT 20.0			
		UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, pickerRect.origin.y, pickerRect.size.width, LABEL_HEIGHT)] autorelease];
		label.backgroundColor = [UIColor colorWithRed:163.0/256.0 green:164.0/256.0 blue:171.0/256.0 alpha:1.0];
		label.textColor = [UIColor whiteColor];
		[containerView addSubview:label];
		[label setText:NSLocalizedString(@"Number Placed:", @"Number Placed label for the Number Picker for the number of publications placed")];

		pickerRect.origin.y += LABEL_HEIGHT;

		pickerRect.size.height = [countPicker sizeThatFits:CGSizeZero].height;
		countPicker.frame = pickerRect;
#else		
		pickerRect.size.height = [countPicker sizeThatFits:CGSizeZero].height;
		countPicker.frame = pickerRect;
#endif
		countPicker.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
		countPicker.autoresizesSubviews = YES;
		[containerView addSubview: countPicker];
	}
	else
	{
		UIImageView *v = [[[UIImageView alloc] initWithFrame:pickerRect] autorelease];
		v.backgroundColor = [UIColor colorWithRed:40.0/256.0 green:42.0/256.0 blue:56.0/256.0 alpha:1.0];
		v.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
		[containerView addSubview: v];
	}

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
	
	if(countPicker)
		return([countPicker number]);
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


