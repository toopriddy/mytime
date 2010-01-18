//
//  EmptyListView.m
//  MyTime
//
//  Created by Brent Priddy on 1/10/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import "EmptyListViewController.h"


@implementation EmptyListViewController
@synthesize mainLabel;
@synthesize subLabel;
@synthesize imageView;

- (void)dealloc 
{
	self.mainLabel = nil;
	self.subLabel = nil;
	self.imageView = nil;
	
    [super dealloc];
}


@end
