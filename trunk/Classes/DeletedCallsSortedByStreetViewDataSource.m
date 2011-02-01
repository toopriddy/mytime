//
//  DeletedCallsSortedByStreetViewDataSource.m
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

#import "SortedCallsViewController.h"
#import "DeletedCallsSortedByStreetViewDataSource.h"
#import "CallTableCell.h"
#import "PSLocalization.h"


@implementation DeletedCallsSortedByStreetViewDataSource



// ElementsDataSourceProtocol methods

// return the callsSorter used by the navigation controller and tab bar item

- (NSString *)name 
{
	return NSLocalizedString(@"Deleted Calls", @"Deleted calls view button title");
}

- (NSString *)title
{
	return NSLocalizedString(@"Deleted Calls Sorted by Street", @"view title");
}

- (NSString *)tabBarImageName
{
	return @"deletedCalls";
}

- (void)dealloc
{
	DEBUG(NSLog(@"%s: dealloc", __FILE__);)
	[super dealloc];
}

- (id)init
{
	[super initSortedBy:CALLS_SORTED_BY_DELETED withMetadata:nil];
	return(self);
}

- (BOOL) showAddNewCall
{
	return NO;
}
@end
