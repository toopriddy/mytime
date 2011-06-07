//
//  MultipleUsersViewController.m
//  MyTime
//
//  Created by Brent Priddy on 6/12/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "MultipleUsersViewController.h"
#import "TableViewCellController.h"
#import "MTUser.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "UITableViewTitleAndValueCell.h"
#import "GenericTableViewSectionController.h"
#import "MetadataEditorViewController.h"
#import "MetadataCustomViewController.h"
#import "PSLocalization.h"

@interface MultipleUsersCellController : NSObject<TableViewCellController, MetadataEditorViewControllerDelegate, UIActionSheetDelegate>
{
	MultipleUsersViewController *delegate;
}
@property (nonatomic, assign) MultipleUsersViewController *delegate;
@property (nonatomic, retain) MTUser *user;
@end
@implementation MultipleUsersCellController
@synthesize delegate;
@synthesize user;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"MultipleUserCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	
	cell.textLabel.text = self.user.name;
	
	cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.accessoryType = [[[MTUser currentUser] name] isEqualToString:self.user.name] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
	return cell;
}

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete)
	{
		UIActionSheet *alertSheet = [[[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Are you sure that you want to DELETE ALL USER DATA for %@?\n\nYou can not recover from this action, you will DELETE all of your calls, hours, and other statistics for this user. Are you really sure you want to do this?", @"Multiple Users: question asked when the user wants to delete a user's data"), self.user.name]
																 delegate:self
														cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
												   destructiveButtonTitle:NSLocalizedString(@"Delete All Data", @"Transferr this call to another MyTime user and delete it off of this iphone, but keep the data")
														otherButtonTitles:nil] autorelease];
		alertSheet.tag = indexPath.row;
		alertSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
		[alertSheet showInView:self.delegate.view];
	}
}

- (void)metadataEditorViewControllerDone:(MetadataEditorViewController *)metadataEditorViewController
{
	NSString *newName = metadataEditorViewController.value;
	NSString *oldName = self.user.name;
	NSManagedObjectContext *managedObjectContext = self.delegate.managedObjectContext;
	
	if([oldName isEqualToString:newName])
	{
		[metadataEditorViewController.navigationController popViewControllerAnimated:YES];
		return;
	}
	
	if(newName.length == 0)
	{
		// we need to make sure that they entered in a name
		UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
		[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
		alertSheet.title = NSLocalizedString(@"Please enter a name since you have more than one user of MyTime", @"Multiple Users: This message is displayed when fails to enter a username when there is more than one user in the system");
		[alertSheet show];
		return;
	}
	if([[managedObjectContext fetchObjectsForEntityName:[MTUser entityName]
									  propertiesToFetch:nil 
									withSortDescriptors:nil
										  withPredicate:@"name == %@", newName] count])
	{
		// need to popup a warning that someone is already named that name
		UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
		[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
		alertSheet.title = NSLocalizedString(@"There is already a user with this name", @"Multiple Users: This message is displayed when the user is renaming their name and it matches another user's name");
		[alertSheet show];
		return;
	}
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




// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(tableView.editing)
	{
		MetadataEditorViewController *p = [[[MetadataEditorViewController alloc] initWithName:NSLocalizedString(@"Your Name", @"The title used in the Settings->Multiple Users screen") type:STRING data:self.user.name value:self.user.name] autorelease];
		[p setAutocapitalizationType:UITextAutocapitalizationTypeWords];
		p.delegate = self;
		[[self.delegate navigationController] pushViewController:p animated:YES];		
		[self.delegate retainObject:self whileViewControllerIsManaged:p];
	}
	else
	{
		[MTUser setCurrentUser:self.user];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		[self.delegate updateWithoutReload];
		if(self.delegate.delegate && [self.delegate.delegate respondsToSelector:@selector(multipleUsersViewController:selectedUser:)])
		{
			[self.delegate.delegate multipleUsersViewController:self.delegate selectedUser:self.user];
		}
		[[self.delegate navigationController] popViewControllerAnimated:YES];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)button
{
	switch(button)
	{
			//delete
		case 0:
		{
			MTUser *currentUser = [MTUser currentUser];
			BOOL wasCurrentUser = currentUser == self.user;
			if(wasCurrentUser)
			{
				[MTUser setCurrentUser:nil];
			}
			[self.user relinquish];
			[self.delegate.managedObjectContext deleteObject:self.user];
			NSError *error = nil;
			if (![self.delegate.managedObjectContext save:&error]) 
			{
				[NSManagedObjectContext presentErrorDialog:error];
			}
			[[self retain] autorelease];
			[self.delegate deleteDisplayRowAtIndexPath:[NSIndexPath indexPathForRow:actionSheet.tag inSection:0]];
			if(wasCurrentUser)
			{
				[MTUser currentUser];
				[self.delegate updateAndReload];
			}
			break;
		}
			//cancel
		case 1:
			[self.delegate updateAndReload];
			break;
	}
}		

@end

@interface AddMultipleUsersCellController : NSObject<TableViewCellController, MetadataEditorViewControllerDelegate>
{
	MultipleUsersViewController *delegate;
	NSIndexPath *selectedIndexPath;
}
@property (nonatomic, copy) NSIndexPath *selectedIndexPath;
@property (nonatomic, assign) MultipleUsersViewController *delegate;
- (BOOL)addUser:(NSString *)name;
@end
@implementation AddMultipleUsersCellController
@synthesize delegate;
@synthesize selectedIndexPath;

- (void)dealloc
{
	self.selectedIndexPath = nil;
	[super dealloc];
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
	
	[cell setValue:NSLocalizedString(@"Add Additional User", @"Button to click to add an additional user to MyTime")];
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

- (void)metadataEditorViewControllerDone:(MetadataEditorViewController *)metadataEditorViewController
{
	if([self addUser:metadataEditorViewController.value])
	{
		[metadataEditorViewController.navigationController popViewControllerAnimated:YES];
	}
}


// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.selectedIndexPath = indexPath;
	// make the new call view 
	MetadataEditorViewController *p = [[[MetadataEditorViewController alloc] initWithName:NSLocalizedString(@"Your Name", @"The title used in the Settings->Multiple Users screen") type:STRING data:@"" value:@""] autorelease];
	p.delegate = self;
	
	[[self.delegate navigationController] pushViewController:p animated:YES];		
	[self.delegate retainObject:self whileViewControllerIsManaged:p];
}

- (BOOL)addUser:(NSString *)name
{
	NSManagedObjectContext *managedObjectContext = self.delegate.managedObjectContext;
	if([[managedObjectContext fetchObjectsForEntityName:[MTUser entityName]
									  propertiesToFetch:nil 
									withSortDescriptors:nil
										  withPredicate:@"name == %@", name] count])
	{
		// need to popup a warning that someone is already named that name
		UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
		[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
		alertSheet.title = NSLocalizedString(@"There is already a user with this name", @"Multiple Users: This message is displayed when the user is renaming their name and it matches another user's name");
		[alertSheet show];
		return NO;
	}
	MTUser *user = [MTUser createUserInManagedObjectContext:managedObjectContext];
	user.name = name;
	[user initalizeUser];

	NSError *error = nil;
	if (![managedObjectContext save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}

	MultipleUsersCellController *cellController = [[[MultipleUsersCellController alloc] init] autorelease];
	cellController.delegate = self.delegate;
	cellController.user = user;
	[[[self.delegate.sectionControllers objectAtIndex:0] cellControllers] insertObject:cellController atIndex:[self.selectedIndexPath row]];
	
	[self.delegate updateWithoutReload];
	return YES;
}


@end


@implementation MultipleUsersViewController
@synthesize delegate;
@synthesize managedObjectContext;

- (id) init;
{
	if ([super initWithStyle:UITableViewStyleGrouped]) 
	{
		// set the title, and tab bar images from the dataSource
		// object. 
		self.title = NSLocalizedString(@"Select User", @"Multiple Users View title");
		
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
	return(YES);
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

	NSArray *users = [managedObjectContext fetchObjectsForEntityName:[MTUser entityName]
												   propertiesToFetch:[NSArray arrayWithObject:@"name"] 
												 withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"order" ascending:YES] ]
													   withPredicate:nil];
	
	GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
	sectionController.editingFooter = NSLocalizedString(@"Please note that if you delete a user ALL of your data will be DELETED for that user, this includes calls, return visits, hours, EVERYTHING!", @"This is the warning message that shows up in the More->Settings->Multiple Users when you are editing the user");
	[self.sectionControllers addObject:sectionController];
	[sectionController release];

	for(MTUser *user in users)
	{
		MultipleUsersCellController *cellController = [[MultipleUsersCellController alloc] init];
		cellController.delegate = self;
		cellController.user = user;
		[sectionController.cellControllers addObject:cellController];
		[cellController release];
	}

	// add the "Add Additional User" cell at the end
	AddMultipleUsersCellController *addCellController = [[AddMultipleUsersCellController alloc] init];
	addCellController.delegate = self;
	[sectionController.cellControllers addObject:addCellController];
	[addCellController release];
	
}

@end
