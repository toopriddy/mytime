//
//  CallsSortedByStudyViewDataSource.m
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
#import "CallsSortedByFilterDataSource.h"
#import "CallTableCell.h"
#import "Settings.h"
#import "PSLocalization.h"
#import "MetadataViewController.h"
#import "MTDisplayRule.h"

@implementation CallsSortedByFilterDataSource

#import "PSRemoveLocalizedString.h"
- (NSString *)unlocalizedName 
{
	return NSLocalizedString(@"Sorted By ...", @"View title");
}
#import "PSAddLocalizedString.h"

- (NSString *)title
{
	return NSLocalizedString(@"Sorted By ...", @"View title");
}

- (BOOL) showAddNewCall
{
	return YES;
}

- (BOOL) useNameAsMainLabel
{
	return NO;
}

- (NSString *)tabBarImageName 
{
	return @"category";
}

- (NSArray *)sectionIndexTitles
{
	NSString *it = [[MTDisplayRule currentDisplayRule] sectionIndexPath];
	if([it isEqualToString:@"dateSortedSectionIndex"])
	{
		return [MTCall dateSortedSectionIndexTitles];
	}
	return nil;
}

- (NSString *)sectionNameForIndex:(int)index
{
	NSString *it = [[MTDisplayRule currentDisplayRule] sectionIndexPath];
	if([it isEqualToString:@"dateSortedSectionIndex"])
	{
		return [MTCall stringForDateSortedIndex:index];
	}
	return nil;
}

- (NSString *)sectionNameKeyPath
{
	return [[MTDisplayRule currentDisplayRule] sectionIndexPath];
}

- (NSArray *)coreDataSortDescriptors
{
	return [[MTDisplayRule currentDisplayRule] coreDataSortDescriptors];
}

- (NSArray *)allSortDescriptors
{
	return [[MTDisplayRule currentDisplayRule] allSortDescriptors];
}


@end
