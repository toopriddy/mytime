//
//  CallsSortedByNameViewDataSource.m
//  MyTime
//
//  Created by Brent Priddy on 9/24/08.
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
#import "CallsSortedByNameViewDataSource.h"
#import "CallTableCell.h"
#import "PSLocalization.h"
#import "MTDisplayRule.h"


@implementation CallsSortedByNameViewDataSource


// return the callsSorter used by the navigation controller and tab bar item

#import "PSRemoveLocalizedString.h"
- (NSString *)unlocalizedName 
{
	return NSLocalizedString(@"Name Sorted", @"button bar title");
}
#import "PSAddLocalizedString.h"

- (NSString *)title
{
	return NSLocalizedString(@"Calls Sorted by Name", @"View title");
}

- (NSString *)tabBarImageName
{
	return @"people";
}

- (BOOL) useNameAsMainLabel
{
	return YES;
}
@end
