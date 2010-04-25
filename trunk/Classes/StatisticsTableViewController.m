//
//  StatisticsTableViewController.m
//  MyTime
//
//  Created by Brent Priddy on 4/9/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "StatisticsTableViewController.h"
#import "Settings.h"
#import "UITableViewTitleAndValueCell.h"
#import "PSUrlString.h"
#import "PSLocalization.h"
#import "StatisticsNumberCell.h"
#import "HourPickerViewController.h"
#import "StatisticsCallsTableViewController.h"

#include "PSRemoveLocalizedString.h"
static NSString *MONTHS[] = {
	NSLocalizedString(@"January", @"Long month name"),
	NSLocalizedString(@"February", @"Long month name"),
	NSLocalizedString(@"March", @"Long month name"),
	NSLocalizedString(@"April", @"Long month name"),
	NSLocalizedString(@"May", @"Short/Long month name"),
	NSLocalizedString(@"June", @"Long month name"),
	NSLocalizedString(@"July", @"Long month name"),
	NSLocalizedString(@"August", @"Long month name"),
	NSLocalizedString(@"September", @"Long month name"),
	NSLocalizedString(@"October", @"Long month name"),
	NSLocalizedString(@"November", @"Long month name"),
	NSLocalizedString(@"December", @"Long month name")
};
#include "PSAddLocalizedString.h"

NSString * const StatisticsTypeHours = @"Hours";
NSString * const StatisticsTypeBooks = @"Books";
NSString * const StatisticsTypeBrochures = @"Brochures";
NSString * const StatisticsTypeMagazines = @"Magazines";
NSString * const StatisticsTypeReturnVisits = @"Return Visits";
NSString * const StatisticsTypeBibleStudies = @"Bible Studies";
NSString * const StatisticsTypeCampaignTracts = @"Campaign Tracts";
NSString * const StatisticsTypeRBCHours = @"RBC Hours";
													
/******************************************************************
 *
 *   ServiceYearStatisticsCellController
 *
 ******************************************************************/
#pragma mark ServiceYearStatisticsCellController
@interface ServiceYearStatisticsCellController : NSObject<TableViewCellController>
{
	NSString *ps_title;
	int *ps_serviceYearValue;
	BOOL ps_isHours;
	NSArray *calls;
	StatisticsTableViewController *delegate;
	BOOL displayIfZero;
}
@property (nonatomic, assign) StatisticsTableViewController *delegate;
@property (nonatomic, retain) NSArray *calls;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, assign) BOOL displayIfZero;
@end
@implementation ServiceYearStatisticsCellController
@synthesize title = ps_title;
@synthesize calls;
@synthesize delegate;
@synthesize displayIfZero;

- (id)initWithTitle:(NSString *)title serviceYearValue:(int *)serviceYearValue isHours:(BOOL)isHours
{
	if( (self = [super init]) )
	{
		self.title = title;
		ps_serviceYearValue = serviceYearValue;
		ps_isHours = isHours;
	}
	return self;
}

- (id)initWithTitle:(NSString *)title serviceYearValue:(int *)serviceYearValue
{
	return [self initWithTitle:title serviceYearValue:serviceYearValue isHours:NO];
}

- (void)dealloc
{
	self.calls = nil;
	self.title = nil;
	[super dealloc];
}

- (BOOL)isViewableWhenNotEditing
{
	return *(ps_serviceYearValue) != 0 || displayIfZero;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"ServiceYearStatisticsCellController";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
	}
	cell.textLabel.text = self.title;
	if(ps_isHours)
	{
		int value = *(ps_serviceYearValue);
		int hours = value / 60;
		int minutes = value % 60;
		if(hours && minutes)
			cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d %@ %d %@", @"You are localizing the time (I dont know if you need to even change this) as in '1 hour 34 minutes' or '2 hours 1 minute' %1$d is the hours number %2$@ is the label for hour(s) %3$d is the minutes number and 4$%@ is the label for minutes(s)"), hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours"), minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")];
		else if(hours)
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@", hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours")];
		else if(minutes)
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@", minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")];
		else
			cell.detailTextLabel.text = @"0";
	}
	else 
	{
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", *(ps_serviceYearValue)];
	}
	
	if(self.calls)
	{
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	else
	{
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}

	
	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(self.calls)
	{
		StatisticsCallsTableViewController *p = [[[StatisticsCallsTableViewController alloc] initWithCalls:self.calls] autorelease];
		[[self.delegate navigationController] pushViewController:p animated:YES];		
		[self.delegate retainObject:self whileViewControllerIsManaged:p];
	}
}

@end

/******************************************************************
 *
 *   StatisticsCellController
 *
 ******************************************************************/
#pragma mark StatisticsCellController
@interface StatisticsCellController : NSObject<TableViewCellController, StatisticsNumberCellDelegate>
{
	NSString *ps_title;
	int *ps_array;
	int ps_section;
	BOOL displayIfZero;
	int ps_timestamp;
	NSMutableDictionary *ps_adjustments;
	NSString *ps_adjustmentName;
	NSArray *calls;
	StatisticsTableViewController *delegate;
	int *ps_serviceYearValue;
}
@property (nonatomic, assign) StatisticsTableViewController *delegate;
@property (nonatomic, retain) NSArray *calls;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, assign) int *array;
@property (nonatomic, assign) int section;
@property (nonatomic, assign) BOOL displayIfZero;
@property (nonatomic, assign) int timestamp;
@property (nonatomic, retain, readonly) NSMutableDictionary *adjustments;
@property (nonatomic, assign) NSString *adjustmentName;
@end
@implementation StatisticsCellController
@synthesize array = ps_array;
@synthesize section = ps_section;
@synthesize title = ps_title;
@synthesize timestamp = ps_timestamp;
@synthesize adjustments = ps_adjustments;
@synthesize adjustmentName = ps_adjustmentName;
@synthesize displayIfZero;
@synthesize calls;
@synthesize delegate;

- (id)initWithTitle:(NSString *)title array:(int *)array section:(int)section timestamp:(int)timestamp adjustmentName:(NSString *)adjustmentName serviceYearValue:(int*)serviceYearValue
{
	if( (self = [super init]) )
	{
		self.title = title;
		self.array = array;
		self.section = section;
		self.timestamp = timestamp;
		self.adjustmentName = adjustmentName;
		ps_serviceYearValue = serviceYearValue;
	}
	return self;
}

- (void)dealloc
{
	self.calls = nil;
	self.title = nil;
	[ps_adjustments release];
	ps_adjustments = nil;
	self.adjustmentName = nil;
	[super dealloc];
}

- (BOOL)isViewableWhenNotEditing
{
	return displayIfZero || self.array[self.section];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"StatisticsCellController";
	StatisticsNumberCell *cell = (StatisticsNumberCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		// Create a temporary UIViewController to instantiate the custom cell.
        UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"StatisticsNumberCell" bundle:nil];
		// Grab a pointer to the custom cell.
        cell = (StatisticsNumberCell *)temporaryController.view;
		// Release the temporary UIViewController.
        [temporaryController autorelease];
	}
	
	cell.nameLabel.text = self.title;
	cell.delegate = self;
	cell.statistic = self.array[self.section];
	if(self.calls)
	{
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	else
	{
		cell.accessoryType = UITableViewCellAccessoryNone;	
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	return cell;
}

- (NSMutableDictionary *)adjustments
{
	if(ps_adjustments == nil)
	{
		// make sure that the main adjustments is there
		NSMutableDictionary *allAdjustments = [[[Settings sharedInstance] userSettings] objectForKey:SettingsStatisticsAdjustments];
		if(allAdjustments == nil)
		{
			// go add the timestamp
			allAdjustments = [NSMutableDictionary dictionary];
			[[[Settings sharedInstance] userSettings] setObject:allAdjustments forKey:SettingsStatisticsAdjustments];
		}
		// make sure the type of adjustment is there
		NSMutableDictionary *temp = [allAdjustments objectForKey:self.adjustmentName];
		if(temp == nil)
		{
			// go add the timestamp
			temp = [NSMutableDictionary dictionary];
			[allAdjustments setObject:temp forKey:self.adjustmentName];
		}
		
		ps_adjustments = [temp retain];
	}
	return [[ps_adjustments retain] autorelease];
}

- (void)statisticsNumberCellValueChanged:(StatisticsNumberCell *)cell
{
	NSString *stamp = [NSString stringWithFormat:@"%d", self.timestamp];
	int value = [[self.adjustments objectForKey:stamp] intValue];
	int difference = value + cell.statistic - self.array[self.section];
	int change = cell.statistic - self.array[self.section];
	self.array[self.section] = cell.statistic;

	if(ps_serviceYearValue)
		*ps_serviceYearValue += change;
	
	[self.adjustments setObject:[NSNumber numberWithInt:difference] forKey:stamp];
	[[Settings sharedInstance] saveData];
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(self.calls && !tableView.editing)
	{
		return indexPath;
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(self.calls && !tableView.editing)
	{
		StatisticsCallsTableViewController *p = [[[StatisticsCallsTableViewController alloc] initWithCalls:self.calls] autorelease];
		[[self.delegate navigationController] pushViewController:p animated:YES];		
		[self.delegate retainObject:self whileViewControllerIsManaged:p];
	}
}


@end

/******************************************************************
 *
 *   HourStatisticsCellController
 *
 ******************************************************************/
#pragma mark HourStatisticsCellController
@interface HourStatisticsCellController : StatisticsCellController <HourPickerViewControllerDelegate, UIActionSheetDelegate>
{
	BOOL enableRounding;
}
@property (nonatomic, assign) BOOL enableRounding;
@end
@implementation HourStatisticsCellController
@synthesize enableRounding;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"HourStatisticsCellController";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	cell.textLabel.text = self.title;
	int hours = self.array[self.section] / 60;
	int minutes = self.array[self.section] % 60;
	if(hours && minutes)
		cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d %@ %d %@", @"You are localizing the time (I dont know if you need to even change this) as in '1 hour 34 minutes' or '2 hours 1 minute' %1$d is the hours number %2$@ is the label for hour(s) %3$d is the minutes number and 4$%@ is the label for minutes(s)"), hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours"), minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")];
	else if(hours)
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@", hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours")];
	else if(minutes)
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@", minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")];
	else
		cell.detailTextLabel.text = @"0";

	if(minutes && enableRounding)
	{
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(tableView.editing)
	{
		// make the new call view 
		HourPickerViewController *p = [[[HourPickerViewController alloc] initWithTitle:NSLocalizedString(@"Enter Hours", @"This is the title for the Statistics->Edit->Select an hours row-> view that pops up to allow you to edit the hours") minutes:self.array[self.section]] autorelease];
		p.delegate = self;
		[[self.delegate navigationController] pushViewController:p animated:YES];		
		[self.delegate retainObject:self whileViewControllerIsManaged:p];
	}
	else
	{
		int hours = self.array[self.section] / 60;
		int minutes = self.array[self.section] % 60;
		if(enableRounding && minutes)
		{
			[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
			int month = self.timestamp % 100;
			NSString *monthName = [[PSLocalization localizationBundle] localizedStringForKey:MONTHS[month - 1] value:MONTHS[month - 1] table:@""];
			
			// handle rolling over minutes
			UIActionSheet *alertSheet = [[[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Would you like to move %d minutes from the month of %@ to the next month? Or, round up to %d hours for %@?\n(This will change the time that you put in the Hours view so you can undo this manually)", @"If the publisher has 1 hour 14 minutes, this question shows up in the statistics view if they click on the hours for a month, this question is asking them if they want to round up or roll over the minutes"), minutes, monthName, (hours+1), monthName]
																	 delegate:self
															cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
													   destructiveButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"Round Up to %d hours", @"Yes round up where %d is a placeholder for the number of hours"), hours+1]
															otherButtonTitles:[NSString stringWithFormat:NSLocalizedString(@"Move to next month", @"Yes roll over the extra minutes to the next month where %d is the placeholder for the number of minutes"), minutes], nil] autorelease];
			// 0: grey with grey and black buttons
			// 1: black background with grey and black buttons
			// 2: transparent black background with grey and black buttons
			// 3: grey transparent background
			alertSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
			[alertSheet showInView:[[[UIApplication sharedApplication] windows] objectAtIndex:0]];
			
		}
	}
}

- (void)hourPickerViewControllerDone:(HourPickerViewController *)hourPickerViewController
{
	NSString *stamp = [NSString stringWithFormat:@"%d", self.timestamp];
	int value = [[self.adjustments objectForKey:stamp] intValue];
	int difference = value + hourPickerViewController.minutes - self.array[self.section];
	int change = hourPickerViewController.minutes - self.array[self.section];
	self.array[self.section] = hourPickerViewController.minutes;
	
	if(ps_serviceYearValue)
		*ps_serviceYearValue += change;
	
	[self.adjustments setObject:[NSNumber numberWithInt:difference] forKey:stamp];
	[[Settings sharedInstance] saveData];
	[[self.delegate navigationController] popViewControllerAnimated:YES];
}
		   
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)button
{
	VERBOSE(NSLog(@"alertSheet: button:%d", button);)
	//	[sheet dismissAnimated:YES];
	
	switch(button)
	{
		case 0: // ROUND UP
		{
			int minutes = self.array[self.section] % 60;
			
			// take off the minutes off of this month
			NSString *stamp = [NSString stringWithFormat:@"%d", self.timestamp];
			int value = [[self.adjustments objectForKey:stamp] intValue];
			int difference = value - minutes + 60; // take off the minutes and add an hour
			self.array[self.section] = self.array[self.section] - minutes + 60;			
			[self.adjustments setObject:[NSNumber numberWithInt:difference] forKey:stamp];
			[[Settings sharedInstance] saveData];
			
			
			[self.delegate updateAndReload];
			break;
		}
			
		case 1: // MOVE TO NEXT MONTH
		{
			int minutes = self.array[self.section] % 60;
			
			// take off the minutes off of this month
			NSString *stamp = [NSString stringWithFormat:@"%d", self.timestamp];
			int value = [[self.adjustments objectForKey:stamp] intValue];
			int difference = value - minutes;
			self.array[self.section] = self.array[self.section] - minutes;			
			[self.adjustments setObject:[NSNumber numberWithInt:difference] forKey:stamp];
			
			// now move it to the next month
			int year = self.timestamp/100;
			int month = self.timestamp%100 + 1;
			if(month > 12)
			{
				month = 1;
				year++;
			}
			stamp = [NSString stringWithFormat:@"%d", (month + year*100)];
			value = [[self.adjustments objectForKey:stamp] intValue];
			[self.adjustments setObject:[NSNumber numberWithInt:(value + minutes)] forKey:stamp];
			
			
			[[Settings sharedInstance] saveData];
			
			[self.delegate updateAndReload];
			break;
		}
	}
}

@end


@implementation StatisticsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
	if( (self = [super initWithStyle:UITableViewStyleGrouped]) )
	{
		self.title = NSLocalizedString(@"Statistics", @"'Statistics' ButtonBar View text and Statistics View Title");
		self.tabBarItem.image = [UIImage imageNamed:@"statistics.png"];
	}
	return self;
}

-(void)viewWillAppear:(BOOL)animated
{
	// force the tableview to load if there was display information stored
	self.forceReload = YES;

	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	NSMutableDictionary *settings = [[Settings sharedInstance] settings];
	if([settings objectForKey:SettingsStatisticsAlertSheetShown] == nil)
	{
		[settings setObject:@"" forKey:SettingsStatisticsAlertSheetShown];
		[[Settings sharedInstance] saveData];
		
		UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
		[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
		alertSheet.title = NSLocalizedString(@"This will show you your tabulated end of the month field service activity including:\nHours\nBooks\nBrochures\nMagazines\nStudies\n Please note that you will only see items that you have counts for.", @"This is a note displayed when they first see the Statistics View");
		[alertSheet show];
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)sendEmailUsingMonthNames:(NSArray *)monthNames selectedMonths:(NSArray *)selectedMonths  
{
	// add notes if there are any
	int index;
	NSString *emailAddress = [[[Settings sharedInstance] settings] objectForKey:SettingsSecretaryEmailAddress];
	if(emailAddress == nil || emailAddress.length == 0)
		return;
	
	MFMailComposeViewController *mailView = [[[MFMailComposeViewController alloc] init] autorelease];
	[mailView setSubject:NSLocalizedString(@"Field Service Activity Report", @"Subject text for the email that is sent for the Field Service Activity report")];
	if(emailAddress && emailAddress.length)
	{
		[mailView setToRecipients:[emailAddress componentsSeparatedByString:@" "]];
	}
	
	NSMutableString *string = [[NSMutableString alloc] initWithString:@"<html><body>"];
	
	NSString *notes = [[[Settings sharedInstance] settings] objectForKey:SettingsSecretaryEmailNotes];
	if([notes length])
	{
		notes = [notes stringByReplacingOccurrencesOfString:@" " withString:@"&nbsp;"];
		notes = [notes stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
		[string appendString:notes];
		[string appendFormat:@"<br><br>"];
	}
	
	for(index = 0; index < [selectedMonths count]; ++index)
	{
		if([[selectedMonths objectAtIndex:index] boolValue])
		{
			[string appendString:@"<h3>"];
			[string appendString:[NSString stringWithFormat:NSLocalizedString(@"%@ Field Service Activity Report:<br>", @"Text used in the email that is sent to the congregation secretary, the <br> you see in the text are RETURN KEYS so that you can space multiple months apart from eachother"), [monthNames objectAtIndex:index]]];
			[string appendString:@"</h3>"];
			
			// HOURS
			NSString *count = @"0";
			int hours = _minutes[index] / 60;
			int minutes = _minutes[index] % 60;
			if(hours && minutes)
				count = [NSString stringWithFormat:NSLocalizedString(@"%d %@ %d %@", @"You are localizing the time (I dont know if you need to even change this) as in '1 hour 34 minutes' or '2 hours 1 minute' %1$d is the hours number %2$@ is the label for hour(s) %3$d is the minutes number and 4$%@ is the label for minutes(s)"), hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours"), minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")];
			else if(hours)
				count = [NSString stringWithFormat:@"%d %@", hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours")];
			else if(minutes)
				count = [NSString stringWithFormat:@"%d %@", minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")];
			[string appendString:[NSString stringWithFormat:@"%@: %@<br>", NSLocalizedString(@"Hours", @"'Hours' ButtonBar View text, Label for the amount of hours spend in the ministry, and Expanded name when on the More view"), count]];
			
			// BOOKS
			[string appendString:[NSString stringWithFormat:@"%@: %d<br>", NSLocalizedString(@"Books", @"Publication Type name"), _books[index]]];
			// BROCHURES
			[string appendString:[NSString stringWithFormat:@"%@: %d<br>", NSLocalizedString(@"Brochures", @"Publication Type name"), _brochures[index]]];
			// MAGAZINES
			[string appendString:[NSString stringWithFormat:@"%@: %d<br>", NSLocalizedString(@"Magazines", @"Publication Type name"), _magazines[index]]];
			// RETURN VISITS
			[string appendString:[NSString stringWithFormat:@"%@: %d<br>", NSLocalizedString(@"Return Visits", @"Return Visits label on the Statistics View"), _returnVisits[index]]];
			// STUDIES
			[string appendString:[NSString stringWithFormat:@"%@: %d<br>", NSLocalizedString(@"Bible Studies", @"Bible Studies label on the Statistics View"), _bibleStudies[index]]];
			// CAMPAIGN TRACTS
			if(_campaignTracts[index])
				[string appendString:[NSString stringWithFormat:@"%@: %d<br>", NSLocalizedString(@"Campaign Tracts", @"Publication Type name"), _campaignTracts[index]]];
			// QUICKBUILD TIME
			if(_quickBuildMinutes[index])
			{
				count = @"0";
				int hours = _quickBuildMinutes[index] / 60;
				int minutes = _quickBuildMinutes[index] % 60;
				if(hours && minutes)
					count = [NSString stringWithFormat:NSLocalizedString(@"%d %@ %d %@", @"You are localizing the time (I dont know if you need to even change this) as in '1 hour 34 minutes' or '2 hours 1 minute' %1$d is the hours number %2$@ is the label for hour(s) %3$d is the minutes number and 4$%@ is the label for minutes(s)"), hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours"), minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")];
				else if(hours)
					count = [NSString stringWithFormat:@"%d %@", hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours")];
				else if(minutes)
					count = [NSString stringWithFormat:@"%d %@", minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")];
				[string appendString:[NSString stringWithFormat:@"%@: %@<br>", NSLocalizedString(@"RBC Hours", @"'RBC Hours' ButtonBar View text, Label for the amount of hours spent doing quick builds"), count]];
			}
			[string appendString:@"<br><br>"];
		}
	}
	
	[string appendString:@"</body></html>"];
	[mailView setMessageBody:string isHTML:YES];
	[string release];
	[mailView setMailComposeDelegate:self];
	[self.navigationController presentModalViewController:mailView animated:YES];
	
}

- (void)monthChooserViewControllerSendEmail:(MonthChooserViewController *)monthChooserViewController
{
	NSString *emailAddress = monthChooserViewController.emailAddress.textField.text;
	[[[Settings sharedInstance] settings] setObject:emailAddress forKey:SettingsSecretaryEmailAddress];
	[[Settings sharedInstance] saveData];
	
	NSArray *selectedMonths = monthChooserViewController.selected;
	NSArray *monthNames = monthChooserViewController.months;
	
	[self sendEmailUsingMonthNames:monthNames selectedMonths:selectedMonths];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)button
{
	VERBOSE(NSLog(@"alertSheet: button:%d", button);)
	//	[sheet dismissAnimated:YES];
	
	if(_emailActionSheet)
	{
		if(button == 0)
		{
			int month = _thisMonth;
			NSMutableArray *months = [NSMutableArray array];
			int i;
			for(i = 0; i < 12; ++i)
			{
				if(month < 1)
					month = 12 + month;
				[months addObject:[[PSLocalization localizationBundle] localizedStringForKey:MONTHS[month - 1] value:MONTHS[month - 1] table:@""]];
				
				--month;
			}
			
			MonthChooserViewController *p = [[[MonthChooserViewController alloc] initWithMonths:months] autorelease];
			p.delegate = self;
			
			[[self navigationController] pushViewController:p animated:YES];		
		}
		else if(button == 1 && actionSheet.numberOfButtons > 2)
		{
			int month = _thisMonth;
			NSMutableArray *months = [NSMutableArray array];
			int i;
			for(i = 0; i < 12; ++i)
			{
				if(month < 1)
					month = 12 + month;
				[months addObject:[[PSLocalization localizationBundle] localizedStringForKey:MONTHS[month - 1] value:MONTHS[month - 1] table:@""]];
				
				--month;
			}
			
			// use the current month unless it is over the 6th day of the month
			int monthGuess = 0;
			NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit) fromDate:[NSDate date]];
			
			if([dateComponents day] <= 6)
			{
				monthGuess = 1;
			}
			NSMutableArray *array = [NSMutableArray array];
			for(int i = 0; i < 12; i++)
			{
				[array addObject:[NSNumber numberWithBool:(monthGuess == i)]];
			}
			[self sendEmailUsingMonthNames:months selectedMonths:array];
		}
	}
	else
	{
		[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
		switch(button)
		{
			case 0: // ROUND UP
			{
				int minutes = _minutes[_selectedMonth] % 60;
				
				NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
				[comps setMonth:-_selectedMonth];
				NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:[NSDate date] options:0];
				
				// now go and add the entry
				NSMutableDictionary *timeEntry = [NSMutableDictionary dictionary];
				[timeEntry setObject:date forKey:SettingsTimeEntryDate];
				[timeEntry setObject:[NSNumber numberWithInt:(60 - minutes)] forKey:SettingsTimeEntryMinutes];
				[[[[Settings sharedInstance] userSettings] objectForKey:SettingsTimeEntries] addObject:timeEntry];
				[[Settings sharedInstance] saveData];
				[self updateAndReload];
				break;
			}
				
			case 1: // MOVE TO NEXT MONTH
			{
				int minutes = _minutes[_selectedMonth] % 60;
				
				NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
				[comps setMonth:(1 - _selectedMonth)];
				NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:[NSDate date] options:0];
				
				//make the time entries editable
				NSMutableArray *timeEntries = [[[Settings sharedInstance] userSettings] objectForKey:SettingsTimeEntries];
				if(timeEntries == nil)
				{
					timeEntries = [NSMutableArray array];
					[[[Settings sharedInstance] userSettings] setObject:timeEntries forKey:SettingsTimeEntries];
				}
				// now go and add the entry
				NSMutableDictionary *timeEntry = [NSMutableDictionary dictionary];
				[timeEntry setObject:date forKey:SettingsTimeEntryDate];
				[timeEntry setObject:[NSNumber numberWithInt:minutes] forKey:SettingsTimeEntryMinutes];
				[timeEntries addObject:timeEntry];
				[[Settings sharedInstance] saveData];
				
				
				int month = _thisMonth - _selectedMonth;
				int year = _thisYear;
				if(month < 1)
				{
					--year;
					month += 12;
				}
				
				// now remove time from an entry in this month
				int timeCount = [timeEntries count];
				int timeIndex;
				for(timeIndex = 0; timeIndex < timeCount; ++timeIndex)
				{
					timeEntry = [timeEntries objectAtIndex:timeIndex];
					
					NSDate *date = [timeEntry objectForKey:SettingsTimeEntryDate];	
					NSNumber *minutesEntry = [timeEntry objectForKey:SettingsTimeEntryMinutes];
					if(date && minutesEntry)
					{
						NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit) fromDate:date];
						if(month == [dateComponents month] && year == [dateComponents year])
						{
							// get the minimum of the two
							int leftover = [minutesEntry intValue] < minutes ? [minutesEntry intValue] : minutes;
							
							NSMutableDictionary *newTimeEntry = [NSMutableDictionary dictionary];
							[newTimeEntry setObject:date forKey:SettingsTimeEntryDate];
							[newTimeEntry setObject:[NSNumber numberWithInt:([minutesEntry intValue] - leftover)] forKey:SettingsTimeEntryMinutes];
							[timeEntries replaceObjectAtIndex:timeIndex withObject:newTimeEntry];
							// subtract off what we were able to take off of this time entry
							// if it turns out that it was not enough, then we will try another entry
							minutes -= leftover;
							if(minutes == 0)
							{
								[[Settings sharedInstance] saveData];
								// we have finished subtracting minutes off of time entries
								break;
							}
						}
					}
				}
				
				
				[self updateAndReload];
				break;
			}
		}
	}
}

- (void)navigationControlEmail:(id)sender
{
	int month = _thisMonth;
	NSMutableArray *months = [NSMutableArray array];
	int i;
	for(i = 0; i < 12; ++i)
	{
		if(month < 1)
			month = 12 + month;
		[months addObject:[[PSLocalization localizationBundle] localizedStringForKey:MONTHS[month - 1] value:MONTHS[month - 1] table:@""]];
		
		--month;
	}
	
	// use the current month unless it is over the 6th day of the month
	NSString *monthGuess = [months objectAtIndex:0];
    // initalize the data to the current date
	NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit) fromDate:[NSDate date]];
	
	if([dateComponents day] <= 6)
	{
		monthGuess = [months objectAtIndex:1];
	}	
	UIActionSheet *actionSheet;
	if([[[Settings sharedInstance] settings] objectForKey:SettingsSecretaryEmailAddress])
	{
		actionSheet = [[[UIActionSheet alloc] initWithTitle:@""
												   delegate:self
										  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
								     destructiveButtonTitle:nil
										  otherButtonTitles:NSLocalizedString(@"Pick Months To Email", @"Statistics button to allow you to pick months to email to the congregation secretary")
						,[NSString stringWithFormat:NSLocalizedString(@"Email %@ Report", @"This is text used in the statistics view where you click on the 'ActionSheet' button and it asks you what you want to do to email your congregation secretary your statistics where %@ is the placeholder for the month"), monthGuess]
						,nil] autorelease];
	}
	else
	{
		actionSheet = [[[UIActionSheet alloc] initWithTitle:@""
												   delegate:self
										  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
									 destructiveButtonTitle:nil
										  otherButtonTitles:NSLocalizedString(@"Pick Months To Email", @"Statistics button to allow you to pick months to email to the congregation secretary")
						,nil] autorelease];
	}
	_emailActionSheet = YES;
	// 0: grey with grey and black buttons
	// 1: black background with grey and black buttons
	// 2: transparent black background with grey and black buttons
	// 3: grey transparent background
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showInView:[[[UIApplication sharedApplication] windows] objectAtIndex:0]];
	
}

- (void)displayButtons
{
	if(self.editing)
	{
		// update the button in the nav bar
		UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																				 target:self
																				 action:@selector(navigationControlDone:)] autorelease];
		[self.navigationItem setRightBarButtonItem:button animated:YES];
		[self.navigationItem setLeftBarButtonItem:nil animated:YES];
		
		// hide the back button so that they cant cancel the edit without hitting done
		self.navigationItem.hidesBackButton = YES;
	}
	else
	{
		// update the button in the nav bar
		UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
																				 target:self
																				 action:@selector(navigationControlEdit:)] autorelease];
		[self.navigationItem setRightBarButtonItem:button animated:YES];
		// update the button in the nav bar
		button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																target:self
																action:@selector(navigationControlEmail:)] autorelease];
		[self.navigationItem setLeftBarButtonItem:button animated:YES];
	}

}

- (void)navigationControlEdit:(id)sender 
{
	self.editing = YES;
	[self displayButtons];
}	

- (void)navigationControlDone:(id)sender 
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	
	self.editing = NO;
	[self displayButtons];
}	

- (void)loadView 
{
	[super loadView];
	
	[self displayButtons];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)countCalls:(NSMutableArray *)calls
{
	int callIndex;
	BOOL newServiceYear = _thisMonth >= 9;
	
	// go through all of the calls and see what the counts are for this month and last month
	for(callIndex = 0; callIndex < [calls count]; ++callIndex)
	{
		NSDictionary *call = [calls objectAtIndex:callIndex];
		if([call objectForKey:CallReturnVisits] != nil)
		{
			// lets check all of the ReturnVisits to make sure that everything was 
			// initialized correctly
			NSMutableArray *returnVisits = [call objectForKey:CallReturnVisits];
			NSMutableDictionary *visit;
			
			BOOL studyAlreadyConducted[12];
			memset(studyAlreadyConducted, 0, sizeof(studyAlreadyConducted));
			
			int previousServiceYearBibleStudies = _serviceYearBibleStudies;
			
			int i;
			int returnVisitsCount = [returnVisits count];
			for(i = returnVisitsCount; i > 0; --i)
			{
				visit = [returnVisits objectAtIndex:i-1];
				NSDate *date = [visit objectForKey:CallReturnVisitDate];
				
				if(date != nil)
				{
					date = [[[NSDate alloc] initWithTimeIntervalSinceReferenceDate:[date timeIntervalSinceReferenceDate]] autorelease];	
					NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit) fromDate:date];
					int month = [dateComponents month];
					int year = [dateComponents year];
					
					int offset = -1;
					
					if(year == _thisYear && 
					   month <= _thisMonth)
					{
						offset = _thisMonth - month;
					}
					// if this call was made last year and in a month after this month
					else if(year == _thisYear - 1 &&
							_thisMonth < month)
					{
						offset = 12 - month + _thisMonth;
					}
					
					// this month's information should not be counted
					if(offset < 0 || offset > 11)
						continue;
					
					NSString *type = [visit objectForKey:CallReturnVisitType];
					BOOL isStudy = [type isEqualToString:CallReturnVisitTypeStudy];
					BOOL isNotAtHome = [type isEqualToString:CallReturnVisitTypeNotAtHome];
					BOOL isTransfer = [type isEqualToString:CallReturnVisitTypeTransferedStudy] ||
					[type isEqualToString:CallReturnVisitTypeTransferedReturnVisit] ||
					[type isEqualToString:CallReturnVisitTypeTransferedNotAtHome];
					
					if(returnVisitsCount > 1 && i != returnVisitsCount)
					{
						// if this is not the first visit and
						// if there are more than 1 visit then that means that any return visits
						// this month are counted as return visits
						if(!isNotAtHome && !isTransfer)
						{
							_returnVisits[offset]++;
							if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
							   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
							{
								_serviceYearReturnVisits++;
							}
						}
					}
					else if(isStudy)
					{
						// go ahead and count studies as return visits
						_returnVisits[offset]++;
						if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
						   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
						{
							_serviceYearReturnVisits++;
						}
					}
					
					if(!studyAlreadyConducted[offset] && 
					   isStudy)
					{
						studyAlreadyConducted[offset] = YES;
						_bibleStudies[offset]++;
						if(_individualCalls[offset] == nil)
						{
							_individualCalls[offset] = [[NSMutableArray alloc] init];
						}
						[_individualCalls[offset] addObject:call];
						
						if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
						   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
						{
							_serviceYearBibleStudies++;
						}
					}
					
					// we only care about counting this month's or last month's returnVisits' calls
					// go through all of the calls and see if we need to count the statistics
					if([visit objectForKey:CallReturnVisitPublications] != nil)
					{
						// they had an array of publications, lets check them too
						NSMutableArray *publications = [visit objectForKey:CallReturnVisitPublications];
						NSMutableDictionary *publication;
						int j;
						int endPublications = [publications count];
						for(j = 0; j < endPublications; ++j)
						{
							publication = [publications objectAtIndex:j];
							NSString *type;
							if((type = [publication objectForKey:CallReturnVisitPublicationType]) != nil)
							{
								if([type isEqualToString:PublicationTypeBook] ||
								   [type isEqualToString:PublicationTypeDVDBible] || 
								   [type isEqualToString:PublicationTypeDVDBook])
								{
									if(!isTransfer)
									{
										_books[offset]++;
										if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
										   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
										{
											_serviceYearBooks++;
										}
									}
								}
								else if([type isEqualToString:PublicationTypeBrochure] ||
										[type isEqualToString:PublicationTypeDVDBrochure])
								{
									if(!isTransfer)
									{
										_brochures[offset]++;
										if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
										   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
										{
											_serviceYearBrochures++;
										}
									}
								}
								else if([type isEqualToString:PublicationTypeMagazine])
								{
									if(!isTransfer)
									{
										_magazines[offset]++;
										if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
										   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
										{
											_serviceYearMagazines++;
										}
									}
								}
								else if([type isEqualToString:PublicationTypeTwoMagazine])
								{
									if(!isTransfer)
									{
										_magazines[offset] += 2;
										if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
										   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
										{
											_serviceYearMagazines += 2;
										}
									}
								}
								else if([type isEqualToString:PublicationTypeCampaignTract])
								{
									if(!isTransfer)
									{
										_campaignTracts[offset]++;
										if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
										   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
										{
											_serviceYearCampaignTracts++;
										}
									}
								}
							}
						}
					}
				}
			}
			// if this is someone we studied with this service year, then count them
			if(previousServiceYearBibleStudies != _serviceYearBibleStudies) 
			{
				_serviceYearStudyIndividuals++;
				[_serviceYearStudyIndividualCalls addObject:call];
			}
		}
	}
}

- (void)computeStatisticsDeletingOldEntries:(BOOL)deleteOldEntries
{
	memset(_books, 0, sizeof(_books));
	memset(_brochures, 0, sizeof(_brochures));
	memset(_minutes, 0, sizeof(_minutes));
	memset(_magazines, 0, sizeof(_magazines));
	memset(_returnVisits, 0, sizeof(_returnVisits));
	memset(_bibleStudies, 0, sizeof(_bibleStudies));
	memset(_campaignTracts, 0, sizeof(_campaignTracts));
	memset(_quickBuildMinutes, 0, sizeof(_quickBuildMinutes));
	
	for(int i = 0; i < kMonthsShown; i++)
	{
		[_individualCalls[i] release];
		_individualCalls[i] = nil;
	}
	_serviceYearBooks = 0;
	_serviceYearBrochures = 0;
	_serviceYearMinutes = 0;
	_serviceYearQuickBuildMinutes = 0;
	_serviceYearMagazines = 0;
	_serviceYearReturnVisits = 0;
	_serviceYearBibleStudies = 0;
	_serviceYearStudyIndividuals = 0;
	_serviceYearCampaignTracts = 0;
	[_serviceYearStudyIndividualCalls release];
	_serviceYearStudyIndividualCalls = [[NSMutableArray alloc] init];
	
	NSMutableDictionary *userSettings = [[Settings sharedInstance] userSettings];
	
	BOOL newServiceYear = _thisMonth >= 9;
	
	//Start with Adjustments
	NSMutableDictionary *adjustmentTypes = [userSettings objectForKey:SettingsStatisticsAdjustments];
	for(NSString *key in [adjustmentTypes allKeys])
	{
		int dummyArray[kMonthsShown];
		int *array = dummyArray;
		int *serviceYearValue;
		
		if([key isEqualToString:StatisticsTypeHours])
		{
			array = _minutes;
			serviceYearValue = &_serviceYearMinutes;
		}
		else if([key isEqualToString:StatisticsTypeBooks])
		{
			array = _books;
			serviceYearValue = &_serviceYearBooks;
		}
		else if([key isEqualToString:StatisticsTypeBrochures])
		{
			array = _brochures;
			serviceYearValue = &_serviceYearBrochures;
		}
		else if([key isEqualToString:StatisticsTypeMagazines])
		{
			array = _magazines;
			serviceYearValue = &_serviceYearMagazines;
		}
		else if([key isEqualToString:StatisticsTypeReturnVisits])
		{
			array = _returnVisits;
			serviceYearValue = &_serviceYearReturnVisits;
		}
		else if([key isEqualToString:StatisticsTypeBibleStudies])
		{
			array = _bibleStudies;
			serviceYearValue = &_serviceYearBibleStudies;
		}
		else if([key isEqualToString:StatisticsTypeCampaignTracts])
		{
			array = _campaignTracts;
			serviceYearValue = &_serviceYearCampaignTracts;
		}
		else if([key isEqualToString:StatisticsTypeRBCHours])
		{
			array = _quickBuildMinutes;
			serviceYearValue = &_serviceYearQuickBuildMinutes;
		}
		assert(array);// you should handle this
		assert(serviceYearValue);// you should handle this

		NSMutableDictionary *adjustments = [adjustmentTypes objectForKey:key];
		for(int section = 0; section < 12; ++section)
		{
			int month = _thisMonth - section;
			int timestamp;
			if(month < 1)
			{
				month = 12 + month;
				timestamp = (_thisYear - 1) * 100 + month;
			}
			else
			{
				timestamp = _thisYear * 100 + month;
			}
			int value = [[adjustments objectForKey:[NSString stringWithFormat:@"%d", timestamp]] intValue];
			if(value == 0)
				continue;
			
			array[section] += value;
						
			if( (newServiceYear && month <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
			   (!newServiceYear && _thisMonth + 4 > month)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
			{
				*serviceYearValue += value;
			}
		}
	}
	
	// Hours entries
	NSArray *timeEntries = [userSettings objectForKey:SettingsTimeEntries];
	int timeIndex;
	int timeCount = [timeEntries count];
	for(timeIndex = 0; timeIndex < timeCount; ++timeIndex)
	{
		NSDictionary *timeEntry = [timeEntries objectAtIndex:timeIndex];
		
		NSDate *date = [timeEntry objectForKey:SettingsTimeEntryDate];	
		NSNumber *minutes = [timeEntry objectForKey:SettingsTimeEntryMinutes];
		if(date && minutes)
		{
			NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit) fromDate:date];
			int month = [dateComponents month];
			int year = [dateComponents year];
			
			int offset = -1;
			if(year == _thisYear && 
			   month <= _thisMonth)
			{
				offset = _thisMonth - month;
			}
			else if(year == _thisYear - 1 &&
			        month > _thisMonth)
			{
				offset = 12 - month + _thisMonth;
			}
			if(offset < 0 || offset > 11)
				continue;
			
			// we found a valid month
			_minutes[offset] += [minutes intValue];
			
			if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
			   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
			{
				_serviceYearMinutes += [minutes intValue];
			}
		}
	}


	// QUICK BUILD
	
	timeEntries = [userSettings objectForKey:SettingsRBCTimeEntries];
	timeCount = [timeEntries count];
	for(timeIndex = 0; timeIndex < timeCount; ++timeIndex)
	{
		NSDictionary *timeEntry = [timeEntries objectAtIndex:timeIndex];
		
		NSDate *date = [timeEntry objectForKey:SettingsTimeEntryDate];	
		NSNumber *minutes = [timeEntry objectForKey:SettingsTimeEntryMinutes];
		if(date && minutes)
		{
			NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit) fromDate:date];
			int month = [dateComponents month];
			int year = [dateComponents year];
			
			int offset = -1;
			if(year == _thisYear && 
			   month <= _thisMonth)
			{
				offset = _thisMonth - month;
			}
			// if this call was made last year and in a month after this month
			else if(year == _thisYear - 1 &&
					_thisMonth < month)
			{
				offset = 12 - month + _thisMonth;
			}
			if(offset < 0 || offset > 11)
				continue;
			
			_quickBuildMinutes[offset] += [minutes intValue];
			
			// newServiceYear means that the months that are added are above the current month
			if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
			   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
			{
				_serviceYearQuickBuildMinutes += [minutes intValue];
			}
		}
	}
	
	
	// go through all of the bulk publications
	NSArray *bulkArray = [userSettings objectForKey:SettingsBulkLiterature];
	NSEnumerator *bulkArrayEnumerator = [bulkArray objectEnumerator];
	NSDictionary *entry;
	
	while( (entry = [bulkArrayEnumerator nextObject]) ) // ASSIGNMENT, NOT COMPARISON 
	{
		NSDate *date = [entry objectForKey:BulkLiteratureDate];
		int offset = -1;
		
		if(date != nil)
		{
			NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit) fromDate:date];
			int month = [dateComponents month];
			int year = [dateComponents year];
			
			if(year == _thisYear && 
			   month <= _thisMonth)
			{
				offset = _thisMonth - month;
			}
			// if this call was made last year and in a month after this month
			else if(year == _thisYear - 1 &&
					_thisMonth < month)
			{
				offset = 12 - month + _thisMonth;
			}
		}
		
		if(offset >= 0)
		{
			NSEnumerator *publicationEnumerator = [[entry objectForKey:BulkLiteratureArray] objectEnumerator];
			NSMutableDictionary *publication;
			while( (publication = [publicationEnumerator nextObject]) )
			{
				int number =[[publication objectForKey:BulkLiteratureArrayCount] intValue];
				NSString *type = [publication objectForKey:BulkLiteratureArrayType];
				if(type != nil)
				{
					if([type isEqualToString:PublicationTypeBook] || 
					   [type isEqualToString:PublicationTypeDVDBible] || 
					   [type isEqualToString:PublicationTypeDVDBook])
					{
						_books[offset] += number;
						if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
						   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
						{
							_serviceYearBooks += number;
						}
					}
					else if([type isEqualToString:PublicationTypeBrochure] || 
							[type isEqualToString:PublicationTypeDVDBrochure])
					{
						_brochures[offset] += number;
						if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
						   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
						{
							_serviceYearBrochures += number;
						}
					}
					else if([type isEqualToString:PublicationTypeMagazine])
					{
						_magazines[offset] += number;
						if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
						   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
						{
							_serviceYearMagazines += number;
						}
					}
					else if([type isEqualToString:PublicationTypeTwoMagazine])
					{
						_magazines[offset] += number*2;
						if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
						   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
						{
							_serviceYearMagazines += number*2;
						}
					}
					else if([type isEqualToString:PublicationTypeCampaignTract])
					{
						_campaignTracts[offset] += number;
						if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
						   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
						{
							_serviceYearCampaignTracts += number;
						}
					}
				}
				
			}
		}
	}
	
	[self countCalls:[userSettings objectForKey:SettingsCalls]];
	[self countCalls:[userSettings objectForKey:SettingsDeletedCalls]];
}

- (BOOL)showYearInformation
{
	NSString *type = [[[Settings sharedInstance] userSettings] objectForKey:SettingsPublisherType];
	return type == nil || 
	[type isEqualToString:PublisherTypePioneer] ||
	[type isEqualToString:PublisherTypeSpecialPioneer] ||
	[type isEqualToString:PublisherTypeTravelingServant];
}

- (void)constructSectionControllers
{
	[super constructSectionControllers];
	
	// save off this month and last month for quick compares
	NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit) fromDate:[NSDate date]];
	_thisMonth = [dateComponents month];
	_thisYear = [dateComponents year];
	
	_lastMonth = _thisMonth == 1 ? 12 : _thisMonth - 1;
	
	if(_thisMonth == 9)
	{
		// first *sigh* go through last service year and add up everything
		_thisMonth = 8;
		_lastMonth = 7;
		[self computeStatisticsDeletingOldEntries:NO];
		
		// then save everything that we care about off
		int serviceYearBooks = _serviceYearBooks;
		int serviceYearBrochures = _serviceYearBrochures;
		int serviceYearMinutes = _serviceYearMinutes;
		int serviceYearQuickBuildMinutes = _serviceYearQuickBuildMinutes;
		int serviceYearMagazines = _serviceYearMagazines;
		int serviceYearReturnVisits = _serviceYearReturnVisits;
		int serviceYearBibleStudies = _serviceYearBibleStudies;
		int serviceYearStudyIndividuals = _serviceYearStudyIndividuals;
		int serviceYearCampaignTracts = _serviceYearCampaignTracts;
		
		NSMutableArray *serviceYearStudyIndividualCalls = _serviceYearStudyIndividualCalls;
		_serviceYearStudyIndividualCalls = [[NSMutableArray alloc] init];
		
		// now recompute the statistics and then...
		_thisMonth = 9;
		_lastMonth = 8;
		[self computeStatisticsDeletingOldEntries:YES];
		
		// use the old service year numbers instead of the current service year
		_serviceYearBooks = serviceYearBooks;
		_serviceYearBrochures = serviceYearBrochures;
		_serviceYearMinutes = serviceYearMinutes;
		_serviceYearQuickBuildMinutes = serviceYearQuickBuildMinutes;
		_serviceYearMagazines = serviceYearMagazines;
		_serviceYearReturnVisits = serviceYearReturnVisits;
		_serviceYearBibleStudies = serviceYearBibleStudies;
		_serviceYearStudyIndividuals = serviceYearStudyIndividuals;
		_serviceYearCampaignTracts = serviceYearCampaignTracts;
		[_serviceYearStudyIndividualCalls release];
		_serviceYearStudyIndividualCalls = serviceYearStudyIndividualCalls;
		
		_serviceYearText = NSLocalizedString(@"Last Service Year Total", @"Last Service year total hours label");
	}
	else
	{
		_serviceYearText = NSLocalizedString(@"Service Year Total", @"Service year total hours label");
		[self computeStatisticsDeletingOldEntries:YES];
	}
	
	// Service Year Totals
	if([self showYearInformation])
	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		sectionController.isViewableWhenEditing = NO;
		sectionController.title = _serviceYearText;
		[self.sectionControllers addObject:sectionController];
		[sectionController release];

		// Hours
		{
			ServiceYearStatisticsCellController *cellController = [[ServiceYearStatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Hours", @"'Hours' ButtonBar View text, Label for the amount of hours spend in the ministry, and Expanded name when on the More view")
																											serviceYearValue:&_serviceYearMinutes
																													 isHours:YES];
			cellController.displayIfZero = YES;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Books
		{
			ServiceYearStatisticsCellController *cellController = [[ServiceYearStatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Books", @"Publication Type name") 
																											serviceYearValue:&_serviceYearBooks];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Brochures
		{
			ServiceYearStatisticsCellController *cellController = [[ServiceYearStatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Brochures", @"Publication Type name") 
																											serviceYearValue:&_serviceYearBrochures];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Magazines
		{
			ServiceYearStatisticsCellController *cellController = [[ServiceYearStatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Magazines", @"Publication Type name") 
																											serviceYearValue:&_serviceYearMagazines];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Return Visits
		{
			ServiceYearStatisticsCellController *cellController = [[ServiceYearStatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Return Visits", @"Return Visits label on the Statistics View") 
																											serviceYearValue:&_serviceYearReturnVisits];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Bible Studies
		{
			ServiceYearStatisticsCellController *cellController = [[ServiceYearStatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Bible Studies", @"Bible Studies label on the Statistics View") 
																											serviceYearValue:&_serviceYearBibleStudies];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Study Individuals
		{
			ServiceYearStatisticsCellController *cellController = [[ServiceYearStatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Study Individuals", @"Bible Studies label on the Statistics View") 
																											serviceYearValue:&_serviceYearStudyIndividuals];
			cellController.calls = _serviceYearStudyIndividualCalls;
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Campaign Tracts
		{
			ServiceYearStatisticsCellController *cellController = [[ServiceYearStatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Campaign Tracts", @"Publication Type name") 
																											serviceYearValue:&_serviceYearCampaignTracts];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// RBC Hours
		{
			ServiceYearStatisticsCellController *cellController = [[ServiceYearStatisticsCellController alloc] initWithTitle:NSLocalizedString(@"RBC Hours", @"'RBC Hours' ButtonBar View text, Label for the amount of hours spent doing quick builds")
																											serviceYearValue:&_serviceYearQuickBuildMinutes
																													 isHours:YES];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
	}	

	// how many months do they want to show?
	int shownMonths = 2;
	NSNumber *value = [[[Settings sharedInstance] userSettings] objectForKey:SettingsMonthDisplayCount];
	if(value)
		shownMonths = [value intValue];
	
	// figure out the timestamp to compare the month/year with
	// we are only comparing serviceYearTimeStampStart < timestamp because we dont want to include september in the counts.
	// the month of september displays last service year only
	int serviceYearTimestampStart;
	if(_thisMonth >= 9)
		serviceYearTimestampStart = _thisYear * 100 + 9;
	else
		serviceYearTimestampStart = (_thisYear - 1) * 100 + 9;
		

	for(int section = 0; section < 12; section++)
	{
		NSString *title;
		int month = _thisMonth - section;
		int timestamp;
		if(month < 1)
		{
			month = 12 + month;
			timestamp = (_thisYear - 1) * 100 + month;
		}
		else
		{
			timestamp = _thisYear * 100 + month;
		}

		title = [NSString stringWithFormat:NSLocalizedString(@"Time for %@", @"Time for %@ Group title on the Statistics View where %@ is the month of the year"), 
				 [[PSLocalization localizationBundle] localizedStringForKey:MONTHS[month - 1] value:MONTHS[month - 1] table:@""]];

		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		sectionController.title = title;
		sectionController.isViewableWhenNotEditing = section < shownMonths; // only show X number of months
		[self.sectionControllers addObject:sectionController];
		[sectionController release];
		
		// Hours
		{
			HourStatisticsCellController *cellController = [[HourStatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Hours", @"'Hours' ButtonBar View text, Label for the amount of hours spend in the ministry, and Expanded name when on the More view")
																										 array:_minutes
																									   section:section
																									 timestamp:timestamp
																								adjustmentName:StatisticsTypeHours
																							  serviceYearValue:(serviceYearTimestampStart < timestamp) ? &_serviceYearMinutes : nil];
			cellController.delegate = self;
			cellController.enableRounding = YES;
			cellController.displayIfZero = YES;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Books
		{
			StatisticsCellController *cellController = [[StatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Books", @"Publication Type name")
																								 array:_books
																							   section:section
																							 timestamp:timestamp
																						adjustmentName:StatisticsTypeBooks
																					  serviceYearValue:((serviceYearTimestampStart < timestamp) ? &_serviceYearBooks : nil)];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Brochures
		{
			StatisticsCellController *cellController = [[StatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Brochures", @"Publication Type name")
																								 array:_brochures
																							   section:section
																							 timestamp:timestamp
																						adjustmentName:StatisticsTypeBrochures
																					  serviceYearValue:((serviceYearTimestampStart < timestamp) ? &_serviceYearBrochures : nil)];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Magazines
		{
			StatisticsCellController *cellController = [[StatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Magazines", @"Publication Type name")
																								 array:_magazines
																							   section:section
																							 timestamp:timestamp
																						adjustmentName:StatisticsTypeMagazines
																					  serviceYearValue:((serviceYearTimestampStart < timestamp) ? &_serviceYearMagazines : nil)];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Return Visits
		{
			StatisticsCellController *cellController = [[StatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Return Visits", @"Return Visits label on the Statistics View")
																								 array:_returnVisits
																							   section:section
																							 timestamp:timestamp
																						adjustmentName:StatisticsTypeReturnVisits
																					  serviceYearValue:((serviceYearTimestampStart < timestamp) ? &_serviceYearReturnVisits : nil)];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Bible Studies
		{
			StatisticsCellController *cellController = [[StatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Bible Studies", @"Bible Studies label on the Statistics View")
																								 array:_bibleStudies
																							   section:section
																							 timestamp:timestamp
																						adjustmentName:StatisticsTypeBibleStudies
																					  serviceYearValue:((serviceYearTimestampStart < timestamp) ? &_serviceYearBibleStudies : nil)];
			cellController.calls = _individualCalls[section];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Campaign Tracts
		{
			StatisticsCellController *cellController = [[StatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Campaign Tracts", @"Publication Type name") 
																								 array:_campaignTracts
																							   section:section
																							 timestamp:timestamp
																						adjustmentName:StatisticsTypeCampaignTracts
																					  serviceYearValue:((serviceYearTimestampStart < timestamp) ? &_serviceYearCampaignTracts : nil)];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// RBC Hours
		{
			HourStatisticsCellController *cellController = [[HourStatisticsCellController alloc] initWithTitle:NSLocalizedString(@"RBC Hours", @"'RBC Hours' ButtonBar View text, Label for the amount of hours spent doing quick builds")
																										 array:_quickBuildMinutes
																									   section:section
																									 timestamp:timestamp
																								adjustmentName:StatisticsTypeRBCHours
																							  serviceYearValue:((serviceYearTimestampStart < timestamp) ? &_serviceYearQuickBuildMinutes : nil)];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
	}
}


@end
