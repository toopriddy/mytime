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
#import "DatePickerView.h"
#import "App.h"

@implementation DatePickerView

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
    DEBUG(NSLog(@"DatePickerView: dealloc");)
    [_picker release];

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
        [nav pushNavigationItem: [[[UINavigationItem alloc] initWithTitle:@"Select Date"] autorelease] ];
        [self addSubview: nav]; 
        // 0 = greay
        // 1 = red
        // 2 = left arrow
        // 3 = blue
        [nav showLeftButton:@"Cancel" withStyle:2 rightButton:@"Done" withStyle:3];
        navSize = [nav bounds].size;
        
        // make a picker for the publications
    	CGSize pickerSize = [UIDatePicker defaultSize];
        VERY_VERBOSE(NSLog(@"CGRectMake: %f,%f", pickerSize.height, pickerSize.width);)
        _picker = [[UIDatePicker alloc] initWithFrame: CGRectMake(0, navSize.height, rect.size.width, pickerSize.height)];
		DEBUG(NSLog(@"picker's date %@\nmy date %@", [_picker date], date);)
		[_picker setDate:date];
		
        pickerSize = [_picker bounds].size;
        VERY_VERBOSE(NSLog(@"CGRectMake: %f,%f", pickerSize.height, pickerSize.width);)

        // we are managing the picker's data and display
    	[_picker setDelegate: self];   
    	[self addSubview: _picker];

        VERY_VERBOSE(NSLog(@"CGRectMake: %f,%f  %f,%f", 0.0, navSize.height + pickerSize.height, rect.size.height - navSize.height - pickerSize.height, rect.size.width);)
        UITable *table = [[UITable alloc] initWithFrame: CGRectMake(0, navSize.height + pickerSize.height, rect.size.width, rect.size.height - navSize.height - pickerSize.height)];
        [table addTableColumn: [[[UITableColumn alloc] initWithTitle:@"Placed Publications" identifier:nil width:rect.size.width] autorelease]];
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

// date
- (NSCalendarDate *)date
{
    return([_picker date]);
}


- (BOOL)respondsToSelector:(SEL)selector
{
	VERY_VERBOSE(NSLog(@"DatePickerView respondsToSelector: %s", selector);)
	return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
	VERY_VERBOSE(NSLog(@"DatePickerView methodSignatureForSelector: %s", selector);)
	return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
	VERY_VERBOSE(NSLog(@"DatePickerView forwardInvocation: %s", [invocation selector]);)
	[super forwardInvocation:invocation];
}


@end

