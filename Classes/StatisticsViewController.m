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

#define AlternateLocalizedString(a, b) (a)

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
					
					if(returnVisitsCount > 1 && i != returnVisitsCount)
					{
						// if this is not the first visit and
						// if there are more than 1 visit then that means that any return visits
						// this month are counted as return visits
						if(!isNotAtHome)
							_returnVisits[offset]++;
						
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
								else if([type isEqualToString:PublicationTypeSpecial])
								{
									_specialPublications[offset]++;
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
	memset(_specialPublications, 0, sizeof(_specialPublications));
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
				_minutes[offset] += [minutes intValue];
			}

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
					else if([type isEqualToString:PublicationTypeSpecial])
					{
						_specialPublications[offset] += number;
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
	
	// if they do quick builds, then see the total time
	if(_serviceYearQuickBuildMinutes)
		count++;

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
		return(1);

	if(_serviceYearQuickBuildMinutes && --section == 0)
		return(1);

	int index = section - 1;
	int count = 0;
	count++; // always show hours
	if(_books[index])
		count++;
	if(_brochures[index])
		count++;
	if(_magazines[index])
		count++;
	if(_specialPublications[index])
		count++;
	if(_returnVisits[index])
		count++;
	if(_bibleStudies[index])
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
	if(_serviceYearQuickBuildMinutes && --section == 0)
	{
		return (NSLocalizedString(@"Service Year Quick Build Total", @"Service year total quick build hours label"));
	}
	NSString *title = @"";
	int month = _thisMonth - (section - 1);
	if(month < 1)
		month = 12 + month;
	title = [NSString stringWithFormat:NSLocalizedString(@"Time for %@", @"Time for %@ Group title on the Statistics View where %@ is the month of the year"), 
														 [[NSBundle mainBundle] localizedStringForKey:MONTHS[month - 1] value:MONTHS[month - 1] table:@""]];
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
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	else
	{
		[cell setValue:@""];
		[cell setTitle:@""];
	}

	if(section == 0)
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

	if(_serviceYearQuickBuildMinutes && --section == 0)
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
	else if(_specialPublications[index] && row-- == 0)
	{
		// if we are not editing, then 
		[cell setTitle:NSLocalizedString(@"Campaign Tracts", @"Publication Type name")];
		[cell setValue:[NSString stringWithFormat:@"%d", _specialPublications[index]]];
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