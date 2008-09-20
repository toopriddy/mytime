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
		alertSheet.title = NSLocalizedString(@"You can see your end of the month field service activity like books, brochures, magazines, return visits and hours, but you will only see what you actually did.", @"This is a note displayed when they first see the Statistics View");
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
			
			int i;
			int returnVisitsCount = [returnVisits count];
			for(i = returnVisitsCount; i > 0; --i)
			{
				visit = [returnVisits objectAtIndex:i-1];
				NSDate *date = [visit objectForKey:CallReturnVisitDate];
				BOOL foundBibleDVD = NO;
				
				if(date != nil)
				{
					date = [[[NSDate alloc] initWithTimeIntervalSinceReferenceDate:[date timeIntervalSinceReferenceDate]] autorelease];	
					NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit) fromDate:date];
					int month = [dateComponents month];
					int year = [dateComponents year];
					if(returnVisitsCount > 1 && i != returnVisitsCount)
					{
						// if this is not the first visit and
						// if there are more than 1 visit then that means that any return visits
						// this month are counted as return visits
						if(month == _thisMonth && year == _thisYear)
						{
							_thisMonthReturnVisits++;
							found = YES;
						}
						else if(month == _lastMonth && year == _thisYear)
						{
							_lastMonthReturnVisits++;
							found = YES;
						}
					}

					// we only care about counting this month's or last month's returnVisits' calls
					if((month == _thisMonth && year == _thisYear) || 
					   (month == _lastMonth && year == _lastYear))
					{
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
										if(month == _thisMonth && year == _thisYear)
										{
											_thisMonthBooks++;
											found = YES;
										}
										else if(month == _lastMonth && year == _thisYear)
										{
											_lastMonthBooks++;
											found = YES;
										}
									}
									else if([type isEqualToString:PublicationTypeBrochure])
									{
										if(month == _thisMonth && year == _thisYear)
										{
											_thisMonthBrochures++;
											found = YES;
										}
										else if(month == _lastMonth && year == _thisYear)
										{
											_lastMonthBrochures++;
											found = YES;
										}
									}
									else if([type isEqualToString:PublicationTypeMagazine])
									{
										if(month == _thisMonth && year == _thisYear)
										{
											_thisMonthMagazines++;
											found = YES;
										}
										else if(month == _lastMonth && year == _thisYear)
										{
											_lastMonthMagazines++;
											found = YES;
										}
									}
									else if([type isEqualToString:PublicationTypeDVDBible])
									{
										if(!foundBibleDVD)
										{
											foundBibleDVD = TRUE;
											if(month == _thisMonth && year == _thisYear)
											{
												_thisMonthBooks++;
												found = YES;
											}
											else if(month == _lastMonth && year == _thisYear)
											{
												_lastMonthBooks++;
												found = YES;
											}
										}
									}
									else if([type isEqualToString:PublicationTypeDVDBook])
									{
										if(month == _thisMonth && year == _thisYear)
										{
											_thisMonthBooks++;
											found = YES;
										}
										else if(month == _lastMonth && year == _thisYear)
										{
											_lastMonthBooks++;
											found = YES;
										}
									}
									else if([type isEqualToString:PublicationTypeSpecial])
									{
										if(month == _thisMonth && year == _thisYear)
										{
											_thisMonthSpecialPublications++;
											found = YES;
										}
										else if(month == _lastMonth && year == _thisYear)
										{
											_lastMonthSpecialPublications++;
											found = YES;
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

- (void)reloadData
{
	NSMutableDictionary *settings = [[Settings sharedInstance] settings];
	_thisMonthBooks = 0;
	_thisMonthBrochures = 0;
	_thisMonthMinutes = 0;
	_thisMonthMagazines = 0;
	_thisMonthReturnVisits = 0;
	_thisMonthBibleStudies = 0;
	_thisMonthSpecialPublications = 0;
	
	_lastMonthBooks = 0;
	_lastMonthBrochures = 0;
	_lastMonthMinutes = 0;
	_lastMonthMagazines = 0;
	_lastMonthReturnVisits = 0;
	_lastMonthBibleStudies = 0;
	_lastMonthSpecialPublications = 0;
	
	
	// save off this month and last month for quick compares
	NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit) fromDate:[NSDate date]];
	_thisMonth = [dateComponents month];
	_thisYear = [dateComponents year];
	
	
	_lastMonth = _thisMonth == 1 ? 12 : _thisMonth - 1;
	_lastYear = _thisMonth == 1 ? _thisYear - 1 : _thisYear;


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

			if(month == _thisMonth && year == _thisYear)
			{
				_thisMonthMinutes += [minutes intValue];
			}
			else if(month == _lastMonth && year == _lastYear)
			{
				_lastMonthMinutes += [minutes intValue];
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
		}
		
		if(foundThisMonth || foundLastMonth)
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
						if(foundThisMonth)
							_thisMonthBooks += number;
						else if(foundLastMonth)
							_lastMonthBooks += number;
					}
					else if([type isEqualToString:PublicationTypeBrochure])
					{
						if(foundThisMonth)
							_thisMonthBrochures += number;
						else if(foundLastMonth)
							_lastMonthBrochures += number;
					}
					else if([type isEqualToString:PublicationTypeMagazine])
					{
						if(foundThisMonth)
							_thisMonthMagazines += number;
						else if(foundLastMonth)
							_lastMonthMagazines += number;
					}
					else if([type isEqualToString:PublicationTypeSpecial])
					{
						if(foundThisMonth)
							_thisMonthSpecialPublications += number;
						else if(foundLastMonth)
							_lastMonthSpecialPublications += number;
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
	// this month and last month
	return 2;
}


- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section 
{
	int count = 0;
    switch (section)
    { 
        // ThisMonth
        case 0:
			count++; // always show hours
			if(_thisMonthBooks)
				count++;
			if(_thisMonthBrochures)
				count++;
			if(_thisMonthMagazines)
				count++;
			if(_thisMonthSpecialPublications)
				count++;
			if(_thisMonthReturnVisits)
				count++;
			if(_thisMonthBibleStudies)
				count++;
				
			break;
        // LastMonth
        case 1:
			count++; // always show hours
			if(_lastMonthBooks)
				count++;
			if(_lastMonthBrochures)
				count++;
			if(_lastMonthMagazines)
				count++;
			if(_lastMonthSpecialPublications)
				count++;
			if(_lastMonthReturnVisits)
				count++;
			if(_lastMonthBibleStudies)
				count++;
			break;
    }
	return(count);
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    VERBOSE(NSLog(@"tableView: titleForHeaderInSection:%d", section);)
	NSString *title = @"";
	switch(section)
	{
		case 0:
			title = [NSString stringWithFormat:NSLocalizedString(@"Time for %@", @"Time for %@ Group title on the Statistics View where %@ is the month of the year"), 
																 [[NSBundle mainBundle] localizedStringForKey:MONTHS[_thisMonth-1] value:MONTHS[_thisMonth-1] table:@""]];
			break;
		case 1:
			title = [NSString stringWithFormat:NSLocalizedString(@"Time for %@", @"Time for %@ Group title on the Statistics View where %@ is the month of the year"), 
																 [[NSBundle mainBundle] localizedStringForKey:MONTHS[_lastMonth-1] value:MONTHS[_lastMonth-1] table:@""]];
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
        // Name
        case 0:
			if(row-- == 0)
			{
				// if we are not editing, then 
				
				[cell setTitle:NSLocalizedString(@"Hours", @"'Hours' ButtonBar View text, Label for the amount of hours spend in the ministry, and Expanded name when on the More view")];
				int hours = _thisMonthMinutes / 60;
				int minutes = _thisMonthMinutes % 60;
				if(hours && minutes)
					[cell setValue:[NSString stringWithFormat:NSLocalizedString(@"%d %@ %d %@", @"You are localizing the time (I dont know if you need to even change this) as in '1 hour 34 minutes' or '2 hours 1 minute' %1$d is the hours number %2$@ is the label for hour(s) %3$d is the minutes number and 4$%@ is the label for minutes(s)"), hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours"), minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")]];
				else if(hours)
					[cell setValue:[NSString stringWithFormat:@"%d %@", hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours")]];
				else if(minutes)
					[cell setValue:[NSString stringWithFormat:@"%d %@", minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")]];
				else
					[cell setValue:@"0"];
			}
			else if(_thisMonthBooks && row-- == 0)
			{
				// if we are not editing, then 
				[cell setTitle:NSLocalizedString(@"Books", @"Publication Type name")];
				[cell setValue:[NSString stringWithFormat:@"%d", _thisMonthBooks]];
			}
			else if(_thisMonthBrochures && row-- == 0)
			{
				// if we are not editing, then 
				[cell setTitle:NSLocalizedString(@"Brochures", @"Publication Type name")];
				[cell setValue:[NSString stringWithFormat:@"%d", _thisMonthBrochures]];
			}
			else if(_thisMonthMagazines && row-- == 0)
			{
				// if we are not editing, then 
				[cell setTitle:NSLocalizedString(@"Magazines", @"Publication Type name")];
				[cell setValue:[NSString stringWithFormat:@"%d", _thisMonthMagazines]];
			}
			else if(_thisMonthReturnVisits && row-- == 0)
			{
				// if we are not editing, then 
				[cell setTitle:NSLocalizedString(@"Return Visits", @"Return Visits label on the Statistics View")];
				[cell setValue:[NSString stringWithFormat:@"%d", _thisMonthReturnVisits]];
			}
			else if(_thisMonthBibleStudies && row-- == 0)
			{
				// if we are not editing, then 
				[cell setTitle:NSLocalizedString(@"Bible Studies", @"Bible Studies label on the Statistics View")];
				[cell setValue:[NSString stringWithFormat:@"%d", _thisMonthBibleStudies]];
			}
            break;

        // Address
        case 1:
			if(row-- == 0)
			{
				// if we are not editing, then 
				[cell setTitle:NSLocalizedString(@"Hours", @"'Hours' ButtonBar View text, Label for the amount of hours spend in the ministry, and Expanded name when on the More view")];
				int hours = _lastMonthMinutes / 60;
				int minutes = _lastMonthMinutes % 60;
				if(hours && minutes)
					[cell setValue:[NSString stringWithFormat:NSLocalizedString(@"%d %@ %d %@", @"You are localizing the time (I dont know if you need to even change this) as in '1 hour 34 minutes' or '2 hours 1 minute' %1$d is the hours number %2$@ is the label for hour(s) %3$d is the minutes number and 4$%@ is the label for minutes(s)"), hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours"), minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")]];
				else if(hours)
					[cell setValue:[NSString stringWithFormat:@"%d %@", hours, hours == 1 ? NSLocalizedString(@"hour", @"Singular form of the word hour") : NSLocalizedString(@"hours", @"Plural form of the word hours")]];
				else if(minutes)
					[cell setValue:[NSString stringWithFormat:@"%d %@", minutes, minutes == 1 ? NSLocalizedString(@"minute", @"Singular form of the word minute") : NSLocalizedString(@"minutes", @"Plural form of the word minutes")]];
				else
					[cell setValue:@"0"];
			}
			else if(_lastMonthBooks && row-- == 0)
			{
				// if we are not editing, then 
				[cell setTitle:NSLocalizedString(@"Books", @"Publication Type name")];
				[cell setValue:[NSString stringWithFormat:@"%d", _lastMonthBooks]];
			}
			else if(_lastMonthBrochures && row-- == 0)
			{
				// if we are not editing, then 
				[cell setTitle:NSLocalizedString(@"Brochures", @"Publication Type name")];
				[cell setValue:[NSString stringWithFormat:@"%d", _lastMonthBrochures]];
			}
			else if(_lastMonthMagazines && row-- == 0)
			{
				// if we are not editing, then 
				[cell setTitle:NSLocalizedString(@"Magazines", @"Publication Type name")];
				[cell setValue:[NSString stringWithFormat:@"%d", _lastMonthMagazines]];
			}
			else if(_lastMonthReturnVisits && row-- == 0)
			{
				// if we are not editing, then 
				[cell setTitle:NSLocalizedString(@"Return Visits", @"Return Visits label on the Statistics View")];
				[cell setValue:[NSString stringWithFormat:@"%d", _lastMonthReturnVisits]];
			}
			else if(_lastMonthBibleStudies && row-- == 0)
			{
				// if we are not editing, then 
				[cell setTitle:NSLocalizedString(@"Bible Studies", @"Bible Studies label on the Statistics View")];
				[cell setValue:[NSString stringWithFormat:@"%d", _lastMonthBibleStudies]];
			}
			break;
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