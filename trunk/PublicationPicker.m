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
#import <UIKit/UITable.h>
#import <UIKit/UITableCell.h>
#import <UIKit/UITableColumn.h>
#import <UIKit/UIPickerView.h>
#import "PublicationPicker.h"
#import "App.h"
#import "MainView.h"

#define YEAR_OFFSET 1900
#define ARRAY_SIZE(a) (sizeof(a)/sizeof(a[0]))

@implementation PublicationPicker


// these should be sorted by (in alphabetical order, except for watchtower and awake)
// MAGIZINES
// BROSHURES
// BOOKS
// ADDED TYPES

typedef struct {
	NSString * name;
	NSString * type;
} PublicationInformation;

static PublicationInformation PUBLICATIONS[] = {
{@"Watchtower",                      PublicationTypeMagazine}
,   {@"Awake",                           PublicationTypeMagazine}

,   {@"   BOOKS",    @""}
,   {@"Bible",    PublicationTypeBook}

,   {@"All Scripture",    PublicationTypeBook}
,   {@"Bible Stories",    PublicationTypeBook}
,   {@"Bible Teach",    PublicationTypeBook}
,   {@"Close to Jehovah",    PublicationTypeBook}
,   {@"Concordance",    PublicationTypeBook}
,   {@"Creation",    PublicationTypeBook}
,   {@"Creator",    PublicationTypeBook}
,   {@"Daniel's Prophecy",    PublicationTypeBook}
,   {@"Family Happiness",    PublicationTypeBook}
,   {@"God's Word",    PublicationTypeBook}
,   {@"Greatest Man",    PublicationTypeBook}
,   {@"Insight",    PublicationTypeBook}
,   {@"Isaiah's Prophecy I",    PublicationTypeBook}
,   {@"Isaiah's Prophecy II",    PublicationTypeBook}
,   {@"Jehovah's Day",    PublicationTypeBook}
,   {@"Knowledge",    PublicationTypeBook}
,   {@"Mankind's Search for God",    PublicationTypeBook}
,   {@"Ministry School",    PublicationTypeBook}
,   {@"My Book of Bible Stories",        PublicationTypeBook}
,   {@"Organized",    PublicationTypeBook}
,   {@"Proclaimers",    PublicationTypeBook}
,   {@"Revelation Climax",    PublicationTypeBook}
,   {@"Sing Praises",    PublicationTypeBook}
,   {@"Teacher",    PublicationTypeBook}
,   {@"Worship God",    PublicationTypeBook}
,   {@"Young People Ask",    PublicationTypeBook}
,   {@"Reasoning",    PublicationTypeBook}

,   {@"   BROCHURES",    @""}
,   {@"Blood",    PublicationTypeBrochure}
,   {@"Book for All",    PublicationTypeBrochure}
,   {@"Divine Name",    PublicationTypeBrochure}
,   {@"Does God Care",    PublicationTypeBrochure}
,   {@"Education",    PublicationTypeBrochure}
,   {@"God's Friend",    PublicationTypeBrochure}
,   {@"Good Land",    PublicationTypeBrochure}
,   {@"Government",    PublicationTypeBrochure}
,   {@"Guidance of God",    PublicationTypeBrochure}
,   {@"Jehovah's Witnesses",    PublicationTypeBrochure}
,   {@"Lasting Peace",    PublicationTypeBrochure}
,   {@"Life on Earth",    PublicationTypeBrochure}
,   {@"Look!",    PublicationTypeBrochure}
,   {@"Nations",    PublicationTypeBrochure}
,   {@"Our Problems",    PublicationTypeBrochure}
,   {@"Purpose of Life",    PublicationTypeBrochure}
,   {@"Require",    PublicationTypeBrochure}
,   {@"Satisfying Life",    PublicationTypeBrochure}
,   {@"Spirits of the Dead",    PublicationTypeBrochure}
,   {@"Trinity",    PublicationTypeBrochure}
,   {@"Watch!",    PublicationTypeBrochure}
,   {@"When Someone Dies",    PublicationTypeBrochure}
,   {@"When We Die",    PublicationTypeBrochure}
,   {@"Why Worship God",    PublicationTypeBrochure}
,   {@"World Without War",    PublicationTypeBrochure}


,   {@"   TRACTS",    @""}
,   {@"A Peaceful New World-Will It Come?",    PublicationTypeTract}
,   {@"Does Fate Rule Our Lives",    PublicationTypeTract}
,   {@"Hellfire-Is It Part of Divine Justice?",    PublicationTypeTract}
,   {@"How to Find the Road to Paradise",    PublicationTypeTract}
,   {@"Immortal Spirit",    PublicationTypeTract}
,   {@"Jehovah's Witnesses-What Do They Believe?",    PublicationTypeTract}
,   {@"The Greatest Name",    PublicationTypeTract}
,   {@"Who Are Jehovah's Witnesses?",    PublicationTypeTract}
,   {@"Comfort for the Depressed",    PublicationTypeTract}
,   {@"Enjoy Family Life",    PublicationTypeTract}
,   {@"Jehovah-Who Is He?",    PublicationTypeTract}
,   {@"Jesus Christ-Who Is He?",    PublicationTypeTract}
,   {@"Know the Bible",    PublicationTypeTract}
,   {@"Peaceful New World",    PublicationTypeTract}
,   {@"Suffering to End",    PublicationTypeTract}
,   {@"What Do Jehovah's Witnesses Believe?",    PublicationTypeTract}
,   {@"What Hope for Dead Loved Ones?",    PublicationTypeTract}
,   {@"Who Really Rules the World?",    PublicationTypeTract}
,   {@"Why You Can Trust the Bible",    PublicationTypeTract}
,   {@"Will This World Survive?",    PublicationTypeTract}
};

static NSString *MONTHS[] = {
@"Jan",
@"Feb",
@"Mar",
@"Apr",
@"May",
@"Jun",
@"Jul",
@"Aug",
@"Sep",
@"Oct",
@"Nov",
@"Dec"
};

+ (NSString *)watchtower
{
	return(PUBLICATIONS[0].name);
}

+ (NSString *)awake
{
	return(PUBLICATIONS[1].name);
}

// when the user selects something in the picker or moves the picker
// to select a different value, this function is called
- (void)pickerViewSelectionChanged: (UIPickerView*)p
{
    VERBOSE(NSLog(@"pickerViewSelectionChanged: ");)
	
    // save off the previous information before the change (we need to know this
    // because we should not look for the year if the previous publication was not
    // a watchtower or an awake
    int previousPublication = _publication;
    int previousYear = _year;
    int previousMonth = _month;
    int previousDay = _day;
	
    VERBOSE(NSLog(@"publication:%@ month:%@ year:%d day:%d", PUBLICATIONS[_publication], MONTHS[_month], _year + YEAR_OFFSET, _day);)
	
	
    // what is the new publication?
    _publication = [p selectedRowForColumn: 0];
    
    // if the previous publication was a watchtower or awake, then 
    // lets get at the month year and possibly date of the magazine
    if(previousPublication == 0 || previousPublication == 1)
    {
        
        _month = [p selectedRowForColumn: 1];
        _year = [p selectedRowForColumn: 2];
        // if the previous year selected was < 2008 then the watchtower would have had a date 
        // column in the picker
        if(previousPublication == 0 && previousYear + YEAR_OFFSET < 2008)
            _day = [p selectedRowForColumn: 3];
        
        // if the previous year selected was < 2007 then the awake would have had a date 
        // column in the picker
        if(previousPublication == 1 && previousYear + YEAR_OFFSET < 2007)
            _day = [p selectedRowForColumn: 3];
    }
    // if anything changed, update the picker so that it will dynamically display the columns
    // (for example if you went from a watchtower to a bible teach book we would only have one
    // column in the picker).  This is to work around a problem that if you select a value before
    // it has time to be animated to the selection point (straight down the middle of the picker) it
    // will get reset and will not pick the correct value, we only update when the values have changed.
    if(previousYear != _year ||
       previousMonth != _month || 
       previousDay != _day ||
       previousPublication != _publication)
    {
        DEBUG(NSLog(@"DATA CHANGED:\npublication:%@ month:%@ year:%d day:%d", PUBLICATIONS[_publication], MONTHS[_month], _year + YEAR_OFFSET, _day);)
        [p reloadData];
    }
}

// how many columns should be in the picker
- (int)numberOfColumnsInPickerView: (UIPickerView*)p
{
    int ret = 1;
    switch(_publication)
    {
        case 0: // Watchtower Jan 2007 15
            // check to see if they chose something before 2008, if so then
            // we need to specify the 1st or the 15th of the month
            if( _year + YEAR_OFFSET < 2008)
            {
                ret = 4;
            }
            else
            {
                // we went to only one a month in 2008
                ret = 3;
            }
            break;
            
        case 1: // Awake Jan 2006 22
            // check to see if they chose something before 2007, if so then
            // we need to specify the 1st or the 15th of the month
            if( _year + YEAR_OFFSET < 2007)
            {
                ret = 4;
            }
            else
            {
                // we went to only one a month in 2008
                ret = 3;
            }
    }
    VERY_VERBOSE(NSLog(@"numberOfColumnsInPickerView: %d", ret);)
    return(ret);
}

// given a column how many rows should be in the column
- (int) pickerView:(UIPickerView*)p numberOfRowsInColumn:(int)col
{
    VERY_VERBOSE(NSLog(@"pickerView: numberOfRowsInColumn: %d", col);)
	
    // col 0 is the publications column
    if(col == 0)
    {
        return(ARRAY_SIZE(PUBLICATIONS));
    }
    else
    {
        // if the publication is a watchtower or an awake
        // then there might be 3 or four columns
        switch(_publication)
        {
            case 0: // Watchtower Jan 2007 15
            case 1: // Awake Jan 2006 22
            {
                switch(col)
                {
                    case 1: // Month
                        return(ARRAY_SIZE(MONTHS));
                    case 2: // Year
                        return(200);
                    case 3: // day
                        return(2);
                        
                }
			}
				
			default:
			{
                return(0);
			}
        }
    }
}

// given a column and a row get the cell for the table
- (id) pickerView:(UIPickerView*)p tableCellForRow:(int)row inColumn:(int)col
{
    VERY_VERBOSE(NSLog(@"pickerView: tableCellForRow: %d inColumn:%d", row, col);)
	id cell = [[[UIImageAndTextTableCell alloc] init] autorelease];
	
    // if this is the publicaiton column then just display the
    // publication name
    if(col == 0)
    {
		[cell setAlignment: 0];
		[cell setTitle: PUBLICATIONS[row].name];
    }
    else
    {
        // if the publicaiton is a watchtower or an awake, then
        // we have to display the month year and possibly date of
        // the publication
        switch(_publication)
        {
            case 0: // Watchtower Jan 2007 15
                switch(col)
			{
				case 1: // Month
					[cell setAlignment: 2];
					[cell setTitle: MONTHS[row]];
					break;
					
				case 2: // Year
					[cell setAlignment: 0];
					// we offset the _year from 1900
					[cell setTitle: [NSString stringWithFormat:@"%d", row+YEAR_OFFSET]];
					break;
					
				case 3: // day
					[cell setAlignment: 2];
					// when the watchtower was bimonthly, it came out on the 1st and 15th
					[cell setTitle: row == 0 ? @"1" : @"15"];
					break;
			}
                break;
                
            case 1: // Awake Jan 2007 15
                switch(col)
			{
				case 1: // Month
					[cell setAlignment: 2];
					[cell setTitle: MONTHS[row]];
					break;
					
				case 2: // Year
					[cell setAlignment: 0];
					// we offset the year from 1900
					[cell setTitle: [NSString stringWithFormat:@"%d", row+YEAR_OFFSET]];
					break;
					
				case 3: // day
					[cell setAlignment: 2];
					// when the awake was bimonthly, it came out on the 8th and 22nd
					[cell setTitle: row == 0 ? @"8" : @"22"];
					break;
			}
                break;
        }
    }    
	return(cell);
}

#define PUBLICATION_WIDTH 140
#define MONTH_WIDTH 53
#define YEAR_WIDTH 58
#define DAY_WIDTH 45

-(float)pickerView:(UIPickerView*)p tableWidthForColumn: (int)col
{
    VERY_VERBOSE(NSLog(@"pickerView: tableWidthForColumn:%d", col);)
	
    // based on what we already know about the publication, lets
    // setup the width of the picker.
    switch([self numberOfColumnsInPickerView: p])
    {
			
        case 1:
            // if there is only one publication, then set the only column to 
            // the width of the entire picker
            return(PUBLICATION_WIDTH + MONTH_WIDTH + YEAR_WIDTH + DAY_WIDTH);
        case 3:
            // if there are three columns then the "last two" columns are combined
            // to make the picker look like it is adjusting for the years
            switch(col)
		{
			case 0:
				return(PUBLICATION_WIDTH);
			case 1:
				return(MONTH_WIDTH);
			case 2:
				return(YEAR_WIDTH + DAY_WIDTH);
		}
        case 4:
            // if there are four columns then report each of the column widths
            switch(col)
		{
			case 0:
				return(PUBLICATION_WIDTH);
			case 1:
				return(MONTH_WIDTH);
			case 2:
				return(YEAR_WIDTH);
			case 3:
				return(DAY_WIDTH);
		}
	}
}

// set the Picker to the current data values
-(void)pickerViewLoaded: (UIPickerView*)p
{
    VERY_VERBOSE(NSLog(@"pickerViewLoaded: ");)
	
    // select the publication
	[p selectRow: _publication inColumn: 0 animated: NO];
	
    // the watchtower and awake are the only ones that have a subscription
    // type of placement, all others are just books that do not have a release
    // time
    if(_publication == 0 || _publication == 1)
    {
    	[p selectRow: _month inColumn: 1 animated: NO];
    	[p selectRow: _year inColumn: 2 animated: NO];
		
        // in 2008, the watchtower went from bimonthly to monthly
        if(_publication == 0 && _year + YEAR_OFFSET < 2008)
            [p selectRow: _day inColumn: 3 animated: NO];
        
        // in 2007, the awake went from bimonthly to monthly
        if(_publication == 1 && _year + YEAR_OFFSET < 2007)
            [p selectRow: _day inColumn: 3 animated: NO];
    }
}

- (void) dealloc
{
    VERY_VERBOSE(NSLog(@"PublicationPicker: dealloc");)
	
    [super dealloc];
}

- (id) initWithFrame: (CGRect)rect
{
    // initalize the data to the current date
	NSCalendarDate *now = [NSCalendarDate calendarDate];
	
    // set the default publication to be the watchtower this month and year
    int publication = 0;
    int year = [now yearOfCommonEra];
    int month = [now monthOfYear];
    int day = 1;
	
    return([self initWithFrame:rect publication:PUBLICATIONS[publication].name year:year month:month day:day]);
}

// initialize this view given the curent configuration
- (id) initWithFrame: (CGRect)rect publication: (NSString *)publication year: (int)year month: (int)month day: (int)day;
{
    if((self = [super initWithFrame: rect])) 
    {
        int i;
        DEBUG(NSLog(@"PublicationPicker initWithFrame: publication:\"%@\" year:%d month:%d day:%d", publication, year, month, day);)
		
        _publication = 0;
        for(i = 0; i < ARRAY_SIZE(PUBLICATIONS); ++i)
        {
            if([publication isEqualToString:PUBLICATIONS[i].name])
            {
                _publication = i;
                break;
            }
        }
        if(_publication == 0 || _publication == 1)
        {
            _year = year - YEAR_OFFSET;
            _month = month - 1;
            // translate the publication date, otherwise leave it at index 0
            if(_publication == 0)
                _day = day == 15 ? 1 : 0;
            if(_publication == 1)
                _day = day == 22 ? 1 : 0;
        }
        else
        {
            // initalize the date information to the current date, since it is just a book
            // and does not have a publication date (if they want to change the publication
            // to a magazine, at least they will see the current date's magazine)
        	NSCalendarDate *now = [NSCalendarDate calendarDate];
			
            // set the default publication to be the watchtower this month and year
            _year = [now yearOfCommonEra] - YEAR_OFFSET;
            _month = [now monthOfYear] - 1;
            _day = 0; // 1st or 22nd
        }
		
        // we are managing the picker's data and display
    	[self setDelegate: self];   
    }
    
    return(self);
}

// year of our common era
- (int)year
{
    return(YEAR_OFFSET + _year);
}

// 0-11 where 0=Jan
- (int)month
{
    if(_publication == 0 || _publication == 1)
        return(_month + 1);
    else
        return(0);
}

// string of the publication name
- (NSString *)publication
{
    return([NSString stringWithString: PUBLICATIONS[_publication].name]);
}

// string of the publication title
- (NSString *)publicationTitle
{
    int day = [self day];
    int year = [self year];
    int month = [self month];
	
    if(_publication == 0 || _publication == 1)
    {
        if(day)
            return([NSString stringWithFormat:@"%@ %@ %d, %d",PUBLICATIONS[_publication].name, MONTHS[month-1], day, year ]);
        else
            return([NSString stringWithFormat:@"%@ %@ %d",PUBLICATIONS[_publication].name, MONTHS[month-1], year ]);
    }
    else
    {
        return([NSString stringWithString: PUBLICATIONS[_publication].name]);
    }
}

// string of the publication name
- (NSString *)publicationType
{
    return([NSString stringWithString: PUBLICATIONS[_publication].type]);
}



// 0 = not used and 1, 8, 15, 22 for the day of the month
- (int)day
{
    // if the previous year selected was < 2008 then the watchtower would have had a date 
    // column in the picker, so figure out which date it is
    if(_publication == 0 && _year + YEAR_OFFSET < 2008)
        return(_day ? 15 : 1);
    
    // if the previous year selected was < 2007 then the awake would have had a date 
    // column in the picker, so figure out which date it is
    if(_publication == 1 && _year + YEAR_OFFSET < 2007)
        return(_day ? 22 : 8);
	
    return(0);
}



- (BOOL)respondsToSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"PublicationPicker respondsToSelector: %s", selector);)
    return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"PublicationPicker methodSignatureForSelector: %s", selector);)
    return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    VERY_VERBOSE(NSLog(@"PublicationPicker forwardInvocation: %s", [invocation selector]);)
    [super forwardInvocation:invocation];
}


@end

