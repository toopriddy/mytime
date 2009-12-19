//
//  SettingsTableViewController.m
//  MyTime
//
//  Created by Brent Priddy on 9/18/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "Settings.h"
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
 *   URLCellController
 *
 ******************************************************************/
#pragma mark URLCellController
@interface URLCellController : NSObject<TableViewCellController>
{
	NSURL *ps_url;
	NSString *ps_title;
}
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSString *title;
@end
@implementation URLCellController
@synthesize url = ps_url;
@synthesize title = ps_title;

- (id)initWithTitle:(NSString *)title URL:(NSURL *)url
{
	if( (self = [super init]) )
	{
		self.title = title;
		self.url = url;
	}
	return self;
}

- (void)dealloc
{
	self.title = nil;
	self.url = nil;
	[super dealloc];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"URLCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.textLabel.text = self.title;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[[UIApplication sharedApplication] openURL:self.url];
}
@end

/******************************************************************
 *
 *   TitleValueCellController
 *
 ******************************************************************/
#pragma mark TitleValueCellController
@interface TitleValueCellController : NSObject<TableViewCellController>
{
	NSString *ps_title;
	NSString *ps_value;
}
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *value;
@end
@implementation TitleValueCellController
@synthesize value = ps_value;
@synthesize title = ps_title;

- (id)initWithTitle:(NSString *)title value:(NSString *)value
{
	if( (self = [super init]) )
	{
		self.title = title;
		self.value = value;
	}
	return self;
}

- (void)dealloc
{
	self.title = nil;
	self.value = nil;
	[super dealloc];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"TitleAndValueCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	cell.textLabel.text = self.title;
	cell.detailTextLabel.text = self.value;
	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
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

	NSString *currentUser = [[[Settings sharedInstance] settings] objectForKey:SettingsMultipleUsersCurrentUser];
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
	[[self.delegate navigationController] pushViewController:viewController animated:YES];
}

- (void) multipleUsersViewController:(MultipleUsersViewController *)viewController selectedUser:(NSString *)name
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
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
	}

	cell.textLabel.text = NSLocalizedString(@"Enable shown popups", @"More View Table Enable shown popups");
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableDictionary *settings = [[Settings sharedInstance] settings];
	[settings removeObjectForKey:SettingsMainAlertSheetShown];
	[settings removeObjectForKey:SettingsTimeAlertSheetShown];
	[settings removeObjectForKey:SettingsStatisticsAlertSheetShown];
	[settings removeObjectForKey:SettingsExistingCallAlertSheetShown];
	
	[[Settings sharedInstance] saveData];
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
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
	}
	
	int number = 2;
	NSNumber *value = [[[Settings sharedInstance] userSettings] objectForKey:SettingsMonthDisplayCount];
	if(value)
		number = [value intValue];
	cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d Months Displayed", @"Number of months shown in the statistics view, setting title"), number];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int number = 2;
	NSNumber *value = [[[Settings sharedInstance] userSettings] objectForKey:SettingsMonthDisplayCount];
	if(value)
		number = [value intValue];
	// open up the edit address view 
	NumberViewController *viewController = [[[NumberViewController alloc] initWithTitle:NSLocalizedString(@"Month Count", @"Title for selecting the number of months shown in the statistics view")
																		  singularLabel:NSLocalizedString(@"Month", @"Month singular") 
																				  label:NSLocalizedString(@"Months", @"Months plural") 
																				 number:number
																					min:1 
																					max:12] autorelease];
	viewController.delegate = self;
	[[self.delegate navigationController] pushViewController:viewController animated:YES];
}

- (void)numberViewControllerDone:(NumberViewController *)numberViewController
{
	[[[Settings sharedInstance] userSettings] setObject:[NSNumber numberWithInt:numberViewController.numberPicker.number] forKey:SettingsMonthDisplayCount];
	[[Settings sharedInstance] saveData];
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
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
	}
	
	cell.textLabel.text = NSLocalizedString(@"Quick Notes", @"Quick Notes title.  This is shown when you click on the notes to type in for a call, it is the title of the view that shows you the last several notes you have typed in");
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	QuickNotesViewController *viewController = [[[QuickNotesViewController alloc] init] autorelease];
	viewController.editOnly = YES;
	[[self.delegate navigationController] pushViewController:viewController animated:YES];
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
	NSString *commonIdentifier = @"PublisherTypeCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
	}
	
	cell.textLabel.text = NSLocalizedString(@"Secretary's Email", @"More->Settings view publisher type setting title");
	NSString *value = [[[Settings sharedInstance] settings] objectForKey:SettingsSecretaryEmailAddress];
	cell.detailTextLabel.text = value;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *value = [[[Settings sharedInstance] settings] objectForKey:SettingsSecretaryEmailAddress];
	
	MetadataEditorViewController *viewController = [[[MetadataEditorViewController alloc] initWithName:NSLocalizedString(@"Secretary's Email", @"More->Settings view publisher type setting title") type:EMAIL data:value value:value] autorelease];
	viewController.delegate = self;
	viewController.tag = indexPath.row;
	[[self.delegate navigationController] pushViewController:viewController animated:YES];
}

- (void)metadataEditorViewControllerDone:(MetadataEditorViewController *)metadataEditorViewController
{
	[[[Settings sharedInstance] settings] setObject:[metadataEditorViewController value] forKey:SettingsSecretaryEmailAddress];
	[[Settings sharedInstance] saveData];
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
	NSString *commonIdentifier = @"PublisherTypeCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
	}
	
	cell.textLabel.text = NSLocalizedString(@"Notes for Secretary", @"More->Settings view publisher type setting title");
//	NSString *value = [[[Settings sharedInstance] settings] objectForKey:SettingsSecretaryEmailNotes];
//	cell.detailTextLabel.text = value;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *value = [[[Settings sharedInstance] settings] objectForKey:SettingsSecretaryEmailNotes];
	
	MetadataEditorViewController *viewController = [[[MetadataEditorViewController alloc] initWithName:NSLocalizedString(@"Notes for Secretary", @"More->Settings view publisher type setting title") type:NOTES data:value value:value] autorelease];
	viewController.delegate = self;
	viewController.delegate = self;
	viewController.tag = indexPath.row;
	[[self.delegate navigationController] pushViewController:viewController animated:YES];
}

- (void)metadataEditorViewControllerDone:(MetadataEditorViewController *)metadataEditorViewController
{
	[[[Settings sharedInstance] settings] setObject:[metadataEditorViewController value] forKey:SettingsSecretaryEmailNotes];
	[[Settings sharedInstance] saveData];
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
	NSString *value = [[[Settings sharedInstance] userSettings] objectForKey:SettingsPublisherType];
	if(value == nil)
		value = PublisherTypePioneer;
	cell.detailTextLabel.text = [[PSLocalization localizationBundle] localizedStringForKey:value value:value table:@""];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *value = [[[Settings sharedInstance] userSettings] objectForKey:SettingsPublisherType];
	if(value == nil)
		value = PublisherTypePioneer;
	
	PublisherTypeViewController *viewController = [[[PublisherTypeViewController alloc] initWithType:value] autorelease];
	viewController.delegate = self;
	[[self.delegate navigationController] pushViewController:viewController animated:YES];
}

- (void)publisherTypeViewControllerDone:(PublisherTypeViewController *)publisherTypeViewController
{
	[[[Settings sharedInstance] userSettings] setObject:publisherTypeViewController.type forKey:SettingsPublisherType];
	[[Settings sharedInstance] saveData];
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
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
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
	
	NSString *passcode = [[[Settings sharedInstance] settings] objectForKey:SettingsPasscode];
	cell.textLabel.text = NSLocalizedString(@"Passcode Lock", @"More->Settings view name for the Passcode Setting");
	if(passcode.length == 0)
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
	NSString *passcode = [[[Settings sharedInstance] settings] objectForKey:SettingsPasscode];
	if(passcode.length == 0)
	{
		SecurityViewController *securityView = [[[SecurityViewController alloc] initWithNibName:@"SecurityView" bundle:[NSBundle mainBundle]] autorelease];
		securityView.promptText = NSLocalizedString(@"Enter a passcode", @"First Prompt to enter a passcode to limit access to MyTime");
		securityView.confirmText = NSLocalizedString(@"Re-enter your passcode", @"First Prompt to enter a passcode to limit access to MyTime");
		securityView.secondaryPromptText = NSLocalizedString(@"Please remember your passcode. You will not be able to recover this passcode if you forget it.", @"warning to the user that they should remember their passcode");
		securityView.shouldConfirm = YES;
		securityView.delegate = self;
		securityView.title = NSLocalizedString(@"Set Passcode", @"Title of the view you are presented from Settings->Passcode when you are enabling the passcode");
		[[self.delegate navigationController] pushViewController:securityView animated:YES];
	}
	else
	{
		SecurityViewController *securityView = [[[SecurityViewController alloc] initWithNibName:@"SecurityView" bundle:[NSBundle mainBundle]] autorelease];
		securityView.promptText = NSLocalizedString(@"Enter your passcode to disable", @"Prompt to enter a passcode turn off the passcode in MyTime");
		securityView.shouldConfirm = NO;
		securityView.passcode = passcode;
		securityView.delegate = self;
		securityView.title = NSLocalizedString(@"Disable Passcode", @"Title of the view you are presented from Settings->Passcode when you are disabling the passcode");
		[[self.delegate navigationController] pushViewController:securityView animated:YES];
	}
}

- (void)securityViewControllerDone:(SecurityViewController *)viewController authenticated:(BOOL)authenticated
{
	[self.delegate.navigationController popViewControllerAnimated:YES];
	if(authenticated)
	{
		NSString *passcode = [[[Settings sharedInstance] settings] objectForKey:SettingsPasscode];
		if(passcode.length == 0)
		{
			// enabling the passcode
			[[[Settings sharedInstance] settings] setObject:viewController.passcode forKey:SettingsPasscode];
			[[Settings sharedInstance] saveData];
		}
		else
		{
			// disabling the passcode
			[[[Settings sharedInstance] settings] removeObjectForKey:SettingsPasscode];
			[[Settings sharedInstance] saveData];
		}
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
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
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
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
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
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
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
			MFMailComposeViewController *mailView = [Settings sendEmailBackup];
			mailView.mailComposeDelegate = self;
			[self retain];
			[self.delegate.navigationController presentModalViewController:mailView animated:YES];
			break;
		}
		case 1: // No, take me to the website
		{
			MFMailComposeViewController *mailView = [Settings sendPrintableEmailBackup];
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
	NSString *commonIdentifier = @"RemoveTestTranslationCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
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
	NSString *commonIdentifier = @"RemoveTestTranslationCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
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

- (id)initWithStyle:(UITableViewStyle)style
{
	if( (self = [super initWithStyle:style]) )
	{
		self.title = NSLocalizedString(@"Settings", @"'Settings' ButtonBar View text and Statistics View Title");
		UIImage *image = [UIImage imageNamed:@"settings.png"];
		self.tabBarItem.image = image;
	}
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)constructSectionControllers
{
	[super constructSectionControllers];
	
	// Donate
	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		[sectionController release];
		
		URLCellController *cellController = [[URLCellController alloc] initWithTitle:NSLocalizedString(@"Please Donate, help me help you", @"More View Table Donation request") URL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=toopriddy%40gmail%2ecom&item_name=PG%20Software&no_shipping=0&no_note=1&tax=0&currency_code=USD&lc=US&bn=PP%2dDonationsBF&charset=UTF%2d8"]];
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
		
		// QuickNotes
		{
			SettingsQuickNotesCellController *cellController = [[SettingsQuickNotesCellController alloc] init];
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
		
		// clear map cache
		{
			ClearMapCacheCellController *cellController = [[ClearMapCacheCellController alloc] init];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}

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