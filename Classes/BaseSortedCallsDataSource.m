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
#import "Settings.h"
#import "MTCall.h"
#import "MTUser.h"

@interface BaseSortedCallsDataSource ()
@end

@implementation BaseSortedCallsDataSource

- (NSString *)name 
{
	return @"Set Me!";
}

- (NSString *)title
{
	return @"Set me!";
}

- (NSString *)tabBarImageName
{
	return @"time";
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

- (void)dealloc
{
	[super dealloc];
}

- (id)initSortedBy:(SortCallsType)sortedBy
{
	return [self initSortedBy:sortedBy withMetadata:nil];
}

- (id)initSortedBy:(SortCallsType)sortedBy withMetadata:(NSString *)metadata
{
	return [self initSortedBy:sortedBy withMetadata:metadata callsName:SettingsCalls];
}

NSArray *sortByStreet(NSArray *previousSorters)
{
	return [previousSorters arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"street" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
																				    [NSSortDescriptor sortDescriptorWithKey:@"houseNumber" ascending:YES selector:@selector(localizedStandardCompare:)],
														                            [NSSortDescriptor sortDescriptorWithKey:@"apartmentNumber" ascending:YES selector:@selector(localizedStandardCompare:)], nil]];
}

NSArray *sortByName(NSArray *previousSorters)
{
	return [previousSorters arrayByAddingObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
}

NSArray *sortByCity(NSArray *previousSorters)
{
	return [previousSorters arrayByAddingObject:[NSSortDescriptor sortDescriptorWithKey:@"city" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
}

NSArray *sortByDate(NSArray *previousSorters)
{
	return [previousSorters arrayByAddingObject:[NSSortDescriptor sortDescriptorWithKey:@"mostRecentReturnVisitDate" ascending:NO]];
}

NSArray *sortByDeletedFlag(NSArray *previousSorters)
{
	return [previousSorters arrayByAddingObject:[NSSortDescriptor sortDescriptorWithKey:@"deleted" ascending:NO]];
}



- (id)initSortedBy:(SortCallsType)sortedBy withMetadata:(NSString *)metadata callsName:(NSString *)callsName;
{
	if( (self = [super init]) )
	{
		_sortedBy = sortedBy;
	}
	return(self);
}

- (NSString *)sectionNameKeyPath
{
	switch(_sortedBy)
	{
		case CALLS_SORTED_BY_STREET:
		case CALLS_SORTED_BY_DELETED:
			// sort by street, city, then name
			return @"uppercaseFirstLetterOfStreet";
		case CALLS_SORTED_BY_CITY:
			return @"city";
		case CALLS_SORTED_BY_NAME:
		case CALLS_SORTED_BY_STUDY:
			return @"uppercaseFirstLetterOfName";
//		case CALLS_SORTED_BY_DATE:
//			return @"mostRecentReturnVisitDate";

		case CALLS_SORTED_BY_METADATA:
			break;
	}
	return nil;
}

- (NSPredicate *)predicate
{
	NSPredicate *filterPredicate = nil;
	MTUser *currentUser = [MTUser currentUser];
	
	// when we filter then we use a NSCompoundPredicate
	
	switch(_sortedBy)
	{
		case CALLS_SORTED_BY_STREET:
			// sort by street, city, then name
			filterPredicate = [NSPredicate predicateWithFormat:@"user == %@ && deletedCall == NO", currentUser];
			break;
		case CALLS_SORTED_BY_DATE:
			// sort by street, city, then name
			filterPredicate = [NSPredicate predicateWithFormat:@"user == %@ && deletedCall == NO", currentUser];
			break;
		case CALLS_SORTED_BY_CITY:
			// sort by street, city, then name
			filterPredicate = [NSPredicate predicateWithFormat:@"user == %@ && deletedCall == NO", currentUser];
			break;
		case CALLS_SORTED_BY_NAME:
			// sort by street, city, then name
			filterPredicate = [NSPredicate predicateWithFormat:@"user == %@ && deletedCall == NO", currentUser];
			break;
		case CALLS_SORTED_BY_DELETED:
			// sort by street, city, then name
			filterPredicate = [NSPredicate predicateWithFormat:@"user == %@ && deletedCall == YES", currentUser];
			break;
		case CALLS_SORTED_BY_STUDY:
			// sort by street, city, then name
			filterPredicate = [NSPredicate predicateWithFormat:@"(user == %@) && (deletedCall == NO) && SUBQUERY(returnVisits,$s,$s.type == 'Study').@count > 0", currentUser];
			break;
		case CALLS_SORTED_BY_METADATA:
			filterPredicate = [NSPredicate predicateWithFormat:@"user == %@ && deletedCall == NO", currentUser];
			break;
	}
	return filterPredicate;
}

- (NSArray *)sortDescriptors
{
	NSArray *sortDescriptors = [NSArray array];
	
	// when we filter then we use a NSCompoundPredicate
	
	switch(_sortedBy)
	{
		case CALLS_SORTED_BY_DELETED:
		case CALLS_SORTED_BY_STREET:
			// sort by street, city, then name
			sortDescriptors = sortByName(sortByCity(sortByStreet(sortDescriptors)));
			break;
		case CALLS_SORTED_BY_DATE:
			// sort by Date, name, city, then street
			sortDescriptors = sortByStreet(sortByCity(sortByName(sortByDate(sortDescriptors))));
			break;
		case CALLS_SORTED_BY_CITY:
			// sort by city, street, then name
			sortDescriptors = sortByName(sortByStreet(sortByCity(sortDescriptors)));
			break;
		case CALLS_SORTED_BY_NAME:
			// sort by name, street, then city
			sortDescriptors = sortByCity(sortByStreet(sortByName(sortDescriptors)));
			break;
		case CALLS_SORTED_BY_STUDY:
			// sort by name, street, then city
			sortDescriptors = sortByCity(sortByStreet(sortByName(sortDescriptors)));
			break;
		case CALLS_SORTED_BY_METADATA:
#warning fix me
			sortDescriptors = sortByName(sortByStreet(sortByCity(sortDescriptors)));
			break;
	}
	
	return sortDescriptors;
}
@end