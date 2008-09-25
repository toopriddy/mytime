//
//  CallsSortedByNameViewDataSource.m
//  MyTime
//
//  Created by Brent Priddy on 9/24/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import "SortedCallsViewController.h"
#import "CallsSortedByNameViewDataSource.h"
#import "CallTableCell.h"
#import "Settings.h"


@implementation CallsSortedByNameViewDataSource

@synthesize callsSorter;



// return the callsSorter used by the navigation controller and tab bar item

- (NSString *)name 
{
	return NSLocalizedString(@"Name Sorted", @"button bar title");
}

- (NSString *)title
{
	return NSLocalizedString(@"Calls Sorted by Name", @"View title");
}


- (BOOL)showDisclosureIcon
{
	return NO;
}

- (UIImage *)tabBarImage 
{
	return [UIImage imageNamed:@"people.png"];
}

- (void)dealloc
{
    DEBUG(NSLog(@"%s: dealloc", __FILE__);)
	[super dealloc];
}

- (id)init
{
	[super initSortedBy:CALLS_SORTED_BY_NAME];
	return(self);
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
