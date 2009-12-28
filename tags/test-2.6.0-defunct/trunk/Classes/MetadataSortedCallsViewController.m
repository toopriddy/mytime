//
//  MetadataSortedCallsViewController.m
//  MyTime
//
//  Created by Brent Priddy on 6/14/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//

#import "MetadataSortedCallsViewController.h"
#import "CallsSortedByFilterDataSource.h"
#import "Settings.h"
#import "MyTimeAppDelegate.h"

@implementation MetadataSortedCallsViewController
@synthesize picker = _picker;

- (void)metadataPickerViewControllerDone:(MetadataPickerViewController *)metadataPickerViewController
{
	CGRect frame = self.picker.view.frame;
	frame.origin.y = - frame.size.height;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.30];
	self.picker.view.frame = frame;
	[UIView commitAnimations];
	_myOverlay = NO;
	
	[_overlay.view removeFromSuperview];
	[_overlay release];
}

- (void)metadataPickerViewControllerChanged:(MetadataPickerViewController *)metadataPickerViewController
{
	CallsSortedByFilterDataSource *source = self.dataSource;
	source.sortedByMetadata = metadataPickerViewController.metadata;
	[self.tableView reloadData];
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithTitle:metadataPickerViewController.metadata
																style:UIBarButtonItemStyleBordered 
															   target:self 
															   action:@selector(changeMetadata)] autorelease];
	[self.navigationItem setLeftBarButtonItem:button];
}

- (void)overlayViewControllerDone:(OverlayViewController *)overlayViewController
{
	if(_myOverlay)
		[self metadataPickerViewControllerDone:nil];
	else
		[super overlayViewControllerDone:overlayViewController];
}

- (void)changeMetadata
{
	UIView *window = [UIApplication sharedApplication].keyWindow;
	//Add the overlay view.
	_overlay = [[OverlayViewController alloc] init];
	
	_myOverlay = YES;
	
	CGFloat yaxis = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y;
	CGFloat width = self.view.frame.size.width;
	CGFloat height = window.frame.size.height - yaxis;
	
	//Parameters x = origion on x-axis, y = origon on y-axis.
	CGRect frame = CGRectMake(0, yaxis, width, height);
	_overlay.view.frame = frame;	
	_overlay.view.backgroundColor = [UIColor blackColor];
	_overlay.view.alpha = 0.0;
	
	_overlay.delegate = self;
	
	[window addSubview:_overlay.view];
	
	
	CallsSortedByFilterDataSource *source = self.dataSource;
	self.picker.metadata = source.sortedByMetadata;
	
	frame = self.picker.view.frame;
	frame.origin.y = self.navigationController.navigationBar.frame.origin.y;
	// correct for 2.X software
	if(frame.origin.y == 0)
		frame.origin.y = 20;

	[self.picker.view removeFromSuperview];
	if(![self.picker.view isDescendantOfView:window])
		[window addSubview:self.picker.view];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.30];
	[self.picker.view setFrame:frame];
	_overlay.view.alpha = 0.5;
	[UIView commitAnimations];

}

- (void)loadView
{
	_myOverlay = NO;
	[super loadView];
	
	CallsSortedByFilterDataSource *source = self.dataSource;
	self.picker = [[MetadataPickerViewController alloc] initWithMetadata:source.sortedByMetadata];
	self.picker.delegate = self;
	[self.picker release];
	// hide the picker view above the screen
	CGRect frame = self.picker.view.frame;
	frame.origin.y = - frame.size.height;
	self.picker.view.frame = frame;
	
	// update the button in the nav bar
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithTitle:source.sortedByMetadata
																style:UIBarButtonItemStyleBordered 
															   target:self 
															   action:@selector(changeMetadata)] autorelease];
	[self.navigationItem setLeftBarButtonItem:button];
}

- (void)dealloc
{
	[_picker release];
	
	[super dealloc];
}
@end
