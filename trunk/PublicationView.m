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
#import "PublicationView.h"
#import "App.h"

#define YEAR_OFFSET 1900
#define ARRAY_SIZE(a) (sizeof(a)/sizeof(a[0]))

@implementation PublicationView

static NSString *PUBLICATIONS[] = {
    @"Watchtower",
    @"Awake",
    @"Bible Teach",
    @"My Book of Bible Stories",
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
		[cell setTitle: PUBLICATIONS[row]];
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

- (void)navigationBar:(UINavigationBar*)nav buttonClicked:(int)button
{
    VERBOSE(NSLog(@"navigationBar: buttonClicked:%s", button ? "cancel" : "save");)
	if(button == 1)
	{
        if(_cancelObject != nil)
        {
            [_cancelObject performSelector:_cancelSelector withObject:self];
        }
	}
	else
	{
        if(_saveObject != nil)
        {
            [_saveObject performSelector:_saveSelector withObject:self];
        }
	}
}

- (void) dealloc
{
    VERY_VERBOSE(NSLog(@"PublicationView: dealloc");)
    [_picker release];

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

    return([self initWithFrame:rect publication:PUBLICATIONS[publication] year:year month:month day:day]);
}

// initialize this view given the curent configuration
- (id) initWithFrame: (CGRect)rect publication: (NSString *)publication year: (int)year month: (int)month day: (int)day;
{
    if((self = [super initWithFrame: rect])) 
    {
        int i;
        DEBUG(NSLog(@"PublicationView initWithFrame: publication:\"%@\" year:%d month:%d day:%d", publication, year, month, day);)

        _saveObject = nil;
        _cancelObject = nil;

        _publication = 0;
        for(i = 0; i < ARRAY_SIZE(PUBLICATIONS); ++i)
        {
            if([publication isEqual:PUBLICATIONS[i]])
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

        // make the navigation bar with
        // Cancel                    Save
        CGSize navSize = [UINavigationBar defaultSize];
        UINavigationBar *nav = [[[UINavigationBar alloc] initWithFrame: CGRectMake(0,0,rect.size.width, navSize.height)] autorelease];
        [nav setDelegate: self];
        [nav pushNavigationItem: [[[UINavigationItem alloc] initWithTitle:@"Select Publication"] autorelease] ];
//        [nav setBarStyle: 1];
        [self addSubview: nav]; 
        // 0 = greay
        // 1 = red
        // 2 = left arrow
        // 3 = blue
        [nav showLeftButton:@"Cancel" withStyle:2 rightButton:@"Done" withStyle:3];
        navSize = [nav bounds].size;
        
        // make a picker for the publications
    	CGSize pickerSize = [UIPickerView defaultSize];
        VERY_VERBOSE(NSLog(@"CGRectMake: %f,%f", pickerSize.height, pickerSize.width);)
        _picker = [[UIPickerView alloc] initWithFrame: CGRectMake(0, navSize.height, rect.size.width, pickerSize.height)];

        pickerSize = [_picker bounds].size;
        VERY_VERBOSE(NSLog(@"CGRectMake: %f,%f", pickerSize.height, pickerSize.width);)

        // we are managing the picker's data and display
    	[_picker setDelegate: self];   
    	[self addSubview: _picker];
        pickerSize = [_picker bounds].size;

        // make a rectangle to show the user what is currently selected across the Picker
        CGRect pickerBarRect = [_picker selectionBarRect];
        pickerBarRect.origin.y += [_picker origin].y;
        UIView *bar = [[[UIView alloc] initWithFrame: pickerBarRect] autorelease];
        // let them see through it
        [bar setAlpha: 0.2];
        [bar setEnabled: NO];
        float bgColor[] = { 0.2, 0.2, 0.2, 1 };
        [bar setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];
        [self addSubview: bar];    

        VERY_VERBOSE(NSLog(@"CGRectMake: %f,%f  %f,%f", 0.0, navSize.height + pickerSize.height, rect.size.height - navSize.height - pickerSize.height, rect.size.width);)
        UITable *table = [[UITable alloc] initWithFrame: CGRectMake(0, navSize.height + pickerSize.height, rect.size.width, rect.size.height - navSize.height - pickerSize.height)];
        [table addTableColumn: [[[UITableColumn alloc] initWithTitle:@"Placed Publications" identifier:nil width:rect.size.width] autorelease]];
//      [table setDataSource: self];
//      [table setDelegate: self];
        [self addSubview: table];
    }
    
    return(self);
}

- (void)setCancelAction: (SEL)aSelector forObject:(NSObject *)obj
{
    _cancelObject = obj;
    _cancelSelector = aSelector;
}

- (void)setSaveAction: (SEL)aSelector forObject:(NSObject *)obj
{
    _saveObject = obj;
    _saveSelector = aSelector;
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
    return([NSString stringWithString: PUBLICATIONS[_publication]]);
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
            return([NSString stringWithFormat:@"%@ %@ %d, %d",PUBLICATIONS[_publication], MONTHS[month-1], day, year ]);
        else
            return([NSString stringWithFormat:@"%@ %@ %d",PUBLICATIONS[_publication], MONTHS[month-1], year ]);
    }
    else
    {
        return([NSString stringWithString: PUBLICATIONS[_publication]]);
    }
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
    VERY_VERBOSE(NSLog(@"PublicationView respondsToSelector: %s", selector);)
    return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"PublicationView methodSignatureForSelector: %s", selector);)
    return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    VERY_VERBOSE(NSLog(@"PublicationView forwardInvocation: %s", [invocation selector]);)
    [super forwardInvocation:invocation];
}


@end

