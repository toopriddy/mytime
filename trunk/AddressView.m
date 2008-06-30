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
#import <UIKit/UISwitchControl.h>
#import <WebCore/WebFontCache.h>
#import "App.h"
#import "AddressView.h"

#define PLACEMENT_OBJECT_COUNT 2


@implementation AddressView

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

- (void)setFocus: (NSTimer *)timer
{
	UIPreferencesTextTableCell *cell = [timer userInfo];
	[cell becomeFirstResponder];
}

- (void) dealloc
{
    DEBUG(NSLog(@"AddressView: dealloc");)
    [_navigationBar release];
    [_table release];
    [_streetNumber release];
    [_street release];
    [_city release];
    [_state release];

    [super dealloc];
}

- (id) initWithFrame: (CGRect)rect
{
    return([self initWithFrame: rect streetNumber:@"" street:@"" city:@"" state:@""]);
}

- (id) initWithFrame: (CGRect)rect streetNumber:(NSString *)streetNumber street:(NSString *)street city:(NSString *)city state:(NSString *)state;
{
    if((self = [super initWithFrame: rect])) 
    {
        DEBUG(NSLog(@"AddressView initWithFrame: %p", self);)

        _cancelObject = nil;
        _saveObject = nil;

        _rect = rect;   
        // make the navigation bar with
        //                        +
        CGSize s = [UINavigationBar defaultSize];
        _navigationBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0,0,rect.size.width, s.height)];
        [_navigationBar setDelegate: self];
		[_navigationBar setAutoresizingMask: kTopBarResizeMask];
		[_navigationBar setAutoresizesSubviews: YES];
        [self addSubview: _navigationBar]; 
        // 0 = greay
        // 1 = red
        // 2 = left arrow
        // 3 = blue
        [_navigationBar showLeftButton:NSLocalizedString(@"Cancel", @"Cancel NavigationBar Button") withStyle:2 rightButton:NSLocalizedString(@"Done", @"Done/Save NavigationBar Button") withStyle:3];
        [_navigationBar pushNavigationItem: [[[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"Call Address", @"Address title for address form")] autorelease] ];
		
        _streetNumber = [[UIPreferencesTextTableCell alloc] init];
        [_streetNumber setValue:streetNumber];
        [[_streetNumber textField] setPlaceholder:NSLocalizedString(@"House Number", @"House Number")];
		[[_streetNumber textField] setPreferredKeyboardType: 1]; // numbers
        [[_streetNumber textField] setAutoCorrectionType:1]; //no correction

        _street = [[UIPreferencesTextTableCell alloc] init];
        [_street setValue:street];
        [[_street textField] setPlaceholder:NSLocalizedString(@"Street", @"Street")];
		
        _city = [[UIPreferencesTextTableCell alloc] init];
        [_city setValue:city];
        [[_city textField] setPlaceholder:NSLocalizedString(@"City", @"City")];
        
		_state = [[UIPreferencesTextTableCell alloc] init];
        [_state setValue:state];
        [[_state textField] setPlaceholder:NSLocalizedString(@"State", @"State")];
        [[_state textField] setAutoCapsType:3]; //caps lock
        [[_state textField] setAutoCorrectionType:1]; //no correction
		
        

		// 0 regular
		// 1 numbers
		// 2 telephone
		// 3 web
		// 4 normal with a numberpad as the numbers
		// 5 seethrough black keyboard normal
		// 6 telephone without +
		// 7 seethrough black telephone without +
		// 8 email address keyboard with space @ . and _ - +
		// 9 email address keyboard with @ . .com
		//[[text textField] setPreferredKeyboardType: 0];
		
        _table = [[UIPreferencesTable alloc] initWithFrame: CGRectMake(0, s.height, rect.size.width, rect.size.height - s.height)];
        [self addSubview: _table];
        [_table setDelegate: self];
        [_table setDataSource: self];
        [_table reloadData];
		[_table setAutoresizingMask: kMainAreaResizeMask];
		[_table setAutoresizesSubviews: YES];

		[NSTimer scheduledTimerWithTimeInterval:.5
										 target:self 
									   selector:@selector(setFocus:) 
									   userInfo:_streetNumber
										repeats:NO];
		
    }
    
    return(self);
}

- (void)textFieldDidBecomeFirstResponder:(id)textField 
{
//	[self setKeyboardVisible:YES];
}

- (void)textFieldDidResignFirstResponder:(id)textField 
{
	
}

- (NSString *)streetNumber
{
	NSString *ret = [_streetNumber value];
    return(ret == nil ? @"" : ret);
}

- (NSString *)street
{
	NSString *ret = [_street value];
    return(ret == nil ? @"" : ret);
}

- (NSString *)city
{
	NSString *ret = [_city value];
    return(ret == nil ? @"" : ret);
}

- (NSString *)state
{
	NSString *ret = [_state value];
    return(ret == nil ? @"" : ret);
}

- (int) numberOfGroupsInPreferencesTable: (UIPreferencesTable *)table 
{
    VERBOSE(NSLog(@"numberOfGroupsInPreferencesTable:");)
    return(1);
}

- (int) preferencesTable: (UIPreferencesTable *)table numberOfRowsInGroup: (int) group 
{
    VERBOSE(NSLog(@"preferencesTable: numberOfRowsInGroup:%d", group);)

    return(4);
}

- (UIPreferencesTableCell *)preferencesTable:(UIPreferencesTable *)aTable cellForGroup:(int)group
{
    VERBOSE(NSLog(@"preferencesTable: cellForGroup:%d", group);)
    return(nil);
} 

- (float)preferencesTable: (UIPreferencesTable *)table heightForRow: (int)row inGroup:(int)group withProposedHeight: (float)proposed 
{
    VERBOSE(NSLog(@"preferencesTable: heightForRow:%d inGroup:%d withProposedHeight:%f", row, group, proposed);)
    return proposed;
}

- (BOOL)preferencesTable:(UIPreferencesTable *)aTable isLabelGroup:(int)group 
{
    VERBOSE(NSLog(@"preferencesTable: isLabelGroup:%d", group);)
    return(NO);
}


- (UIPreferencesTableCell *)preferencesTable: (UIPreferencesTable *)table cellForRow: (int)row inGroup: (int)group 
{
    VERBOSE(NSLog(@"preferencesTable: cellForRow:%d inGroup:%d", row, group);)
    if(group == 0)
    {
        switch(row) 
        {
            // House Number
            case 0:
				return(_streetNumber);
            case 1:
				return(_street);
            case 2:
				return(_city);
            case 3:
				return(_state);
        }
    }
	return(nil);
}



- (BOOL)respondsToSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"AddressView respondsToSelector: %s", selector);)
    return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"AddressView methodSignatureForSelector: %s", selector);)
    return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    VERY_VERBOSE(NSLog(@"AddressView forwardInvocation: %s", [invocation selector]);)
    [super forwardInvocation:invocation];
}

@end






