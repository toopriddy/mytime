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
	NSDictionary *entry = (NSDictionary *)labelCellController.userData;
	[[self.navigationItem rightBarButtonItem] setEnabled:YES];
	self.sorter.name = [entry objectForKey:MTSorterEntryName];
	self.sorter.additionalInformationTypeUuid = [entry objectForKey:MTSorterEntryUUID];
	self.sorter.path = [entry objectForKey:MTSorterEntryPath];
	self.sorter.sectionIndexPath = [entry objectForKey:MTSorterEntrySectionIndexPath];
	if([entry objectForKey:MTSorterEntryRequiresArraySorting])
	{
		self.sorter.requiresArraySortingValue = YES;
	}

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
		cellController.selectionStyle = UITableViewCellSelectionStyleNone;
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
		sectionController.editingTitle = sectionController.title;
		[self.sectionControllers addObject:sectionController];
		[sectionController release];
		
		int row = 0;
		for(NSDictionary *entry in [group objectForKey:MTSorterGroupArray])
		{
			PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
			cellController.title = [entry objectForKey:MTSorterEntryName];
			cellController.userData = entry;
			if([entry objectForKey:MTSorterEntryRequiresArraySorting])
			{
				cellController.model = self.sorter;
				cellController.modelPath = @"name";
				cellController.checkedValue = [entry objectForKey:MTSorterEntryName];
				if([self.sorter.additionalInformationTypeUuid isEqualToString:[entry objectForKey:MTSorterEntryUUID]])
				{
					self.selectedIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
				}
			}
			else
			{
				cellController.model = self.sorter;
				cellController.modelPath = @"path";
				cellController.checkedValue = [entry objectForKey:MTSorterEntryPath];
				if([self.sorter.path isEqualToString:[entry objectForKey:MTSorterEntryPath]])
				{
					self.selectedIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
				}
			}
			[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:sortSelectedAtIndexPath:)];
			[self addCellController:cellController toSection:sectionController];
			++row;
		}
		++section;
	}
	[[self.navigationItem rightBarButtonItem] setEnabled:self.selectedIndexPath != nil];
}

@end
