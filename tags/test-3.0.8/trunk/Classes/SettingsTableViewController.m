//
//  SettingsTableViewController.m
//  MyTime
//
//  Created by Brent Priddy on 9/18/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "SettingsTableViewController.h"
#import "BackupView.h"
#import "NumberViewController.h"
#import "PSUrlString.h"
#import "PSLocalization.h"
#import "MultipleUsersViewController.h"
#import "MyTimeWebServerView.h"
#import "PublisherTypeViewController.h"
#import "SecurityViewController.h"
#import "MetadataEditorViewController.h"
#import "QuickNotesViewController.h"
#import "UITableViewSwitchCell.h"
#import "MTSettings.h"
#import "MTUser.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "MyTimeAppDelegate.h"
#import "DisplayRulesViewController.h"
#import "PSLabelCellController.h"
#import "PSDateCellController.h"

// base class for 
@interface SettingsCellController : NSObject<TableViewCellController>
{
	SettingsTableViewController *delegate;
}
@property (nonatomic, assign) SettingsTableViewController *delegate;
@end
@implementation SettingsCellController
@synthesize delegate;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}

@end




/******************************************************************
 *
 *   SelectUserCellController
 *
 ******************************************************************/
#pragma mark SelectUserCellController
@interface SelectUserCellController : SettingsCellController <MultipleUsersViewControllerDelegate>
{
}
@end
@implementation SelectUserCellController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"SelectUserCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
	}
	
	cell.textLabel.text = NSLocalizedString(@"Current User", @"Settings label for the current user");

	NSString *currentUser = [[MTUser currentUser] name];
	if(currentUser == nil || currentUser.length == 0)
	{
		currentUser = NSLocalizedString(@"Default User", @"Multiple Users: the default user name when the user has not entered a name for themselves");
	}
	cell.detailTextLabel.text = currentUser;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	MultipleUsersViewController *viewController = [[[MultipleUsersViewController alloc] init] autorelease];
	viewController.delegate = self;
	viewController.managedObjectContext = [[MyTimeAppDelegate sharedInstance] managedObjectContext];
	[[self.delegate navigationController] pushViewController:viewController animated:YES];
	[self.delegate retainObject:self whileViewControllerIsManaged:viewController];
}

- (void) multipleUsersViewController:(MultipleUsersViewController *)viewController selectedUser:(MTUser *)user
{
	NSIndexPath *selectedRow = [self.delegate.tableView indexPathForSelectedRow];
	if(selectedRow)
	{
		[self.delegate.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRow] withRowAnimation:UITableViewRowAnimationFade];
	}
	else
	{
		self.delegate.forceReload = YES;
	}
}
@end





/******************************************************************
 *
 *   EnablePopupsCellController
 *
 ******************************************************************/
#pragma mark EnablePopupsCellController
@interface EnablePopupsCellController : NSObject<TableViewCellController>
{
}
@end
@implementation EnablePopupsCellController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"EnablePopupsCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
		cell.detailTextLabel.text = @"";
	}

	cell.textLabel.text = NSLocalizedString(@"Enable shown popups", @"More View Table Enable shown popups");
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	MTSettings *settings = [MTSettings settings];

	settings.mainAlertSheetShownValue = NO;
	settings.timeAlertSheetShownValue = NO;
	settings.statisticsAlertSheetShownValue = NO;
	settings.existingCallAlertSheetShownValue = NO;
	NSError *error = nil;
	if (![settings.managedObjectContext save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
		abort();
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
	[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
	alertSheet.title = NSLocalizedString(@"Popup messages like this are now enabled to be shown once all throughout MyTime", @"Confirmation message about enabling popup messages");
	[alertSheet show];
}
@end


/******************************************************************
 *
 *   MonthsDisplayedCellController
 *
 ******************************************************************/
#pragma mark MonthsDisplayedCellController
@interface MonthsDisplayedCellController : SettingsCellController <NumberViewControllerDelegate>
{
}
@end
@implementation MonthsDisplayedCellController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"MonthsDisplayedCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	
	MTUser *user = [MTUser currentUser];
	int number = user.monthDisplayCountValue;
	if(number == 1)
		cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d Month Displayed", @"Number of months shown in the statistics view, setting title"), number];
	else
		cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d Months Displayed", @"Number of months shown in the statistics view, setting title"), number];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	MTUser *user = [MTUser currentUser];
	// open up the edit address view 
	NumberViewController *viewController = [[[NumberViewController alloc] initWithTitle:NSLocalizedString(@"Month Count", @"Title for selecting the number of months shown in the statistics view")
																		  singularLabel:NSLocalizedString(@"Month", @"Month singular") 
																				  label:NSLocalizedString(@"Months", @"Months plural") 
																				 number:user.monthDisplayCountValue
																					min:1 
																					max:12] autorelease];
	viewController.delegate = self;
	[[self.delegate navigationController] pushViewController:viewController animated:YES];
	[self.delegate retainObject:self whileViewControllerIsManaged:viewController];
}

- (void)numberViewControllerDone:(NumberViewController *)numberViewController
{
	MTUser *user = [MTUser currentUser];
	user.monthDisplayCountValue = numberViewController.numberPicker.number;
	NSError *error = nil;
	if (![user.managedObjectContext save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
		abort();
	}
	NSIndexPath *selectedRow = [self.delegate.tableView indexPathForSelectedRow];
	if(selectedRow)
	{
		[self.delegate.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRow] withRowAnimation:UITableViewRowAnimationFade];
	}
	else
	{
		self.delegate.forceReload = YES;
	}
}
@end

/******************************************************************
 *
 *   SettingsQuickNotesCellController
 *
 ******************************************************************/
#pragma mark SettingsQuickNotesCellController
@interface SettingsQuickNotesCellController : SettingsCellController
{
}
@end
@implementation SettingsQuickNotesCellController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"QuickNotesSettingCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	
	cell.textLabel.text = NSLocalizedString(@"Quick Notes", @"Quick Notes title.  This is shown when you click on the notes to type in for a call, it is the title of the view that shows you the last several notes you have typed in");
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	MTSettings *settings = [MTSettings settings];
		
	QuickNotesViewController *viewController = [[[QuickNotesViewController alloc] init] autorelease];
	viewController.editOnly = YES;
	viewController.managedObjectContext = settings.managedObjectContext;
	[[self.delegate navigationController] pushViewController:viewController animated:YES];
	[self.delegate retainObject:self whileViewControllerIsManaged:viewController];
}
@end

/******************************************************************
 *
 *   BackupEmailAddressCellController
 *
 ******************************************************************/
#pragma mark BackupEmailAddressCellController
@interface BackupEmailAddressCellController : SettingsCellController <MetadataEditorViewControllerDelegate>
{
}
@end
@implementation BackupEmailAddressCellController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"EmailBackupEmailCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
	}
	
	cell.textLabel.text = NSLocalizedString(@"Backup Address", @"More->Settings view backup email address");
	MTSettings *settings = [MTSettings settings];
	cell.detailTextLabel.text = settings.backupEmail;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	MTSettings *settings = [MTSettings settings];
	NSString *value = settings.backupEmail;
	
	MetadataEditorViewController *viewController = [[[MetadataEditorViewController alloc] initWithName:NSLocalizedString(@"Backup Address", @"More->Settings view backup email address") type:EMAIL data:value value:value] autorelease];
	viewController.delegate = self;
	viewController.tag = indexPath.row;
	[[self.delegate navigationController] pushViewController:viewController animated:YES];
	[self.delegate retainObject:self whileViewControllerIsManaged:viewController];
}

- (void)metadataEditorViewControllerDone:(MetadataEditorViewController *)metadataEditorViewController
{
	MTSettings *settings = [MTSettings settings];
	settings.backupEmail = [metadataEditorViewController value];
	NSError *error = nil;
	if (![settings.managedObjectContext save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
		abort();
	}
	
	NSIndexPath *selectedRow = [self.delegate.tableView indexPathForSelectedRow];
	if(selectedRow)
	{
		[self.delegate.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRow] withRowAnimation:UITableViewRowAnimationFade];
	}
	else
	{
		self.delegate.forceReload = YES;
	}
	[metadataEditorViewController.navigationController popViewControllerAnimated:YES];
}
@end

/******************************************************************
 *
 *   BackupEmailIncludeAttachmentCellController
 *
 ******************************************************************/
#pragma mark BackupEmailIncludeAttachmentCellController
@interface BackupEmailIncludeAttachmentCellController : SettingsCellController <UITableViewSwitchCellDelegate>
{
	UIViewController *cellViewController;
}
@property (nonatomic, retain) UIViewController *cellViewController;
@end
@implementation BackupEmailIncludeAttachmentCellController
@synthesize cellViewController;
- (void)dealloc
{
	self.cellViewController = nil;
	
	[super dealloc];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.cellViewController = [[[UIViewController alloc] initWithNibName:@"UITableViewSwitchCell" bundle:nil] autorelease];
	UITableViewSwitchCell *cell = (UITableViewSwitchCell *)self.cellViewController.view;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.delegate = self;
	cell.otherTextLabel.text = NSLocalizedString(@"Backup Attachment", @"More->Settings view backup attachment");
	MTSettings *settings = [MTSettings settings];
	cell.booleanSwitch.on = settings.backupShouldIncludeAttachmentValue;
	return cell;
}

- (void)uiTableViewSwitchCellChanged:(UITableViewSwitchCell *)uiTableViewSwitchCell
{
	MTSettings *settings = [MTSettings settings];
	settings.backupShouldIncludeAttachmentValue = uiTableViewSwitchCell.booleanSwitch.on;
	NSError *error = nil;
	if (![settings.managedObjectContext save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
		abort();
	}
	
}
@end

/******************************************************************
 *
 *   BackupEmailUncompressedLinkCellController
 *
 ******************************************************************/
#pragma mark BackupEmailUncompressedLinkCellController
@interface BackupEmailUncompressedLinkCellController : SettingsCellController <UITableViewSwitchCellDelegate>
{
	UIViewController *cellViewController;
}
@property (nonatomic, retain) UIViewController *cellViewController;
@end
@implementation BackupEmailUncompressedLinkCellController
@synthesize cellViewController;
- (void)dealloc
{
	self.cellViewController = nil;
	
	[super dealloc];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.cellViewController = [[[UIViewController alloc] initWithNibName:@"UITableViewSwitchCell" bundle:nil] autorelease];
	UITableViewSwitchCell *cell = (UITableViewSwitchCell *)self.cellViewController.view;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.delegate = self;
	cell.otherTextLabel.text = NSLocalizedString(@"Compress Backup", @"More->Settings view Compress backup link");
	MTSettings *settings = [MTSettings settings];
	cell.booleanSwitch.on = settings.backupShouldCompressLinkValue;
	return cell;
}

- (void)uiTableViewSwitchCellChanged:(UITableViewSwitchCell *)uiTableViewSwitchCell
{
	MTSettings *settings = [MTSettings settings];
	settings.backupShouldCompressLinkValue = uiTableViewSwitchCell.booleanSwitch.on;
	NSError *error = nil;
	if (![settings.managedObjectContext save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
		abort();
	}
	
}
@end

/******************************************************************
 *
 *   EmailBackupIntervalCellController
 *
 ******************************************************************/
#pragma mark EmailBackupIntervalCellController
@interface EmailBackupIntervalCellController : SettingsCellController <NumberViewControllerDelegate>
{
}
@end
@implementation EmailBackupIntervalCellController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"MonthsDisplayedCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	
	int number = 0;
	MTSettings *settings = [MTSettings settings];
	number = settings.autobackupIntervalValue;
	
	if(number)
	{
		if(number == 1)
		{
			cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Autobackup every day", @"Autobackup label when enabled in the statistics view, setting title"), number];
		}
		else
		{
			cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Autobackup after %u days", @"Autobackup label when enabled in the statistics view, setting title"), number];
		}
	}
	else 
	{
		cell.textLabel.text = NSLocalizedString(@"Email autobackup disabled", @"Autobackup disabled label in the statistics view, setting title");
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int number = 0;
	MTSettings *settings = [MTSettings settings];
	number = settings.autobackupIntervalValue;
	// open up the edit address view 
	NumberViewController *viewController = [[[NumberViewController alloc] initWithTitle:NSLocalizedString(@"Autobackup Interval", @"Title for selecting the number of days till you autobackup from the statistics view")
																		  singularLabel:NSLocalizedString(@"Day", @"Day singular") 
																				  label:NSLocalizedString(@"Days", @"Days plural") 
																				 number:number
																					min:0 
																					max:365] autorelease];
	viewController.delegate = self;
	[[self.delegate navigationController] pushViewController:viewController animated:YES];
	[self.delegate retainObject:self whileViewControllerIsManaged:viewController];
}

- (void)numberViewControllerDone:(NumberViewController *)numberViewController
{
	MTSettings *settings = [MTSettings settings];
	settings.autobackupIntervalValue = numberViewController.numberPicker.number;
	NSError *error = nil;
	if (![settings.managedObjectContext save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
		abort();
	}
	NSIndexPath *selectedRow = [self.delegate.tableView indexPathForSelectedRow];
	if(selectedRow)
	{
		[self.delegate.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRow] withRowAnimation:UITableViewRowAnimationFade];
	}
	else
	{
		self.delegate.forceReload = YES;
	}
}
@end


/******************************************************************
 *
 *   SecretaryEmailCellController
 *
 ******************************************************************/
#pragma mark SecretaryEmailCellController
@interface SecretaryEmailCellController : SettingsCellController <MetadataEditorViewControllerDelegate>
{
}
@end
@implementation SecretaryEmailCellController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"SecretaryEmailCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
	}
	
	cell.textLabel.text = NSLocalizedString(@"Secretary's Email", @"More->Settings view publisher type setting title");
	NSString *value = [[MTUser currentUser] secretaryEmailAddress];
	cell.detailTextLabel.text = value;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *value = [[MTUser currentUser] secretaryEmailAddress];
	
	MetadataEditorViewController *viewController = [[[MetadataEditorViewController alloc] initWithName:NSLocalizedString(@"Secretary's Email", @"More->Settings view publisher type setting title") type:EMAIL data:value value:value] autorelease];
	viewController.delegate = self;
	viewController.tag = indexPath.row;
	[[self.delegate navigationController] pushViewController:viewController animated:YES];
	[self.delegate retainObject:self whileViewControllerIsManaged:viewController];
}

- (void)metadataEditorViewControllerDone:(MetadataEditorViewController *)metadataEditorViewController
{
	MTUser *currentUser = [MTUser currentUser];
	currentUser.secretaryEmailAddress = [metadataEditorViewController value];
	NSError *error = nil;
	if (![currentUser.managedObjectContext save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
		abort();
	}
	NSIndexPath *selectedRow = [self.delegate.tableView indexPathForSelectedRow];
	if(selectedRow)
	{
		[self.delegate.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRow] withRowAnimation:UITableViewRowAnimationFade];
	}
	else
	{
		self.delegate.forceReload = YES;
	}
	[metadataEditorViewController.navigationController popViewControllerAnimated:YES];
}
@end

/******************************************************************
 *
 *   SecretaryEmailNotesCellController
 *
 ******************************************************************/
#pragma mark SecretaryEmailNotesCellController
@interface SecretaryEmailNotesCellController : SettingsCellController <MetadataEditorViewControllerDelegate>
{
}
@end
@implementation SecretaryEmailNotesCellController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"SecretaryEmailTypeCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	
	cell.textLabel.text = NSLocalizedString(@"Notes for Secretary", @"More->Settings view publisher type setting title");
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *value = [[MTUser currentUser] secretaryEmailNotes];
	
	MetadataEditorViewController *viewController = [[[MetadataEditorViewController alloc] initWithName:NSLocalizedString(@"Notes for Secretary", @"More->Settings view publisher type setting title") type:NOTES data:value value:value] autorelease];
	viewController.delegate = self;
	viewController.delegate = self;
	viewController.tag = indexPath.row;
	[[self.delegate navigationController] pushViewController:viewController animated:YES];
	[self.delegate retainObject:self whileViewControllerIsManaged:viewController];
}

- (void)metadataEditorViewControllerDone:(MetadataEditorViewController *)metadataEditorViewController
{
	MTUser *currentUser = [MTUser currentUser];
	currentUser.secretaryEmailNotes = [metadataEditorViewController value];
	NSError *error = nil;
	if (![currentUser.managedObjectContext save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
		abort();
	}

	NSIndexPath *selectedRow = [self.delegate.tableView indexPathForSelectedRow];
	if(selectedRow)
	{
		[self.delegate.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRow] withRowAnimation:UITableViewRowAnimationFade];
	}
	else
	{
		self.delegate.forceReload = YES;
	}
	[metadataEditorViewController.navigationController popViewControllerAnimated:YES];
}
@end




/******************************************************************
 *
 *   PublisherTypeCellController
 *
 ******************************************************************/
#pragma mark PublisherTypeCellController
@interface PublisherTypeCellController : SettingsCellController <PublisherTypeViewControllerDelegate>
{
}
@end
@implementation PublisherTypeCellController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"PublisherTypeCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
	}
	
	cell.textLabel.text = NSLocalizedString(@"Publisher Type", @"More->Settings view publisher type setting title");
	MTUser *currentUser = [MTUser currentUser];
	cell.detailTextLabel.text = [[PSLocalization localizationBundle] localizedStringForKey:currentUser.publisherType value:currentUser.publisherType table:@""];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	MTUser *currentUser = [MTUser currentUser];
	
	PublisherTypeViewController *viewController = [[[PublisherTypeViewController alloc] initWithType:currentUser.publisherType] autorelease];
	viewController.delegate = self;
	[[self.delegate navigationController] pushViewController:viewController animated:YES];
	[self.delegate retainObject:self whileViewControllerIsManaged:viewController];
}

- (void)publisherTypeViewControllerDone:(PublisherTypeViewController *)publisherTypeViewController
{
	MTUser *currentUser = [MTUser currentUser];
	currentUser.publisherType = publisherTypeViewController.type;
	NSError *error = nil;
	if (![currentUser.managedObjectContext save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
		abort();
	}
	
	NSIndexPath *selectedRow = [self.delegate.tableView indexPathForSelectedRow];
	if(selectedRow)
	{
		[self.delegate.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRow] withRowAnimation:UITableViewRowAnimationFade];
	}
	else
	{
		self.delegate.forceReload = YES;
	}
}
@end


/******************************************************************
 *
 *   ClearMapCacheCellController
 *
 ******************************************************************/
#pragma mark ClearMapCacheCellController
@interface ClearMapCacheCellController : NSObject<TableViewCellController>
{
}
@end
@implementation ClearMapCacheCellController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"ClearMapCacheCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	
	cell.textLabel.text = NSLocalizedString(@"Erase map cache", @"More->Settings view title for erasing the map cache");
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
	BOOL exists = [fileManager fileExistsAtPath:[@"~/Documents/MapMicrosoft VirtualEarth.sqlite" stringByExpandingTildeInPath]];
	if(exists && ![fileManager removeItemAtPath:[@"~/Documents/MapMicrosoft VirtualEarth.sqlite" stringByExpandingTildeInPath] error:nil])
	{
		UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
		[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
		alertSheet.title = NSLocalizedString(@"Could not delete map cache", @"More->Settings->Delete map cache: error message if the map cache could not be deleted");
		[alertSheet show];
		return;
	}
	
	UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
	[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
	alertSheet.title = NSLocalizedString(@"Map cache has been deleted", @"Confirmation message about the map data being deleted");
	[alertSheet show];
}
@end


/******************************************************************
 *
 *   PasscodeCellController
 *
 ******************************************************************/
#pragma mark PasscodeCellController
@interface PasscodeCellController : SettingsCellController <SecurityViewControllerDelegate>
{
}
@end
@implementation PasscodeCellController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"PasscodeCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
	}
	
	MTSettings *settings = [MTSettings settings];
	cell.textLabel.text = NSLocalizedString(@"Passcode Lock", @"More->Settings view name for the Passcode Setting");
	if(settings.passcode.length == 0)
	{
		cell.detailTextLabel.text = NSLocalizedString(@"Off", @"Off or disabled (used in the More->Settings->Passcode Lock Setting");
	}
	else
	{
		cell.detailTextLabel.text = NSLocalizedString(@"On", @"On or enabled (used in the More->Settings->Passcode Lock Setting");
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	MTSettings *settings = [MTSettings settings];
	if(settings.passcode.length == 0)
	{
		SecurityViewController *securityView = [[[SecurityViewController alloc] initWithNibName:@"SecurityView" bundle:[NSBundle mainBundle]] autorelease];
		securityView.promptText = NSLocalizedString(@"Enter a passcode", @"First Prompt to enter a passcode to limit access to MyTime");
		securityView.confirmText = NSLocalizedString(@"Re-enter your passcode", @"First Prompt to enter a passcode to limit access to MyTime");
		securityView.secondaryPromptText = NSLocalizedString(@"Please remember your passcode. You will not be able to recover this passcode if you forget it.", @"warning to the user that they should remember their passcode");
		securityView.shouldConfirm = YES;
		securityView.delegate = self;
		securityView.title = NSLocalizedString(@"Set Passcode", @"Title of the view you are presented from Settings->Passcode when you are enabling the passcode");
		[[self.delegate navigationController] pushViewController:securityView animated:YES];
		[self.delegate retainObject:self whileViewControllerIsManaged:securityView];
	}
	else
	{
		SecurityViewController *securityView = [[[SecurityViewController alloc] initWithNibName:@"SecurityView" bundle:[NSBundle mainBundle]] autorelease];
		securityView.promptText = NSLocalizedString(@"Enter your passcode to disable", @"Prompt to enter a passcode turn off the passcode in MyTime");
		securityView.shouldConfirm = NO;
		securityView.passcode = settings.passcode;
		securityView.delegate = self;
		securityView.title = NSLocalizedString(@"Disable Passcode", @"Title of the view you are presented from Settings->Passcode when you are disabling the passcode");
		[[self.delegate navigationController] pushViewController:securityView animated:YES];
		[self.delegate retainObject:self whileViewControllerIsManaged:securityView];
	}
}

- (void)securityViewControllerDone:(SecurityViewController *)viewController authenticated:(BOOL)authenticated
{
	[self.delegate.navigationController popViewControllerAnimated:YES];
	if(authenticated)
	{
		MTSettings *settings = [MTSettings settings];
		if(settings.passcode.length == 0)
		{
			// enabling the passcode
			settings.passcode = viewController.passcode;
		}
		else
		{
			// disabling the passcode
			settings.passcode = nil;
		}
		NSError *error = nil;
		if (![settings.managedObjectContext save:&error]) 
		{
			[NSManagedObjectContext presentErrorDialog:error];
			abort();
		}
	}
	NSIndexPath *selectedRow = [self.delegate.tableView indexPathForSelectedRow];
	if(selectedRow)
	{
		[self.delegate.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRow] withRowAnimation:UITableViewRowAnimationFade];
	}
	else
	{
		NSLog(@"\n\n\n\n FORCE RELOAD\n\n\n\n");
		self.delegate.forceReload = YES;
	}
}
@end



/******************************************************************
 *
 *   RemoveTestTranslationCellController
 *
 ******************************************************************/
#pragma mark RemoveTestTranslationCellController
@interface RemoveTestTranslationCellController : NSObject<TableViewCellController>
{
}
@end
@implementation RemoveTestTranslationCellController

- (BOOL)isViewableWhenNotEditing
{
	return [[NSFileManager defaultManager] fileExistsAtPath:[@"~/Documents/translation.bundle" stringByExpandingTildeInPath]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"RemoveTestTranslationCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	
	cell.textLabel.text = NSLocalizedString(@"Remove Custom Translation", @"More->Settings custom translation title");

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
	if(![fileManager removeItemAtPath:[@"~/Documents/translation.bundle" stringByExpandingTildeInPath] error:nil])
	{
		UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
		[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
		alertSheet.title = NSLocalizedString(@"Could not remove custom translation", @"More->Settings->Remove Custom Translation: error message if the custom translation file could not be removed");
		[alertSheet show];
		return;
	}
	UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
	[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
	alertSheet.title = NSLocalizedString(@"Please quit MyTime to apply change", @"More->Settings->Remove Custom Translation: confirmaiton message when you have applied the 'Remove Custom Translation'");
	[alertSheet show];
}
@end

/******************************************************************
 *
 *   EmailMeCellController
 *
 ******************************************************************/
#pragma mark EmailMeCellController
@interface EmailMeCellController : SettingsCellController<UIActionSheetDelegate>
{
}
@end
@implementation EmailMeCellController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"EmailMeCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	
	cell.textLabel.text = NSLocalizedString(@"Questions, Comments? Email me", @"More View Table Questions, Comments? Email me");
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIActionSheet *alertSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Because I might have received > 200 emails about a question, please read the Frequently Asked Questions section of the MyTime website before emailing me to ask a question.  Also, please read the existing feature request list before requesting a feature.", @"message displayed when someone wants to email me, I just want to make sure that they have read the website before asking a question")
															 delegate:self
													cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
											   destructiveButtonTitle:NSLocalizedString(@"I have read the webpage", @"button that the user clicks when they have let their Yes mean Yes that they have read the website")
													otherButtonTitles:NSLocalizedString(@"Show me the webpage", @"button that the user clicks when they have not read the FAQ or feature request list"), nil] autorelease];
	// 0: grey with grey and black buttons
	// 1: black background with grey and black buttons
	// 2: transparent black background with grey and black buttons
	// 3: grey transparent background
	alertSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[alertSheet showInView:[[[UIApplication sharedApplication] windows] objectAtIndex:0]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)button
{
	VERBOSE(NSLog(@"alertSheet: button:%d", button);)
	//	[sheet dismissAnimated:YES];
	
	[self.delegate.tableView deselectRowAtIndexPath:[self.delegate.tableView indexPathForSelectedRow] animated:YES];
	switch(button)
	{
		case 0: // Yes, email toopriddy@gmail.com
		{
			NSURL *url = [NSURL URLWithString:@"mailto:toopriddy@gmail.com?subject=Regarding%20your%20MyTime%20application"];
			[[UIApplication sharedApplication] openURL:url];
			break;
		}
		case 1: // No, take me to the website
		{
			NSURL *url = [NSURL URLWithString:@"http://mytime.googlecode.com"];
			[[UIApplication sharedApplication] openURL:url];
			break;
		}
	}
}
@end


/******************************************************************
 *
 *   EmailBackupCellController
 *
 ******************************************************************/
#pragma mark EmailBackupCellController
@interface EmailBackupCellController : SettingsCellController<UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
{
}
@end
@implementation EmailBackupCellController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"EmailBackupCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	
	cell.textLabel.text = NSLocalizedString(@"Email backup", @"More View Table backup your data by emailing the data");
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIActionSheet *alertSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Email printable backup or MyTime backup? (The printable backup can not be used to automatically restore MyTime data)", @"question to ask the user if they want a mytime backup or printable backup")
															 delegate:self
													cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
											   destructiveButtonTitle:nil
													otherButtonTitles:NSLocalizedString(@"Email MyTime Backup", @"button that the user clicks when they want to email a mytime backups"), 
								                                      NSLocalizedString(@"Email Printable Backup", @"button that the user clicks when they want to email a printable backup"), 
								                                      nil] autorelease];
	// 0: grey with grey and black buttons
	// 1: black background with grey and black buttons
	// 2: transparent black background with grey and black buttons
	// 3: grey transparent background
	alertSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[alertSheet showInView:[[[UIApplication sharedApplication] windows] objectAtIndex:0]];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	// for some reason the MFMailComposeViewController is crashing when the email is not getting sent
	[controller retain];
	[controller autorelease];
	[self.delegate.navigationController dismissModalViewControllerAnimated:YES];
	[self autorelease];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)button
{
	VERBOSE(NSLog(@"alertSheet: button:%d", button);)
	//	[sheet dismissAnimated:YES];
	
	[self.delegate.tableView deselectRowAtIndexPath:[self.delegate.tableView indexPathForSelectedRow] animated:YES];
	switch(button)
	{
		case 0: // Yes, email toopriddy@gmail.com
		{
			MFMailComposeViewController *mailView = [MyTimeAppDelegate sendEmailBackup];
			mailView.mailComposeDelegate = self;
			[self retain];
			[self.delegate.navigationController presentModalViewController:mailView animated:YES];
			break;
		}
		case 1: // No, take me to the website
		{
			MFMailComposeViewController *mailView = [MyTimeAppDelegate sendPrintableEmailBackup];
			mailView.mailComposeDelegate = self;
			[self retain];
			[self.delegate.navigationController presentModalViewController:mailView animated:YES];
			break;
		}
	}
}
@end

/******************************************************************
 *
 *   MyTimeBackupCellController
 *
 ******************************************************************/
#pragma mark MyTimeBackupCellController
@interface MyTimeBackupCellController : NSObject<TableViewCellController>
{
	BackupView *backupView;
}
@end
@implementation MyTimeBackupCellController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"MyTimeBackupTranslationCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}

	cell.textLabel.text = NSLocalizedString(@"Backup using 'MyTime Backup'", @"More View Table backup your data");
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	backupView = [[BackupView alloc] init];
	[backupView setDelegate:self];
	[backupView show];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[backupView stop];
	[backupView release];
}
@end

/******************************************************************
 *
 *   MyTimeWebserverCellController
 *
 ******************************************************************/
#pragma mark MyTimeWebserverCellController
@interface MyTimeWebserverCellController : NSObject<TableViewCellController>
{
}
@end
@implementation MyTimeWebserverCellController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"MyTimeWebserverTranslationCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	
	cell.textLabel.text = NSLocalizedString(@"Start MyTime Webserver", @"Settings View button to start the webserver that allows you to type in your calls, import/export data, add translations, and import hours");
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	MyTimeWebServerView *view = [[[MyTimeWebServerView alloc] init] autorelease];
	[view show];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end




@implementation SettingsTableViewController

- (void)userChanged
{
	[self updateAndReload];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
	if( (self = [super initWithStyle:style]) )
	{
		self.title = NSLocalizedString(@"Settings", @"'Settings' ButtonBar View text and Statistics View Title");
		UIImage *image = [UIImage imageNamed:@"settings.png"];
		self.tabBarItem.image = image;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userChanged) name:MTNotificationUserChanged object:nil];

	}
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)labelCellController:(PSLabelCellController *)labelCellController tableView:(UITableView *)tableView displayRulesSelectedAtIndexPath:(NSIndexPath *)indexPath
{
	MTSettings *settings = [MTSettings settings];
	DisplayRulesViewController *controller = [[[DisplayRulesViewController alloc] init] autorelease];
	controller.managedObjectContext = settings.managedObjectContext;
	controller.onlyAllowEditing = YES;
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)constructSectionControllers
{
	[super constructSectionControllers];
	MTUser *user = [MTUser currentUser];
	// Donate
	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		[sectionController release];
		
		URLCellController *cellController = [[URLCellController alloc] initWithTitle:NSLocalizedString(@"Please Donate, help me help you", @"More View Table Donation request") URL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=LCRTAWJDDBJJY"]];
		[sectionController.cellControllers addObject:cellController];
		[cellController release];
	}	
	
	// User section
	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		sectionController.title = NSLocalizedString(@"Multiple User Settings", @"Settings section header for the current user");
		[sectionController release];
		
		SelectUserCellController *cellController = [[SelectUserCellController alloc] init];
		cellController.delegate = self;
		[sectionController.cellControllers addObject:cellController];
		[cellController release];
	}	
	
	// Settings
	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		sectionController.title = NSLocalizedString(@"Settings", @"'Settings' ButtonBar View text and Statistics View Title");
		[sectionController release];
		
		// Number of months shown in statistics view
		{
			MonthsDisplayedCellController *cellController = [[MonthsDisplayedCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		
		// Display Rules
		{
			PSLabelCellController *cellController = [[[PSLabelCellController alloc] init] autorelease];
			cellController.title = NSLocalizedString(@"Display Rules", @"In the Settings view this is the row that lets you configure all of the sorting/filter rules");
			cellController.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:displayRulesSelectedAtIndexPath:)];
			[self addCellController:cellController toSection:sectionController];
		}
		
		// QuickNotes
		{
			SettingsQuickNotesCellController *cellController = [[SettingsQuickNotesCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		
		// Backup Address
		{
			BackupEmailAddressCellController *cellController = [[BackupEmailAddressCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		
		// Backup Dont Include Attachment
		{
			BackupEmailIncludeAttachmentCellController *cellController = [[BackupEmailIncludeAttachmentCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		
		// Compress Backup Link
		{
			BackupEmailUncompressedLinkCellController *cellController = [[BackupEmailUncompressedLinkCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}

		// Number of months shown in statistics view
		{
			EmailBackupIntervalCellController *cellController = [[EmailBackupIntervalCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}		
		
		// Secretary Email
		{
			SecretaryEmailCellController *cellController = [[SecretaryEmailCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		
		// Secretary Email Notes
		{
			SecretaryEmailNotesCellController *cellController = [[SecretaryEmailNotesCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		
		// publisher type
		{
			PublisherTypeCellController *cellController = [[PublisherTypeCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		
		// Pioneer Start Date
		{
			PSDateCellController *cellController = [[PSDateCellController alloc] init];
			cellController.model = user;
			cellController.modelPath = @"pioneerStartDate";
			cellController.title = NSLocalizedString(@"Pioneer Start Date", @"Label for More->Settings pioneer start date used to start calculating the statistics");
			cellController.datePickerMode = UIDatePickerModeDate;
			if([[[NSLocale currentLocale] localeIdentifier] isEqualToString:@"en_GB"])
			{
				[cellController setDateFormat:@"d/M/yyy"];
			}
			else
			{
				[cellController setDateFormat:NSLocalizedString(@"M/d/yyy", @"localized date string string using http://unicode.org/reports/tr35/tr35-4.html#Date_Format_Patterns as a guide to how to format the date")];
			}
			
			[self addCellController:cellController toSection:sectionController];
		}
		
		// Passcode
		{
			PasscodeCellController *cellController = [[PasscodeCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		
		// Re-enable popups
		{
			EnablePopupsCellController *cellController = [[EnablePopupsCellController alloc] init];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}

#if 0		
		// clear map cache
		{
			ClearMapCacheCellController *cellController = [[ClearMapCacheCellController alloc] init];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
#endif
		// Remove Test Translation
		{
			RemoveTestTranslationCellController *cellController = [[RemoveTestTranslationCellController alloc] init];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
	}
	
	// Contact Information
	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		sectionController.title = NSLocalizedString(@"Contact Information", @"More View Table Group Title");
		[sectionController release];
		
		// Mytime website
		{
			URLCellController *cellController = [[URLCellController alloc] initWithTitle:NSLocalizedString(@"MyTime Website", @"More View Table MyTime Website") URL:[NSURL URLWithString:@"http://mytime.googlecode.com"]];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}

		// documentation
		{
			URLCellController *cellController = [[URLCellController alloc] initWithTitle:NSLocalizedString(@"Documentation", @"More View Table Link to Documentation") URL:[NSURL URLWithString:@"http://code.google.com/p/mytime/wiki/youtubeDocumentation"]];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		
		// Found a bug?
		{
			URLCellController *cellController = [[URLCellController alloc] initWithTitle:NSLocalizedString(@"Found a bug?", @"Button in More->settings that points the user to the bug tracking system") URL:[NSURL URLWithString:@"http://mytime.googlecode.com"]];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		
		// email me
		{
			EmailMeCellController *cellController = [[EmailMeCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
	}		
	
	// Backup
	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		sectionController.title = NSLocalizedString(@"Backup", @"More View Table Group Title");
		[sectionController release];
		
		// Email backup
		{
			EmailBackupCellController *cellController = [[EmailBackupCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}

		// MyTime Backup program
		{
			MyTimeBackupCellController *cellController = [[MyTimeBackupCellController alloc] init];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// MyTime Webserver
		{
			MyTimeWebserverCellController *cellController = [[MyTimeWebserverCellController alloc] init];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
	}		
	
	
	// Version 
	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		sectionController.title = NSLocalizedString(@"Version", @"More View Table Group Title");
		[sectionController release];
		
		// Version
		{
			TitleValueCellController *cellController = [[TitleValueCellController alloc] initWithTitle:NSLocalizedString(@"MyTime Version", @"More View Table MyTime Version") value:[NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Build date
		{
			TitleValueCellController *cellController = [[TitleValueCellController alloc] initWithTitle:NSLocalizedString(@"Build Date", @"More View Table Build Date") value:[NSString stringWithFormat:@"%s", __DATE__]];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
	}		
}


@end
