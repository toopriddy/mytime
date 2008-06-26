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
#import <GraphicsServices/GraphicsServices.h>
#import <UIKit/UIKit.h>
#import "TimeView.h"
#import "App.h"
#import "TimePickerView.h"

@implementation TimeTable

- (id)initWithFrame:(CGRect) rect timeEntries:(NSMutableArray*) timeEntries;
{
    if((self = [super initWithFrame: rect])) 
    {
		DEBUG(NSLog(@"TimeTable: initWithFrame");)
		_timeEntries = timeEntries;
		_offset = rect.origin;
		[self setSeparatorStyle: 1];
		[self enableRowDeletion: YES animated:YES];
		
	}
	return self;
}


- (int)swipe:(int)direction withEvent:(struct __GSEvent *)event;
{
	if ((direction == kSwipeDirectionRight) || (direction == kSwipeDirectionLeft) )
	{
        // The line below should be used with the newer toolchain.  If you
        // are using the older toolchain, comment this one out and use the
        // two commented out lines below.
        CGPoint point = GSEventGetLocationInWindow(event);

        // The next two lines are used with the old toolchain.  If you are
        // using the older toolchain uncomment these two lines and comment
        // out the line above.
//	CGRect rect = GSEventGetLocationInWindow(event);
//	CGPoint point = CGPointMake(rect.origin.x, rect.origin.y-50.0f); 

		point.x -= _offset.x;
		point.y -= _offset.y;
		
		int row = [self rowAtPoint:point];

		if( [[self visibleCellForRow:row column:0] isRemoveControlVisible] )
		{
			[[self visibleCellForRow:row column:0] _showDeleteOrInsertion:NO 
														   withDisclosure:NO 
																 animated:NO 
																 isDelete:NO 
													andRemoveConfirmation:NO];
		}
		else
		{
			[[self visibleCellForRow:row column:0] _showDeleteOrInsertion:YES
		                                                   withDisclosure:NO 
														         animated:YES 
																 isDelete:YES 
													andRemoveConfirmation:YES];
		}	
	}
	return [super swipe:direction withEvent:event];
}

- (BOOL)respondsToSelector:(SEL)selector
{
	VERY_VERBOSE(NSLog(@"TimeTable respondsToSelector: %s", selector);)
	return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
	VERY_VERBOSE(NSLog(@"TimeTable methodSignatureForSelector: %s", selector);)
	return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
	VERY_VERBOSE(NSLog(@"TimeTable forwardInvocation: %s", [invocation selector]);)
	[super forwardInvocation:invocation];
}
@end





@implementation TimeView

static int sortByDate(id v1, id v2, void *context)
{
	// ok, we need to compare the dates of the calls since we have
	// at least one call for each of 
	NSDate *date1 = [v1 objectForKey:SettingsTimeEntryDate];
	NSDate *date2 = [v2 objectForKey:SettingsTimeEntryDate];
	return(-[date1 compare:date2]);
}


// sort the time entries and remove the 3 month old entries
- (void)sort
{
	int i;
	NSArray *sortedArray = [_timeEntries sortedArrayUsingFunction:sortByDate context:NULL];
	[sortedArray retain];
	[_timeEntries setArray:sortedArray];
	[sortedArray release];

	// remove all entries that are older than 3 months
	NSCalendarDate *now = [[NSCalendarDate calendarDate] dateByAddingYears:0 months:-3 days:0 hours:0 minutes:0 seconds:0];
	int count = [_timeEntries count];
	for(i = 0; i < count; ++i)
	{
		NSLog(@"Comparing %d to %d", now, [[_timeEntries objectAtIndex:i] objectForKey:SettingsTimeEntryDate]);
		if([now compare:[[_timeEntries objectAtIndex:i] objectForKey:SettingsTimeEntryDate]] > 0)
		{
			[_timeEntries removeObjectAtIndex:i];
			--i;
			count = [_timeEntries count];
		}
	}
	
	[_table reloadData];
}

- (void)dealloc
{
	[_table release];
	
	[super dealloc];
}


- (id) initWithFrame: (CGRect)rect settings:(NSMutableDictionary *) settings
{
    if((self = [super initWithFrame: rect])) 
    {
        DEBUG(NSLog(@"TimeView initWithFrame:");)

		_timeEntries = [[NSMutableArray alloc] initWithArray:[settings objectForKey:SettingsTimeEntries]];
		[settings setObject:_timeEntries forKey:SettingsTimeEntries];

        _rect = rect;   
        // make the navigation bar 
        CGSize s = [UINavigationBar defaultSize];
        _navigationBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0,0,rect.size.width, s.height)];
        [_navigationBar setDelegate: self];
		[_navigationBar setAutoresizingMask: kTopBarResizeMask];
		[_navigationBar setAutoresizesSubviews: YES];
        [self addSubview: _navigationBar]; 

		// 0 = gray
		// 1 = red
		// 2 = left arrow
		// 3 = blue
		[_navigationBar pushNavigationItem: [[[UINavigationItem alloc] initWithTitle:@"Time"] autorelease] ];
		if([settings objectForKey:SettingsTimeStartDate] == nil)
		{
			[_navigationBar showLeftButton:@"Start Time" withStyle:3 rightButton:@"+" withStyle:3];
		}
		else
		{
			[_navigationBar showLeftButton:@"Stop Time" withStyle:1 rightButton:@"+" withStyle:3];
		}
		_table = [[TimeTable alloc] initWithFrame: CGRectMake(0, s.height, rect.size.width, rect.size.height - s.height) 
		                              timeEntries:_timeEntries];

		[_table addTableColumn: [[[UITableColumn alloc] initWithTitle:@"Times" identifier:nil width: rect.size.width] autorelease]];
        [_table setDelegate: self];
        [_table setDataSource: self];
		[_table setAutoresizingMask: kMainAreaResizeMask];
		[_table setAutoresizesSubviews: YES];
        [self addSubview: _table];
		[_table reloadData];
    }
    
    return(self);
}
/******************************************************************
 *
 *   DATE PICKER VIEW CALLBACKS
 *
 ******************************************************************/

- (void)addTimeCancelAction: (TimePickerView *)view
{
    DEBUG(NSLog(@"TimeView addTimeCancelAction:");)
    [[App getInstance] transition:9 fromView:view toView:[[App getInstance] mainView]];
}

- (void)addTimeSaveAction: (TimePickerView *)view
{
    DEBUG(NSLog(@"TimeView addTimeSaveAction:");)
    VERBOSE(NSLog(@"date is = %@, minutes %d", [view date], [view minutes]);)

	NSMutableDictionary *entry = [[[NSMutableDictionary alloc] init] autorelease];

	[entry setObject:[view date] forKey:SettingsTimeEntryDate];
	[entry setObject:[[[NSNumber alloc] initWithInt:[view minutes]] autorelease] forKey:SettingsTimeEntryMinutes];
	[_timeEntries insertObject:entry atIndex:0];
    
    [[App getInstance] transition:9 fromView:view toView:[[App getInstance] mainView]];

	[self sort];

	// save the data
	[[App getInstance] saveData];
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
		case 0: // Add Time
		{
			[self retain];
			TimePickerView *p = [[[TimePickerView alloc] initWithFrame:_rect] autorelease];

			// setup the callbacks for save or cancel
			[p setCancelAction: @selector(addTimeCancelAction:) forObject:self];
			[p setSaveAction: @selector(addTimeSaveAction:) forObject:self];
			[p setAutoresizingMask: kMainAreaResizeMask];
			[p setAutoresizesSubviews: YES];

			// transition from bottom up sliding ontop of the old view
			[[App getInstance] transition:8 fromView:[[App getInstance] mainView] toView:p];
			break;
		}
		
		case 1: // start/stop time
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
				[nav showLeftButton:@"Stop Time" withStyle:1 rightButton:@"+" withStyle:3];
				[_table reloadData];
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

				[nav showLeftButton:@"Start Time" withStyle:3 rightButton:@"+" withStyle:3];
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
    DEBUG(NSLog(@"numberOfRowsInTable:");)
	int count = [_timeEntries count];
    DEBUG(NSLog(@"numberOfRowsInTable: %d", count);)
	return(count);
}

- (UITableCell*)table:(UITable*)table cellForRow:(int)row column:(UITableColumn *)column
{
    DEBUG(NSLog(@"table: cellForRow: %d", row);)
	id cell = [[[UIImageAndTextTableCell alloc] init] autorelease];
	
	[cell setShowSelection:NO];
	
	NSMutableDictionary *entry = [_timeEntries objectAtIndex:row];

	NSNumber *time = [entry objectForKey:SettingsTimeEntryMinutes];

	NSCalendarDate *date = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:[[entry objectForKey:SettingsTimeEntryDate] timeIntervalSinceReferenceDate]] autorelease];	
	[cell setTitle:[date descriptionWithCalendarFormat:@"%a %b %d"]];

	CGSize s = CGSizeMake( [column width], [table rowHeight] );
	UITextLabel* label = [[[UITextLabel alloc] initWithFrame: CGRectMake(150,0,s.width,s.height)] autorelease];
	float bgColor[] = { 0,0,0,0 };
	[label setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];

	int minutes = [time intValue];
	int hours = minutes / 60;
	minutes %= 60;
	if(hours && minutes)
		[label setText:[NSString stringWithFormat:@"%d %s %d %s", hours, hours == 1 ? "hour" : "hours", minutes, minutes == 1 ? "minute" : "minutes"]];
	else if(hours)
		[label setText:[NSString stringWithFormat:@"%d %s", hours, hours == 1 ? "hour" : "hours"]];
	else if(minutes)
		[label setText:[NSString stringWithFormat:@"%d %s", minutes, minutes == 1 ? "minute" : "minutes"]];
	
	[cell addSubview: label];

	return cell;
}

-(BOOL)table:(UITable*)table deleteRow:(int)row
{
    DEBUG(NSLog(@"table: deleteRow: %d", row);)
	[_timeEntries removeObjectAtIndex:row];
	[[App getInstance] saveData];
	
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


- (BOOL)respondsToSelector:(SEL)selector
{
	VERY_VERBOSE(NSLog(@"TimeView respondsToSelector: %s", selector);)
	return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
	VERY_VERBOSE(NSLog(@"TimeView methodSignatureForSelector: %s", selector);)
	return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
	VERY_VERBOSE(NSLog(@"TimeView forwardInvocation: %s", [invocation selector]);)
	[super forwardInvocation:invocation];
}


@end
