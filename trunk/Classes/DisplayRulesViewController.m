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
#import "MTUser.h"
#import "MTDisplayRule.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "UITableViewTitleAndValueCell.h"
#import "PSLocalization.h"

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

- (void)displayRuleViewControllerDone:(DisplayRuleViewController *)displayRuleViewController
{
	NSManagedObjectContext *managedObjectContext = self.delegate.managedObjectContext;
	
	MTUser *currentUser = [MTUser currentUser];
	self.user.name = newName;
	if(currentUser == self.user)
	{
		[MTUser setCurrentUser:self.user];
	}
	
	NSError *error = nil;
	if (![managedObjectContext save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
	self.delegate.forceReload = YES;
	[metadataEditorViewController.navigationController popViewControllerAnimated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"MultipleUserCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	
	cell.textLabel.text = self.displayRule.name;
	
	cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.accessoryType = [self.delegate.selectedDisplayRule.name isEqualToString:self.displayRule.name] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
	return cell;
}

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete)
	{
		MTDisplayRule *currentDisplayRule = [MTDisplayRule currentDisplayRule];
		[self.delegate.managedObjectContext deleteObject:self.displayRule];
		NSError *error = nil;
		if (![self.delegate.managedObjectContext save:&error]) 
		{
			[NSManagedObjectContext presentErrorDialog:error];
		}
		[[self retain] autorelease];
		[self.delegate deleteDisplayRowAtIndexPath:[NSIndexPath indexPathForRow:actionSheet.tag inSection:0]];
		if(self.displayRule = currentDisplayRule)
		{
			[MTUser setCurrentDisplayRule:nil];
			[MTUser currentDisplayRule];
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
@end

@interface AddDisplayRuleCellController : NSObject<TableViewCellController, MetadataEditorViewControllerDelegate>
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
	MTUser *currentUser = [MTUser currentUser];
	self.user.name = newName;
	if(currentUser == self.user)
	{
		[MTUser setCurrentUser:self.user];
	}
	
	NSError *error = nil;
	if (![managedObjectContext save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
	self.temporaryDisplayRule = nil;
	self.delegate.forceReload = YES;
	[metadataEditorViewController.navigationController popViewControllerAnimated:YES];
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
	
	[cell setValue:NSLocalizedString(@"Add New Sort Rule", @"Button to click to add an additional sort or filter rule for the Sorted By ... view")];
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
	[moc deleteObject:self.temporaryStreet];
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
	[self.delegate resignAllFirstResponders];
	
	self.temporaryDisplayRule = [MTDisplayRule insertInManagedObjectContext:self.delegate.managedObjectContext];
	self.temporaryDisplayRule.user = [MTUser currentUser];
	NotAtHomeStreetViewController *controller = [[[DisplayRuleViewController alloc] initWithDisplayRule:self.temporaryDisplayRule newDisplayRule:YES] autorelease];
	controller.delegate = self;
	
	// push the element view controller onto the navigation stack to display it
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
	
	// create a custom navigation bar button and set it to always say "back"
	UIBarButtonItem *temporaryBarButtonItem = [[[UIBarButtonItem alloc] init] autorelease];
	temporaryBarButtonItem.title = NSLocalizedString(@"Cancel", @"Cancel button");
	
	controller.title = NSLocalizedString(@"Add Sort Rule", @"Title for the Sorted By ... area when you are editing the display rules");
	[self.delegate presentModalViewController:navigationController animated:YES];
	[temporaryBarButtonItem setAction:@selector(navigationControlCanceled)];
	[temporaryBarButtonItem setTarget:self];
	controller.navigationItem.leftBarButtonItem = temporaryBarButtonItem;
	
	[self.delegate retainObject:self whileViewControllerIsManaged:controller];
}

- (void)displayRuleViewControllerDone:(DisplayRuleViewController *)displayRuleViewController
{
	self.temporaryDisplayRule = nil;
	NSError *error = nil;
	if(![self.delegate.managedObjectContext save:&error])
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
	
	[self.delegate dismissModalViewControllerAnimated:YES];
	[self.delegate updateAndReload];
}
@end

@implementation DisplayRulesViewController
@synthesize delegate;
@synthesize managedObjectContext;

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

- (void)constructSectionControllers
{
	[super constructSectionControllers];
	
	NSArray *users = [managedObjectContext fetchObjectsForEntityName:[MTDisplayRule entityName]
												   propertiesToFetch:[NSArray arrayWithObject:@"name"] 
												 withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"order" ascending:YES] ]
													   withPredicate:nil];
	
	GenericTableViewSectionController *sectionController = [[DisplayRulesSectionController alloc] init];
	[self.sectionControllers addObject:sectionController];
	[sectionController release];
	
	for(MTDisplayRule *displayRule in displayRules)
	{
		DisplayRuleCellController *cellController = [[DisplayRuleCellController alloc] init];
		cellController.delegate = self;
		cellController.displayRule = displayRule;
		[sectionController.cellControllers addObject:cellController];
		[cellController release];
	}
	
	// add the "Add Additional User" cell at the end
	AddDisplayRuleCellController *addCellController = [[AddDisplayRuleCellController alloc] init];
	addCellController.delegate = self;
	[sectionController.cellControllers addObject:addCellController];
	[addCellController release];
	
}

@end
