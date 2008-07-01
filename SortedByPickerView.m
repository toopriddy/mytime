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
#import "SortedByPickerView.h"
#import "MainView.h"
#import "App.h"

#define ARRAY_SIZE(a) (sizeof(a)/sizeof(a[0]))

ViewEntry VIEWS[] = {
    {SortByStreet,  VIEW_SORTED_BY_STREET}
,   {SortByDate,    VIEW_SORTED_BY_DATE}
};


@implementation SortedByPickerView

// how many columns should be in the picker
- (int)numberOfColumnsInPickerView: (UIPickerView*)p
{
    return(1);
}

// given a column how many rows should be in the column
- (int) pickerView:(UIPickerView*)p numberOfRowsInColumn:(int)col
{
    VERY_VERBOSE(NSLog(@"pickerView: numberOfRowsInColumn: %d", col);)

    // col 0 is the publications column
	return(ARRAY_SIZE(VIEWS));
}

// given a column and a row get the cell for the table
- (id) pickerView:(UIPickerView*)p tableCellForRow:(int)row inColumn:(int)col
{
    VERY_VERBOSE(NSLog(@"pickerView: tableCellForRow: %d inColumn:%d", row, col);)
	id cell = [[[UIImageAndTextTableCell alloc] init] autorelease];

	[cell setAlignment: 0];
	[cell setTitle: VIEWS[row].name];

	return(cell);
}

// set the Picker to the current data values
-(void)pickerViewLoaded: (UIPickerView*)p
{
    VERY_VERBOSE(NSLog(@"pickerViewLoaded: ");)

    // select the publication
	[p selectRow: _entry inColumn: 0 animated: NO];
}


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
    DEBUG(NSLog(@"SortedByPickerView: dealloc");)
    [_picker release];

    [super dealloc];
}

// initialize this view given the curent configuration
- (id) initWithFrame: (CGRect)rect value: (NSString *)value title: (NSString *)title
{
    if((self = [super initWithFrame: rect])) 
    {
        _saveObject = nil;
        _cancelObject = nil;
		
		int i;
		for(i = 0; i < ARRAY_SIZE(VIEWS); ++i)
		{
			if([value isEqual:VIEWS[i].name])
			{
				_entry = i;
			}
		}

        // make the navigation bar with
        // Cancel                    Save
        CGSize navSize = [UINavigationBar defaultSize];
        UINavigationBar *nav = [[[UINavigationBar alloc] initWithFrame: CGRectMake(0,0,rect.size.width, navSize.height)] autorelease];
        [nav setDelegate: self];
        [nav pushNavigationItem: [[[UINavigationItem alloc] initWithTitle:title] autorelease] ];
		[nav setAutoresizingMask: kTopBarResizeMask];
		[nav setAutoresizesSubviews: YES];
        [self addSubview: nav]; 
        // 0 = greay
        // 1 = red
        // 2 = left arrow
        // 3 = blue
        [nav showLeftButton:NSLocalizedString(@"Cancel", @"Cancel NavigationBar Button") withStyle:2 rightButton:NSLocalizedString(@"Done", @"Done/Save NavigationBar Button") withStyle:3];
        navSize = [nav bounds].size;
        
        // make a picker for the publications
    	CGSize pickerSize = [UIDatePicker defaultSize];
        VERY_VERBOSE(NSLog(@"CGRectMake: %f,%f", pickerSize.height, pickerSize.width);)
        _picker = [[UIPickerView alloc] initWithFrame: CGRectMake(0, navSize.height, rect.size.width, pickerSize.height)];
		
        pickerSize = [_picker bounds].size;
        VERY_VERBOSE(NSLog(@"CGRectMake: %f,%f", pickerSize.height, pickerSize.width);)

        // we are managing the picker's data and display
    	[_picker setDelegate: self];
		[_picker setAutoresizingMask: kPickerResizeMask];
		[_picker setAutoresizesSubviews: YES];
    	[self addSubview: _picker];

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
		[table setAutoresizingMask: kMainAreaResizeMask];
		[table setAutoresizesSubviews: YES];
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
- (NSString *)value
{
    return(VIEWS[[_picker selectedRowForColumn: 0]].name);
}

- (BOOL)respondsToSelector:(SEL)selector
{
	VERY_VERBOSE(NSLog(@"SortedByPickerView respondsToSelector: %s", selector);)
	return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
	VERY_VERBOSE(NSLog(@"SortedByPickerView methodSignatureForSelector: %s", selector);)
	return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
	VERY_VERBOSE(NSLog(@"SortedByPickerView forwardInvocation: %s", [invocation selector]);)
	[super forwardInvocation:invocation];
}


@end

