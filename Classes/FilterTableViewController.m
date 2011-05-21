//
//  FilterSectionController.m
//  MyTime
//
//  Created by Brent Priddy on 3/19/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import "FilterTableViewController.h"
#import "PSLabelCellController.h"
#import "PSCheckmarkCellController.h"
#import "PSSwitchCellController.h"
#import "TableViewCellController.h"
#import "GenericTableViewSectionController.h"
#import "PSSegmentedControlCellController.h"
#import "MTDisplayRule.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "PSLocalization.h"

@implementation FilterTableViewController
@synthesize filter = filter_;
@synthesize tableViewController;
@synthesize managedObjectContext;
@synthesize temporaryFilter;

- (void)dealloc 
{
	self.filter = nil;
	self.temporaryFilter = nil;
	self.tableViewController = nil;
	self.managedObjectContext = nil;
	
    [super dealloc];
}

- (void)labelCellController:(PSLabelCellController *)labelCellController tableView:(UITableView *)tableView deleteFilterAtIndexPath:(NSIndexPath *)indexPath
{
	MTFilter *filter = (MTFilter *)labelCellController.userData;
	NSManagedObjectContext *moc = filter.managedObjectContext;
	
	[moc deleteObject:filter];
	NSError *error = nil;
	if (![moc save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
	[[self retain] autorelease];
	[self.tableViewController deleteDisplayRowAtIndexPath:indexPath];
}

- (void)labelCellController:(PSLabelCellController *)labelCellController tableView:(UITableView *)tableView editFilterFromSelectionAtIndexPath:(NSIndexPath *)indexPath
{
	MTFilter *filter = (MTFilter *)labelCellController.userData;

	FilterDetailViewController *p = [[[FilterDetailViewController alloc] initWithFilter:filter newFilter:NO] autorelease];
	p.filter = filter;
	p.delegate = self;
	[[self.tableViewController navigationController] pushViewController:p animated:YES];		
	[self.tableViewController retainObject:labelCellController whileViewControllerIsManaged:p];
}

- (void)filterDetailViewControllerDone:(FilterDetailViewController *)viewController
{
	NSManagedObjectContext *moc = self.filter.managedObjectContext;
	
	NSError *error = nil;
	if (![moc save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}

	[self.tableViewController updateAndReload];
}


- (void)filterViewControllerDone:(FilterViewController *)viewController
{
	NSManagedObjectContext *moc = self.filter.managedObjectContext;
	
	NSError *error = nil;
	if (![moc save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
	if(self.temporaryFilter)
	{
		self.temporaryFilter = nil;
		[self.tableViewController dismissModalViewControllerAnimated:YES];
	}
	else
	{
		[self.tableViewController.navigationController popViewControllerAnimated:YES];
	}
	
	[self.tableViewController updateAndReload];
}

- (void)addFilterNavigationControlCanceled
{
	[self.tableViewController dismissModalViewControllerAnimated:YES];
	NSManagedObjectContext *moc = self.temporaryFilter.managedObjectContext;
	[moc deleteObject:self.temporaryFilter];
	self.temporaryFilter = nil;
	NSError *error = nil;
	if(![moc save:&error])
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
}

- (void)labelCellController:(PSLabelCellController *)labelCellController tableView:(UITableView *)tableView addFilterFromSelectionAtIndexPath:(NSIndexPath *)indexPath
{
	self.temporaryFilter = [MTFilter createFilterForFilter:self.filter];
	self.temporaryFilter.filterEntityName = self.filter.filterEntityName;

	FilterViewController *controller = [[[FilterViewController alloc] initWithFilter:self.temporaryFilter newFilter:YES] autorelease];
	controller.delegate = self;
	
	// push the element view controller onto the navigation stack to display it
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
	
	// create a custom navigation bar button and set it to always say "back"
	UIBarButtonItem *temporaryBarButtonItem = [[[UIBarButtonItem alloc] init] autorelease];
	temporaryBarButtonItem.title = NSLocalizedString(@"Cancel", @"Cancel button");
	
	controller.title = NSLocalizedString(@"New Filter Rule", @"Title for the Sorted By ... area when you are editing the display rules and adding a filter rule");
	[self.tableViewController presentModalViewController:navigationController animated:YES];
	[temporaryBarButtonItem setAction:@selector(addFilterNavigationControlCanceled)];
	[temporaryBarButtonItem setTarget:self];
	controller.navigationItem.leftBarButtonItem = temporaryBarButtonItem;
	
	[self.tableViewController retainObject:controller whileViewControllerIsManaged:controller];
}


- (void)constructSectionControllersForTableViewController:(GenericTableViewController *)genericTableViewController
{
	self.tableViewController = genericTableViewController;

	// Filters
	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		[genericTableViewController.sectionControllers addObject:sectionController];
		sectionController.editingTitle = NSLocalizedString(@"Filter Rules", @"Section title for the Display Rule editing view");
		[sectionController release];
		
		PSSegmentedControlCellController *cellController = [[[PSSegmentedControlCellController alloc] init] autorelease];
		cellController.title = NSLocalizedString(@"Match", @"label name for the cell asking if you want to match all or just match one");
		cellController.model = self.filter;
		cellController.modelPath = @"and";
		cellController.segmentedControlTitles = [NSArray arrayWithObjects:NSLocalizedString(@"All", @"label name for the cell asking if you want to match all or just match one"), NSLocalizedString(@"One", @"label name for the cell asking if you want to match all or just match one"), nil];
		cellController.segmentedControlValues = [NSArray arrayWithObjects:[NSNumber numberWithBool:YES], [NSNumber numberWithBool:NO], nil];
		cellController.editingStyle = UITableViewCellEditingStyleNone;
		[genericTableViewController addCellController:cellController toSection:sectionController];
		
		NSArray *currentFilters = [self.filter.filters sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"order" ascending:YES]]];
		
		for(MTFilter *filter in currentFilters)
		{
			PSLabelCellController *cellController = [[[PSLabelCellController alloc] init] autorelease];
			cellController.title = filter.title;
			cellController.editingStyle = UITableViewCellEditingStyleDelete;
			cellController.userData = filter;
			[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:editFilterFromSelectionAtIndexPath:)];
			[cellController setDeleteTarget:self action:@selector(labelCellController:tableView:deleteFilterAtIndexPath:)];
			[genericTableViewController addCellController:cellController toSection:sectionController];
		}
		
		// add the "Add Filter" cell at the end
		{
			PSLabelCellController *cellController = [[[PSLabelCellController alloc] init] autorelease];
			cellController.title = NSLocalizedString(@"Add Filter Rule", @"Button to click to add an additional sort or filter rule for the Sorted By ... view");
			cellController.editingStyle = UITableViewCellEditingStyleInsert;
			[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:addFilterFromSelectionAtIndexPath:)];
			[cellController setInsertTarget:self action:@selector(labelCellController:tableView:addFilterFromSelectionAtIndexPath:)];
			[genericTableViewController addCellController:cellController toSection:sectionController];
		}
	}	
}


@end
