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

#if 0
@interface DisplayRuleCellController : NSObject<TableViewCellController, DisplayRuleViewControllerDelegate, UIActionSheetDelegate>
{
	DisplayRulesViewController *delegate;
	BOOL wasSelected;
}
@property (nonatomic, assign) DisplayRulesViewController *delegate;
@property (nonatomic, retain) MTDisplayRule *displayRule;
@end
@implementation DisplayRuleCellController
@synthesize delegate;
@synthesize displayRule;

- (void)dealloc
{
	self.displayRule = nil;
	
	[super dealloc];
}

- (void)displayRuleViewControllerDone:(DisplayRuleViewController *)displayRuleViewController
{
	NSManagedObjectContext *managedObjectContext = self.delegate.managedObjectContext;
	
	NSError *error = nil;
	if (![managedObjectContext save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
	self.delegate.forceReload = YES;
	[displayRuleViewController.navigationController popViewControllerAnimated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"MultipleUserCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	MTUser *currentUser = [MTUser currentUser];
	cell.textLabel.text = self.displayRule.name;
	
	cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.accessoryType = currentUser.currentDisplayRule  == self.displayRule ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
	return cell;
}

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete)
	{
		MTDisplayRule *currentDisplayRule = [MTDisplayRule currentDisplayRule];
		BOOL wasCurrentDisplayRule = currentDisplayRule == self.displayRule;
		MTUser *currentUser = [MTUser currentUser];
		if(wasCurrentDisplayRule)
			currentUser.currentDisplayRule = nil;
		
		[self.delegate.managedObjectContext deleteObject:self.displayRule];
		NSError *error = nil;
		if (![self.delegate.managedObjectContext save:&error]) 
		{
			[NSManagedObjectContext presentErrorDialog:error];
		}
		[[self retain] autorelease];
		[self.delegate deleteDisplayRowAtIndexPath:indexPath];
		if(wasCurrentDisplayRule)
		{			
			[MTDisplayRule currentDisplayRule];
			[self.delegate updateAndReload];
		}
	}
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(tableView.editing)
	{
		DisplayRuleViewController *p = [[[DisplayRuleViewController alloc] initWithDisplayRule:self.displayRule] autorelease];
		p.delegate = self;
		[[self.delegate navigationController] pushViewController:p animated:YES];		
		[self.delegate retainObject:self whileViewControllerIsManaged:p];
	}
	else
	{
		[MTDisplayRule setCurrentDisplayRule:self.displayRule];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		[self.delegate updateWithoutReload];
		if(self.delegate.delegate && [self.delegate.delegate respondsToSelector:@selector(displayRulesViewController:selectedDisplayRule:)])
		{
			[self.delegate.delegate displayRulesViewController:self.delegate selectedDisplayRule:self.displayRule];
		}
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return self.displayRule.deleteable ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}


@end

@interface AddDisplayRuleCellController : NSObject<TableViewCellController, DisplayRuleViewControllerDelegate>
{
	DisplayRulesViewController *delegate;
	MTDisplayRule *temporaryDisplayRule;
}
@property (nonatomic, retain) MTDisplayRule *temporaryDisplayRule;
@property (nonatomic, assign) DisplayRulesViewController *delegate;
@end
@implementation AddDisplayRuleCellController
@synthesize delegate;
@synthesize temporaryDisplayRule;

- (void)dealloc
{
	self.temporaryDisplayRule = nil;
	[super dealloc];
}

- (void)displayRuleViewControllerDone:(DisplayRuleViewController *)displayRuleViewController
{
	NSManagedObjectContext *managedObjectContext = self.delegate.managedObjectContext;
	// let the MTDisplayRule sort out what is the currentDisplayRule if this is adding the first one
	[MTDisplayRule currentDisplayRule];
	
	NSError *error = nil;
	if (![managedObjectContext save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
	self.temporaryDisplayRule = nil;
	[self.delegate dismissModalViewControllerAnimated:YES];
	[self.delegate updateAndReload];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"AddMultipleUserCell";
	UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewTitleAndValueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	[cell setValue:NSLocalizedString(@"Add New Display Rule", @"Button to click to add an additional sort or filter rule for the Sorted By ... view")];
	return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleInsert;
}

- (BOOL)isViewableWhenNotEditing
{
	return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)navigationControlCanceled
{
	NSManagedObjectContext *moc = self.temporaryDisplayRule.managedObjectContext;
	[moc deleteObject:self.temporaryDisplayRule];
	self.temporaryDisplayRule = nil;
	NSError *error = nil;
	if(![moc save:&error])
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
	[self.delegate dismissModalViewControllerAnimated:YES];
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.temporaryDisplayRule = [MTDisplayRule insertInManagedObjectContext:self.delegate.managedObjectContext];
	self.temporaryDisplayRule.user = [MTUser currentUser];
	DisplayRuleViewController *controller = [[[DisplayRuleViewController alloc] initWithDisplayRule:self.temporaryDisplayRule newDisplayRule:YES] autorelease];
	controller.delegate = self;
	
	// push the element view controller onto the navigation stack to display it
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
	
	// create a custom navigation bar button and set it to always say "back"
	UIBarButtonItem *temporaryBarButtonItem = [[[UIBarButtonItem alloc] init] autorelease];
	temporaryBarButtonItem.title = NSLocalizedString(@"Cancel", @"Cancel button");
	
	controller.title = NSLocalizedString(@"New Display Rule", @"Title for the Sorted By ... area when you are editing the display rules");
	[self.delegate presentModalViewController:navigationController animated:YES];
	[temporaryBarButtonItem setAction:@selector(navigationControlCanceled)];
	[temporaryBarButtonItem setTarget:self];
	controller.navigationItem.leftBarButtonItem = temporaryBarButtonItem;
	
	[self.delegate retainObject:self whileViewControllerIsManaged:controller];
}
@end
#endif

@implementation DisplayRulesViewController
@synthesize delegate;
@synthesize managedObjectContext;
@synthesize temporaryDisplayRule;

- (id) init;
{
	if ([super initWithStyle:UITableViewStyleGrouped]) 
	{
		// set the title, and tab bar images from the dataSource
		// object. 
		self.title = NSLocalizedString(@"Select Sort Rule", @"Sort Rules View title");
		
		self.hidesBottomBarWhenPushed = YES;
	}
	return self;
}

- (void)dealloc 
{
	self.temporaryDisplayRule = nil;
	self.tableView.delegate = nil;
	self.tableView.dataSource = nil;
	
	self.tableView = nil;
	
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
	
	[self updateAndReload];
	
	[self navigationControlDone:nil];
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
}


- (void)labelCellController:(PSLabelCellController *)labelCellController tableView:(UITableView *)tableView deleteSorterAtIndexPath:(NSIndexPath *)indexPath
{
	MTDisplayRule *displayRule = (MTDisplayRule *)labelCellController.model;
	MTDisplayRule *currentDisplayRule = [MTDisplayRule currentDisplayRule];
	BOOL wasCurrentDisplayRule = currentDisplayRule == displayRule;
	MTUser *currentUser = [MTUser currentUser];
	if(wasCurrentDisplayRule)
		currentUser.currentDisplayRule = nil;
	
	[self.managedObjectContext deleteObject:displayRule];
	NSError *error = nil;
	if (![self.managedObjectContext save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
	[[self retain] autorelease];
	[self deleteDisplayRowAtIndexPath:indexPath];
	if(wasCurrentDisplayRule)
	{			
		[MTDisplayRule currentDisplayRule];
		[self updateAndReload];
	}
}

- (void)labelCellController:(PSLabelCellController *)labelCellController tableView:(UITableView *)tableView modifySorterFromSelectionAtIndexPath:(NSIndexPath *)indexPath
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
		[self updateWithoutReload];
		if(self.delegate && [self.delegate respondsToSelector:@selector(displayRulesViewController:selectedDisplayRule:)])
		{
			[self.delegate displayRulesViewController:self selectedDisplayRule:displayRule];
		}
	}
}


- (void)addSorterNavigationControlCanceled
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

- (void)labelCellController:(PSLabelCellController *)labelCellController tableView:(UITableView *)tableView addSorterFromSelectionAtIndexPath:(NSIndexPath *)indexPath
{
	self.temporaryDisplayRule = [MTDisplayRule insertInManagedObjectContext:self.managedObjectContext];
	self.temporaryDisplayRule.user = [MTUser currentUser];
	DisplayRuleViewController *controller = [[[DisplayRuleViewController alloc] initWithDisplayRule:self.temporaryDisplayRule newDisplayRule:YES] autorelease];
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
	
	NSArray *displayRules = [managedObjectContext fetchObjectsForEntityName:[MTDisplayRule entityName]
														  propertiesToFetch:[NSArray arrayWithObject:@"name"] 
														withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"order" ascending:YES] ]
															  withPredicate:nil];
	
	GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
	[self.sectionControllers addObject:sectionController];
	[sectionController release];
	
	for(MTDisplayRule *displayRule in displayRules)
	{
		PSLabelCellController *cellController = [[[PSLabelCellController alloc] init] autorelease];
		cellController.model = displayRule;
		cellController.modelPath = @"name";
		[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:modifySorterFromSelectionAtIndexPath:)];
		[cellController setDeleteTarget:self action:@selector(labelCellController:tableView:deleteSorterAtIndexPath:)];
		[sectionController.cellControllers addObject:cellController];
	}
	
	// add the "Add Additional User" cell at the end
	{
		PSLabelCellController *cellController = [[[PSLabelCellController alloc] init] autorelease];
		cellController.title = NSLocalizedString(@"Add New Display Rule", @"Button to click to add an additional sort or filter rule for the Sorted By ... view");
		[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:addSorterFromSelectionAtIndexPath:)];
		[cellController setInsertTarget:self action:@selector(labelCellController:tableView:addSorterFromSelectionAtIndexPath:)];
		[sectionController.cellControllers addObject:cellController];
	}
}

@end
