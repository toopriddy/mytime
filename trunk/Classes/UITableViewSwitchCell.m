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

#import "UITableViewSwitchCell.h"

@implementation UITableViewSwitchCell
@synthesize booleanSwitch;
@synthesize otherTextLabel;
@synthesize delegate = _delegate;
@synthesize observeEditing;

- (void)dealloc
{
	self.booleanSwitch = nil;
	self.otherTextLabel = nil;
	
	[super dealloc];
}

- (IBAction)switchChanged
{
	if(self.delegate && [self.delegate respondsToSelector:@selector(uiTableViewSwitchCellChanged:)])
	{
		[self.delegate uiTableViewSwitchCellChanged:self];
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	[self bringSubviewToFront:self.booleanSwitch];
	
	if(self.observeEditing)
		self.booleanSwitch.enabled = self.editing;
}

@end
