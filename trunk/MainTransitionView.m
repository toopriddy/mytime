//
//  MainTransitionView.m
//  MyTime
//
//  Created by Brent Priddy on 3/4/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import "App.h"
#import "MainTransitionView.h"


@implementation MainTransitionView

- (id) initWithFrame: (CGRect)rect
{
    if((self = [super initWithFrame: rect])) 
    {
		[self setDelegate:self];
	}
	
	return(self);
}

- (void)dealloc
{
	[_alertSheetText release];
	[super dealloc];
}

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
	[sheet dismissAnimated:YES];
}

- (void)transition:(int)transition fromView:(UIView*)fromView toView:(UIView *)toView withAlert:(NSString *)alert
{
	[_alertSheetText release];
	_alertSheetText = alert;
	[_alertSheetText retain];
	[self transition:transition fromView:fromView toView:toView];
}
- (void)transitionViewDidComplete:(UITransitionView *)view
{
	if(_alertSheetText)
	{
		UIAlertSheet *alertSheet = [[UIAlertSheet alloc] initWithFrame:CGRectMake(0, 240, 320, 240)];
		[alertSheet setTitle:@"Did you know?"];
		[alertSheet setBodyText:_alertSheetText];
		[alertSheet addButtonWithTitle:@"OK"];
		[alertSheet setDefaultButton: [[alertSheet buttons] objectAtIndex: 0]];
		[alertSheet setDelegate:self];
		// 0: grey with grey and black buttons
		// 1: black background with grey and black buttons
		// 2: transparent black background with grey and black buttons
		// 3: grey transparent background
		[alertSheet setAlertSheetStyle: 0];
		[alertSheet presentSheetFromAboveView:self];		
		[_alertSheetText release];
		_alertSheetText = nil;
	}
}


- (BOOL)respondsToSelector:(SEL)selector
{
	VERY_VERBOSE(NSLog(@"MainTransitionView respondsToSelector: %s", selector);)
	return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
	VERY_VERBOSE(NSLog(@"MainTransitionView methodSignatureForSelector: %s", selector);)
	return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
	VERY_VERBOSE(NSLog(@"MainTransitionView forwardInvocation: %s", [invocation selector]);)
	[super forwardInvocation:invocation];
}

@end
