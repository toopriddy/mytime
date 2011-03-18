//
//  BaseSortedCallsDataSource.m
//  MyTime
//
//  Created by Brent Priddy on 8/13/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "BaseSortedCallsDataSource.h"
#import "SortedCallsViewController.h"
#import "CallTableCell.h"
#import "MTCall.h"
#import "MTUser.h"
#import "MTDisplayRule.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "PSLocalization.h"

@interface BaseSortedCallsDataSource ()
@end

@implementation BaseSortedCallsDataSource
- (void)dealloc
{
	[super dealloc];
}

- (UITableViewStyle)tableViewStyle 
{
	return UITableViewStylePlain;
};

- (BOOL)showDisclosureIcon
{
	return NO;
}

- (BOOL) showAddNewCall
{
	return YES;
}

- (BOOL) useNameAsMainLabel
{
	return NO;
}

- (NSPredicate *)predicate
{
	MTUser *currentUser = [MTUser currentUser];
	return [NSPredicate predicateWithFormat:@"user == %@ && deletedCall == NO", currentUser];
#warning fix me to use the predicate of the MTDisplayRule
	//	return [[MTDisplayRule displayRuleForInternalName:[self unlocalizedName]] sectionIndexPath];
}

- (NSString *)name 
{
	NSString *name = [self unlocalizedName];
	return [[PSLocalization localizationBundle] localizedStringForKey:name value:name table:@""];
}

- (NSString *)unlocalizedName
{
	return @"Set me!";
}

- (NSString *)title
{
	return @"Set me!";
}

- (NSString *)tabBarImageName
{
	return @"time";
}

- (NSArray *)sectionIndexTitles
{
	NSString *it = [[MTDisplayRule displayRuleForInternalName:[self unlocalizedName]] sectionIndexPath];
	if([it isEqualToString:@"dateSortedSectionIndex"])
	{
		return [MTCall dateSortedSectionIndexTitles];
	}
	return nil;
}

- (NSString *)sectionNameForIndex:(int)index
{
	NSString *it = [[MTDisplayRule displayRuleForInternalName:[self unlocalizedName]] sectionIndexPath];
	if([it isEqualToString:@"dateSortedSectionIndex"])
	{
		return [MTCall stringForDateSortedIndex:index];
	}
	return nil;
}

- (NSString *)sectionNameKeyPath
{
	return [[MTDisplayRule displayRuleForInternalName:[self unlocalizedName]] sectionIndexPath];
}

- (NSArray *)coreDataSortDescriptors
{
	return [[MTDisplayRule displayRuleForInternalName:[self unlocalizedName]] coreDataSortDescriptors];
}

- (NSArray *)allSortDescriptors
{
	return [[MTDisplayRule displayRuleForInternalName:[self unlocalizedName]] allSortDescriptors];
}

- (BOOL)requiresArraySorting
{
	return [[MTDisplayRule displayRuleForInternalName:[self unlocalizedName]] requiresArraySorting];
}

- (BOOL)sectionIndexDisplaysSingleLetter
{
	return YES;
}

@end