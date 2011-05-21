//
//  MetadataSortedCallsViewController.m
//  MyTime
//
//  Created by Brent Priddy on 6/14/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "MetadataSortedCallsViewController.h"
#import "CallsSortedByFilterDataSource.h"
#import "MyTimeAppDelegate.h"
#import "MTSettings.h"
#import "PSLocalization.h"
@implementation MetadataSortedCallsViewController

- (void)displayRulesViewController:(DisplayRulesViewController *)viewController selectedDisplayRule:(MTDisplayRule *)displayRule;
{
	[self reloadTableFromSourceChange];
	[self.navigationController popViewControllerAnimated:YES];
	NSString *name = displayRule.localizedName;
	if([name length] == 0)
	{
		name = NSLocalizedString(@"Display Rule", @"Title of button on the Sorted By... view if the user put in a display rule that does not have a name");
	}
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithTitle:name
																style:UIBarButtonItemStyleBordered 
															   target:self 
															   action:@selector(changeMetadata)] autorelease];
	[self.navigationItem setLeftBarButtonItem:button];
}

- (void)changeMetadata
{
	MTSettings *settings = [MTSettings settings];
	DisplayRulesViewController *controller = [[[DisplayRulesViewController alloc] init] autorelease];
	controller.delegate = self;
	controller.managedObjectContext = settings.managedObjectContext;
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)loadView
{
	[super loadView];
	self.navigationItem.hidesBackButton = YES;
	
	MTDisplayRule *currentDisplayRule = [MTDisplayRule currentDisplayRule];
	// update the button in the nav bar
	NSString *name = currentDisplayRule.localizedName;
	if([name length] == 0)
	{
		name = NSLocalizedString(@"Display Rule", @"Title of button on the Sorted By... view if the user put in a display rule that does not have a name");
	}
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithTitle:name
																style:UIBarButtonItemStyleBordered 
															   target:self 
															   action:@selector(changeMetadata)] autorelease];
	[self.navigationItem setLeftBarButtonItem:button];
}
@end
