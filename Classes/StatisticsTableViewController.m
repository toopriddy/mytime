//
//  StatisticsTableViewController.m
//  MyTime
//
//  Created by Brent Priddy on 4/9/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import "StatisticsTableViewController.h"
#import "Settings.h"
#import "UITableViewTitleAndValueCell.h"
#import "PSUrlString.h"
#import "PSLocalization.h"

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

/******************************************************************
 *
 *   StatisticsCellController
 *
 ******************************************************************/
#pragma mark StatisticsCellController
@interface StatisticsCellController : NSObject<TableViewCellController>
{
	NSString *ps_title;
	int *ps_array;
	int ps_section;
	BOOL displayIfZero;
}
@property (nonatomic, retain) NSString *title;
@property (nonatomic, assign) int *array;
@property (nonatomic, assign) int section;
@property (nonatomic, assign) BOOL displayIfZero;
@end
@implementation StatisticsCellController
@synthesize array = ps_array;
@synthesize section = ps_section;
@synthesize title = ps_title;
@synthesize displayIfZero;

- (id)initWithTitle:(NSString *)title array:(int *)array section:(int)section
{
	if( (self = [super init]) )
	{
		self.title = title;
		self.array = array;
		self.section = section;
	}
	return self;
}

- (void)dealloc
{
	self.title = nil;
	[super dealloc];
}

- (BOOL)isViewableWhenNotEditing
{
	return displayIfZero || self.array[self.section];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"StatisticsCellController";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	cell.textLabel.text = self.title;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", self.array[self.section]];
	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}
@end

/******************************************************************
 *
 *   HourStatisticsCellController
 *
 ******************************************************************/
#pragma mark HourStatisticsCellController
@interface HourStatisticsCellController : StatisticsCellController
{
}
@end
@implementation HourStatisticsCellController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"HourStatisticsCellController";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
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

	if(minutes)
	{
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
	[super viewWillAppear:animated];
	// force the tableview to load
	[self updateAndReload];
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

- (void)navigationControlEdit:(id)sender 
{
	// update the button in the nav bar
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(navigationControlDone:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:YES];
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
	// show the back button when they are done editing
	self.navigationItem.hidesBackButton = NO;
	
	// hide the back button so that they cant cancel the edit without hitting done
	self.navigationItem.hidesBackButton = YES;
	
	self.editing = YES;
}	

- (void)navigationControlDone:(id)sender 
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	
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
	
	self.editing = NO;
}	

- (void)loadView 
{
	[super loadView];
	
	// update the button in the nav bar
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
																			 target:self
																			 action:@selector(navigationControlEdit:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:YES];
	// add action button
	 button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
															 target:self
															 action:@selector(navigationControlEmail:)] autorelease];
	[self.navigationItem setLeftBarButtonItem:button animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)countCalls:(NSMutableArray *)calls removeOld:(BOOL)removeOld
{
	BOOL found;
	int callIndex;
	BOOL newServiceYear = _thisMonth >= 9;
	
	// go through all of the calls and see what the counts are for this month and last month
	for(callIndex = 0; callIndex < [calls count]; ++callIndex)
	{
		NSDictionary *call = [calls objectAtIndex:callIndex];
		found = NO;
		if([call objectForKey:CallReturnVisits] != nil)
		{
			// lets check all of the ReturnVisits to make sure that everything was 
			// initialized correctly
			NSMutableArray *returnVisits = [call objectForKey:CallReturnVisits];
			NSMutableDictionary *visit;
			
			BOOL studyAlreadyConducted[12];
			memset(studyAlreadyConducted, 0, sizeof(studyAlreadyConducted));
			
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
					
					found = YES;
					
					if(!studyAlreadyConducted[offset] && 
					   isStudy)
					{
						studyAlreadyConducted[offset] = YES;
						_bibleStudies[offset]++;
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
		}
		if(!found && removeOld)
		{
			[calls removeObjectAtIndex:callIndex];
			[[Settings sharedInstance] saveData];
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
	
	_serviceYearBooks = 0;
	_serviceYearBrochures = 0;
	_serviceYearMinutes = 0;
	_serviceYearQuickBuildMinutes = 0;
	_serviceYearMagazines = 0;
	_serviceYearReturnVisits = 0;
	_serviceYearBibleStudies = 0;
	_serviceYearCampaignTracts = 0;
	
	NSMutableDictionary *userSettings = [[Settings sharedInstance] userSettings];
	
	BOOL newServiceYear = _thisMonth >= 9;
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
	
	[self countCalls:[userSettings objectForKey:SettingsCalls] removeOld:NO];
	[self countCalls:[userSettings objectForKey:SettingsDeletedCalls] removeOld:deleteOldEntries];
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
	_lastYear = _thisMonth == 1 ? _thisYear - 1 : _thisYear;
	
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
		int serviceYearCampaignTracts = _serviceYearCampaignTracts;
		
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
		_serviceYearCampaignTracts = serviceYearCampaignTracts;
		
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
			TitleValueCellController *cellController = [[TitleValueCellController alloc] initWithTitle:NSLocalizedString(@"Hours", @"'Hours' ButtonBar View text, Label for the amount of hours spend in the ministry, and Expanded name when on the More view")];
			int hours = _serviceYearMinutes / 60;
			int minutes = _serviceYearMinutes % 60;
			if(hours && minutes)
				cellController.value = [NSString stringWithFormat:NSLocalizedString(@"%d %@ %d %@", @"You are localizing the time (I dont know if you need to even change this) as in '1 hour 34 minutes' or '2 hours 1 minute' %1$d is the hours number %2$@ is the label for hour(s) %3$d is the minutes number and 4$%@ is the label for minutes(s)"), hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours"), minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")];
			else if(hours)
				cellController.value = [NSString stringWithFormat:@"%d %@", hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours")];
			else if(minutes)
				cellController.value = [NSString stringWithFormat:@"%d %@", minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")];
			else
				cellController.value = @"0";
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Books
		if(_serviceYearBooks)
		{
			TitleValueCellController *cellController = [[TitleValueCellController alloc] initWithTitle:NSLocalizedString(@"Books", @"Publication Type name") value:[NSString stringWithFormat:@"%d", _serviceYearBooks]];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		if(_serviceYearBrochures)
		// Brochures
		{
			TitleValueCellController *cellController = [[TitleValueCellController alloc] initWithTitle:NSLocalizedString(@"Brochures", @"Publication Type name") value:[NSString stringWithFormat:@"%d", _serviceYearBrochures]];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Magazines
		if(_serviceYearMagazines)
		{
			TitleValueCellController *cellController = [[TitleValueCellController alloc] initWithTitle:NSLocalizedString(@"Magazines", @"Publication Type name") value:[NSString stringWithFormat:@"%d", _serviceYearMagazines]];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Return Visits
		if(_serviceYearReturnVisits)
		{
			TitleValueCellController *cellController = [[TitleValueCellController alloc] initWithTitle:NSLocalizedString(@"Return Visits", @"Return Visits label on the Statistics View") value:[NSString stringWithFormat:@"%d", _serviceYearReturnVisits]];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Bible Studies
		if(_serviceYearBibleStudies)
		{
			TitleValueCellController *cellController = [[TitleValueCellController alloc] initWithTitle:NSLocalizedString(@"Bible Studies", @"Bible Studies label on the Statistics View") value:[NSString stringWithFormat:@"%d", _serviceYearBibleStudies]];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Campaign Tracts
		if(_serviceYearCampaignTracts)
		{
			TitleValueCellController *cellController = [[TitleValueCellController alloc] initWithTitle:NSLocalizedString(@"Campaign Tracts", @"Publication Type name") value:[NSString stringWithFormat:@"%d", _serviceYearCampaignTracts]];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// RBC Hours
		if(_serviceYearQuickBuildMinutes)
		{
			TitleValueCellController *cellController = [[TitleValueCellController alloc] initWithTitle:NSLocalizedString(@"RBC Hours", @"'RBC Hours' ButtonBar View text, Label for the amount of hours spent doing quick builds")];
			int hours = _serviceYearQuickBuildMinutes / 60;
			int minutes = _serviceYearQuickBuildMinutes % 60;
			if(hours && minutes)
				cellController.value = [NSString stringWithFormat:NSLocalizedString(@"%d %@ %d %@", @"You are localizing the time (I dont know if you need to even change this) as in '1 hour 34 minutes' or '2 hours 1 minute' %1$d is the hours number %2$@ is the label for hour(s) %3$d is the minutes number and 4$%@ is the label for minutes(s)"), hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours"), minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")];
			else if(hours)
				cellController.value = [NSString stringWithFormat:@"%d %@", hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours")];
			else if(minutes)
				cellController.value = [NSString stringWithFormat:@"%d %@", minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")];
			else
				cellController.value = @"0";
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
	}	

	// how many months do they want to show?
	int shownMonths = 2;
	NSNumber *value = [[[Settings sharedInstance] userSettings] objectForKey:SettingsMonthDisplayCount];
	if(value)
		shownMonths = [value intValue];
	
	for(int section = 0; section < 12; section++)
	{
		NSString *title;
		int month = _thisMonth - section;
		if(month < 1)
			month = 12 + month;
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
																									   section:section];
			cellController.displayIfZero = YES;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Books
		{
			StatisticsCellController *cellController = [[StatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Books", @"Publication Type name")
																								 array:_books
																							   section:section];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Brochures
		{
			StatisticsCellController *cellController = [[StatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Brochures", @"Publication Type name")
																								 array:_brochures
																							   section:section];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Magazines
		{
			StatisticsCellController *cellController = [[StatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Magazines", @"Publication Type name")
																								 array:_magazines
																							   section:section];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Return Visits
		{
			StatisticsCellController *cellController = [[StatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Return Visits", @"Return Visits label on the Statistics View")
																								 array:_returnVisits
																							   section:section];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Bible Studies
		{
			StatisticsCellController *cellController = [[StatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Bible Studies", @"Bible Studies label on the Statistics View")
																								 array:_bibleStudies
																							   section:section];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// Campaign Tracts
		{
			StatisticsCellController *cellController = [[StatisticsCellController alloc] initWithTitle:NSLocalizedString(@"Campaign Tracts", @"Publication Type name") 
																								 array:_campaignTracts
																							   section:section];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		// RBC Hours
		{
			HourStatisticsCellController *cellController = [[HourStatisticsCellController alloc] initWithTitle:NSLocalizedString(@"RBC Hours", @"'RBC Hours' ButtonBar View text, Label for the amount of hours spent doing quick builds")
																										 array:_quickBuildMinutes
																									   section:section];
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
	}
}


@end
