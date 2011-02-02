//
//  DisplayRuleViewController.m
//  MyTime
//
//  Created by Brent Priddy on 1/23/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import "DisplayRuleViewController.h"
#import "SorterViewController.h"
#import "TableViewCellController.h"
#import "GenericTableViewSectionController.h"
#import "PSLabelCellController.h"
#import "MTUser.h"
#import "MTDisplayRule.h"
#import "MTSorter.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "UITableViewTitleAndValueCell.h"
#import "PSTextFieldCellController.h"
#import "PSLocalization.h"

@implementation DisplayRuleViewController
@synthesize delegate;
@synthesize displayRule;
@synthesize allTextFields;
@synthesize temporarySorter;

- (id) initWithDisplayRule:(MTDisplayRule *)theDisplayRule newDisplayRule:(BOOL)newDisplayRule
{
	if ([super initWithStyle:UITableViewStyleGrouped]) 
	{
		// set the title, and tab bar images from the dataSource
		// object. 
		self.title = NSLocalizedString(@"Edit Display Rule", @"Sort Rules View title");
		self.displayRule = theDisplayRule;
		self.hidesBottomBarWhenPushed = YES;
	}
	return self;
}

- (void)dealloc 
{
	self.allTextFields = nil;
	self.displayRule = nil;
	self.temporarySorter = nil;
	
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)navigationControlDone:(id)sender 
{
#warning implement me
}	

- (void)loadView 
{
	[super loadView];
	self.tableView.editing = YES;
	
	[self navigationControlDone:nil];
}

- (void)sorterViewControllerDone:(SorterViewController *)sorterViewController
{
	NSManagedObjectContext *moc = self.displayRule.managedObjectContext;
	
	NSError *error = nil;
	if (![moc save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
	if(self.temporarySorter)
	{
		self.temporarySorter = nil;
		[self dismissModalViewControllerAnimated:YES];
	}
	else
	{
		[self.navigationController popViewControllerAnimated:YES];
	}
	
	[self updateAndReload];
}


- (void)labelCellController:(PSLabelCellController *)labelCellController tableView:(UITableView *)tableView deleteSorterAtIndexPath:(NSIndexPath *)indexPath
{
	MTSorter *sorter = (MTSorter *)labelCellController.model;
	
	[self.displayRule.managedObjectContext deleteObject:sorter];
	NSError *error = nil;
	if (![self.displayRule.managedObjectContext save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
	[[self retain] autorelease];
	[self deleteDisplayRowAtIndexPath:indexPath];
	[self updateAndReload];
}

- (void)labelCellController:(PSLabelCellController *)labelCellController tableView:(UITableView *)tableView modifySorterFromSelectionAtIndexPath:(NSIndexPath *)indexPath
{
	MTSorter *sorter = (MTSorter *)labelCellController.model;
	SorterViewController *p = [[[SorterViewController alloc] initWithSorter:sorter newSorter:NO] autorelease];
	p.delegate = self;
	[[self navigationController] pushViewController:p animated:YES];		
	[self retainObject:labelCellController whileViewControllerIsManaged:p];
}


- (void)addSorterNavigationControlCanceled
{
	NSManagedObjectContext *moc = self.temporarySorter.managedObjectContext;
	[moc deleteObject:self.temporarySorter];
	self.temporarySorter = nil;
	NSError *error = nil;
	if(![moc save:&error])
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
	[self dismissModalViewControllerAnimated:YES];
}

- (void)labelCellController:(PSLabelCellController *)labelCellController tableView:(UITableView *)tableView addSorterFromSelectionAtIndexPath:(NSIndexPath *)indexPath
{
	self.temporarySorter = [MTSorter insertInManagedObjectContext:self.displayRule.managedObjectContext];
	self.temporarySorter.displayRule = self.displayRule;
	SorterViewController *controller = [[[SorterViewController alloc] initWithSorter:self.temporarySorter newSorter:YES] autorelease];
	controller.delegate = self;
	
	// push the element view controller onto the navigation stack to display it
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
	
	// create a custom navigation bar button and set it to always say "back"
	UIBarButtonItem *temporaryBarButtonItem = [[[UIBarButtonItem alloc] init] autorelease];
	temporaryBarButtonItem.title = NSLocalizedString(@"Cancel", @"Cancel button");
	
	controller.title = NSLocalizedString(@"New Display Rule", @"Title for the Sorted By ... area when you are editing the display rules");
	[self presentModalViewController:navigationController animated:YES];
	[temporaryBarButtonItem setAction:@selector(addSorterNavigationControlCanceled)];
	[temporaryBarButtonItem setTarget:self];
	controller.navigationItem.leftBarButtonItem = temporaryBarButtonItem;
	
	[self retainObject:controller whileViewControllerIsManaged:controller];
}

- (void)constructSectionControllers
{
	[super constructSectionControllers];

	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		[sectionController release];

		{
			if(self.displayRule.deleteableValue)
			{
				PSTextFieldCellController *cellController = [[[PSTextFieldCellController alloc] init] autorelease];
				cellController.model = self.displayRule;
				cellController.modelPath = @"name";
				cellController.placeholder = NSLocalizedString(@"Display Rule Name", @"This is the placeholder text in the Display Rule detail screen where you name the display rule");
				cellController.returnKeyType = UIReturnKeyDone;
				cellController.clearButtonMode = UITextFieldViewModeAlways;
				cellController.autocapitalizationType = UITextAutocapitalizationTypeWords;
				cellController.selectionStyle = UITableViewCellSelectionStyleNone;
				cellController.obtainFocus = obtainFocus;
				cellController.allTextFields = self.allTextFields;
				cellController.indentWhileEditing = NO;
				obtainFocus = NO;
				[self addCellController:cellController toSection:sectionController];
			}
			else
			{
				PSLabelCellController *cellController = [[[PSLabelCellController alloc] init] autorelease];
				cellController.model = self.displayRule;
				cellController.indentWhileEditing = NO;
				cellController.selectionStyle = UITableViewCellSelectionStyleNone;
				cellController.modelPath = @"name";
				[self addCellController:cellController toSection:sectionController];
			}
		}
	}
	
	// Sorters
	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		sectionController.title = NSLocalizedString(@"Sort Rules", @"Section title for the Display Rule editing view");
		[sectionController release];

		NSArray *sorters = [self.displayRule.managedObjectContext fetchObjectsForEntityName:[MTSorter entityName]
																		  propertiesToFetch:nil
																		withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"order" ascending:YES] ]
																			  withPredicate:@"displayRule == %@", self.displayRule];
		
		for(MTSorter *sorter in sorters)
		{
			PSLabelCellController *cellController = [[[PSLabelCellController alloc] init] autorelease];
			cellController.model = sorter;
			cellController.modelPath = @"name";
			cellController.editingStyle = UITableViewCellEditingStyleDelete;
			[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:modifySorterFromSelectionAtIndexPath:)];
			[cellController setDeleteTarget:self action:@selector(labelCellController:tableView:deleteSorterAtIndexPath:)];
			[self addCellController:cellController toSection:sectionController];
		}
		
		// add the "Add Sorter" cell at the end
		{
			PSLabelCellController *cellController = [[[PSLabelCellController alloc] init] autorelease];
			cellController.title = NSLocalizedString(@"Add New Sort Rule", @"Button to click to add an additional sort or filter rule for the Sorted By ... view");
			cellController.editingStyle = UITableViewCellEditingStyleInsert;
			[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:addSorterFromSelectionAtIndexPath:)];
			[cellController setInsertTarget:self action:@selector(labelCellController:tableView:addSorterFromSelectionAtIndexPath:)];
			[self addCellController:cellController toSection:sectionController];
		}
	}	
}

@end
