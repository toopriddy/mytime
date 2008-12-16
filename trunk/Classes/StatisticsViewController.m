//
//  StatisticsViewController.m
//  MyTime
//
//  Created by Brent Priddy on 7/26/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import "StatisticsViewController.h"
#import "Settings.h"
#import "UITableViewTitleAndValueCell.h"



static NSString *MONTHS[] = {
	AlternateLocalizedString(@"January", @"Long month name"),
	AlternateLocalizedString(@"February", @"Long month name"),
	AlternateLocalizedString(@"March", @"Long month name"),
	AlternateLocalizedString(@"April", @"Long month name"),
	AlternateLocalizedString(@"May", @"Short/Long month name"),
	AlternateLocalizedString(@"June", @"Long month name"),
	AlternateLocalizedString(@"July", @"Long month name"),
	AlternateLocalizedString(@"August", @"Long month name"),
	AlternateLocalizedString(@"September", @"Long month name"),
	AlternateLocalizedString(@"October", @"Long month name"),
	AlternateLocalizedString(@"November", @"Long month name"),
	AlternateLocalizedString(@"December", @"Long month name")
};

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return(NO);
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
	[string appendString:[NSLocalizedString(@"Field Service Activity Report", @"Subject text for the email that is sent for the Field Service Activity report") stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	[string appendString:@"&body="];

	NSString *notes = [[[Settings sharedInstance] settings] objectForKey:SettingsSecretaryEmailNotes];
	if([notes length])
	{
		[string appendString:[notes stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		[string appendString:[@"\n\n" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	}
	
	for(index = 0; index < [selectedMonths count]; ++index)
	{
		if([[selectedMonths objectAtIndex:index] boolValue])
		{
			[string appendString:[[NSString stringWithFormat:NSLocalizedString(@"%@ Field Service Activity Report:\n", @"Text used in the email that is sent to the congregation secretary, the \\n you see in the text are RETURN KEYS so that you can space multiple months apart from eachother"), [monthNames objectAtIndex:index]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

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
			[string appendString:[[NSString stringWithFormat:@"%@: %@\n", NSLocalizedString(@"Hours", @"'Hours' ButtonBar View text, Label for the amount of hours spend in the ministry, and Expanded name when on the More view"), count] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

			// BOOKS
			[string appendString:[[NSString stringWithFormat:@"%@: %d\n", NSLocalizedString(@"Books", @"Publication Type name"), _books[index]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			// BROCHURES
			[string appendString:[[NSString stringWithFormat:@"%@: %d\n", NSLocalizedString(@"Brochures", @"Publication Type name"), _brochures[index]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			// MAGAZINES
			[string appendString:[[NSString stringWithFormat:@"%@: %d\n", NSLocalizedString(@"Magazines", @"Publication Type name"), _magazines[index]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			// RETURN VISITS
			[string appendString:[[NSString stringWithFormat:@"%@: %d\n", NSLocalizedString(@"Return Visits", @"Return Visits label on the Statistics View"), _returnVisits[index]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			// STUDIES
			[string appendString:[[NSString stringWithFormat:@"%@: %d\n", NSLocalizedString(@"Bible Studies", @"Bible Studies label on the Statistics View"), _bibleStudies[index]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			// CAMPAIGN TRACTS
			if(_campaignTracts[index])
				[string appendString:[[NSString stringWithFormat:@"%@: %d\n", NSLocalizedString(@"Campaign Tracts", @"Publication Type name"), _campaignTracts[index]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
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
				[string appendString:[[NSString stringWithFormat:@"%@: %@\n", NSLocalizedString(@"Quick Build Hours", @"'Quick Build Hours' ButtonBar View text, Label for the amount of hours spent doing quick builds"), count] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			}
			[string appendString:[@"\n\n" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
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
		[months addObject:[[NSBundle mainBundle] localizedStringForKey:MONTHS[month - 1] value:MONTHS[month - 1] table:@""]];
		
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
	// force the tableview to load
	[self reloadData];
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

- (void)countCalls:(NSMutableArray *)calls removeOld:(BOOL)removeOld
{
	BOOL found;
	int callIndex;

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
					else if(month != 12 && 
							year == _thisYear - 1 &&
							_thisMonth > month)
					{
						offset = 12 - _thisMonth + month;
					}
					
					// this month's information should not be counted
					if(offset < 0)
						continue;
						
					NSString *type = [visit objectForKey:CallReturnVisitType];
					BOOL isStudy = [type isEqualToString:(NSString *)CallReturnVisitTypeStudy];
					BOOL isNotAtHome = [type isEqualToString:(NSString *)CallReturnVisitTypeNotAtHome];
					
					bool counted = NO;
					if(returnVisitsCount > 1 && i != returnVisitsCount)
					{
						// if this is not the first visit and
						// if there are more than 1 visit then that means that any return visits
						// this month are counted as return visits
						if(!isNotAtHome)
						{
							_returnVisits[offset]++;
							counted = YES;
						}
					}
					else if(isStudy)
					{
						// go ahead and count studies as return visits
						if(!counted)
						{
							_returnVisits[offset]++;
							counted = YES;
						}
					}

					found = YES;

					if(!studyAlreadyConducted[offset] && 
					   isStudy)
					{
						studyAlreadyConducted[offset] = YES;
						_bibleStudies[offset]++;
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
									_books[offset]++;
								}
								else if([type isEqualToString:PublicationTypeBrochure])
								{
									_brochures[offset]++;
								}
								else if([type isEqualToString:PublicationTypeMagazine])
								{
									_magazines[offset]++;
								}
								else if([type isEqualToString:PublicationTypeDVDBible])
								{
									if(!foundBibleDVD)
									{
										_books[offset]++;
										foundBibleDVD = TRUE;
									}
								}
								else if([type isEqualToString:PublicationTypeDVDBook])
								{
									_books[offset]++;
								}
								else if([type isEqualToString:PublicationTypeCampaignTract])
								{
									_campaignTracts[offset]++;
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

- (void)reloadData
{
	NSMutableDictionary *settings = [[Settings sharedInstance] settings];
	
	memset(_books, 0, sizeof(_books));
	memset(_brochures, 0, sizeof(_brochures));
	memset(_minutes, 0, sizeof(_minutes));
	memset(_magazines, 0, sizeof(_magazines));
	memset(_returnVisits, 0, sizeof(_returnVisits));
	memset(_bibleStudies, 0, sizeof(_bibleStudies));
	memset(_campaignTracts, 0, sizeof(_campaignTracts));
	memset(_quickBuildMinutes, 0, sizeof(_quickBuildMinutes));

	_serviceYearMinutes = 0;
	_serviceYearQuickBuildMinutes = 0;

	// save off this month and last month for quick compares
	NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit) fromDate:[NSDate date]];
	_thisMonth = [dateComponents month];
	_thisYear = [dateComponents year];

	_lastMonth = _thisMonth == 1 ? 12 : _thisMonth - 1;
	_lastYear = _thisMonth == 1 ? _thisYear - 1 : _thisYear;

	BOOL newServiceYear = _thisMonth >= 9;
	NSArray *timeEntries = [settings objectForKey:SettingsTimeEntries];
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
				offset = 12 + _thisMonth - month;
			}
			if(offset >= 0)
			{
				// we found a valid month
				_minutes[offset] += [minutes intValue];

				if(newServiceYear && offset <= (_thisMonth - 9))
				{
					_serviceYearMinutes += [minutes intValue];
				}
				else if(!newServiceYear && offset <= 12 - (_thisMonth - 9))
				{
					_serviceYearMinutes += [minutes intValue];
				}
			}
		}
	}

	// QUICK BUILD
	
	timeEntries = [settings objectForKey:SettingsQuickBuildTimeEntries];
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
			else if(month != 12 && 
			        year == _thisYear - 1 &&
			        _thisMonth > month)
			{
				offset = 12 - _thisMonth + month;
			}
			if(offset >= 0)
			{
				_quickBuildMinutes[offset] += [minutes intValue];
			}

			if(newServiceYear && offset <= (_thisMonth - 9))
			{
				_serviceYearQuickBuildMinutes += [minutes intValue];
			}
			else if(!newServiceYear && offset <= 12 - (_thisMonth - 9))
			{
				_serviceYearQuickBuildMinutes += [minutes intValue];
			}
		}
	}


	// go through all of the bulk publications
	NSArray *bulkArray = [settings objectForKey:SettingsBulkLiterature];
	NSEnumerator *bulkArrayEnumerator = [bulkArray objectEnumerator];
	NSDictionary *entry;
	
	while( (entry = [bulkArrayEnumerator nextObject]) ) // ASSIGNMENT, NOT COMPARISON 
	{
		NSDate *date = [entry objectForKey:BulkLiteratureDate];
		BOOL foundThisMonth = NO;
		BOOL foundLastMonth = NO;
		int offset = -1;
			
		if(date != nil)
		{
			NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit) fromDate:date];
			int month = [dateComponents month];
			int year = [dateComponents year];
			// if this is not the first visit and
			// if there are more than 1 visit then that means that any return visits
			// this month are counted as return visits
			if(month == _thisMonth && year == _thisYear)
				foundThisMonth = YES;
			else if(month == _lastMonth && year == _thisYear)
				foundLastMonth = YES;

			if(year == _thisYear && 
			   month <= _thisMonth)
			{
				offset = _thisMonth - month;
			}
			else if(month != 12 && 
			        year == _thisYear - 1 &&
			        _thisMonth > month)
			{
				offset = 12 - _thisMonth + month;
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
					}
					else if([type isEqualToString:PublicationTypeBrochure])
					{
						_brochures[offset] += number;
					}
					else if([type isEqualToString:PublicationTypeMagazine])
					{
						_magazines[offset] += number;
					}
					else if([type isEqualToString:PublicationTypeDVDBible])
					{
						_books[offset] += number;
					}
					else if([type isEqualToString:PublicationTypeDVDBook])
					{
						_books[offset] += number;
					}
					else if([type isEqualToString:PublicationTypeCampaignTract])
					{
						_campaignTracts[offset] += number;
					}
				}
				
			}
		}
	}

	[self countCalls:[settings objectForKey:SettingsCalls] removeOld:NO];
	[self countCalls:[settings objectForKey:SettingsDeletedCalls] removeOld:YES];
	[theTableView reloadData];
}




// UITableViewDataSource methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  
{
	int count = 1;
	
	NSNumber *value = [[[Settings sharedInstance] settings] objectForKey:SettingsMonthDisplayCount];
	if(value)
		count += [value intValue];
	else
		count += 2; // default to see 2 months

	return count;
}


- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section 
{
	// the service year is the first section
	if(section == 0)
	{
		return(_serviceYearQuickBuildMinutes ? 2 : 1);
	}

	int index = section - 1;
	int count = 0;
	count++; // always show hours
	if(_books[index])
		count++;
	if(_brochures[index])
		count++;
	if(_magazines[index])
		count++;
	if(_returnVisits[index])
		count++;
	if(_bibleStudies[index])
		count++;
	if(_campaignTracts[index])
		count++;
	if(_quickBuildMinutes[index])
		count++;

	return(count);
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    VERBOSE(NSLog(@"tableView: titleForHeaderInSection:%d", section);)
	
	if(section == 0)
	{
		return (NSLocalizedString(@"Service Year Total", @"Service year total hours label"));
	}
	NSString *title = @"";
	int month = _thisMonth - (section - 1);
	if(month < 1)
		month = 12 + month;
	title = [NSString stringWithFormat:NSLocalizedString(@"Time for %@", @"Time for %@ Group title on the Statistics View where %@ is the month of the year"), 
														 [[NSBundle mainBundle] localizedStringForKey:MONTHS[month - 1] value:MONTHS[month - 1] table:@""]];
    return(title);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int row = [indexPath row];
	int section = [indexPath section];
    VERBOSE(NSLog(@"tableView: cellForRow:%d inSection:%d", row, section);)

	if(section == 0)
		return;

	int index = section - 1;

	if(row-- == 0)
	{
		// if we are not editing, then 
		int hours = _minutes[index] / 60;
		int minutes = _minutes[index] % 60;
		
		if(minutes)
		{
			_selectedMonth = index;
			_emailActionSheet = NO;
			int month = _thisMonth - index;
			if(month < 1)
				month = 12 + month;
			NSString *monthName = [[NSBundle mainBundle] localizedStringForKey:MONTHS[month - 1] value:MONTHS[month - 1] table:@""];

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
				[months addObject:[[NSBundle mainBundle] localizedStringForKey:MONTHS[month - 1] value:MONTHS[month - 1] table:@""]];
				
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
				[months addObject:[[NSBundle mainBundle] localizedStringForKey:MONTHS[month - 1] value:MONTHS[month - 1] table:@""]];
				
				--month;
			}

			// use the current month unless it is over the 6th day of the month
			NSString *monthGuess = [months objectAtIndex:0];
			NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit) fromDate:[NSDate date]];

			if([dateComponents day] <= 6)
			{
				monthGuess = [months objectAtIndex:1];
			}	
			
			[self sendEmailUsingMonthNames:[NSArray arrayWithObject:monthGuess] selectedMonths:[NSArray arrayWithObject:[NSNumber numberWithBool:YES]]];
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
				[[[[Settings sharedInstance] settings] objectForKey:SettingsTimeEntries] addObject:timeEntry];
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
				NSMutableArray *timeEntries = [NSMutableArray arrayWithArray:[[[Settings sharedInstance] settings] objectForKey:SettingsTimeEntries]];
				[[[Settings sharedInstance] settings] setObject:timeEntries forKey:SettingsTimeEntries];

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

	if(section == 0)
	{
		switch(row)
		{
			case 0:
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

				return cell;
			}
			case 1:
			{
				[cell setTitle:NSLocalizedString(@"Quick Build Hours", @"'Quick Build Hours' ButtonBar View text, Label for the amount of hours spent doing quick builds")];
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

				return cell;
			}
		}
		return nil;
	}

	int index = section - 1;


	if(row-- == 0)
	{
		// if we are not editing, then 
		
		[cell setTitle:NSLocalizedString(@"Hours", @"'Hours' ButtonBar View text, Label for the amount of hours spend in the ministry, and Expanded name when on the More view")];
		int hours = _minutes[index] / 60;
		int minutes = _minutes[index] % 60;
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
	else if(_books[index] && row-- == 0)
	{
		// if we are not editing, then 
		[cell setTitle:NSLocalizedString(@"Books", @"Publication Type name")];
		[cell setValue:[NSString stringWithFormat:@"%d", _books[index]]];
	}
	else if(_brochures[index] && row-- == 0)
	{
		// if we are not editing, then 
		[cell setTitle:NSLocalizedString(@"Brochures", @"Publication Type name")];
		[cell setValue:[NSString stringWithFormat:@"%d", _brochures[index]]];
	}
	else if(_magazines[index] && row-- == 0)
	{
		// if we are not editing, then 
		[cell setTitle:NSLocalizedString(@"Magazines", @"Publication Type name")];
		[cell setValue:[NSString stringWithFormat:@"%d", _magazines[index]]];
	}
	else if(_returnVisits[index] && row-- == 0)
	{
		// if we are not editing, then 
		[cell setTitle:NSLocalizedString(@"Return Visits", @"Return Visits label on the Statistics View")];
		[cell setValue:[NSString stringWithFormat:@"%d", _returnVisits[index]]];
	}
	else if(_bibleStudies[index] && row-- == 0)
	{
		// if we are not editing, then 
		[cell setTitle:NSLocalizedString(@"Bible Studies", @"Bible Studies label on the Statistics View")];
		[cell setValue:[NSString stringWithFormat:@"%d", _bibleStudies[index]]];
	}
	else if(_campaignTracts[index] && row-- == 0)
	{
		// if we are not editing, then 
		[cell setTitle:NSLocalizedString(@"Campaign Tracts", @"Publication Type name")];
		[cell setValue:[NSString stringWithFormat:@"%d", _campaignTracts[index]]];
	}
	else if(_quickBuildMinutes[index] && row-- == 0)
	{
		// if we are not editing, then 
		[cell setTitle:NSLocalizedString(@"Quick Build Hours", @"'Quick Build Hours' ButtonBar View text, Label for the amount of hours spent doing quick builds")];
		int hours = _quickBuildMinutes[index] / 60;
		int minutes = _quickBuildMinutes[index] % 60;
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