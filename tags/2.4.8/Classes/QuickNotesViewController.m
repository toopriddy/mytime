//
//  QuickNotesViewController.m
//  MyTime
//
//  Created by Brent Priddy on 8/21/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//
#if 0
#import "QuickNotesViewController.h"
#import "TableViewCellController.h"
#import "Settings.h"
#import "UITableViewTitleAndValueCell.h"
#import "GenericTableViewSectionController.h"
#import "PSLocalization.h"

@interface QuickNotesCellController : NSObject<TableViewCellController, MetadataEditorViewControllerDelegate>
{
	QuickNotesViewController *delegate;
}
@property (nonatomic, assign) QuickNotesViewController *delegate;
@end
@implementation QuickNotesViewController
@synthesize delegate;
@end


@interface AddNewNoteSectionController : QuickNotesCellController
{
}
@end
@implementation AddNewNoteSectionController

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
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier];
	}
	
	cell.textLabel.text = name;
	
	cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.accessoryType = [currentUser isEqualToString:name] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
	return cell;
}


- (void)metadataEditorViewControllerDone:(MetadataEditorViewController *)metadataEditorViewController
{
	// pass this onto the caller
	
	[self.delegate renameUser:metadataEditorViewController.tag toName:metadataEditorViewController.value];
	self.delegate.forceReload = YES;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableArray *notes = [[[Settings sharedInstance] settings] objectForKey:SettingsQuickNotes];
	NSMutableDictionary *note = [notes objectAtIndex:indexPath.row];

	// make the new call view 
	NotesViewController *p = [[[NotesViewController alloc] initWithNotes:note] autorelease];
	p.delegate = self;
	p.tag = indexPath.row;
	[[self.delegate navigationController] pushViewController:p animated:YES];		

// fix me
	if(tableView.editing)
	{
		MetadataEditorViewController *p = [[[MetadataEditorViewController alloc] initWithName:@"Your Name" type:STRING data:username value:username] autorelease];
		[p setAutocapitalizationType:UITextAutocapitalizationTypeWords];
		p.delegate = self;
		p.tag = indexPath.row;
		[[self.delegate navigationController] pushViewController:p animated:YES];		
	}
	else
	{
		[self.delegate changeToUser:indexPath.row];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		[self.delegate updateWithoutReload];
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
	MetadataEditorViewController *p = [[[MetadataEditorViewController alloc] initWithName:@"Your Name" type:STRING data:@"" value:@""] autorelease];
	p.delegate = self;
	
	[[self.delegate navigationController] pushViewController:p animated:YES];		
}


@end





@interface AddNewNoteSectionController : GenericTableViewSectionController
{
}
@end
@implementation AddNewNoteSectionController

- (BOOL)isViewableWhenEditing
{
	return NO;
}
@end



@interface FavoriteNotesSectionController : GenericTableViewSectionController
{
}
@end
@implementation FavoriteNotesSectionController

- (BOOL)isViewableWhenNotEditing
{
 	return [[[[Settings sharedInstance] userSettings] objectForKey:SettingsQuickNotes] count];
}
@end






@implementation QuickNotesViewController
@synthesize returnVistHistory;

- (id) init;
{
	if ([super initWithStyle:UITableViewStyleGrouped]) 
	{
		// set the title, and tab bar images from the dataSource
		// object. 
		self.title = NSLocalizedString(@"Quick Notes", @"Quick Notes title.  This is shown when you click on the notes to type in for a call, it is the title of the view that shows you the last several notes you have typed in");
		
		self.hidesBottomBarWhenPushed = YES;
	}
	return self;
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
	[super loadView];
	
	[self updateAndReload];
	
	[self navigationControlDone:nil];
}

- (void)constructSectionControllers
{
	[super constructSectionControllers];
	
	NSMutableDictionary *userSettings = [[Settings sharedInstance] userSettings];
	NSMutableArray *notes = [userSettings objectForKey:SettingsQuickNotes];

// Add A New Note section
	GenericTableViewSectionController *sectionController = [[AddNewNoteSectionController alloc] init];
	[self.sectionControllers addObject:sectionController];
	[sectionController release];
	
	JustNotesCellController *cellController = [[JustNotesCellController alloc] init];
	cellController.delegate = self;
	[sectionController.cellControllers addObject:cellController];
	[cellController release];
	
	GenericTableViewSectionController *sectionController = [[FavoriteNotesSectionController alloc] init];
	[self.sectionControllers addObject:sectionController];
	[sectionController release];
	
// Favorate Notes Section
	for(NSMutableDictionary *entry in notes)
	{
		QuickNotesCellController *cellController = [[FavoriteNotesCellController alloc] init];
		cellController.delegate = self;
		[sectionController.cellControllers addObject:cellController];
		[cellController release];
	}
	
	// add the "Add Additional User" cell at the end
	AddMultipleUsersCellController *addCellController = [[AddFavoriteNotesCellController alloc] init];
	addCellController.delegate = self;
	[sectionController.cellControllers addObject:addCellController];
	[addCellController release];

// Notes History Section
	NSArray *returnVisits = [[userSettings objectForKey:SettingsCalls] valueForKeyPath:CallReturnVisits];
	self.returnVistHistory = [returnVisits sortedArrayUsingDescriptors:[[NSSortDescriptor alloc] initWithKey:CallReturnVisitDate ascending:NO]];

	int i = 0;
	for(NSMutableDictionary *entry in self.returnVistHistory)
	{
		i++;
		QuickNotesCellController *cellController = [[NotesHistoryCellController alloc] init];
		cellController.delegate = self;
		[sectionController.cellControllers addObject:cellController];
		[cellController release];
		
		// we need to put a limit on the calls
		if(i == 100)
		{
			break;
		}
	}
}


@end
#endif