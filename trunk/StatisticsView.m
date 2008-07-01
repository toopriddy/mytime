//
//  MyTime
//
//  Created by Brent Priddy on 12/29/07.
//  Copyright 2007 PG Software. All rights reserved.
//


#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/UIThreePartButton.h>
#import <UIKit/UINavigationBar.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UIPreferencesTable.h>
#import <UIKit/UIPreferencesTextTableCell.h>
#import <UIKit/UIPickerView.h>
#import <UIKit/UITextFieldLabel.h>
#import "StatisticsView.h"
#import "App.h"

const char* svn_version(void);

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

@implementation StatisticsView

- (void)dealloc
{
	[_table release];
	
	[super dealloc];
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
				NSCalendarDate *date = [visit objectForKey:CallReturnVisitDate];
				if(date != nil)
				{
					date = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:[date timeIntervalSinceReferenceDate]] autorelease];	
				
					int month = [date monthOfYear];
					int year = [date yearOfCommonEra];
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
									if([type isEqual:PublicationTypeBook])
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
									else if([type isEqual:PublicationTypeBrochure])
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
									else if([type isEqual:PublicationTypeMagazine])
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
									else if([type isEqual:PublicationTypeSpecial])
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
			[[App getInstance] saveData];
		}
	}
}

- (void)reloadData
{
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
	_thisMonth = [[NSCalendarDate calendarDate] monthOfYear];
	_lastMonth = _thisMonth == 1 ? 12 : _thisMonth - 1;
	_thisYear = [[NSCalendarDate calendarDate] yearOfCommonEra];
	_lastYear = _thisMonth == 1 ? _thisYear - 1 : _thisYear;


	NSArray *timeEntries = [_settings objectForKey:SettingsTimeEntries];
	int timeIndex;
	int timeCount = [timeEntries count];
	for(timeIndex = 0; timeIndex < timeCount; ++timeIndex)
	{
		NSDictionary *timeEntry = [timeEntries objectAtIndex:timeIndex];
		NSCalendarDate *date = [timeEntry objectForKey:SettingsTimeEntryDate];
		NSNumber *minutes = [timeEntry objectForKey:SettingsTimeEntryMinutes];
		if(date && minutes)
		{
			date = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:[date timeIntervalSinceReferenceDate]] autorelease];	
			int month = [date monthOfYear];
			int year = [date yearOfCommonEra];

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
	NSArray *bulkArray = [_settings objectForKey:SettingsBulkLiterature];
	NSEnumerator *bulkArrayEnumerator = [bulkArray objectEnumerator];
	NSDictionary *entry;
	
	while( (entry = [bulkArrayEnumerator nextObject]) ) // ASSIGNMENT, NOT COMPARISON 
	{
		NSCalendarDate *date = [entry objectForKey:BulkLiteratureDate];
		BOOL foundThisMonth = NO;
		BOOL foundLastMonth = NO;
		if(date != nil)
		{
			date = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:[date timeIntervalSinceReferenceDate]] autorelease];	
			
			int month = [date monthOfYear];
			int year = [date yearOfCommonEra];
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
					if([type isEqual:PublicationTypeBook])
					{
						if(foundThisMonth)
							_thisMonthBooks += number;
						else if(foundLastMonth)
							_lastMonthBooks += number;
					}
					else if([type isEqual:PublicationTypeBrochure])
					{
						if(foundThisMonth)
							_thisMonthBrochures += number;
						else if(foundLastMonth)
							_lastMonthBrochures += number;
					}
					else if([type isEqual:PublicationTypeMagazine])
					{
						if(foundThisMonth)
							_thisMonthMagazines += number;
						else if(foundLastMonth)
							_lastMonthMagazines += number;
					}
					else if([type isEqual:PublicationTypeSpecial])
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

	[self countCalls:[_settings objectForKey:SettingsCalls] removeOld:NO];
	[self countCalls:[_settings objectForKey:SettingsDeletedCalls] removeOld:YES];
	[_table reloadData];
}

- (id) initWithFrame: (CGRect)rect settings:(NSMutableDictionary *)settings
{
    if((self = [super initWithFrame: rect])) 
    {
        DEBUG(NSLog(@"CallView initWithFrame:");)

        _rect = rect;   
		_settings = settings;
        
        _table = [[UIPreferencesTable alloc] initWithFrame: _rect];
        [self addSubview: _table];
        [_table setDelegate: self];
        [_table setDataSource: self];
		[_table enableRowDeletion: YES animated:YES];
		[_table setAutoresizingMask: kMainAreaResizeMask];
		[_table setAutoresizesSubviews: YES];
		[self reloadData];
    }
    
    return(self);
}


/******************************************************************
 *
 *   PREFERENCES TABLE DELEGATE FUNCTIONS
 *
 ******************************************************************/
- (int) numberOfGroupsInPreferencesTable: (UIPreferencesTable *)table 
{
    VERBOSE(NSLog(@"numberOfGroupsInPreferencesTable:");)
    int count = 0;
	// ThisMonth
	count++;

	// LastMonth
	count++;

	VERBOSE(NSLog(@"count=%d", count);)
    return(count);
}

- (int) preferencesTable: (UIPreferencesTable *)table numberOfRowsInGroup: (int) group 
{
    VERBOSE(NSLog(@"preferencesTable: numberOfRowsInGroup:%d", group);)
	int count = 0;
    switch (group)
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

- (UIPreferencesTableCell *)preferencesTable:(UIPreferencesTable *)aTable cellForGroup:(int)group
{
    VERBOSE(NSLog(@"preferencesTable: cellForGroup:%d", group);)
	UIPreferencesTableCell *cell = nil;
	switch(group)
	{
		case 0:
			cell = [[UIPreferencesTableCell alloc] init];
			[cell setTitle:[NSString stringWithFormat:NSLocalizedString(@"Time for %@", @"Time for %@ Group title on the Statistics View where %@ is the month of the year"), MONTHS[_thisMonth - 1]]];
			break;
		case 1:
			cell = [[UIPreferencesTableCell alloc] init];
			[cell setTitle:[NSString stringWithFormat:NSLocalizedString(@"Time for %@", @"Time for %@ Group title on the Statistics View where %@ is the month of the year"), MONTHS[_lastMonth - 1]]];
			break;
    }
    return(cell);
} 

- (float)preferencesTable: (UIPreferencesTable *)table heightForRow: (int)row inGroup:(int)group withProposedHeight: (float)proposed 
{
    VERBOSE(NSLog(@"preferencesTable: heightForRow:%d inGroup:%d withProposedHeight:%f", row, group, proposed);)
    switch(group)
    {
        default:
            if (row == -1) 
            {
                return 40;
            }
            break;
    }
    return proposed;
}

- (BOOL)preferencesTable:(UIPreferencesTable *)aTable isLabelGroup:(int)group 
{
    VERBOSE(NSLog(@"preferencesTable: isLabelGroup:%d", group);)
	return(NO);
}


- (UIPreferencesTableCell *)preferencesTable: (UIPreferencesTable *)table cellForRow: (int)row inGroup: (int)group 
{
    VERBOSE(NSLog(@"preferencesTable: cellForRow:%d inGroup:%d", row, group);)
    UIPreferencesTableCell *cell = nil;

    switch (group) 
    {
        // Name
        case 0:
			if(row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
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
				[cell setShowSelection:NO];
			}
			else if(_thisMonthBooks && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:NSLocalizedString(@"Books", @"Publication Type name")];
				[cell setValue:[NSString stringWithFormat:@"%d", _thisMonthBooks]];
				[cell setShowSelection:NO];
			}
			else if(_thisMonthBrochures && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:NSLocalizedString(@"Brochures", @"Publication Type name")];
				[cell setValue:[NSString stringWithFormat:@"%d", _thisMonthBrochures]];
				[cell setShowSelection:NO];
			}
			else if(_thisMonthMagazines && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:NSLocalizedString(@"Magazines", @"Publication Type name")];
				[cell setValue:[NSString stringWithFormat:@"%d", _thisMonthMagazines]];
				[cell setShowSelection:NO];
			}
			else if(_thisMonthReturnVisits && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:NSLocalizedString(@"Return Visits", @"Return Visits label on the Statistics View")];
				[cell setValue:[NSString stringWithFormat:@"%d", _thisMonthReturnVisits]];
				[cell setShowSelection:NO];
			}
			else if(_thisMonthBibleStudies && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:NSLocalizedString(@"Bible Studies", @"Bible Studies label on the Statistics View")];
				[cell setValue:[NSString stringWithFormat:@"%d", _thisMonthBibleStudies]];
				[cell setShowSelection:NO];
			}
            break;

        // Address
        case 1:
			if(row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
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
				[cell setShowSelection:NO];
			}
			else if(_lastMonthBooks && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:NSLocalizedString(@"Books", @"Publication Type name")];
				[cell setValue:[NSString stringWithFormat:@"%d", _lastMonthBooks]];
				[cell setShowSelection:NO];
			}
			else if(_lastMonthBrochures && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:NSLocalizedString(@"Brochures", @"Publication Type name")];
				[cell setValue:[NSString stringWithFormat:@"%d", _lastMonthBrochures]];
				[cell setShowSelection:NO];
			}
			else if(_lastMonthMagazines && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:NSLocalizedString(@"Magazines", @"Publication Type name")];
				[cell setValue:[NSString stringWithFormat:@"%d", _lastMonthMagazines]];
				[cell setShowSelection:NO];
			}
			else if(_lastMonthReturnVisits && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:NSLocalizedString(@"Return Visits", @"Return Visits label on the Statistics View")];
				[cell setValue:[NSString stringWithFormat:@"%d", _lastMonthReturnVisits]];
				[cell setShowSelection:NO];
			}
			else if(_lastMonthBibleStudies && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:NSLocalizedString(@"Bible Studies", @"Bible Studies label on the Statistics View")];
				[cell setValue:[NSString stringWithFormat:@"%d", _lastMonthBibleStudies]];
				[cell setShowSelection:NO];
			}
			break;
		
    }

    // [ cell setShowSelection: NO ];
    return(cell);
}

- (BOOL)respondsToSelector:(SEL)selector
{
	VERY_VERBOSE(NSLog(@"StatisticsView respondsToSelector: %s", selector);)
	return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
	VERY_VERBOSE(NSLog(@"StatisticsView methodSignatureForSelector: %s", selector);)
	return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
	VERY_VERBOSE(NSLog(@"StatisticsView forwardInvocation: %s", [invocation selector]);)
	[super forwardInvocation:invocation];
}

@end

