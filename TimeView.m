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

@implementation TimeView

- (void)dealloc
{
	[_table release];
	
	[super dealloc];
}


- (id) initWithFrame: (CGRect)rect settings:(NSMutableDictionary *) settings
{
    if((self = [super initWithFrame: rect])) 
    {
        DEBUG(NSLog(@"CallView initWithFrame:");)

		_timeEntries = [[NSMutableArray alloc] initWithArray:[settings objectForKey:SettingsTimeEntries]];
		[settings setObject:_timeEntries forKey:SettingsTimeEntries];

        _rect = rect;   
        // make the navigation bar 
        CGSize s = [UINavigationBar defaultSize];
        _navigationBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0,0,rect.size.width, s.height)];
        [_navigationBar setDelegate: self];
        [self addSubview: _navigationBar]; 

		// 0 = gray
		// 1 = red
		// 2 = left arrow
		// 3 = blue
		[_navigationBar pushNavigationItem: [[[UINavigationItem alloc] initWithTitle:@"Time"] autorelease] ];
		if([settings objectForKey:SettingsTimeStartDate] == nil)
		{
			[_navigationBar showLeftButton:@"Add Time" withStyle:0 rightButton:@"Start Time" withStyle:3];
		}
		else
		{
			[_navigationBar showLeftButton:@"Add Time" withStyle:0 rightButton:@"Stop Time" withStyle:1];
		}
        
        _table = [[UITable alloc] initWithFrame: CGRectMake(0, s.height, rect.size.width, rect.size.height - s.height)];
		[_table addTableColumn: [[[UITableColumn alloc] initWithTitle:@"Times" identifier:nil width: rect.size.width] autorelease]];
        [self addSubview: _table];
        [_table setDelegate: self];
        [_table setDataSource: self];
		[_table setSeparatorStyle: 1];
		[_table enableRowDeletion: YES animated:YES];
		[_table reloadData];
    }
    
    return(self);
}


/******************************************************************
 *
 *   NAVIGATION BAR
 *   1 left button                                0 right button
 ******************************************************************/
- (void)navigationBar:(UINavigationBar*)nav buttonClicked:(int)button
{
	DEBUG(NSLog(@"navigationBar: buttonClicked:%s", button == 0? "Start/Stop time" : "Add Time");)

	switch(button)
	{
		case 1: // Add Time
			break;
		
		case 0: // start/stop time
		{
			NSMutableDictionary *settings = [[App getInstance] getSavedData];
			if([settings objectForKey:SettingsTimeStartDate] == nil)
			{
				[settings setObject:[NSCalendarDate calendarDate] forKey:SettingsTimeStartDate];
				[[App getInstance] saveData];
				// 0 = gray
				// 1 = red
				// 2 = left arrow
				// 3 = blue
				[nav showLeftButton:@"Add Time" withStyle:0 rightButton:@"Stop Time" withStyle:1];
			}
			else
			{
				// we found a saved start date, lets see how much time there was between then and now
				NSCalendarDate *date = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:[[settings objectForKey:SettingsTimeStartDate] timeIntervalSinceReferenceDate]] autorelease];	
				NSCalendarDate *now = [NSCalendarDate calendarDate];
				
				int minutes = [now timeIntervalSinceDate:date]/60.0;
				if(minutes > 0)
				{
					NSMutableDictionary *entry = [[[NSMutableDictionary alloc] init] autorelease];

					[entry setObject:date forKey:SettingsTimeEntryDate];
					[entry setObject:[[[NSNumber alloc] initWithInt:minutes] autorelease] forKey:SettingsTimeEntryMinutes];
					[_timeEntries insertObject:entry atIndex:0];
				
					[_table reloadData];
				}
				[settings removeObjectForKey:SettingsTimeStartDate];
				[[App getInstance] saveData];

				[nav showLeftButton:@"Add Time" withStyle:0 rightButton:@"Start Time" withStyle:3];
			}
			break;
		}
	}
}


/******************************************************************
 *
 *   TABLE DELEGATE FUNCTIONS
 *
 ******************************************************************/

- (int)numberOfRowsInTable:(UITable*)table
{
	int count = [_timeEntries count];
    DEBUG(NSLog(@"numberOfRowsInTable: %d", count);)
	return(count);
}

- (UITableCell*)table:(UITable*)table cellForRow:(int)row column:(UITableColumn *)column
{
    DEBUG(NSLog(@"table: cellForRow: %d", row);)
	id cell = [[[UIImageAndTextTableCell alloc] init] autorelease];
	
	NSMutableDictionary *entry = [_timeEntries objectAtIndex:row];

	NSNumber *time = [entry objectForKey:SettingsTimeEntryMinutes];

	NSCalendarDate *date = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:[[entry objectForKey:SettingsTimeEntryDate] timeIntervalSinceReferenceDate]] autorelease];	
	[cell setTitle:[date descriptionWithCalendarFormat:@"%a %b %d"]];

	CGSize s = CGSizeMake( [column width], [table rowHeight] );
	UITextLabel* label = [[[UITextLabel alloc] initWithFrame: CGRectMake(200,0,s.width,s.height)] autorelease];
	float bgColor[] = { 0,0,0,0 };
	[label setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];

	int minutes = [time intValue];
	int hours = minutes / 60;
	minutes %= 60;
	if(hours && minutes)
		[label setText:[NSString stringWithFormat:@"%d hours %d minutes", hours, minutes]];
	else if(hours)
		[label setText:[NSString stringWithFormat:@"%d hours", hours]];
	else if(minutes)
		[label setText:[NSString stringWithFormat:@"%d minutes", minutes]];
	
	[cell addSubview: label];

	return cell;
}

-(BOOL)table:(UITable*)table showDisclosureForRow:(int)row
{
    DEBUG(NSLog(@"table: showDisclosureForRow");)
    return(NO);
}

-(BOOL)table:(UITable*)table canDeleteRow:(int)row
{
    DEBUG(NSLog(@"table: canDeleteRow");)
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
