//
//  SorterViewController.m
//  MyTime
//
//  Created by Brent Priddy on 1/30/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import "SorterViewController.h"
#import "PSLabelCellController.h"
#import "PSCheckmarkCellController.h"
#import "PSSwitchCellController.h"
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
@synthesize selectedIndexPath;

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
	self.selectedIndexPath = nil;
	
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


- (void)navigationControlDone:(id)sender 
{
	if(self.delegate && [self.delegate respondsToSelector:@selector(sorterViewControllerDone:)])
	{
		[self.delegate sorterViewControllerDone:self];
	}
}	

- (void)loadView 
{
	[super loadView];
	[self.navigationItem setHidesBackButton:YES animated:YES];
	// update the button in the nav bar
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(navigationControlDone:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:YES];
}

- (void)labelCellController:(PSCheckmarkCellController *)labelCellController tableView:(UITableView *)tableView sortSelectedAtIndexPath:(NSIndexPath *)indexPath
{
	[[self.navigationItem rightBarButtonItem] setEnabled:YES];
	self.sorter.name = labelCellController.title;
	self.sorter.path = (NSString *)labelCellController.checkedValue;
	self.sorter.sectionIndexPath = [MTSorter sectionIndexPathForPath:self.sorter.path];
	self.sorter.requiresArraySortingValue = [MTSorter requiresArraySortingForPath:self.sorter.path];
	if(self.selectedIndexPath)
	{
		[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
	}
	self.selectedIndexPath = indexPath;
}

- (void)constructSectionControllers
{
	[super constructSectionControllers];

	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		[sectionController release];
		
		PSSwitchCellController *cellController = [[[PSSwitchCellController alloc] init] autorelease];
		cellController.title = NSLocalizedString(@"Sort Ascending", @"Title for row in the 'Edit Sort Rule' view for the ascending switch");
		cellController.model = self.sorter;
		cellController.modelPath = @"ascending";
		[self addCellController:cellController toSection:sectionController];
	}
	
	int section = 1;
	for(NSDictionary *group in [MTSorter sorterInformationArray])
	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		sectionController.title = [group objectForKey:MTSorterGroupName];
		[self.sectionControllers addObject:sectionController];
		[sectionController release];
		
		int row = 0;
		for(NSDictionary *entry in [group objectForKey:MTSorterGroupArray])
		{
			PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
			cellController.model = self.sorter;
			cellController.modelPath = @"path";
			cellController.title = [entry objectForKey:MTSorterEntryName];
			cellController.checkedValue = [entry objectForKey:MTSorterEntryPath];
			[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:sortSelectedAtIndexPath:)];
			[self addCellController:cellController toSection:sectionController];
			if([cellController.checkedValue isEqual:self.sorter.path])
			{
				self.selectedIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
			}
			++row;
		}
		++section;
	}
	[[self.navigationItem rightBarButtonItem] setEnabled:self.selectedIndexPath != nil];
}

@end
