//
//  SettingsViewController.m
//  MyTime
//
//  Created by Brent Priddy on 8/13/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import "SettingsViewController.h"
#import "Settings.h"
#import "UITableViewTitleAndValueCell.h"
#import "BackupView.h"

@implementation SettingsViewController

@synthesize theTableView;

#warning fix me
#define svn_version() "1.0"

- (id)init
{
	if ([super init]) 
	{
		theTableView = nil;
		
		
		// set the title, and tab bar images from the dataSource
		// object. 
		self.title = NSLocalizedString(@"Settings", @"'Settings' ButtonBar View text and Statistics View Title");
		self.tabBarItem.image = [UIImage imageNamed:@"settings.png"];
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
	return(YES);
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
	// force the tableview to load
	[theTableView reloadData];
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  
{
    int count = 0;

	// Donate View
	count++;
	
	// Settings
	count++;

	// mytime website
	count++;

	// backup
	count++;
	
	// version
	count++;
	
	VERBOSE(NSLog(@"count=%d", count);)
    return(count);
}

- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section 
{
	int count = 0;
    switch (section)
    { 
        // Donate
        case 0:
			count++; // always show hours
			break;

        // Settings
        case 1:
			count++; // enable popups
			break;
		
        // Website
        case 2:
			count++; 
			count++; 
			break;
		
		// version 
		case 3:
			count++; //version
			break;
			
		// version 
		case 4:
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
		case 0:
			break;

        // Settings
		case 1:
			title = NSLocalizedString(@"Settings", @"'Settings' ButtonBar View text and Statistics View Title");
			break;
		
        // Website
        case 2:
			title = NSLocalizedString(@"Contact Information", @"More View Table Group Title");
			break;
		
        // Backup
        case 3:
			title = NSLocalizedString(@"Backup", @"More View Table Group Title");
			break;
		
		// version 
		case 4:
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
		[cell setValue:@""];
		[cell setTitle:@""];
	}


    switch (section) 
    {
        // Donate
        case 0:
			switch(row)
			{
				case 0:
					// if we are not editing, then 
					[cell setValue:NSLocalizedString(@"Please Donate, help me help you", @"More View Table Donation request")];
					break;
			}
            break;

        // Settings
		case 1:
			switch(row)
			{
				case 0:
					[cell setTitle:NSLocalizedString(@"Enable shown popups", @"More View Table Enable shown popups")];
					break;
			}
			break;
		
        // Website
        case 2:
			switch(row)
			{
				case 0:
					[cell setTitle:NSLocalizedString(@"MyTime Website", @"More View Table MyTime Website")];
					break;
					
				case 1:
					[cell setTitle:NSLocalizedString(@"Questions, Comments? Email me", @"More View Table Questions, Comments? Email me")];
					break;
			}
			break;
		
        // Website
        case 3:
			switch(row)
			{
				case 0:
					[cell setTitle:NSLocalizedString(@"Backup your data", @"More View Table backup your data")];
					break;
			}
			break;
		
		// version 
		case 4:
			switch(row)
			{
				case 0:
					[cell setTitle:NSLocalizedString(@"MyTime Version", @"More View Table MyTime Version")];
					[cell setValue:[NSString stringWithFormat:@"%s", svn_version()]];
					break;
				case 1:
					[cell setTitle:NSLocalizedString(@"Build Date", @"More View Table Build Date")];
					[cell setValue:[NSString stringWithFormat:@"%s", __DATE__]];
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

    DEBUG(NSLog(@"tableRowSelected: tableRowSelected section=@d row%d ", section, row);)

	switch(section)
	{
		case 0:
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
				
		case 1:
			switch(row)
			{
				// Re-enable popups
				case 0:
				{
					NSMutableDictionary *settings = [[Settings sharedInstance] settings];
					[settings removeObjectForKey:SettingsMainAlertSheetShown];
					[settings removeObjectForKey:SettingsTimeAlertSheetShown];
					[settings removeObjectForKey:SettingsStatisticsAlertSheetShown];
					[[Settings sharedInstance] saveData];
					[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
					UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
					[alertSheet addButtonWithTitle:@"OK"];
					alertSheet.title = NSLocalizedString(@"Popup messages like this are now enabled all throughout MyTime", @"Confirmation message about enabling popup messages");
					[alertSheet show];
					return;
				}
			}
			break;

		case 2:
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

				// email me
				case 1:
				{
					NSURL *url = [NSURL URLWithString:@"mailto:toopriddy@gmail.com?subject=Regarding%20your%20MyTime%20application"];
					[[UIApplication sharedApplication] openURL:url];
					return;
				}
			}
			break;

		case 3:
			switch(row)
			{
				// Backup your data
				case 0:
				{
					backupView = [[BackupView alloc] init];
					[backupView setDelegate:self];
					[backupView show];
					[tableView deselectRowAtIndexPath:indexPath animated:YES];
				}
			}
			break;
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if(alertView == backupView)
	{
		[backupView stop];
		[backupView release];
	}
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