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


@implementation BaseSortedCallsDataSource

@synthesize callsSorter;

- (NSString *)name 
{
	return @"Set Me!";
}

- (NSString *)title
{
	return @"Set me!";
}

- (UIImage *)tabBarImageName
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

- (NSMutableDictionary *)callForIndexPath:(NSIndexPath *)indexPath 
{
	return [callsSorter callForRowAtIndexPath:indexPath];
}

- (void)setCall:(NSMutableDictionary *)call forIndexPath:(NSIndexPath *)indexPath 
{
	[callsSorter setCall:call forIndexPath:indexPath];
}

- (void)addCall:(NSMutableDictionary *)call
{
	[callsSorter addCall:call];
}

- (void)dealloc
{
	DEBUG(NSLog(@"%s: dealloc", __FILE__);)
	[callsSorter release];
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

- (id)initSortedBy:(SortCallsType)sortedBy withMetadata:(NSString *)metadata callsName:(NSString *)callsName;
{
	[super init];
	callsSorter = [[CallsSorter alloc] initSortedBy:sortedBy withMetadata:metadata callsName:callsName];
	return(self);
}


- (void)refreshData
{
	[callsSorter refreshData];
}

- (void)filterUsingSearchText:(NSString *)searchText
{
	[callsSorter filterUsingSearchText:searchText];
	[callsSorter refreshData];
}


// UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CallTableCell *cell = (CallTableCell *)[tableView dequeueReusableCellWithIdentifier:@"CallTableCell"];
	if (cell == nil) 
	{
		cell = [[[CallTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CallTableCell"] autorelease];
	}
    
	// configure cell contents
	// all the rows should show the disclosure indicator
	if ([self showDisclosureIcon])
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	if([self useNameAsMainLabel])
	{
		[cell useNameAsMainLabel];
	}
	else
	{
		[cell useStreetAsMainLabel];
	}
	cell.call = [self callForIndexPath:indexPath];
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return [callsSorter numberOfSections];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
	return [callsSorter sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index 
{
	if([title isEqualToString:@"{search}"])
	{
		[tableView scrollRectToVisible:[[tableView tableHeaderView] bounds] animated:NO];
		return -1;
	}
	return [callsSorter sectionForSectionIndexTitle:title atIndex:index];
}

- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section 
{
	return([callsSorter numberOfRowsInSection:section]);
}

- (void)deleteCallAtIndexPath:(NSIndexPath *)indexPath keepInformation:(BOOL)keepInformation
{
	// remove the call from the array
	if(keepInformation)
	{
		NSMutableDictionary *settings = [[Settings sharedInstance] userSettings];
		NSMutableDictionary *call = [callsSorter callForRowAtIndexPath:indexPath];
		NSMutableArray *deletedCalls = [settings objectForKey:SettingsDeletedCalls];
		if(deletedCalls == nil)
		{
			deletedCalls = [NSMutableArray array];
			[settings setObject:deletedCalls forKey:SettingsDeletedCalls];
		}
		[deletedCalls addObject:call];
	}
	[callsSorter deleteCallAtIndexPath:indexPath];
	[[Settings sharedInstance] saveData];
}

- (void)restoreCallAtIndexPath:(NSIndexPath *)indexPath
{
	// remove the call from the array
	NSMutableDictionary *settings = [[Settings sharedInstance] userSettings];
	NSMutableDictionary *call = [callsSorter callForRowAtIndexPath:indexPath];
	NSMutableArray *aliveCalls = [settings objectForKey:SettingsCalls];
	if(aliveCalls == nil)
	{
		aliveCalls = [NSMutableArray array];
		[settings setObject:aliveCalls forKey:SettingsCalls];
	}
	[aliveCalls addObject:call];
	[callsSorter restoreCallAtIndexPath:indexPath];
	[[Settings sharedInstance] saveData];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	return [callsSorter titleForHeaderInSection:section];
}

- (BOOL)respondsToSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"%s respondsToSelector: %s", __FILE__, selector);)
    return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"%s methodSignatureForSelector: %s", __FILE__, selector);)
    return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    VERY_VERBOSE(NSLog(@"%s forwardInvocation: %s", __FILE__, [invocation selector]);)
    [super forwardInvocation:invocation];
}



@end
