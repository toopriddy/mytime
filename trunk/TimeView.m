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
#import "TimeView.h"
#import "App.h"

static NSString *MONTHS[] = {
	@"January",
	@"February",
	@"March",
	@"April",
	@"May",
	@"June",
	@"July",
	@"August",
	@"September",
	@"October",
	@"November",
	@"December"
};


@implementation TimeView

- (void)dealloc
{
	[_table release];
	
	[super dealloc];
}

- (void)reloadData
{
	_thisMonthBooks = 0;
	_thisMonthBroshures = 0;
	_thisMonthHours = 0;
	_thisMonthMagazines = 0;
	_thisMonthReturnVisits = 0;
	_thisMonthBibleStudies = 0;
	_thisMonthSpecialPublications = 0;
	
	_lastMonthBooks = 0;
	_lastMonthBroshures = 0;
	_lastMonthHours = 0;
	_lastMonthMagazines = 0;
	_lastMonthReturnVisits = 0;
	_lastMonthBibleStudies = 0;
	_lastMonthSpecialPublications = 0;
	


	NSMutableDictionary *settings = [[App getInstance] getSavedData];
	int callIndex;
	NSArray *calls = [settings objectForKey:SettingsCalls];
	int callCount = [calls count];
	
	// save off this month and last month for quick compares
	_thisMonth = [[NSCalendarDate calendarDate] monthOfYear];
	_lastMonth = _thisMonth == 1 ? 12 : _thisMonth - 1;
	_thisYear = [[NSCalendarDate calendarDate] yearOfCommonEra];
	_lastYear = _thisMonth == 1 ? _thisYear - 1 : _thisYear;
	
	// go through all of the calls and see what the counts are for this month and last month
	for(callIndex = 0; callIndex < callCount; ++callIndex)
	{
		NSDictionary *call = [calls objectAtIndex:callIndex];
		
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
							_thisMonthReturnVisits++;
						else if(month == _lastMonth && year == _thisYear)
							_lastMonthReturnVisits++;
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
											_thisMonthBooks++;
										else if(month == _lastMonth && year == _thisYear)
											_lastMonthBooks++;
									}
									else if([type isEqual:PublicationTypeBroshure])
									{
										if(month == _thisMonth && year == _thisYear)
											_thisMonthBroshures++;
										else if(month == _lastMonth && year == _thisYear)
											_lastMonthBroshures++;
									}
									else if([type isEqual:PublicationTypeMagazine])
									{
										if(month == _thisMonth && year == _thisYear)
											_thisMonthMagazines++;
										else if(month == _lastMonth && year == _thisYear)
											_lastMonthMagazines++;
									}
									else if([type isEqual:PublicationTypeSpecial])
									{
										if(month == _thisMonth && year == _thisYear)
											_thisMonthSpecialPublications++;
										else if(month == _lastMonth && year == _thisYear)
											_lastMonthSpecialPublications++;
									}
								}
							}
						}
					}
				}
			}
		}
	}
        
	[_table reloadData];
}

- (id) initWithFrame: (CGRect)rect
{
    if((self = [super initWithFrame: rect])) 
    {
        DEBUG(NSLog(@"CallView initWithFrame:");)

        _rect = rect;   
        // make the navigation bar with
        //                        +
        CGSize s = [UINavigationBar defaultSize];
        _navigationBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0,0,rect.size.width, s.height)];
        [_navigationBar setDelegate: self];
        [self addSubview: _navigationBar]; 

		// 0 = gray
		// 1 = red
		// 2 = left arrow
		// 3 = blue
		[_navigationBar pushNavigationItem: [[[UINavigationItem alloc] initWithTitle:@"Time"] autorelease] ];
		[_navigationBar showLeftButton:@"Add Time" withStyle:0 rightButton:@"Start Time" withStyle:3];
        
        _table = [[UIPreferencesTable alloc] initWithFrame: CGRectMake(0, s.height, rect.size.width, rect.size.height - s.height)];
        [self addSubview: _table];
        [_table setDelegate: self];
        [_table setDataSource: self];
		[_table enableRowDeletion: YES animated:YES];
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

	// how are we going to do the time...
	
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
			if(_thisMonthBroshures)
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
			if(_lastMonthBroshures)
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
			[cell setTitle:[NSString stringWithFormat:@"Time for %@", MONTHS[_thisMonth - 1]]];
			break;
		case 1:
			cell = [[UIPreferencesTableCell alloc] init];
			[cell setTitle:[NSString stringWithFormat:@"Time for %@", MONTHS[_lastMonth - 1]]];
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
				[cell setTitle:@"Hours"];
				[cell setValue:[NSString stringWithFormat:@"%d", _thisMonthHours]];
			}
			else if(_thisMonthBooks && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:@"Books"];
				[cell setValue:[NSString stringWithFormat:@"%d", _thisMonthBooks]];
			}
			else if(_thisMonthBroshures && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:@"Broshures"];
				[cell setValue:[NSString stringWithFormat:@"%d", _thisMonthBroshures]];
			}
			else if(_thisMonthMagazines && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:@"Magazines"];
				[cell setValue:[NSString stringWithFormat:@"%d", _thisMonthMagazines]];
			}
			else if(_thisMonthReturnVisits && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:@"Return Visits"];
				[cell setValue:[NSString stringWithFormat:@"%d", _thisMonthReturnVisits]];
			}
			else if(_thisMonthBibleStudies && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:@"Bible Studies"];
				[cell setValue:[NSString stringWithFormat:@"%d", _thisMonthBibleStudies]];
			}
            break;

        // Address
        case 1:
			if(row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:@"Hours"];
				[cell setValue:[NSString stringWithFormat:@"%d", _lastMonthHours]];
			}
			else if(_lastMonthBooks && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:@"Books"];
				[cell setValue:[NSString stringWithFormat:@"%d", _lastMonthBooks]];
			}
			else if(_lastMonthBroshures && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:@"Broshures"];
				[cell setValue:[NSString stringWithFormat:@"%d", _lastMonthBroshures]];
			}
			else if(_lastMonthMagazines && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:@"Magazines"];
				[cell setValue:[NSString stringWithFormat:@"%d", _lastMonthMagazines]];
			}
			else if(_lastMonthReturnVisits && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:@"Return Visits"];
				[cell setValue:[NSString stringWithFormat:@"%d", _lastMonthReturnVisits]];
			}
			else if(_lastMonthBibleStudies && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:@"Bible Studies"];
				[cell setValue:[NSString stringWithFormat:@"%d", _lastMonthBibleStudies]];
			}
			break;
    }

   // [ cell setShowSelection: NO ];
    return(cell);
}


@end
