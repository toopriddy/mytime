//
//  NotesViewController.m
//  MyTime
//
//  Created by Brent Priddy on 9/20/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//

#import "NotesViewController.h"
#import "Settings.h"

@implementation NotesViewController
@synthesize textView;
@synthesize containerView;
@synthesize delegate;



- (id) initWithNotes:(NSString *)notes
{
	if ([super init]) 
	{
		// set the title, and tab bar images from the dataSource
		// object.
        
//		self.hidesBottomBarWhenPushed = YES;
		 
		self.title = NSLocalizedString(@"Visit Notes", @"Title for the view where you write notes for a call");
		
		self.textView = [[[UITextView alloc] initWithFrame:CGRectZero] autorelease];
		textView.text = notes;
	}
	return self;
}

- (void)dealloc 
{
	self.containerView = nil;
	self.textView = nil;
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
		[delegate notesViewControllerDone:self];
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
	CGRect textViewRect = [containerView bounds];
	if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
	{
		textViewRect.size.height -= 160;
	}
	else
	{
		textViewRect.size.height = 200;
	}
	textView.frame = textViewRect;
	[containerView setBackgroundColor:[UIColor whiteColor]];
	[containerView addSubview:textView];
	self.view = containerView;
	
	// add DONE button
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(navigationControlDone:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:NO];
	self.navigationItem.hidesBackButton = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
	[textView becomeFirstResponder];
	[super viewWillAppear:animated];
}

// date
- (NSString *)notes
{
    return(textView.text);
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