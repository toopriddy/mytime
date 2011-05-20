//
//  UITableViewSeitchCell.m
//  MyTime
//
//  Created by Brent Priddy on 7/6/09.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "UITableViewSegmentedControlCell.h"

@implementation UITableViewSegmentedControlCell
@synthesize segmentedControl;
@synthesize otherTextLabel;
@synthesize delegate = _delegate;
@synthesize observeEditing;
@synthesize segmentedControlTitles;
@synthesize selectedSegmentIndex = selectedSegmentIndex_;

+ (float)heightForRow
{
	return 60;
}

- (void)dealloc
{
	self.segmentedControl = nil;
	self.otherTextLabel = nil;
	
	[super dealloc];
}

- (IBAction)segmentedControlChanged
{
	self.selectedSegmentIndex = self.segmentedControl.selectedSegmentIndex;
	if(self.delegate && [self.delegate respondsToSelector:@selector(uiTableViewSegmentedControllCellChanged:)])
	{
		[self.delegate uiTableViewSegmentedControllCellChanged:self];
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	[self bringSubviewToFront:self.segmentedControl];
	
	if(self.segmentedControl)
		self.segmentedControl.enabled = self.editing;
	
	int i = 0;
	for(NSString *name in self.segmentedControlTitles)
	{ 
		[self.segmentedControl setTitle:name forSegmentAtIndex:i++];
	}
	self.segmentedControl.selectedSegmentIndex = self.selectedSegmentIndex;
}

- (void)setSelectedSegmentIndex:(int)selectedIndex
{
	selectedSegmentIndex_ = selectedIndex;
	self.segmentedControl.selectedSegmentIndex = self.selectedSegmentIndex;
}

@end
