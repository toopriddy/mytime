//
//  SorterViewController.m
//  MyTime
//
//  Created by Brent Priddy on 1/30/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import "SorterViewController.h"
#import "PSLabelCellController.h"
#import "SorterViewController.h"
#import "TableViewCellController.h"
#import "GenericTableViewSectionController.h"
#import "PSLabelCellController.h"
#import "MTSorter.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "PSTextFieldCellController.h"
#import "PSLocalization.h"

@implementation SorterViewController
@synthesize delegate;
@synthesize sorter;

- (id) initWithSorter:(MTSorter *)theSorter newSorter:(BOOL)newSorter
{
	if ([super initWithStyle:UITableViewStyleGrouped]) 
	{
		// set the title, and tab bar images from the dataSource
		// object. 
		self.title = NSLocalizedString(@"Edit Sort Rule", @"Sort Rules View title");
		self.sorter = theSorter;
		self.hidesBottomBarWhenPushed = YES;
	}
	return self;
}

- (void)dealloc 
{
	self.sorter = nil;
	
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


- (void)navigationControlDone:(id)sender 
{
#warning fix me
}	

- (void)loadView 
{
	[super loadView];
	[self updateAndReload];
	
	// update the button in the nav bar
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(navigationControlDone:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:YES];
}

- (void)labelCellController:(PSLabelCellController *)labelCellController tableView:(UITableView *)tableView sortSelectedAtIndexPath:(NSIndexPath *)indexPath
{
#warning implement me
}

- (void)constructSectionControllers
{
	[super constructSectionControllers];
	
	for(NSDictionary *group in [MTSorter sorterInformationArray])
	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		sectionController.title = [group objectForKey:MTSorterGroupName];
		[self.sectionControllers addObject:sectionController];
		[sectionController release];
		
		for(NSDictionary *entry in [group objectForKey:MTSorterGroupArray])
		{
			PSLabelCellController *cellController = [[[PSLabelCellController alloc] init] autorelease];
			cellController.model = entry;
			cellController.modelPath = MTSorterEntryName;
			if([self.sorter.path isEqualToString:[entry objectForKey:MTSorterEntryPath]])
			{
				cellController.accessoryType = UITableViewCellAccessoryCheckmark; 
			}
			[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:sortSelectedAtIndexPath:)];
			[sectionController.cellControllers addObject:cellController];
		}
	}
	
}

@end
