//
//  FilterViewController.m
//  MyTime
//
//  Created by Brent Priddy on 1/30/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import "FilterViewController.h"
#import "PSLabelCellController.h"
#import "PSSwitchCellController.h"
#import "FilterViewController.h"
#import "TableViewCellController.h"
#import "GenericTableViewSectionController.h"
#import "PSLabelCellController.h"
#import "MTFilter.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "PSTextFieldCellController.h"
#import "PSLocalization.h"

@implementation FilterViewController
@synthesize delegate;
@synthesize filter;
@synthesize selectedIndexPath;

- (id) initWithFilter:(MTFilter *)theFilter newFilter:(BOOL)newFilter
{
	if ([super initWithStyle:UITableViewStyleGrouped]) 
	{
		// set the title, and tab bar images from the dataSource
		// object. 
		self.title = NSLocalizedString(@"Edit Sort Rule", @"Sort Rules View title");
		self.filter = theFilter;
		self.hidesBottomBarWhenPushed = YES;
	}
	return self;
}

- (void)dealloc 
{
	self.filter = nil;
	self.selectedIndexPath = nil;
	
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


- (void)navigationControlDone:(id)sender 
{
	if(self.delegate && [self.delegate respondsToSelector:@selector(filterViewControllerDone:)])
	{
		[self.delegate filterViewControllerDone:self];
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

- (void)labelCellController:(PSLabelCellController *)labelCellController tableView:(UITableView *)tableView sortSelectedAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *entry = (NSDictionary *)labelCellController.userData;
	self.filter.untranslatedName = [entry objectForKey:MTFilterUntranslatedName];
	NSString *entityName = [entry objectForKey:MTFilterEntityName];
	if(entityName)
	{
		self.filter.filterEntityName = entityName;
	}
	self.filter.path = [entry objectForKey:MTFilterPath];
	self.filter.listValue = [entry objectForKey:MTFilterSubFilters] != nil;
	self.filter.operator = @"";
	self.filter.value = @"";

	[[self.navigationItem rightBarButtonItem] setEnabled:YES];

	if(self.selectedIndexPath)
	{
		[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
	}
	
	self.selectedIndexPath = indexPath;
	
	[self navigationControlDone:nil];
}

- (void)constructSectionControllers
{
	[super constructSectionControllers];
	
	int section = 1;
	for(NSDictionary *group in [MTFilter displayEntriesForEntityName:self.filter.filterEntityName])
	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		sectionController.title = [group objectForKey:MTFilterGroupName];
		sectionController.editingTitle = sectionController.title;
		[self.sectionControllers addObject:sectionController];
		[sectionController release];
		
		int row = 0;
		for(NSDictionary *entry in [group objectForKey:MTFilterGroupArray])
		{
			PSLabelCellController *cellController = [[[PSLabelCellController alloc] init] autorelease];
			cellController.userData = entry;
			cellController.title = [[PSLocalization localizationBundle] localizedStringForKey:[entry objectForKey:MTFilterUntranslatedName] value:[entry objectForKey:MTFilterUntranslatedName] table:nil];
			[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:sortSelectedAtIndexPath:)];
			[self addCellController:cellController toSection:sectionController];
			++row;
		}
		++section;
	}
	[[self.navigationItem rightBarButtonItem] setEnabled:self.selectedIndexPath != nil];
}

@end
