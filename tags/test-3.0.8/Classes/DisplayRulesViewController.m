//
//  DisplayRulesViewController.m
//  MyTime
//
//  Created by Brent Priddy on 1/22/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import "DisplayRulesViewController.h"
#import "DisplayRuleViewController.h"
#import "TableViewCellController.h"
#import "GenericTableViewSectionController.h"
#import "PSLabelCellController.h"
#import "MTUser.h"
#import "MTDisplayRule.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "UITableViewTitleAndValueCell.h"
#import "PSLocalization.h"


@implementation DisplayRulesViewController
@synthesize delegate;
@synthesize managedObjectContext;
@synthesize temporaryDisplayRule;
@synthesize onlyAllowEditing;

- (id) init;
{
	if ([super initWithStyle:UITableViewStyleGrouped]) 
	{
		// set the title, and tab bar images from the dataSource
		// object. 
		
		self.hidesBottomBarWhenPushed = YES;
	}
	return self;
}

- (void)dealloc 
{
	self.temporaryDisplayRule = nil;
	self.tableView.delegate = nil;
	self.tableView.dataSource = nil;
	
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)navigationControlEdit:(id)sender 
{
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
	[self.tableView flashScrollIndicators];
	
	self.title = NSLocalizedString(@"Edit Sort Rules", @"Sort Rules View title");
	// update the button in the nav bar
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(navigationControlDone:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:YES];
	
	self.navigationItem.hidesBackButton = YES;
	
	self.editing = YES;
}	

- (void)navigationControlDone:(id)sender 
{
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
	[self.tableView flashScrollIndicators];
	
	self.title = NSLocalizedString(@"Select Sort Rule", @"Sort Rules View title");
	// update the button in the nav bar
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
																			 target:self
																			 action:@selector(navigationControlEdit:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:YES];
	
	self.navigationItem.hidesBackButton = NO;
	
	self.editing = NO;
}	

- (void)loadView 
{
	[super loadView];
	
	if(self.onlyAllowEditing)
	{
		self.title = NSLocalizedString(@"Edit Sort Rules", @"Sort Rules View title");
		self.editing = YES;
	}
	else
	{
		if(self.editing)
		{
			[self navigationControlEdit:nil];
		}
		else
		{
			[self navigationControlDone:nil];
		}
	}
}

- (void)displayRuleViewControllerDone:(DisplayRuleViewController *)displayRuleViewController
{
	NSManagedObjectContext *moc = self.managedObjectContext;
	// let the MTDisplayRule sort out what is the currentDisplayRule if this is adding the first one
	[MTDisplayRule currentDisplayRule];
	
	NSError *error = nil;
	if (![moc save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
	if(self.temporaryDisplayRule)
	{
		self.temporaryDisplayRule = nil;
		[self dismissModalViewControllerAnimated:YES];
	}
	else
	{
		[self.navigationController popViewControllerAnimated:YES];
	}

	[self updateAndReload];
	[[NSNotificationCenter defaultCenter] postNotificationName:MTNotificationDisplayRuleChanged object:nil];
}


- (void)labelCellController:(PSLabelCellController *)labelCellController tableView:(UITableView *)tableView deleteDisplayRuleAtIndexPath:(NSIndexPath *)indexPath
{
	MTDisplayRule *displayRule = (MTDisplayRule *)labelCellController.model;
	MTDisplayRule *currentDisplayRule = [MTDisplayRule currentDisplayRule];
	BOOL wasCurrentDisplayRule = currentDisplayRule == displayRule;
	if(wasCurrentDisplayRule)
	{
		[MTDisplayRule setCurrentDisplayRule:nil];
	}
	
	[self.managedObjectContext deleteObject:displayRule];
	[MTDisplayRule currentDisplayRule];
	
	NSError *error = nil;
	if (![self.managedObjectContext save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
	[[self retain] autorelease];
	[self deleteDisplayRowAtIndexPath:indexPath];
	if(wasCurrentDisplayRule)
	{			
		[self updateAndReload];
	}
}

- (void)labelCellController:(PSLabelCellController *)labelCellController tableView:(UITableView *)tableView modifyDisplayRuleFromSelectionAtIndexPath:(NSIndexPath *)indexPath
{
	MTDisplayRule *displayRule = (MTDisplayRule *)labelCellController.model;
	if(tableView.editing)
	{
		DisplayRuleViewController *p = [[[DisplayRuleViewController alloc] initWithDisplayRule:displayRule newDisplayRule:NO] autorelease];
		p.delegate = self;
		[[self navigationController] pushViewController:p animated:YES];		
		[self retainObject:labelCellController whileViewControllerIsManaged:p];
	}
	else
	{
		[MTDisplayRule setCurrentDisplayRule:displayRule];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		[self updateAndReload];
		if(self.delegate && [self.delegate respondsToSelector:@selector(displayRulesViewController:selectedDisplayRule:)])
		{
			[self.delegate displayRulesViewController:self selectedDisplayRule:displayRule];
		}
	}
}


- (void)addDisplayRuleNavigationControlCanceled
{
	NSManagedObjectContext *moc = self.temporaryDisplayRule.managedObjectContext;
	[moc deleteObject:self.temporaryDisplayRule];
	self.temporaryDisplayRule = nil;
	NSError *error = nil;
	if(![moc save:&error])
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
	[self dismissModalViewControllerAnimated:YES];
}

- (void)labelCellController:(PSLabelCellController *)labelCellController tableView:(UITableView *)tableView addDisplayRuleFromSelectionAtIndexPath:(NSIndexPath *)indexPath
{
	self.temporaryDisplayRule = [MTDisplayRule createDisplayRuleForUser:[MTUser currentUser]];
	DisplayRuleViewController *controller = [[[DisplayRuleViewController alloc] initWithDisplayRule:self.temporaryDisplayRule newDisplayRule:YES] autorelease];
	controller.delegate = self;
	
	// push the element view controller onto the navigation stack to display it
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
	
	// create a custom navigation bar button and set it to always say "back"
	UIBarButtonItem *temporaryBarButtonItem = [[[UIBarButtonItem alloc] init] autorelease];
	temporaryBarButtonItem.title = NSLocalizedString(@"Cancel", @"Cancel button");
	
	controller.title = NSLocalizedString(@"New Display Rule", @"Title for the Sorted By ... area when you are editing the display rules");
	[self presentModalViewController:navigationController animated:YES];
	[temporaryBarButtonItem setAction:@selector(addDisplayRuleNavigationControlCanceled)];
	[temporaryBarButtonItem setTarget:self];
	controller.navigationItem.leftBarButtonItem = temporaryBarButtonItem;
	
	[self retainObject:controller whileViewControllerIsManaged:controller];
}

- (void)constructSectionControllers
{
	[super constructSectionControllers];
	MTUser *currentUser = [MTUser currentUser];
	MTDisplayRule *currentDisplayRule = [MTDisplayRule currentDisplayRule];
	
	{
		NSArray *displayRules = [managedObjectContext fetchObjectsForEntityName:[MTDisplayRule entityName]
															  propertiesToFetch:[NSArray arrayWithObject:@"name"] 
															withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"order" ascending:YES] ]
																  withPredicate:@"internal == YES && user == %@", currentUser];
		
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		sectionController.editingTitle = NSLocalizedString(@"MyTime Display Rules", @"Title of the section when editing the display rules, this title defines the 'X Sorted' tabs' sort/display rules");
		sectionController.editingFooter = NSLocalizedString(@"These display rules are used in MyTime for all of the street, city, date, name, study, etc. sorted views", @"this is the description in the Display Rules view when you are editing the display rules");
		sectionController.isViewableWhenEditing = YES;
		sectionController.isViewableWhenNotEditing = NO;
		[self.sectionControllers addObject:sectionController];
		[sectionController release];
		
		for(MTDisplayRule *displayRule in displayRules)
		{
			PSLabelCellController *cellController = [[[PSLabelCellController alloc] init] autorelease];
			cellController.model = displayRule;
			cellController.modelPath = @"name";
			cellController.indentWhileEditing = NO;
			cellController.editingStyle = displayRule.deleteableValue ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
			cellController.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
			[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:modifyDisplayRuleFromSelectionAtIndexPath:)];
			[cellController setDeleteTarget:self action:@selector(labelCellController:tableView:deleteDisplayRuleAtIndexPath:)];
			[self addCellController:cellController toSection:sectionController];
		}
	}	
	
	{
		NSArray *displayRules = [managedObjectContext fetchObjectsForEntityName:[MTDisplayRule entityName]
															  propertiesToFetch:[NSArray arrayWithObject:@"name"] 
															withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"order" ascending:YES] ]
																  withPredicate:@"user == %@", currentUser];
		
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		sectionController.editingTitle = NSLocalizedString(@"User Defined Display Rules", @"Title for the Display rules section when editing the display rules");
		[self.sectionControllers addObject:sectionController];
		[sectionController release];
		
		for(MTDisplayRule *displayRule in displayRules)
		{
			PSLabelCellController *cellController = [[[PSLabelCellController alloc] init] autorelease];
			cellController.model = displayRule;
			cellController.modelPath = @"name";
			cellController.isViewableWhenEditing = !displayRule.internalValue;
			cellController.editingStyle = displayRule.deleteableValue ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
			cellController.accessoryType = displayRule == currentDisplayRule ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
			cellController.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
			[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:modifyDisplayRuleFromSelectionAtIndexPath:)];
			[cellController setDeleteTarget:self action:@selector(labelCellController:tableView:deleteDisplayRuleAtIndexPath:)];
			[self addCellController:cellController toSection:sectionController];
		}
		
		// add the "Add Display Rule" cell at the end
		{
			PSLabelCellController *cellController = [[[PSLabelCellController alloc] init] autorelease];
			cellController.title = NSLocalizedString(@"Add New Display Rule", @"Button to click to add an additional sort or filter rule for the Sorted By ... view");
			cellController.isViewableWhenNotEditing = NO;
			cellController.editingStyle = UITableViewCellEditingStyleInsert;
			[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:addDisplayRuleFromSelectionAtIndexPath:)];
			[cellController setInsertTarget:self action:@selector(labelCellController:tableView:addDisplayRuleFromSelectionAtIndexPath:)];
			[self addCellController:cellController toSection:sectionController];
		}
	}
}

@end
