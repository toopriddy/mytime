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
#import "PublicationView.h"
#import "App.h"
#import "MainView.h"
#import "NumberedPicker.h"

#define YEAR_OFFSET 1900
#define ARRAY_SIZE(a) (sizeof(a)/sizeof(a[0]))

@implementation PublicationView

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
	[_countPicker release];
	
    [super dealloc];
}

- (id) initWithFrame: (CGRect)rect
{
    return([self initWithFrame:rect showCount:NO]);
}


- (id) initWithFrame: (CGRect)rect showCount:(BOOL)showCount
{
    // initalize the data to the current date
	NSCalendarDate *now = [NSCalendarDate calendarDate];

    // set the default publication to be the watchtower this month and year
    int year = [now yearOfCommonEra];
    int month = [now monthOfYear];
    int day = 1;

    return([self initWithFrame:rect publication:[PublicationPicker watchtower] year:year month:month day:day showCount:showCount number:0]);
}

// initialize this view given the curent configuration
- (id) initWithFrame: (CGRect)rect publication: (NSString *)publication year: (int)year month: (int)month day: (int)day
{
    return([self initWithFrame:rect publication:publication year:year month:month day:day showCount:NO number:0]);
}

// initialize this view given the curent configuration
- (id) initWithFrame: (CGRect)rect publication: (NSString *)publication year: (int)year month: (int)month day: (int)day showCount:(BOOL)showCount number:(int)number
{
    if((self = [super initWithFrame: rect])) 
    {
        DEBUG(NSLog(@"PublicationView initWithFrame: publication:\"%@\" year:%d month:%d day:%d", publication, year, month, day);)

        _saveObject = nil;
        _cancelObject = nil;

        // make the navigation bar with
        // Cancel                    Save
        CGSize navSize = [UINavigationBar defaultSize];
        UINavigationBar *nav = [[[UINavigationBar alloc] initWithFrame: CGRectMake(0,0,rect.size.width, navSize.height)] autorelease];
        [nav setDelegate: self];
        [nav pushNavigationItem: [[[UINavigationItem alloc] initWithTitle:@"Select Publication"] autorelease] ];
		[nav setAutoresizingMask: kTopBarResizeMask];
		[nav setAutoresizesSubviews: YES];
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
        _picker = [[PublicationPicker alloc] initWithFrame: CGRectMake(0, navSize.height, rect.size.width, pickerSize.height)
											   publication:publication
													  year:year
													 month:month
													   day:day];
		[_picker setAutoresizingMask: kPickerResizeMask];
		[_picker setAutoresizesSubviews: YES];
		[_picker setSoundsEnabled:NO];

        pickerSize = [_picker bounds].size;
        VERY_VERBOSE(NSLog(@"CGRectMake: %f,%f", pickerSize.height, pickerSize.width);)

        // we are managing the picker's data and display
    	[self addSubview: _picker];
        pickerSize = [_picker bounds].size;

		if(showCount)
		{
#if 1			
#define LABEL_HEIGHT 20.0			
			UITextLabel *label = [[[UITextLabel alloc] initWithFrame:CGRectMake(0.0, navSize.height + pickerSize.height, rect.size.width, LABEL_HEIGHT)] autorelease];
			[self addSubview:label];
			[label setText:@"Number Placed:"];
			VERY_VERBOSE(NSLog(@"CGRectMake: %f,%f  %f,%f",                  0.0, navSize.height + pickerSize.height + LABEL_HEIGHT, rect.size.width, rect.size.height - navSize.height - pickerSize.height - LABEL_HEIGHT);)
			_countPicker = [[NumberedPicker alloc] initWithFrame: CGRectMake(0.0, navSize.height + pickerSize.height + LABEL_HEIGHT, rect.size.width, rect.size.height - navSize.height - pickerSize.height - LABEL_HEIGHT)
			
#else		
			VERY_VERBOSE(NSLog(@"CGRectMake: %f,%f  %f,%f",                  0.0, navSize.height + pickerSize.height, rect.size.width, rect.size.height - navSize.height - pickerSize.height);)
			_countPicker = [[NumberedPicker alloc] initWithFrame: CGRectMake(0.0, navSize.height + pickerSize.height, rect.size.width, rect.size.height - navSize.height - pickerSize.height)
#endif
															 min:1
															 max:200
														  number:number
														   title:@"Count:"];
			[_countPicker setSoundsEnabled:NO];
			[_countPicker setAutoresizingMask: kMainAreaResizeMask];
			[_countPicker setAutoresizesSubviews: YES];
			[self addSubview: _countPicker];
		}
		else
		{
			_countPicker = nil;
			VERY_VERBOSE(NSLog(@"CGRectMake: %f,%f  %f,%f", 0.0, navSize.height + pickerSize.height, rect.size.height - navSize.height - pickerSize.height, rect.size.width);)
			UITable *table = [[UITable alloc] initWithFrame: CGRectMake(0, navSize.height + pickerSize.height, rect.size.width, rect.size.height - navSize.height - pickerSize.height)];
			[table addTableColumn: [[[UITableColumn alloc] initWithTitle:@"Placed Publications" identifier:nil width:rect.size.width] autorelease]];
			[table setAutoresizingMask: kMainAreaResizeMask];
			[table setAutoresizesSubviews: YES];
			[self addSubview: table];
		}
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

- (PublicationPicker *)publicationPicker
{
	return(_picker);
}

- (int)count
{
    VERY_VERBOSE(NSLog(@"PublicationView count");)
	
	if(_countPicker)
		return([_countPicker number]);
	else
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

