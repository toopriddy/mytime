//
//  BaseSortedCallsDataSource.m
//  MyTime
//
//  Created by Brent Priddy on 8/13/08.
//  Copyright 2008 PG Software. All rights reserved.
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

- (UIImage *)tabBarImage 
{
	return [UIImage imageNamed:@"time.png"];
}




- (UITableViewStyle)tableViewStyle 
{
	return UITableViewStylePlain;
};

- (BOOL)showDisclosureIcon
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
	[super init];
	callsSorter = [[CallsSorter alloc] initWithCalls:[[[Settings sharedInstance] settings] objectForKey:SettingsCalls] sortedBy:sortedBy];
	return(self);
}


- (void)refreshData
{
	[callsSorter refreshData];
}

// UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CallTableCell *cell = (CallTableCell *)[tableView dequeueReusableCellWithIdentifier:@"CallTableCell"];
	if (cell == nil) 
	{
		cell = [[[CallTableCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"CallTableCell"] autorelease];
	}
    
	// configure cell contents
	// all the rows should show the disclosure indicator
	if ([self showDisclosureIcon])
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	// set the element for this cell as specified by the callsSortersource. The atomicElementForIndexPath: is declared
	// as part of the ElementsDataSource Protocol and will return the appropriate element for the index row
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
		NSMutableDictionary *settings = [[Settings sharedInstance] settings];
		NSMutableDictionary *call = [callsSorter callForRowAtIndexPath:indexPath];
		NSMutableArray *deletedCalls = [NSMutableArray arrayWithArray:[settings objectForKey:SettingsDeletedCalls]];
		[settings setObject:deletedCalls forKey:SettingsDeletedCalls];
		[deletedCalls addObject:call];
	}
	[callsSorter deleteCallAtIndexPath:indexPath];
	[[Settings sharedInstance] saveData];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	return([callsSorter titleForHeaderInSection:section]);
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
