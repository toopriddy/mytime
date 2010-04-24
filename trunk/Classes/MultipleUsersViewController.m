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
#import "Settings.h"
#import "UITableViewTitleAndValueCell.h"
#import "GenericTableViewSectionController.h"
#import "MetadataEditorViewController.h"
#import "MetadataCustomViewController.h"
#import "PSLocalization.h"

@interface MultipleUsersCellController : NSObject<TableViewCellController, MetadataEditorViewControllerDelegate>
{
	MultipleUsersViewController *delegate;
}
@property (nonatomic, assign) MultipleUsersViewController *delegate;
@end
@implementation MultipleUsersCellController
@synthesize delegate;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSArray *users = [[[Settings sharedInstance] settings] objectForKey:SettingsMultipleUsers];
	NSMutableDictionary *user = [users objectAtIndex:indexPath.row];
	NSString *currentUser = [[[Settings sharedInstance] settings] objectForKey:SettingsMultipleUsersCurrentUser];
	NSString *name = [user objectForKey:SettingsMultipleUsersName];
	
	NSString *commonIdentifier = @"MultipleUserCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	
	cell.textLabel.text = name;
	
	cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.accessoryType = [currentUser isEqualToString:name] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
	return cell;
}

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete)
	{
		[self.delegate deleteUser:indexPath.row];
	}
}

- (void)metadataEditorViewControllerDone:(MetadataEditorViewController *)metadataEditorViewController
{
	[self.delegate renameUser:metadataEditorViewController.tag toName:metadataEditorViewController.value];
	self.delegate.forceReload = YES;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableArray *users = [[[Settings sharedInstance] settings] objectForKey:SettingsMultipleUsers];
	NSMutableDictionary *user = [users objectAtIndex:indexPath.row];
	NSString *username = [user objectForKey:SettingsMultipleUsersName];
	if(tableView.editing)
	{
		MetadataEditorViewController *p = [[[MetadataEditorViewController alloc] initWithName:NSLocalizedString(@"Your Name", @"The title used in the Settings->Multiple Users screen") type:STRING data:username value:username] autorelease];
		[p setAutocapitalizationType:UITextAutocapitalizationTypeWords];
		p.delegate = self;
		p.tag = indexPath.row;
		[[self.delegate navigationController] pushViewController:p animated:YES];		
		[self.delegate retainObject:self whileViewControllerIsManaged:p];
	}
	else
	{
		[self.delegate changeToUser:indexPath.row];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		[self.delegate updateWithoutReload];
		if(self.delegate.delegate && [self.delegate.delegate respondsToSelector:@selector(multipleUsersViewController:selectedUser:)])
		{
			[self.delegate.delegate multipleUsersViewController:self.delegate selectedUser:username];
		}
		[[self.delegate navigationController] popViewControllerAnimated:YES];
	}
}

// Editing

@end

@interface AddMultipleUsersCellController : NSObject<TableViewCellController, MetadataEditorViewControllerDelegate>
{
	MultipleUsersViewController *delegate;
}
@property (nonatomic, assign) MultipleUsersViewController *delegate;
@end
@implementation AddMultipleUsersCellController
@synthesize delegate;

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
	[self.delegate addUser:metadataEditorViewController.value];
}


// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// make the new call view 
	MetadataEditorViewController *p = [[[MetadataEditorViewController alloc] initWithName:NSLocalizedString(@"Your Name", @"The title used in the Settings->Multiple Users screen") type:STRING data:@"" value:@""] autorelease];
	p.delegate = self;
	
	[[self.delegate navigationController] pushViewController:p animated:YES];		
	[self.delegate retainObject:self whileViewControllerIsManaged:p];
}


@end


@interface MultipleUsersSectionController : GenericTableViewSectionController
{
}
@end
@implementation MultipleUsersSectionController

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if(tableView.editing)
		return NSLocalizedString(@"Please note that if you delete a user ALL of your data will be DELETED for that user, this includes calls, return visits, hours, EVERYTHING!", @"This is the warning message that shows up in the More->Settings->Multiple Users when you are editing the user");
	else
		return nil;
}
@end



@implementation MultipleUsersViewController
@synthesize delegate;

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

- (BOOL)renameUser:(int)index toName:(NSString *)newName
{
	NSMutableArray *users = [[[Settings sharedInstance] settings] objectForKey:SettingsMultipleUsers];
	NSString *oldName = [[[[[Settings sharedInstance] settings] objectForKey:SettingsMultipleUsers] objectAtIndex:index] objectForKey:SettingsMultipleUsersName];

	if([oldName isEqualToString:newName])
	{
		return YES;
	}
	
	if(newName.length == 0 && users.count > 1)
	{
		// we need to make sure that they entered in a name
		UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
		[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
		alertSheet.title = [NSString stringWithFormat:NSLocalizedString(@"Please enter a name since you have more than one user of MyTime", @"Multiple Users: This message is displayed when fails to enter a username when there is more than one user in the system")];
		[alertSheet show];
		return NO;
	}
	for(NSMutableDictionary *user in users)
	{
		if([newName isEqualToString:[user objectForKey:SettingsMultipleUsersName]])
		{
			// need to popup a warning that someone is already named that name
			UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
			[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
			alertSheet.title = [NSString stringWithFormat:NSLocalizedString(@"There is already a user with this name", @"Multiple Users: This message is displayed when the user is renaming their name and it matches another user's name")];
			[alertSheet show];
			return NO;
		}
	}
	NSString *currentUser = [[[Settings sharedInstance] settings] objectForKey:SettingsMultipleUsersCurrentUser];
	if([currentUser isEqualToString:oldName])
	{
		[[[Settings sharedInstance] settings] setObject:newName forKey:SettingsMultipleUsersCurrentUser];
	}
	NSMutableDictionary *user = [[[[Settings sharedInstance] settings] objectForKey:SettingsMultipleUsers] objectAtIndex:index];
	[user setObject:newName forKey:SettingsMultipleUsersName];

	[[Settings sharedInstance] saveData];
	return YES;
}

- (BOOL)addUser:(NSString *)name
{
	NSMutableArray *users = [[[Settings sharedInstance] settings] objectForKey:SettingsMultipleUsers];

	for(NSMutableDictionary *user in users)
	{
		if([name isEqualToString:[user objectForKey:SettingsMultipleUsersName]])
		{
			// need to popup a warning that someone is already named that name
			UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
			[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
			alertSheet.title = [NSString stringWithFormat:NSLocalizedString(@"There is already a user with this name", @"Multiple Users: This message is displayed when the user is renaming their name and it matches another user's name")];
			[alertSheet show];
			return NO;
		}
	}
	MultipleUsersCellController *cellController = [[[MultipleUsersCellController alloc] init] autorelease];
	cellController.delegate = self;
	[[[self.sectionControllers objectAtIndex:0] cellControllers] insertObject:cellController atIndex:users.count];
	[users addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:name, SettingsMultipleUsersName, nil]];
	[[Settings sharedInstance] saveData];


	[self updateWithoutReload];
	return YES;
}

- (void)deleteUser:(int)index
{
	NSString *name = [[[[[Settings sharedInstance] settings] objectForKey:SettingsMultipleUsers] objectAtIndex:index] objectForKey:SettingsMultipleUsersName];
	UIActionSheet *alertSheet = [[[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Are you sure that you want to DELETE ALL USER DATA for %@?\n\nYou can not recover from this action, you will DELETE all of your calls, hours, and other statistics for this user. Are you really sure you want to do this?", @"Multiple Users: question asked when the user wants to delete a user's data"), name]
															 delegate:self
												    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
											   destructiveButtonTitle:NSLocalizedString(@"Delete All Data", @"Transferr this call to another MyTime user and delete it off of this iphone, but keep the data")
												    otherButtonTitles:nil] autorelease];
	
	alertSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	alertSheet.tag = index;
	[alertSheet showInView:self.view];
}

- (void)initalizeDefaultUser
{
	NSMutableArray *users = [[[Settings sharedInstance] settings] objectForKey:SettingsMultipleUsers];
	if(users == nil)
	{
		users = [NSMutableArray array];
	}
	NSString *username = NSLocalizedString(@"Default User", @"Multiple Users: the default user name when the user has not entered a name for themselves");
	[users addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:username, SettingsMultipleUsersName, nil]];
	
	[[[Settings sharedInstance] settings] setObject:users forKey:SettingsMultipleUsers];
	[[[Settings sharedInstance] settings] setObject:username forKey:SettingsMultipleUsersCurrentUser];
	
	[self updateAndReload];
}

- (void)changeToUser:(int)index
{
	NSMutableArray *users = [[[Settings sharedInstance] settings] objectForKey:SettingsMultipleUsers];
	NSMutableDictionary *user = [users objectAtIndex:index];
	
	[[Settings sharedInstance] changeSettingsToUser:[user objectForKey:SettingsMultipleUsersName] save:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)button
{
	VERBOSE(NSLog(@"alertSheet: button:%d", button);)
	switch(button)
	{
		//delete
		case 0:
		{
			NSMutableArray *users = [[[Settings sharedInstance] settings] objectForKey:SettingsMultipleUsers];
			NSString *currentUser = [[[Settings sharedInstance] settings] objectForKey:SettingsMultipleUsersCurrentUser];
			NSMutableDictionary *user = [users objectAtIndex:actionSheet.tag];
			BOOL changeUser = [currentUser isEqualToString:[user objectForKey:SettingsMultipleUsersName]];
			
			[users removeObjectAtIndex:actionSheet.tag];
			[self deleteDisplayRowAtIndexPath:[NSIndexPath indexPathForRow:actionSheet.tag inSection:0]];
			if(users.count == 0)
			{
				[self initalizeDefaultUser];
			}
			if(changeUser)
			{
				[self changeToUser:0];
				[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
			}
			[[Settings sharedInstance] saveData];
			break;
		}
		//cancel
		case 1:
			[self.tableView reloadData];
			break;
	}
}		

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return(YES);
}

- (void)navigationControlEdit:(id)sender 
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	
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
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)

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
	NSMutableArray *users = [[[Settings sharedInstance] settings] objectForKey:SettingsMultipleUsers];
	if(users == nil)
	{
		[self initalizeDefaultUser];
	}
	[super loadView];

	[self updateAndReload];
	
	[self navigationControlDone:nil];
}

- (void)constructSectionControllers
{
	[super constructSectionControllers];

	NSArray *users = [[[Settings sharedInstance] settings] objectForKey:SettingsMultipleUsers];

	GenericTableViewSectionController *sectionController = [[MultipleUsersSectionController alloc] init];
	[self.sectionControllers addObject:sectionController];
	[sectionController release];

	for(NSMutableDictionary *entry in users)
	{
		MultipleUsersCellController *cellController = [[MultipleUsersCellController alloc] init];
		cellController.delegate = self;
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
