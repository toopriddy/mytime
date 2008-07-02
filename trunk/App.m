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
#import "App.h"
#import "MainView.h"


@implementation App

App *me;

- (void)transition:(int)transition fromView:(UIView *)from toView:(UIView *)to
{
	if(from)
	{
		[to setFrame:[from frame]];
	}
    [_transitionView transition:transition fromView:from toView:to];
}

- (void)saveData
{
	[_mainView saveData];
}

- (NSMutableDictionary *)getSavedData
{
	return([_mainView getSavedData]);
}

- (void)setCalls:(NSMutableArray *)calls
{
	[_mainView setCalls:calls];
}

- (UIWindow *)window
{
	return(_window);
}

- (MainView *)mainView
{
	return(_mainView);
}

- (CGRect)rect
{
	return(_rect);
}

+ (App *)getInstance
{
    return(me);
}

-(void)dealloc
{
    [_window release];
    [_transitionView release];
	[_mainView release];

    [super dealloc];

}

- (void) applicationDidFinishLaunching: (id) unused
{
    me = self;
    _rect = [UIHardware fullScreenApplicationContentRect];
    _window = [[UIWindow alloc] initWithContentRect: _rect];

	[_window orderFront: self];
	[_window makeKey: self];
    [_window _setHidden: NO];

	[_window setAutoresizingMask: kMainAreaResizeMask];
	[_window setAutoresizesSubviews: YES];

	_rect.origin.x = 0;
	_rect.origin.y = 0;

    _transitionView = [[MainTransitionView alloc] initWithFrame: _rect];
	[_transitionView setAutoresizingMask: kMainAreaResizeMask];
	[_transitionView setAutoresizesSubviews: YES];
    [_window setContentView: _transitionView];
    
    [(_mainView = [MainView alloc]) initWithFrame: _rect];
    [_transitionView transition:0 toView:_mainView]; 
	[_mainView setAutoresizingMask: kMainAreaResizeMask];
	[_mainView setAutoresizesSubviews: YES];

	if([[self getSavedData] objectForKey:SettingsMainAlertSheetShown] == nil)
	{
		[[self getSavedData] setObject:@"" forKey:SettingsMainAlertSheetShown];

		UIAlertSheet *alertSheet = [[UIAlertSheet alloc] initWithFrame:CGRectMake(0, 240, 320, 240)];
		[alertSheet setTitle:NSLocalizedString(@"MyTime Info", @"Main allert sheet for new news, this might be presented as different information everytime that you upgrade")];
		[alertSheet setBodyText:NSLocalizedString(@"Thanks for using MyTime! Unfortunately you will not be able to run MyTime if you upgrade to iPhone/iTouch 2.0 software, you need to visit the application website on the 'More' View for backup instructions.  If you work for apple or know someone who does, then bug them to accept my Developer Program Application :P\nI am also looking for translators, MyTime has been used by many people in other countries. Interested in helping? Email me.", @"Information for the user to know what is going on with this and new releases")];
		[alertSheet setDelegate:self];
		// 0: grey with grey and black buttons
		// 1: black background with grey and black buttons
		// 2: transparent black background with grey and black buttons
		// 3: grey transparent background
		[alertSheet setAlertSheetStyle: 0];
		[alertSheet popupAlertAnimated:YES];		
	}
}


- (void)applicationSuspend:(GSEvent*)event
{
	[self saveData];
	[self terminate];
}

/* Here's the recommended method for doing custom stuff when the screen's rotation has changed... */
- (void) setUIOrientation: (int) o_code 
{
	NSLog(@"orientation changed %d", o_code);
	int oldAngle = orientationDegrees;
	[super setUIOrientation: o_code];
	if (oldAngle != orientationDegrees) 
	{
		/* We know that the display was reoriented, and can now take action. */
		[self vibrateForDuration: 1];
	}
}

- (void)rotateme: (NSNumber *)value
{
	int val = [value intValue];
	[self setUIOrientation: val];
	
	[self performSelector: @selector(rotateme:) 
			   withObject:[[NSNumber alloc] initWithInt:(val == 3 ? 1 : 3)] 
			   afterDelay:5];
}

- (id)init
{
	if((self = [super init])) 
    {
		NSLog(@"App init");
		[self setUIOrientation: [UIHardware deviceOrientation:YES]];

	}
#if 0
	[self performSelector: @selector(rotateme:) 
			   withObject:[[NSNumber alloc] initWithInt:3] 
			   afterDelay:5];
#endif
	return self;
}

- (BOOL)respondsToSelector:(SEL)selector
{
    VERBOSE(NSLog(@"App respondsToSelector: %s", selector);)
    return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    VERBOSE(NSLog(@"App methodSignatureForSelector: %s", selector);)
    return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    VERBOSE(NSLog(@"App forwardInvocation: %s", [invocation selector]);)
    [super forwardInvocation:invocation];
}


@end
