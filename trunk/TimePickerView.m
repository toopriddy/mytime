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
#import "TimePickerView.h"
#import "App.h"

@implementation TimePickerView

- (void)navigationBar:(UINavigationBar*)nav buttonClicked:(int)button
{
    DEBUG(NSLog(@"navigationBar: buttonClicked:%s", button ? "cancel" : "save");)
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
    DEBUG(NSLog(@"TimePickerView: dealloc");)
    [_datePicker release];
    [_timePicker release];

    [super dealloc];
}

- (id) initWithFrame: (CGRect)rect
{
    return([self initWithFrame:rect date:nil]);
}

// initialize this view given the curent configuration
- (id) initWithFrame: (CGRect)rect date: (NSCalendarDate *)date
{
    if((self = [super initWithFrame: rect])) 
    {
        _saveObject = nil;
        _cancelObject = nil;

		if(date == nil)
		{
			// initalize the data to the current date
			date = [NSCalendarDate calendarDate];
		}


        // make the navigation bar with
        // Cancel                    Save
        CGSize navSize = [UINavigationBar defaultSize];
        UINavigationBar *nav = [[[UINavigationBar alloc] initWithFrame: CGRectMake(0,0,rect.size.width, navSize.height)] autorelease];
        [nav setDelegate: self];
        [nav pushNavigationItem: [[[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"Select Time", @"Select Time")] autorelease] ];
		[nav setAutoresizingMask: kTopBarResizeMask];
		[nav setAutoresizesSubviews: YES];
        [self addSubview: nav]; 
        // 0 = greay
        // 1 = red
        // 2 = left arrow
        // 3 = blue
        [nav showLeftButton:NSLocalizedString(@"Cancel", @"Cancel") withStyle:2 rightButton:NSLocalizedString(@"Done", @"Done") withStyle:3];
        navSize = [nav bounds].size;
        
        // make a picker for the publications
        _datePicker = [[UIDatePicker alloc] initWithFrame: CGRectMake(0, navSize.height, rect.size.width, (rect.size.height - navSize.height)/2)];
		[_datePicker setDate:date];
		
    	CGSize pickerSize = [_datePicker bounds].size;
        VERY_VERBOSE(NSLog(@"CGRectMake: %f,%f", pickerSize.height, pickerSize.width);)

        // we are managing the picker's data and display
    	[_datePicker setDelegate: self];
		// 0: hour, min, AM/PM
		// 1: Month, date, year   
		// 2: date(day of week, month, date), hor, min, am/pm
		// 3: hours, mins
		[_datePicker setDatePickerMode:1];
		[_datePicker setAutoresizingMask: kPickerResizeMask];
		[_datePicker setAutoresizesSubviews: YES];
		[_datePicker setSoundsEnabled:NO];
    	[self addSubview: _datePicker];


        _timePicker = [[UIDatePicker alloc] initWithFrame: CGRectMake(0, navSize.height + pickerSize.height, rect.size.width, (rect.size.height - navSize.height)/2)];
		// init to display one hour zero minutes
		[_timePicker setDate:[[[NSCalendarDate alloc] initWithYear: 1978 month:7 day:26 hour:1 minute:0 second:0 timeZone:nil] autorelease]];
		// 0: hour, min, AM/PM
		[_timePicker setAutoresizingMask: kPickerResizeMask];
		[_timePicker setAutoresizesSubviews: YES];
		// 1: Month, date, year   
		// 2: date(day of week, month, date), hor, min, am/pm
		// 3: hours, mins
		[_timePicker setDatePickerMode:3];
		[_timePicker setSoundsEnabled:NO];
    	[self addSubview: _timePicker];
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

// date
- (NSCalendarDate *)date
{
    return([_datePicker date]);
}

- (int)minutes
{
    return([_timePicker hour]*60 + [_timePicker minute]);
}



- (BOOL)respondsToSelector:(SEL)selector
{
	VERY_VERBOSE(NSLog(@"TimePickerView respondsToSelector: %s", selector);)
	return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
	VERY_VERBOSE(NSLog(@"TimePickerView methodSignatureForSelector: %s", selector);)
	return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
	VERY_VERBOSE(NSLog(@"TimePickerView forwardInvocation: %s", [invocation selector]);)
	[super forwardInvocation:invocation];
}


@end

