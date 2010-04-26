//
//  OverlayViewController.m
//  MyTime
//
//  Created by Brent Priddy on 7/24/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//
#import "OverlayViewController.h"

@implementation OverlayViewController

@synthesize delegate;

- (id)init
{
	[super init];
	
	self.view = [[UIView alloc] init];
	[self.view release];
	
	return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	if(delegate && [delegate respondsToSelector:@selector(overlayViewControllerDone:)])
	{
		[delegate overlayViewControllerDone:self];
	}
}

@end
