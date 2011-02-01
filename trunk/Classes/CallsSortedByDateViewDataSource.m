//
//  CallsSortedByDateViewDataSource.m
//  MyTime
//
//  Created by Brent Priddy on 7/26/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "SortedCallsViewController.h"
#import "CallsSortedByDateViewDataSource.h"
#import "CallTableCell.h"
#import "PSLocalization.h"


@implementation CallsSortedByDateViewDataSource

- (NSString *)name 
{
	return NSLocalizedString(@"Date Sorted", @"button bar title");
}

- (NSString *)title
{
	return NSLocalizedString(@"Calls Sorted by Date", @"view title");
}

- (NSString *)tabBarImageName
{
	return @"time";
}

- (void)dealloc
{
	DEBUG(NSLog(@"%s: dealloc", __FILE__);)
	[super dealloc];
}

- (id)init
{
	[super initSortedBy:CALLS_SORTED_BY_DATE];
	return(self);
}
@end
