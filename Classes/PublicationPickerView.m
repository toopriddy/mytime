//
//  PublicationPickerView.m
//  MyTime
//
//  Created by Brent Priddy on 8/7/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import "PublicationPickerView.h"
#import "Settings.h"

#define YEAR_OFFSET 1900
#define ARRAY_SIZE(a) (sizeof(a)/sizeof(a[0]))

#define AlternateLocalizedString(a, b) (a)

static NSString *MONTHS[] = {
	AlternateLocalizedString(@"Jan", @"Short month name"),
	AlternateLocalizedString(@"Feb", @"Short month name"),
	AlternateLocalizedString(@"Mar", @"Short month name"),
	AlternateLocalizedString(@"Apr", @"Short month name"),
	AlternateLocalizedString(@"May", @"Short/Long month name"),
	AlternateLocalizedString(@"Jun", @"Short month name"),
	AlternateLocalizedString(@"Jul", @"Short month name"),
	AlternateLocalizedString(@"Aug", @"Short month name"),
	AlternateLocalizedString(@"Sep", @"Short month name"),
	AlternateLocalizedString(@"Oct", @"Short month name"),
	AlternateLocalizedString(@"Nov", @"Short month name"),
	AlternateLocalizedString(@"Dec", @"Short month name")
};


@implementation PublicationPickerView


// these should be sorted by (in alphabetical order, except for watchtower and awake)
// MAGIZINES
// BROCHURES
// BOOKS
// ADDED TYPES

typedef struct {
	NSString * name;
	NSString * type;
} PublicationInformation;

/*
Just a way that the genstrings program can pickup the publication types
 
NSLocalizedString(@"Book", @"Publication Type name")
NSLocalizedString(@"Brochure", @"Publication Type name")
NSLocalizedString(@"Magazine", @"Publication Type name")
NSLocalizedString(@"Tract", @"Publication Type name")
NSLocalizedString(@"Special", @"Publication Type name")
 
*/

static const PublicationInformation PUBLICATIONS[] = {
{AlternateLocalizedString(@"Watchtower", @"Magizine Publication Name"),     PublicationTypeMagazine}
,   {AlternateLocalizedString(@"Awake", @"Magizine Publication Name"),       PublicationTypeMagazine}

,   {AlternateLocalizedString(@"   BOOKS", @"Publication Type and Seperator in the Publication Picker"),    PublicationTypeHeading}
,   {AlternateLocalizedString(@"Bible", @"Book Publication Name"),   PublicationTypeBook}

,   {AlternateLocalizedString(@"All Scripture", @"Book Publication Name"),   PublicationTypeBook}
,   {AlternateLocalizedString(@"Bible Stories", @"Book Publication Name"),   PublicationTypeBook}
,   {AlternateLocalizedString(@"Bible Teach", @"Book Publication Name"),   PublicationTypeBook}
,   {AlternateLocalizedString(@"Close to Jehovah", @"Book Publication Name"),   PublicationTypeBook}
,   {AlternateLocalizedString(@"Concordance", @"Book Publication Name"),   PublicationTypeBook}
,   {AlternateLocalizedString(@"Creation", @"Book Publication Name"),   PublicationTypeBook}
,   {AlternateLocalizedString(@"Creator", @"Book Publication Name"),   PublicationTypeBook}
,   {AlternateLocalizedString(@"Daniel's Prophecy", @"Book Publication Name"),   PublicationTypeBook}
,   {AlternateLocalizedString(@"Family Happiness", @"Book Publication Name"),   PublicationTypeBook}
,   {AlternateLocalizedString(@"God's Word", @"Book Publication Name"),   PublicationTypeBook}
,   {AlternateLocalizedString(@"Greatest Man", @"Book Publication Name"),   PublicationTypeBook}
,   {AlternateLocalizedString(@"Insight", @"Book Publication Name"),   PublicationTypeBook}
,   {AlternateLocalizedString(@"Isaiah's Prophecy I", @"Book Publication Name"),   PublicationTypeBook}
,   {AlternateLocalizedString(@"Isaiah's Prophecy II", @"Book Publication Name"),   PublicationTypeBook}
,   {AlternateLocalizedString(@"Jehovah's Day", @"Book Publication Name"),   PublicationTypeBook}
,   {AlternateLocalizedString(@"Knowledge", @"Book Publication Name"),   PublicationTypeBook}
,   {AlternateLocalizedString(@"Mankind's Search for God", @"Book Publication Name"),   PublicationTypeBook}
,   {AlternateLocalizedString(@"Ministry School", @"Book Publication Name"),   PublicationTypeBook}
,   {AlternateLocalizedString(@"My Book of Bible Stories", @"Book Publication Name"),       PublicationTypeBook}
,   {AlternateLocalizedString(@"Organized", @"Book Publication Name"),   PublicationTypeBook}
,   {AlternateLocalizedString(@"Proclaimers", @"Book Publication Name"),   PublicationTypeBook}
,   {AlternateLocalizedString(@"Revelation Climax", @"Book Publication Name"),   PublicationTypeBook}
,   {AlternateLocalizedString(@"Sing Praises", @"Book Publication Name"),   PublicationTypeBook}
,   {AlternateLocalizedString(@"Teacher", @"Book Publication Name"),   PublicationTypeBook}
,   {AlternateLocalizedString(@"Worship God", @"Book Publication Name"),   PublicationTypeBook}
,   {AlternateLocalizedString(@"Young People Ask", @"Book Publication Name"),   PublicationTypeBook}
,   {AlternateLocalizedString(@"Reasoning", @"Book Publication Name"),   PublicationTypeBook}



,   {AlternateLocalizedString(@"   BIBLE DVD", @"Publication Type and Seperator in the Publication Picker"),   PublicationTypeHeading}
,   {AlternateLocalizedString(@"Bible DVD: Matthew", @"Bible DVD Publication Name"),   PublicationTypeDVDBible}
,   {AlternateLocalizedString(@"Bible DVD: Mark", @"Bible DVD Publication Name"),   PublicationTypeDVDBible}
,   {AlternateLocalizedString(@"Bible DVD: Luke", @"Bible DVD Publication Name"),   PublicationTypeDVDBible}
,   {AlternateLocalizedString(@"Bible DVD: John", @"Bible DVD Publication Name"),   PublicationTypeDVDBible}
,   {AlternateLocalizedString(@"Bible DVD: Acts", @"Bible DVD Publication Name"),   PublicationTypeDVDBible}
,   {AlternateLocalizedString(@"Bible DVD: Romans", @"Bible DVD Publication Name"),   PublicationTypeDVDBible}


,   {AlternateLocalizedString(@"   DVD", @"Publication Type and Seperator in the Publication Picker"),   PublicationTypeHeading}
,   {AlternateLocalizedString(@"DVD: Bible Teach", @"DVD Publication Name"),   PublicationTypeDVDBook}
,   {AlternateLocalizedString(@"DVD: Family Happiness", @"DVD Publication Name"),   PublicationTypeDVDBook}
,   {AlternateLocalizedString(@"DVD: Worship God", @"DVD Publication Name"),   PublicationTypeDVDBook}
,   {AlternateLocalizedString(@"DVD: Great Teacher", @"DVD Publication Name"),   PublicationTypeDVDBook}
,   {AlternateLocalizedString(@"DVD: Bible Stories", @"DVD Publication Name"),   PublicationTypeDVDBook}
,   {AlternateLocalizedString(@"DVD: Greatest Man", @"DVD Publication Name"),   PublicationTypeDVDBook}
,   {AlternateLocalizedString(@"DVD: God's Friend", @"DVD Publication Name"),   PublicationTypeDVDBook}
,   {AlternateLocalizedString(@"DVD: Require", @"DVD Publication Name"),   PublicationTypeDVDBook}
,   {AlternateLocalizedString(@"DVD: Keep on the Watch", @"DVD Publication Name"),   PublicationTypeDVDBook}
,   {AlternateLocalizedString(@"DVD: Spirits of the dead", @"DVD Publication Name"),   PublicationTypeDVDBook}
,   {AlternateLocalizedString(@"DVD: When someone you love dies", @"DVD Publication Name"),   PublicationTypeDVDBook}
,   {AlternateLocalizedString(@"DVD: Knowledge", @"DVD Publication Name"),   PublicationTypeDVDBook}
,   {AlternateLocalizedString(@"DVD: Sing Praises Vol 1&2", @"DVD Publication Name"),   PublicationTypeDVDBook}
,   {AlternateLocalizedString(@"DVD: Sing Praises Vol 3", @"DVD Publication Name"),   PublicationTypeDVDBook}

,   {AlternateLocalizedString(@"DVD: Noah/David", @"DVD Publication Name"),   PublicationTypeDVDNotCount}
,   {AlternateLocalizedString(@"DVD Drama: Pursue Goals", @"DVD Publication Name"),   PublicationTypeDVDNotCount}
,   {AlternateLocalizedString(@"DVD Drama: Bore Witness", @"DVD Publication Name"),   PublicationTypeDVDNotCount}
,   {AlternateLocalizedString(@"DVD Drama: Troublesome Times/Boldly Witnessing", @"DVD Publication Name"),   PublicationTypeDVDNotCount}
,   {AlternateLocalizedString(@"DVD Drama: Submit to Authority", @"DVD Publication Name"),   PublicationTypeDVDNotCount}
,   {AlternateLocalizedString(@"DVD Drama: Respect Authority", @"DVD Publication Name"),   PublicationTypeDVDNotCount}

,   {AlternateLocalizedString(@"   BROCHURES", @"Publication Type and Seperator in the Publication Picker"),   PublicationTypeHeading}
,   {AlternateLocalizedString(@"Blood", @"Brochures Publication Name"),   PublicationTypeBrochure}
,   {AlternateLocalizedString(@"Book for All", @"Brochures Publication Name"),   PublicationTypeBrochure}
,   {AlternateLocalizedString(@"Divine Name", @"Brochures Publication Name"),   PublicationTypeBrochure}
,   {AlternateLocalizedString(@"Does God Care", @"Brochures Publication Name"),   PublicationTypeBrochure}
,   {AlternateLocalizedString(@"Education", @"Brochures Publication Name"),   PublicationTypeBrochure}
,   {AlternateLocalizedString(@"God's Friend", @"Brochures Publication Name"),   PublicationTypeBrochure}
,   {AlternateLocalizedString(@"Good Land", @"Brochures Publication Name"),   PublicationTypeBrochure}
,   {AlternateLocalizedString(@"Government", @"Brochures Publication Name"),   PublicationTypeBrochure}
,   {AlternateLocalizedString(@"Guidance of God", @"Brochures Publication Name"),   PublicationTypeBrochure}
,   {AlternateLocalizedString(@"Jehovah's Witnesses", @"Brochures Publication Name"),   PublicationTypeBrochure}
,   {AlternateLocalizedString(@"Lasting Peace", @"Brochures Publication Name"),   PublicationTypeBrochure}
,   {AlternateLocalizedString(@"Life on Earth", @"Brochures Publication Name"),   PublicationTypeBrochure}
,   {AlternateLocalizedString(@"Look!", @"Brochures Publication Name"),   PublicationTypeBrochure}
,   {AlternateLocalizedString(@"Nations", @"Brochures Publication Name"),   PublicationTypeBrochure}
,   {AlternateLocalizedString(@"Our Problems", @"Brochures Publication Name"),   PublicationTypeBrochure}
,   {AlternateLocalizedString(@"Purpose of Life", @"Brochures Publication Name"),   PublicationTypeBrochure}
,   {AlternateLocalizedString(@"Require", @"Brochures Publication Name"),   PublicationTypeBrochure}
,   {AlternateLocalizedString(@"Satisfying Life", @"Brochures Publication Name"),   PublicationTypeBrochure}
,   {AlternateLocalizedString(@"Spirits of the Dead", @"Brochures Publication Name"),   PublicationTypeBrochure}
,   {AlternateLocalizedString(@"Trinity", @"Brochures Publication Name"),   PublicationTypeBrochure}
,   {AlternateLocalizedString(@"Watch!", @"Brochures Publication Name"),   PublicationTypeBrochure}
,   {AlternateLocalizedString(@"When Someone Dies", @"Brochures Publication Name"),   PublicationTypeBrochure}
,   {AlternateLocalizedString(@"When We Die", @"Brochures Publication Name"),   PublicationTypeBrochure}
,   {AlternateLocalizedString(@"Why Worship God", @"Brochures Publication Name"),   PublicationTypeBrochure}
,   {AlternateLocalizedString(@"World Without War", @"Brochures Publication Name"),   PublicationTypeBrochure}


,   {AlternateLocalizedString(@"   TRACTS", @"Publication Type and Seperator in the Publication Picker"),   PublicationTypeHeading}
,   {AlternateLocalizedString(@"A Peaceful New World-Will It Come?", @"Tracts Publication Name"),   PublicationTypeTract}
,   {AlternateLocalizedString(@"Does Fate Rule Our Lives", @"Tracts Publication Name"),   PublicationTypeTract}
,   {AlternateLocalizedString(@"Hellfire-Is It Part of Divine Justice?", @"Tracts Publication Name"),   PublicationTypeTract}
,   {AlternateLocalizedString(@"How to Find the Road to Paradise", @"Tracts Publication Name"),   PublicationTypeTract}
,   {AlternateLocalizedString(@"Immortal Spirit", @"Tracts Publication Name"),   PublicationTypeTract}
,   {AlternateLocalizedString(@"Jehovah's Witnesses-What Do They Believe?", @"Tracts Publication Name"),   PublicationTypeTract}
,   {AlternateLocalizedString(@"The Greatest Name", @"Tracts Publication Name"),   PublicationTypeTract}
,   {AlternateLocalizedString(@"Who Are Jehovah's Witnesses?", @"Tracts Publication Name"),   PublicationTypeTract}
,   {AlternateLocalizedString(@"Comfort for the Depressed", @"Tracts Publication Name"),   PublicationTypeTract}
,   {AlternateLocalizedString(@"Enjoy Family Life", @"Tracts Publication Name"),   PublicationTypeTract}
,   {AlternateLocalizedString(@"Jehovah-Who Is He?", @"Tracts Publication Name"),   PublicationTypeTract}
,   {AlternateLocalizedString(@"Jesus Christ-Who Is He?", @"Tracts Publication Name"),   PublicationTypeTract}
,   {AlternateLocalizedString(@"Know the Bible", @"Tracts Publication Name"),   PublicationTypeTract}
,   {AlternateLocalizedString(@"Peaceful New World", @"Tracts Publication Name"),   PublicationTypeTract}
,   {AlternateLocalizedString(@"Suffering to End", @"Tracts Publication Name"),   PublicationTypeTract}
,   {AlternateLocalizedString(@"What Do Jehovah's Witnesses Believe?", @"Tracts Publication Name"),   PublicationTypeTract}
,   {AlternateLocalizedString(@"What Hope for Dead Loved Ones?", @"Tracts Publication Name"),   PublicationTypeTract}
,   {AlternateLocalizedString(@"Who Really Rules the World?", @"Tracts Publication Name"),   PublicationTypeTract}
,   {AlternateLocalizedString(@"Why You Can Trust the Bible", @"Tracts Publication Name"),   PublicationTypeTract}
,   {AlternateLocalizedString(@"Will This World Survive?", @"Tracts Publication Name"),   PublicationTypeTract}
};

+ (NSString *)watchtower
{
	return([[NSBundle mainBundle] localizedStringForKey:PUBLICATIONS[0].name value:PUBLICATIONS[0].name table:@""]);
}

+ (NSString *)awake
{
	return([[NSBundle mainBundle] localizedStringForKey:PUBLICATIONS[1].name value:PUBLICATIONS[1].name table:@""]);
}



// Delegate Methods

#define PUBLICATION_WIDTH 140
#define MONTH_WIDTH 53
#define YEAR_WIDTH 58
#define DAY_WIDTH 45

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    VERY_VERBOSE(NSLog(@"pickerView: widthForComponent:%d", component);)
	
    // based on what we already know about the publication, lets
    // setup the width of the picker.
    switch([self numberOfComponentsInPickerView: pickerView])
    {
			
        case 1:
            // if there is only one publication, then set the only column to 
            // the width of the entire picker
            return(PUBLICATION_WIDTH + MONTH_WIDTH + YEAR_WIDTH + DAY_WIDTH);
        case 3:
            // if there are three columns then the "last two" columns are combined
            // to make the picker look like it is adjusting for the years
            switch(component)
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
            switch(component)
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
		default:
			return(1);
	}
}
#if 0
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    VERY_VERBOSE(NSLog(@"pickerView: viewForRow:%d inComponent:%d", row, component);)
	
	UILabel *cell = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, [self pickerView:pickerView widthForComponent:component] - 6.0, 44.0)] autorelease];
	cell.autoresizingMask  = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	
#warning need to setup height	
    // if this is the publicaiton column then just display the
    // publication name
    if(component == 0)
    {
		
		cell.textAlignment = UITextAlignmentLeft;
		cell.text = [[NSBundle mainBundle] localizedStringForKey:PUBLICATIONS[row].name value:PUBLICATIONS[row].name table:@""];
    }
    else
    {
        // if the publicaiton is a watchtower or an awake, then
        // we have to display the month year and possibly date of
        // the publication
        switch(_publication)
        {
            case 0: // Watchtower Jan 2007 15
                switch(component)
				{
					case 1: // Month
					{
						cell.textAlignment = UITextAlignmentCenter;
						cell.text = [[NSBundle mainBundle] localizedStringForKey:MONTHS[row] value:MONTHS[row] table:@""];
						break;
					}	
					case 2: // Year
						cell.textAlignment = UITextAlignmentLeft;
						// we offset the _year from 1900
						cell.text = [NSString stringWithFormat:@"%d", row+YEAR_OFFSET];
						break;
						
					case 3: // day
						cell.textAlignment = UITextAlignmentCenter;
						// when the watchtower was bimonthly, it came out on the 1st and 15th
						cell.text = row == 0 ? @"1" : @"15";
						break;
				}
                break;
                
            case 1: // Awake Jan 2007 15
                switch(component)
				{
					case 1: // Month
					{
						cell.textAlignment = UITextAlignmentCenter;
						cell.text = [[NSBundle mainBundle] localizedStringForKey:MONTHS[row] value:MONTHS[row] table:@""];
						break;
					}	
					case 2: // Year
						cell.textAlignment = UITextAlignmentLeft;
						// we offset the _year from 1900
						cell.text = [NSString stringWithFormat:@"%d", row+YEAR_OFFSET];
						break;
						
					case 3: // day
						cell.textAlignment = UITextAlignmentCenter;
						// when the awake was bimonthly, it came out on the 8th and 22nd
						cell.text = row == 0 ? @"8" : @"22";
						break;
				}
				break;
        }
    }    
	return(cell);
}
#else
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    VERY_VERBOSE(NSLog(@"pickerView: viewForRow:%d inComponent:%d", row, component);)
	NSString *ret = @"";
	
    // if this is the publicaiton column then just display the
    // publication name
    if(component == 0)
    {
		ret = [[NSBundle mainBundle] localizedStringForKey:PUBLICATIONS[row].name value:PUBLICATIONS[row].name table:@""];
    }
    else
    {
        // if the publicaiton is a watchtower or an awake, then
        // we have to display the month year and possibly date of
        // the publication
        switch(_publication)
        {
            case 0: // Watchtower Jan 2007 15
                switch(component)
				{
					case 1: // Month
						ret = [[NSBundle mainBundle] localizedStringForKey:MONTHS[row] value:MONTHS[row] table:@""];
						break;
					case 2: // Year
						// we offset the _year from 1900
						ret = [NSString stringWithFormat:@"%d", row+YEAR_OFFSET];
						break;
						
					case 3: // day
						// when the watchtower was bimonthly, it came out on the 1st and 15th
						ret = row == 0 ? @"1" : @"15";
						break;
				}
                break;
                
            case 1: // Awake Jan 2007 15
                switch(component)
				{
					case 1: // Month
					{
						ret = [[NSBundle mainBundle] localizedStringForKey:MONTHS[row] value:MONTHS[row] table:@""];
						break;
					}	
					case 2: // Year
						// we offset the _year from 1900
						ret = [NSString stringWithFormat:@"%d", row+YEAR_OFFSET];
						break;
						
					case 3: // day
						// when the awake was bimonthly, it came out on the 8th and 22nd
						ret = row == 0 ? @"8" : @"22";
						break;
				}
				break;
        }
    }    
	return(ret);
}
#endif
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // save off the previous information before the change (we need to know this
    // because we should not look for the year if the previous publication was not
    // a watchtower or an awake
    int previousPublication = _publication;
    int previousYear = _year;
    int previousMonth = _month;
    int previousDay = _day;
	
    VERBOSE(NSLog(@"publication:%@ month:%@ year:%d day:%d", PUBLICATIONS[_publication], MONTHS[_month], _year + YEAR_OFFSET, _day);)
	
	// what is the new publication?
	if(component == 0)
	{
		_publication = row;
    }
    // if the previous publication was a watchtower or awake, then 
    // lets get at the month year and possibly date of the magazine
    if(previousPublication == 0 || previousPublication == 1)
    {
        if(component == 1)
			_month = row;
        if(component == 2)
			_year = row;
        // if the previous year selected was < 2008 then the watchtower would have had a date 
        // column in the picker
        if(component == 3 && previousPublication == 0 && previousYear + YEAR_OFFSET < 2008)
            _day = row;
        
        // if the previous year selected was < 2007 then the awake would have had a date 
        // column in the picker
        if(component == 3 && previousPublication == 1 && previousYear + YEAR_OFFSET < 2007)
            _day = row;
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
        [pickerView reloadAllComponents];

        if(component == 0 &&
		   [PUBLICATIONS[_publication].type isEqualToString:PublicationTypeHeading])
		{
			// skip past the heading
			_publication++;
			[self selectRow: _publication inComponent: 0 animated: YES];
		}

		// the watchtower and awake are the only ones that have a subscription
		// type of placement, all others are just books that do not have a release
		// time
		if(_publication == 0 || _publication == 1)
		{
			[self selectRow: _month inComponent: 1 animated: NO];
			[self selectRow: _year inComponent: 2 animated: NO];
			
			// in 2008, the watchtower went from bimonthly to monthly
			if(_publication == 0 && _year + YEAR_OFFSET < 2008)
				[self selectRow: _day inComponent: 3 animated: NO];
			
			// in 2007, the awake went from bimonthly to monthly
			if(_publication == 1 && _year + YEAR_OFFSET < 2007)
				[self selectRow: _day inComponent: 3 animated: NO];
		}
    }
}

// DataSource Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
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
    VERY_VERBOSE(NSLog(@"numberOfComponentsInPickerView: %d", ret);)
    return(ret);
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    VERY_VERBOSE(NSLog(@"pickerView: numberOfRowsInComponent: %d", component);)
	
    // col 0 is the publications column
    if(component == 0)
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
                switch(component)
                {
                    case 1: // Month
                        return(12);
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

- (void) dealloc
{
    VERY_VERBOSE(NSLog(@"PublicationPicker: dealloc");)
	
    [super dealloc];
}

- (id) initWithFrame: (CGRect)rect
{
    // initalize the data to the current date
	NSDate *date = [NSDate date];
	NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit) fromDate:date];
    // set the default publication to be the watchtower this month and year
	int month = [dateComponents month];
	int year = [dateComponents year];
    int day = 1;
	
    return([self initWithFrame:rect publication:[PublicationPickerView watchtower] year:year month:month day:day]);
}

// initialize this view given the curent configuration
- (id) initWithFrame: (CGRect)rect publication: (NSString *)publication year: (int)year month: (int)month day: (int)day;
{
    if((self = [super initWithFrame: rect])) 
    {
        int i;
        DEBUG(NSLog(@"PublicationPickerView initWithFrame: publication:\"%@\" year:%d month:%d day:%d", publication, year, month, day);)

		self.showsSelectionIndicator = YES;
        // we are managing the picker's data and display
		self.delegate = self;
		self.dataSource = self;
		
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
			NSDate *date = [NSDate date];
			NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit) fromDate:date];
            // set the default publication to be the watchtower this month and year
            _year = [dateComponents year] - YEAR_OFFSET;
            _month = [dateComponents month] - 1;
            _day = 0; // 1st or 22nd
        }
		
		[self reloadAllComponents];
		// select the publication
		[self selectRow: _publication inComponent: 0 animated: NO];
		
		// the watchtower and awake are the only ones that have a subscription
		// type of placement, all others are just books that do not have a release
		// time
		if(_publication == 0 || _publication == 1)
		{
			[self selectRow: _month inComponent: 1 animated: NO];
			[self selectRow: _year inComponent: 2 animated: NO];
			
			// in 2008, the watchtower went from bimonthly to monthly
			if(_publication == 0 && _year + YEAR_OFFSET < 2008)
				[self selectRow: _day inComponent: 3 animated: NO];
			
			// in 2007, the awake went from bimonthly to monthly
			if(_publication == 1 && _year + YEAR_OFFSET < 2007)
				[self selectRow: _day inComponent: 3 animated: NO];
		}
		[self setSoundsEnabled:NO];
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
    return([NSString stringWithString:PUBLICATIONS[_publication].name]);
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
            return([NSString stringWithFormat:NSLocalizedString(@"%@ %@ %d, %d", @"This is a representation for the watchtower or awake when it was published on the 1, 15 and 2, 22 respectively, like Watchtower March 15, 2001, please use %1$@ as the magazine type %2$@ as the month %3$d as the day of the month and %4$d as the year"),
							                                    [[NSBundle mainBundle] localizedStringForKey:PUBLICATIONS[_publication].name value:PUBLICATIONS[_publication].name table:@""], 
																[[NSBundle mainBundle] localizedStringForKey:MONTHS[month-1] value:MONTHS[month-1] table:@""], 
																day, 
																year ]);
        else
            return([NSString stringWithFormat:NSLocalizedString(@"%@ %@ %d", @"This is a representation for the watchtower or awake when it was published on the 1, 15 and 2, 22 respectively, like Watchtower March 15, 2001, please use %1$@ as the magazine type %2$@ as the month and %3$d as the year"),
			                                                    [[NSBundle mainBundle] localizedStringForKey:PUBLICATIONS[_publication].name value:PUBLICATIONS[_publication].name table:@""], 
																[[NSBundle mainBundle] localizedStringForKey:MONTHS[month-1] value:MONTHS[month-1] table:@""], 
																year ]);
    }
    else
    {
        return([NSString stringWithString: [[NSBundle mainBundle] localizedStringForKey:PUBLICATIONS[_publication].name value:PUBLICATIONS[_publication].name table:@""]] );
    }
}

// string of the publication name
- (NSString *)publicationType
{
    return([NSString stringWithString:PUBLICATIONS[_publication].type]);
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
	BOOL ret = [super respondsToSelector:selector];
    VERY_VERBOSE(NSLog(@"%s respondsToSelector: %s ? %s", __FILE__, selector, ret ? "YES" : "NO");)
    return ret;
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

