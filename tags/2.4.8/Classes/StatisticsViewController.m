//
//  StatisticsViewController.m
//  MyTime
//
//  Created by Brent Priddy on 7/26/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "StatisticsViewController.h"
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

@implementation StatisticsViewController

@synthesize theTableView;

- (id)init
{
	if ([super init]) 
	{
		theTableView = nil;
		
		// set the title, and tab bar images from the dataSource
		// object. 
		self.title = NSLocalizedString(@"Statistics", @"'Statistics' ButtonBar View text and Statistics View Title");
		self.tabBarItem.image = [UIImage imageNamed:@"statistics.png"];
		
		_serviceYearText = NSLocalizedString(@"Service Year Total", @"Service year total hours label");
	}
	return self;
}


- (void)dealloc 
{
	theTableView.delegate = nil;
	theTableView.dataSource = nil;
	[theTableView release];
	[super dealloc];
}

- (BOOL)showYearInformation
{
	NSString *type = [[[Settings sharedInstance] userSettings] objectForKey:SettingsPublisherType];
	return type == nil || 
	       [type isEqualToString:PublisherTypePioneer] ||
		   [type isEqualToString:PublisherTypeSpecialPioneer] ||
		   [type isEqualToString:PublisherTypeTravelingServant];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)sendEmailUsingMonthNames:(NSArray *)monthNames selectedMonths:(NSArray *)selectedMonths  
{
	// add notes if there are any
	int index;
	NSString *emailAddress = [[[Settings sharedInstance] settings] objectForKey:SettingsSecretaryEmailAddress];
	if(emailAddress == nil || emailAddress.length == 0)
		return;
	
	NSMutableString *string = [[[NSMutableString alloc] initWithFormat:@"mailto:%@?", emailAddress] autorelease];
	[string appendString:@"subject="];
	[string appendString:[NSLocalizedString(@"Field Service Activity Report", @"Subject text for the email that is sent for the Field Service Activity report") stringWithEscapedCharacters]];
	[string appendString:@"&body="];

	NSString *notes = [[[Settings sharedInstance] settings] objectForKey:SettingsSecretaryEmailNotes];
	if([notes length])
	{
		[string appendString:[notes stringWithEscapedCharacters]];
		[string appendString:[[NSString stringWithFormat:@"\n\n"] stringWithEscapedCharacters]];
	}
	
	for(index = 0; index < [selectedMonths count]; ++index)
	{
		if([[selectedMonths objectAtIndex:index] boolValue])
		{
			[string appendString:[[NSString stringWithFormat:NSLocalizedString(@"%@ Field Service Activity Report:\n", @"Text used in the email that is sent to the congregation secretary, the \\n you see in the text are RETURN KEYS so that you can space multiple months apart from eachother"), [monthNames objectAtIndex:index]] stringWithEscapedCharacters]];

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
			[string appendString:[[NSString stringWithFormat:@"%@: %@\n", NSLocalizedString(@"Hours", @"'Hours' ButtonBar View text, Label for the amount of hours spend in the ministry, and Expanded name when on the More view"), count] stringWithEscapedCharacters]];

			// BOOKS
			[string appendString:[[NSString stringWithFormat:@"%@: %d\n", NSLocalizedString(@"Books", @"Publication Type name"), _books[index]] stringWithEscapedCharacters]];
			// BROCHURES
			[string appendString:[[NSString stringWithFormat:@"%@: %d\n", NSLocalizedString(@"Brochures", @"Publication Type name"), _brochures[index]] stringWithEscapedCharacters]];
			// MAGAZINES
			[string appendString:[[NSString stringWithFormat:@"%@: %d\n", NSLocalizedString(@"Magazines", @"Publication Type name"), _magazines[index]] stringWithEscapedCharacters]];
			// RETURN VISITS
			[string appendString:[[NSString stringWithFormat:@"%@: %d\n", NSLocalizedString(@"Return Visits", @"Return Visits label on the Statistics View"), _returnVisits[index]] stringWithEscapedCharacters]];
			// STUDIES
			[string appendString:[[NSString stringWithFormat:@"%@: %d\n", NSLocalizedString(@"Bible Studies", @"Bible Studies label on the Statistics View"), _bibleStudies[index]] stringWithEscapedCharacters]];
			// CAMPAIGN TRACTS
			if(_campaignTracts[index])
				[string appendString:[[NSString stringWithFormat:@"%@: %d\n", NSLocalizedString(@"Campaign Tracts", @"Publication Type name"), _campaignTracts[index]] stringWithEscapedCharacters]];
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
				[string appendString:[[NSString stringWithFormat:@"%@: %@\n", NSLocalizedString(@"RBC Hours", @"'RBC Hours' ButtonBar View text, Label for the amount of hours spent doing quick builds"), count] stringWithEscapedCharacters]];
			}
			[string appendString:[[NSString stringWithFormat:@"\n\n"] stringWithEscapedCharacters]];
		}
	}
	NSURL *url = [NSURL URLWithString:string];
	[[UIApplication sharedApplication] openURL:url];

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

- (void)loadView 
{
	// create a new table using the full application frame
	// we'll ask the datasource which type of table to use (plain or grouped)
	UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] 
														  style:UITableViewStyleGrouped];
	
	// set the autoresizing mask so that the table will always fill the view
	tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	
	// set the tableview delegate to this object and the datasource to the datasource which has already been set
	tableView.delegate = self;
	tableView.dataSource = self;
	
	// set the tableview as the controller view
    self.theTableView = tableView;
	self.view = tableView;

	// add + button
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																			 target:self
																			 action:@selector(navigationControlEmail:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:NO];


	[self reloadData];

	[tableView release];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	// force the tableview to load
	[self reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
	[theTableView flashScrollIndicators];

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
			BOOL foundBibleDVD = NO;
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
					
					bool counted = NO;
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
							counted = YES;
						}
					}
					else if(isStudy)
					{
						// go ahead and count studies as return visits
						if(!counted)
						{
							_returnVisits[offset]++;
							if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
							   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
							{
								_serviceYearReturnVisits++;
							}
							counted = YES;
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
								if([type isEqualToString:PublicationTypeBook])
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
								else if([type isEqualToString:PublicationTypeBrochure])
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
								else if([type isEqualToString:PublicationTypeDVDBible])
								{
									if(!foundBibleDVD)
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
										foundBibleDVD = TRUE;
									}
								}
								else if([type isEqualToString:PublicationTypeDVDBook])
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

- (void)computeStatistics
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
					if([type isEqualToString:PublicationTypeBook])
					{
						_books[offset] += number;
						if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
							(!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
						{
							_serviceYearBooks += number;
						}
					}
					else if([type isEqualToString:PublicationTypeBrochure])
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
					else if([type isEqualToString:PublicationTypeDVDBible])
					{
						_books[offset] += number;
						if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
						   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
						{
							_serviceYearBooks += number;
						}
					}
					else if([type isEqualToString:PublicationTypeDVDBook])
					{
						_books[offset] += number;
						if( (newServiceYear && offset <= (_thisMonth - 9)) || // newServiceYear means that the months that are added are above the current month
						   (!newServiceYear && _thisMonth + 4 > offset)) // !newServiceYear means that we are in months before September, just add them if their offset puts them after september
						{
							_serviceYearBooks += number;
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
	[self countCalls:[userSettings objectForKey:SettingsDeletedCalls] removeOld:YES];
}

- (void)reloadData
{
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
		[self computeStatistics];
		
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
		[self computeStatistics];
		
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
		[self computeStatistics];
	}
	[theTableView reloadData];
}




// UITableViewDataSource methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  
{
	int count = 0;
	if([self showYearInformation])
		count++;
	
	NSNumber *value = [[[Settings sharedInstance] userSettings] objectForKey:SettingsMonthDisplayCount];
	if(value)
		count += [value intValue];
	else
		count += 2; // default to see 2 months

	return count;
}


- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section 
{
	// the service year is the first section
	if([self showYearInformation])
	{
		if(section == 0)
		{
			int count = 0;
			count++; // always show hours
			if(_serviceYearBooks)
				count++;
			if(_serviceYearBrochures)
				count++;
			if(_serviceYearMagazines)
				count++;
			if(_serviceYearReturnVisits)
				count++;
			if(_serviceYearBibleStudies)
				count++;
			if(_serviceYearCampaignTracts)
				count++;
			if(_serviceYearQuickBuildMinutes)
				count++;
			
			return count;
		}
		section--;
	}
	
	int count = 0;
	count++; // always show hours
	if(_books[section])
		count++;
	if(_brochures[section])
		count++;
	if(_magazines[section])
		count++;
	if(_returnVisits[section])
		count++;
	if(_bibleStudies[section])
		count++;
	if(_campaignTracts[section])
		count++;
	if(_quickBuildMinutes[section])
		count++;

	return(count);
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    VERBOSE(NSLog(@"tableView: titleForHeaderInSection:%d", section);)
	
	if([self showYearInformation])
	{
		if(section == 0)
		{
			return _serviceYearText;
		}
		section--;
	}
	NSString *title = @"";
	int month = _thisMonth - section;
	if(month < 1)
		month = 12 + month;
	title = [NSString stringWithFormat:NSLocalizedString(@"Time for %@", @"Time for %@ Group title on the Statistics View where %@ is the month of the year"), 
														 [[PSLocalization localizationBundle] localizedStringForKey:MONTHS[month - 1] value:MONTHS[month - 1] table:@""]];
    return(title);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int row = [indexPath row];
	int section = [indexPath section];
    VERBOSE(NSLog(@"tableView: cellForRow:%d inSection:%d", row, section);)

	if([self showYearInformation])
	{
		if(section == 0)
			return;

		section--;
	}

	if(row-- == 0)
	{
		// if we are not editing, then 
		int hours = _minutes[section] / 60;
		int minutes = _minutes[section] % 60;
		
		if(minutes)
		{
			_selectedMonth = section;
			_emailActionSheet = NO;
			int month = _thisMonth - section;
			if(month < 1)
				month = 12 + month;
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
		[theTableView deselectRowAtIndexPath:[theTableView indexPathForSelectedRow] animated:YES];
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
				[self reloadData];
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
				
				
				[self reloadData];
				break;
			}
		}
	}
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
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	else
	{
		[cell setValue:@""];
		[cell setTitle:@""];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}

	if([self showYearInformation])
	{
		if(section == 0)
		{
			if(row-- == 0)
			{
				[cell setTitle:NSLocalizedString(@"Hours", @"'Hours' ButtonBar View text, Label for the amount of hours spend in the ministry, and Expanded name when on the More view")];
				int hours = _serviceYearMinutes / 60;
				int minutes = _serviceYearMinutes % 60;
				if(hours && minutes)
					[cell setValue:[NSString stringWithFormat:NSLocalizedString(@"%d %@ %d %@", @"You are localizing the time (I dont know if you need to even change this) as in '1 hour 34 minutes' or '2 hours 1 minute' %1$d is the hours number %2$@ is the label for hour(s) %3$d is the minutes number and 4$%@ is the label for minutes(s)"), hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours"), minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")]];
				else if(hours)
					[cell setValue:[NSString stringWithFormat:@"%d %@", hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours")]];
				else if(minutes)
					[cell setValue:[NSString stringWithFormat:@"%d %@", minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")]];
				else
					[cell setValue:@"0"];
			}
			else if(_serviceYearBooks && row-- == 0)
			{
				// if we are not editing, then 
				[cell setTitle:NSLocalizedString(@"Books", @"Publication Type name")];
				[cell setValue:[NSString stringWithFormat:@"%d", _serviceYearBooks]];
			}
			else if(_serviceYearBrochures && row-- == 0)
			{
				// if we are not editing, then 
				[cell setTitle:NSLocalizedString(@"Brochures", @"Publication Type name")];
				[cell setValue:[NSString stringWithFormat:@"%d", _serviceYearBrochures]];
			}
			else if(_serviceYearMagazines && row-- == 0)
			{
				// if we are not editing, then 
				[cell setTitle:NSLocalizedString(@"Magazines", @"Publication Type name")];
				[cell setValue:[NSString stringWithFormat:@"%d", _serviceYearMagazines]];
			}
			else if(_serviceYearReturnVisits && row-- == 0)
			{
				// if we are not editing, then 
				[cell setTitle:NSLocalizedString(@"Return Visits", @"Return Visits label on the Statistics View")];
				[cell setValue:[NSString stringWithFormat:@"%d", _serviceYearReturnVisits]];
			}
			else if(_serviceYearBibleStudies && row-- == 0)
			{
				// if we are not editing, then 
				[cell setTitle:NSLocalizedString(@"Bible Studies", @"Bible Studies label on the Statistics View")];
				[cell setValue:[NSString stringWithFormat:@"%d", _serviceYearBibleStudies]];
			}
			else if(_serviceYearCampaignTracts && row-- == 0)
			{
				// if we are not editing, then 
				[cell setTitle:NSLocalizedString(@"Campaign Tracts", @"Publication Type name")];
				[cell setValue:[NSString stringWithFormat:@"%d", _serviceYearCampaignTracts]];
			}
			else if(_serviceYearQuickBuildMinutes && row-- == 0)
			{
				// if we are not editing, then 
				[cell setTitle:NSLocalizedString(@"RBC Hours", @"'RBC Hours' ButtonBar View text, Label for the amount of hours spent doing quick builds")];
				int hours = _serviceYearQuickBuildMinutes / 60;
				int minutes = _serviceYearQuickBuildMinutes % 60;
				if(hours && minutes)
					[cell setValue:[NSString stringWithFormat:NSLocalizedString(@"%d %@ %d %@", @"You are localizing the time (I dont know if you need to even change this) as in '1 hour 34 minutes' or '2 hours 1 minute' %1$d is the hours number %2$@ is the label for hour(s) %3$d is the minutes number and 4$%@ is the label for minutes(s)"), hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours"), minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")]];
				else if(hours)
					[cell setValue:[NSString stringWithFormat:@"%d %@", hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours")]];
				else if(minutes)
					[cell setValue:[NSString stringWithFormat:@"%d %@", minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")]];
				else
					[cell setValue:@"0"];
			}				
			else
			{
				return nil;
			}
			
			return cell;
		}
		
		section--;
	}

	if(row-- == 0)
	{
		// if we are not editing, then 
		
		[cell setTitle:NSLocalizedString(@"Hours", @"'Hours' ButtonBar View text, Label for the amount of hours spend in the ministry, and Expanded name when on the More view")];
		int hours = _minutes[section] / 60;
		int minutes = _minutes[section] % 60;
		if(hours && minutes)
			[cell setValue:[NSString stringWithFormat:NSLocalizedString(@"%d %@ %d %@", @"You are localizing the time (I dont know if you need to even change this) as in '1 hour 34 minutes' or '2 hours 1 minute' %1$d is the hours number %2$@ is the label for hour(s) %3$d is the minutes number and 4$%@ is the label for minutes(s)"), hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours"), minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")]];
		else if(hours)
			[cell setValue:[NSString stringWithFormat:@"%d %@", hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours")]];
		else if(minutes)
			[cell setValue:[NSString stringWithFormat:@"%d %@", minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")]];
		else
			[cell setValue:@"0"];
			
		if(minutes)
		{
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	}
	else if(_books[section] && row-- == 0)
	{
		// if we are not editing, then 
		[cell setTitle:NSLocalizedString(@"Books", @"Publication Type name")];
		[cell setValue:[NSString stringWithFormat:@"%d", _books[section]]];
	}
	else if(_brochures[section] && row-- == 0)
	{
		// if we are not editing, then 
		[cell setTitle:NSLocalizedString(@"Brochures", @"Publication Type name")];
		[cell setValue:[NSString stringWithFormat:@"%d", _brochures[section]]];
	}
	else if(_magazines[section] && row-- == 0)
	{
		// if we are not editing, then 
		[cell setTitle:NSLocalizedString(@"Magazines", @"Publication Type name")];
		[cell setValue:[NSString stringWithFormat:@"%d", _magazines[section]]];
	}
	else if(_returnVisits[section] && row-- == 0)
	{
		// if we are not editing, then 
		[cell setTitle:NSLocalizedString(@"Return Visits", @"Return Visits label on the Statistics View")];
		[cell setValue:[NSString stringWithFormat:@"%d", _returnVisits[section]]];
	}
	else if(_bibleStudies[section] && row-- == 0)
	{
		// if we are not editing, then 
		[cell setTitle:NSLocalizedString(@"Bible Studies", @"Bible Studies label on the Statistics View")];
		[cell setValue:[NSString stringWithFormat:@"%d", _bibleStudies[section]]];
	}
	else if(_campaignTracts[section] && row-- == 0)
	{
		// if we are not editing, then 
		[cell setTitle:NSLocalizedString(@"Campaign Tracts", @"Publication Type name")];
		[cell setValue:[NSString stringWithFormat:@"%d", _campaignTracts[section]]];
	}
	else if(_quickBuildMinutes[section] && row-- == 0)
	{
		// if we are not editing, then 
		[cell setTitle:NSLocalizedString(@"RBC Hours", @"'RBC Hours' ButtonBar View text, Label for the amount of hours spent doing quick builds")];
		int hours = _quickBuildMinutes[section] / 60;
		int minutes = _quickBuildMinutes[section] % 60;
		if(hours && minutes)
			[cell setValue:[NSString stringWithFormat:NSLocalizedString(@"%d %@ %d %@", @"You are localizing the time (I dont know if you need to even change this) as in '1 hour 34 minutes' or '2 hours 1 minute' %1$d is the hours number %2$@ is the label for hour(s) %3$d is the minutes number and 4$%@ is the label for minutes(s)"), hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours"), minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")]];
		else if(hours)
			[cell setValue:[NSString stringWithFormat:@"%d %@", hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours")]];
		else if(minutes)
			[cell setValue:[NSString stringWithFormat:@"%d %@", minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")]];
		else
			[cell setValue:@"0"];
	}
	
	return cell;
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