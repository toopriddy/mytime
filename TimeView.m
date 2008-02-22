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

@implementation TimeView

- (void)dealloc
{
	[_table release];
	
	[super dealloc];
}


- (id) initWithFrame: (CGRect)rect timeEntries:(NSMutableArray **)timeEntries
{
    if((self = [super initWithFrame: rect])) 
    {
        DEBUG(NSLog(@"CallView initWithFrame:");)

		_timeEntries = [[NSMutableArray alloc] initWithArray:*timeEntries];
		*timeEntries = _timeEntries;
		
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
    }
    
    return(self);
}


/******************************************************************
 *
 *   TABLE DELEGATE FUNCTIONS
 *
 ******************************************************************/

- (int)numberOfRowsInTable:(UITable*)table
{
	return [_timeEntries count];
}

- (UITableCell*)table:(UITable*)table cellForRow:(int)row column:(UITableColumn *)column
{
#if 0
	id cell = [[[UIImageAndTextTableCell alloc] init] autorelease];
	NSString *title = [[[NSString alloc] init] autorelease];
	NSString *houseNumber = [[_calls objectAtIndex:row] objectForKey:CallStreetNumber ];
	NSString *street = [[_calls objectAtIndex:row] objectForKey:CallStreet];

	if(houseNumber && [houseNumber length])
		title = [title stringByAppendingFormat:@"%@ ", houseNumber];
	if(street && [street length])
		title = [title stringByAppendingString:street];
	if([title length] == 0)
		title = @"(unknown street)";

	[cell setTitle: title];

	CGSize s = CGSizeMake( [column width], [table rowHeight] );
	UITextLabel* label = [[[UITextLabel alloc] initWithFrame: CGRectMake(200,0,s.width,s.height)] autorelease];
	float bgColor[] = { 0,0,0,0 };
	[label setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];
	[label setText:[[_calls objectAtIndex:row] objectForKey:CallName]];
	[cell addSubview: label];

	return cell;
#endif
return nil;
}

-(BOOL)table:(UITable*)table showDisclosureForRow:(int)row
{
    return(NO);
}

-(BOOL)table:(UITable*)table canDeleteRow:(int)row
{
	return YES;
}

-(void)table:(UITable*)table movedRow:(int)fromRow toRow:(int)toRow
{
    DEBUG(NSLog(@"table: movedRow");)
}

- (void)tableRowSelected:(NSNotification*)notification
{
    int row = [[notification object] selectedRow];
    DEBUG(NSLog(@"tableRowSelected: tableRowSelected row=%@ row%d", notification, row);)

    if(row < [_timeEntries count])
    {
    }
}



@end
