//
//  SettingsViewController.m
//  MyTime
//
//  Created by Brent Priddy on 8/13/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "SettingsViewController.h"
#import "Settings.h"
#import "UITableViewTitleAndValueCell.h"
#import "BackupView.h"
#import "NumberViewController.h"
#import "PSUrlString.h"
#import "PSLocalization.h"
#import "MultipleUsersViewController.h"
#import "MyTimeWebServerView.h"

enum {
	DONATE_SECTION,
	USER_SECTION,
	SETTINGS_SECTION,
	CONTACT_INFO_SECTION,
	BACKUP_SECTION,
	VERSION_SECTION,
	SECTION_COUNT
};

@implementation SettingsViewController

@synthesize theTableView;

- (id)init
{
	if ([super init]) 
	{
		theTableView = nil;
		
		
		// set the title, and tab bar images from the dataSource
		// object. 
		self.title = NSLocalizedString(@"Settings", @"'Settings' ButtonBar View text and Statistics View Title");
		UIImage *image = [UIImage imageNamed:@"settings.png"];
		self.tabBarItem.image = image;
	}
	return self;
}


- (void)dealloc 
{
	theTableView.delegate = nil;
	theTableView.dataSource = nil;
	self.theTableView = nil;
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)loadView 
{
	// create a new table using the full application frame
	// we'll ask the datasource which type of table to use (plain or grouped)
	UITableView *tableView = [[[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] 
														  style:UITableViewStyleGrouped] autorelease];
	
	// set the autoresizing mask so that the table will always fill the view
	tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	
	// set the tableview delegate to this object and the datasource to the datasource which has already been set
	tableView.delegate = self;
	tableView.dataSource = self;
	
	// set the tableview as the controller view
    self.theTableView = tableView;
	self.view = tableView;

	[theTableView reloadData];

}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	// force the tableview to load
	[theTableView reloadData];
}


- (void)viewDidAppear:(BOOL)animated
{
	[theTableView flashScrollIndicators];
	[theTableView deselectRowAtIndexPath:[theTableView indexPathForSelectedRow] animated:YES];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  
{
	VERBOSE(NSLog(@"count=%d", SECTION_COUNT);)
    return(SECTION_COUNT);
}

- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section 
{
	int count = 0;
    switch (section)
    { 
			// Donate
        case DONATE_SECTION:
			count++; // always show hours
			break;

			// User
        case USER_SECTION:
			count++; // one user selection
			break;

			// Settings
        case SETTINGS_SECTION:
		{
			count++; // enable popups
			count++; // number of months shown
			count++; // publisher type
			count++; // erase map cache
			count++; // passcode
			NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
			if([fileManager fileExistsAtPath:[@"~/Documents/translation.bundle" stringByExpandingTildeInPath]])
				count++;
			break;
		}
				
        // Website
        case CONTACT_INFO_SECTION:
			count++; // mytime website
			count++; // documentation
			count++; // found a bug?
			count++; // question comments? 
			break;
		
		// bakup
		case BACKUP_SECTION:
			count++; // email backup
			count++; //Mytime backup
			count++; //Mytime webserver
			break;
			
		// version 
		case VERSION_SECTION:
			count++; //version
			count++; //build date
			break;
    }
    VERBOSE(NSLog(@"preferencesTable: numberOfRowsInGroup:%d count:%d", section, count);)
	return(count);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    VERBOSE(NSLog(@"tableView: titleForHeaderInSection:%d", section);)
	NSString *title = @"";
	switch(section)
	{
        // Donate
		case DONATE_SECTION:
			break;

		// User section
		case USER_SECTION:
			title = NSLocalizedString(@"Multiple User Settings", @"Settings section header for the current user");
			break;

		// Settings
		case SETTINGS_SECTION:
			title = NSLocalizedString(@"Settings", @"'Settings' ButtonBar View text and Statistics View Title");
			break;
		
        // Website
        case CONTACT_INFO_SECTION:
			title = NSLocalizedString(@"Contact Information", @"More View Table Group Title");
			break;
		
        // Backup
        case BACKUP_SECTION:
			title = NSLocalizedString(@"Backup", @"More View Table Group Title");
			break;
		
		// version 
		case VERSION_SECTION:
			title = NSLocalizedString(@"Version", @"More View Table Group Title");
			break;
    }
    return(title);
} 



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int row = [indexPath row];
	int section = [indexPath section];
    VERBOSE(NSLog(@"tableView: cellForRow:%d inSection:%d", row, section);)
	UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[tableView dequeueReusableCellWithIdentifier:@"StatisticsTableCell"];
	if (cell == nil) 
	{
		cell = [[[UITableViewTitleAndValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"StatisticsTableCell"] autorelease];
	}
	else
	{
		[cell setAccessoryType:UITableViewCellAccessoryNone];
		[cell setValue:@""];
		[cell setTitle:@""];
		[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
	}


    switch (section) 
    {
        // Donate
        case DONATE_SECTION:
			switch(row)
			{
				case 0:
					[cell setValue:NSLocalizedString(@"Please Donate, help me help you", @"More View Table Donation request")];
					break;
			}
            break;

		// Current User
        case USER_SECTION:
			switch(row)
			{
				case 0:
				{
					[cell setTitle:NSLocalizedString(@"Current User", @"Settings label for the current user")];
					NSString *currentUser = [[[Settings sharedInstance] settings] objectForKey:SettingsMultipleUsersCurrentUser];
					if(currentUser == nil || currentUser.length == 0)
					{
						currentUser = NSLocalizedString(@"Default User", @"Multiple Users: the default user name when the user has not entered a name for themselves");
					}
					[cell setValue:currentUser];
					[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
					break;
				}
			}
            break;
			
        // Settings
		case SETTINGS_SECTION:
			switch(row)
			{
				case 0:
					[cell setTitle:NSLocalizedString(@"Enable shown popups", @"More View Table Enable shown popups")];
					break;
				case 1:
				{
					int number = 2;
					NSNumber *value = [[[Settings sharedInstance] userSettings] objectForKey:SettingsMonthDisplayCount];
					if(value)
						number = [value intValue];
					[cell setTitle:[NSString stringWithFormat:NSLocalizedString(@"%d Months Displayed", @"Number of months shown in the statistics view, setting title"), number]];
					[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
					break;
				}
				case 2:
				{
					[cell setTitle:NSLocalizedString(@"Publisher Type", @"More->Settings view publisher type setting title")];
					NSString *value = [[[Settings sharedInstance] userSettings] objectForKey:SettingsPublisherType];
					if(value == nil)
						value = PublisherTypePioneer;
					[cell setValue:[[PSLocalization localizationBundle] localizedStringForKey:value value:value table:@""]];
					[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
					break;
				}
				case 3:
				{
					[cell setTitle:NSLocalizedString(@"Erase map cache", @"More->Settings view title for erasing the map cache")];
					break;
				}
				case 4:
				{
					NSString *passcode = [[[Settings sharedInstance] settings] objectForKey:SettingsPasscode];
					[cell setTitle:NSLocalizedString(@"Passcode Lock", @"More->Settings view name for the Passcode Setting")];
					if(passcode.length == 0)
					{
						[cell setValue:NSLocalizedString(@"Off", @"Off or disabled (used in the More->Settings->Passcode Lock Setting")];
					}
					else
					{
						[cell setValue:NSLocalizedString(@"On", @"On or enabled (used in the More->Settings->Passcode Lock Setting")];
					}
					[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
					break;
				}
				case 5:
				{
					[cell setTitle:NSLocalizedString(@"Remove Custom Translation", @"More->Settings custom translation title")];
					break;
				}
			}
			break;
		
        // Website
        case CONTACT_INFO_SECTION:
			switch(row)
			{
				case 0:
					[cell setTitle:NSLocalizedString(@"MyTime Website", @"More View Table MyTime Website")];
					break;
					
				case 1:
					[cell setTitle:NSLocalizedString(@"Documentation", @"More View Table Link to Documentation")];
					break;
					
				case 2:
					[cell setTitle:NSLocalizedString(@"Found a bug?", @"Button in More->settings that points the user to the bug tracking system")];
					break;
					
				case 3:
					[cell setTitle:NSLocalizedString(@"Questions, Comments? Email me", @"More View Table Questions, Comments? Email me")];
					break;
			}
			break;
		
        // Backup
        case BACKUP_SECTION:
			switch(row)
			{
				case 0:
					[cell setTitle:NSLocalizedString(@"Email backup", @"More View Table backup your data by emailing the data")];
					break;
					
				case 1:
					[cell setTitle:NSLocalizedString(@"Backup using 'MyTime Backup'", @"More View Table backup your data")];
					break;

				case 2:
					[cell setTitle:NSLocalizedString(@"Start MyTime Webserver", @"Settings View button to start the webserver that allows you to type in your calls, import/export data, add translations, and import hours")];
					break;
			}
			break;
		
		// version 
		case VERSION_SECTION:
			switch(row)
			{
				case 0:
					[cell setTitle:NSLocalizedString(@"MyTime Version", @"More View Table MyTime Version")];
					[cell setValue:[NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
					[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
					break;
				case 1:
					[cell setTitle:NSLocalizedString(@"Build Date", @"More View Table Build Date")];
					[cell setValue:[NSString stringWithFormat:@"%s", __DATE__]];
					[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
					break;
			}
			break;
    }

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    int section = [indexPath section];

    DEBUG(NSLog(@"tableRowSelected: tableRowSelected section=%d row%d ", section, row);)

	switch(section)
	{
		case DONATE_SECTION:
			switch(row)
			{
				// Donate
				case 0:
				{
					// open up a url
					NSURL *url = [NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=toopriddy%40gmail%2ecom&item_name=PG%20Software&no_shipping=0&no_note=1&tax=0&currency_code=USD&lc=US&bn=PP%2dDonationsBF&charset=UTF%2d8"];
					[[UIApplication sharedApplication] openURL:url];
					return;
				}
			}
			break;

		case USER_SECTION:
			switch(row)
			{
				case 0:
				{
					MultipleUsersViewController *viewController = [[[MultipleUsersViewController alloc] init] autorelease];
//					viewController.delegate = self;
					[[self navigationController] pushViewController:viewController animated:YES];
					return;
				}
			}
			break;

		case SETTINGS_SECTION:
			switch(row)
			{
				// Re-enable popups
				case 0:
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
					return;
				}
				// Number of months shown in statistics view
				case 1:
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
					[[self navigationController] pushViewController:viewController animated:YES];
					return;
				}
				case 2:
				{
					NSString *value = [[[Settings sharedInstance] userSettings] objectForKey:SettingsPublisherType];
					if(value == nil)
						value = PublisherTypePioneer;
					
					PublisherTypeViewController *viewController = [[[PublisherTypeViewController alloc] initWithType:value] autorelease];
					viewController.delegate = self;
					[[self navigationController] pushViewController:viewController animated:YES];
					return;
				}
				case 3:
				{
					NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
					BOOL exists = [fileManager fileExistsAtPath:[@"~/Documents/MapMicrosoft VirtualEarth.sqlite" stringByExpandingTildeInPath]];
					if(exists && ![fileManager removeItemAtPath:[@"~/Documents/MapMicrosoft VirtualEarth.sqlite" stringByExpandingTildeInPath] error:nil])
					{
						UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
						[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
						alertSheet.title = NSLocalizedString(@"Could not delete map cache", @"More->Settings->Delete map cache: error message if the map cache could not be deleted");
						[alertSheet show];
						break;
					}
					
					UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
					[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
					alertSheet.title = NSLocalizedString(@"Map cache has been deleted", @"Confirmation message about the map data being deleted");
					[alertSheet show];
					break;
				}
				case 4:
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
						[[self navigationController] pushViewController:securityView animated:YES];
					}
					else
					{
						SecurityViewController *securityView = [[[SecurityViewController alloc] initWithNibName:@"SecurityView" bundle:[NSBundle mainBundle]] autorelease];
						securityView.promptText = NSLocalizedString(@"Enter your passcode to disable", @"Prompt to enter a passcode turn off the passcode in MyTime");
						securityView.shouldConfirm = NO;
						securityView.passcode = passcode;
						securityView.delegate = self;
						securityView.title = NSLocalizedString(@"Disable Passcode", @"Title of the view you are presented from Settings->Passcode when you are disabling the passcode");
						[[self navigationController] pushViewController:securityView animated:YES];
					}
					return;
				}
				case 5:
				{
					NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
					if(![fileManager removeItemAtPath:[@"~/Documents/translation.bundle" stringByExpandingTildeInPath] error:nil])
					{
						UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
						[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
						alertSheet.title = NSLocalizedString(@"Could not remove custom translation", @"More->Settings->Remove Custom Translation: error message if the custom translation file could not be removed");
						[alertSheet show];
						break;
					}
					UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
					[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
					alertSheet.title = NSLocalizedString(@"Please quit MyTime to apply change", @"More->Settings->Remove Custom Translation: confirmaiton message when you have applied the 'Remove Custom Translation'");
					[alertSheet show];
					break;
				}
			}
			break;

		case CONTACT_INFO_SECTION:
			switch(row)
			{
				// website
				case 0:
				{
					// open up a url to mytime.googlecode.com
					NSURL *url = [NSURL URLWithString:@"http://mytime.googlecode.com"];
					[[UIApplication sharedApplication] openURL:url];
					return;
				}
					
				// Documentation
				case 1:
				{
					// open up a url to mytime.googlecode.com
					NSURL *url = [NSURL URLWithString:@"http://code.google.com/p/mytime/wiki/youtubeDocumentation"];
					[[UIApplication sharedApplication] openURL:url];
					return;
				}
					
				// found a bug?
				case 2:
				{
					// open up a url to mytime.googlecode.com
					NSURL *url = [NSURL URLWithString:@"http://code.google.com/p/mytime/issues/list"];
					[[UIApplication sharedApplication] openURL:url];
					return;
				}

				// email me
				case 3:
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
					return;
				}
			}
			break;

		case BACKUP_SECTION:
			switch(row)
			{
				case 0:
				{
					[Settings sendEmailBackup];
					return;
				}
					// MyTime Backup program
				case 1:
				{
					backupView = [[BackupView alloc] init];
					[backupView setDelegate:self];
					[backupView show];
					break;
				}
					// MyTime Webserver
				case 2:
				{
					MyTimeWebServerView *view = [[[MyTimeWebServerView alloc] init] autorelease];
					[view show];
					break;
				}
			}
			break;
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if(alertView == backupView)
	{
		[backupView stop];
		[backupView release];
	}
}

- (void)securityViewControllerDone:(SecurityViewController *)viewController authenticated:(BOOL)authenticated
{
	[self.navigationController popViewControllerAnimated:YES];
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
}


- (void)numberViewControllerDone:(NumberViewController *)numberViewController
{
	[theTableView deselectRowAtIndexPath:[theTableView indexPathForSelectedRow] animated:YES];
	[[[Settings sharedInstance] userSettings] setObject:[NSNumber numberWithInt:numberViewController.numberPicker.number] forKey:SettingsMonthDisplayCount];
	[[Settings sharedInstance] saveData];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)button
{
	VERBOSE(NSLog(@"alertSheet: button:%d", button);)
//	[sheet dismissAnimated:YES];

	[theTableView deselectRowAtIndexPath:[theTableView indexPathForSelectedRow] animated:YES];
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


- (void)publisherTypeViewControllerDone:(PublisherTypeViewController *)publisherTypeViewController
{
	[[[Settings sharedInstance] userSettings] setObject:publisherTypeViewController.type forKey:SettingsPublisherType];
	[[Settings sharedInstance] saveData];
}


//
//
// UITableViewDelegate methods
//
//

// NONE

- (BOOL)respondsToSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"%s respondsToSelector: %s", __FILE__, selector);)
    return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"%s methodSignatureForSelector: %s", __FILE__, selector);)
    return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    VERY_VERBOSE(NSLog(@"%s forwardInvocation: %s", __FILE__, [invocation selector]);)
    [super forwardInvocation:invocation];
}

@end