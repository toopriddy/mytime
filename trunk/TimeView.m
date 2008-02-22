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

const char* svn_version(void);

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
        
        _table = [[UITable alloc] initWithFrame: CGRectMake(0, s.height, rect.size.width, rect.size.height - s.height)];
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
 *   TABLE DELEGATE FUNCTIONS
 *
 ******************************************************************/


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
				[cell setShowSelection:NO];
			}
			else if(_thisMonthBooks && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:@"Books"];
				[cell setValue:[NSString stringWithFormat:@"%d", _thisMonthBooks]];
				[cell setShowSelection:NO];
			}
			else if(_thisMonthBroshures && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:@"Broshures"];
				[cell setValue:[NSString stringWithFormat:@"%d", _thisMonthBroshures]];
				[cell setShowSelection:NO];
			}
			else if(_thisMonthMagazines && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:@"Magazines"];
				[cell setValue:[NSString stringWithFormat:@"%d", _thisMonthMagazines]];
				[cell setShowSelection:NO];
			}
			else if(_thisMonthReturnVisits && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:@"Return Visits"];
				[cell setValue:[NSString stringWithFormat:@"%d", _thisMonthReturnVisits]];
				[cell setShowSelection:NO];
			}
			else if(_thisMonthBibleStudies && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:@"Bible Studies"];
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
				[cell setTitle:@"Hours"];
				[cell setValue:[NSString stringWithFormat:@"%d", _lastMonthHours]];
				[cell setShowSelection:NO];
			}
			else if(_lastMonthBooks && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:@"Books"];
				[cell setValue:[NSString stringWithFormat:@"%d", _lastMonthBooks]];
				[cell setShowSelection:NO];
			}
			else if(_lastMonthBroshures && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:@"Broshures"];
				[cell setValue:[NSString stringWithFormat:@"%d", _lastMonthBroshures]];
				[cell setShowSelection:NO];
			}
			else if(_lastMonthMagazines && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:@"Magazines"];
				[cell setValue:[NSString stringWithFormat:@"%d", _lastMonthMagazines]];
				[cell setShowSelection:NO];
			}
			else if(_lastMonthReturnVisits && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:@"Return Visits"];
				[cell setValue:[NSString stringWithFormat:@"%d", _lastMonthReturnVisits]];
				[cell setShowSelection:NO];
			}
			else if(_lastMonthBibleStudies && row-- == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:@"Bible Studies"];
				[cell setValue:[NSString stringWithFormat:@"%d", _lastMonthBibleStudies]];
				[cell setShowSelection:NO];
			}
			break;
		
		case 2:
			if(row == 0)
			{
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setTitle:@"MyTime Build Version"];
				[cell setValue:[NSString stringWithFormat:@"%s", svn_version()]];
				[cell setShowSelection:NO];
			}
    }

    // [ cell setShowSelection: NO ];
    return(cell);
}


@end
