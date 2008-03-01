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

    [super dealloc];

}

- (void) applicationDidFinishLaunching: (id) unused
{
    me = self;
    _rect = [UIHardware fullScreenApplicationContentRect];
    _window = [[UIWindow alloc] initWithContentRect: _rect];

	reorientationDuration = 0.35f;
	orientationDegrees = -1;

	[_window orderFront: self];
	[_window makeKey: self];
    [_window _setHidden: NO];

	_rect.origin.x = 0;
	_rect.origin.y = 0;

    _transitionView = [[UITransitionView alloc] initWithFrame: _rect];
    [_window setContentView: _transitionView];
    
    _mainView = [[MainView alloc] initWithFrame: _rect];
    [_transitionView transition:0 toView:_mainView]; 
	[self setUIOrientation: 1];

}


- (void)applicationSuspend:(GSEvent*)event
{
	[self saveData];
	[self terminate];
}

- (void) deviceOrientationChanged: (GSEvent*)event 
{
//	[self setUIOrientation: [UIHardware deviceOrientation:YES]];
}

static const int orientations[7] = {-1, 0, -1, 90, -90, -1, -1};

- (void) setUIOrientation: (unsigned int)o_code 
{
	DEBUG(NSLog(@"setUIOrientation: %d", o_code);)
	if (o_code > 6) 
		return;
	/* Degrees should technically be a float, but without integers here, rounding errors seem to screw up the UI over time.
		The compiler will automatically cast to a float when appropriate API calls are made. */
	int degrees = orientations[o_code];
	if (degrees == -1) 
		return;
	if (degrees == orientationDegrees) 
		return;
	if(orientationDegrees == -1)
		orientationDegrees = 0;
	
	/* Find the rect a fullscreen app would use under the new rotation... */
	bool landscape = (degrees == 90 || degrees == -90);
	struct CGSize size = [UIHardware mainScreenSize];
	float statusBar = [UIHardware statusBarHeight];
	
	if (landscape) 
	{
		size.width -= statusBar;
	} 
	else 
	{
		size.height -= statusBar;
	}
	
	FullKeyBounds.origin.x = (degrees == 90) ? statusBar : 0;
	FullKeyBounds.origin.y = 0;
	FullKeyBounds.size = size;
	
	FullContentBounds.origin.x = FullContentBounds.origin.y = 0;
	FullContentBounds.size = (landscape) ? CGSizeMake(size.height, size.width) : size; 
	
	/* Now that our member variable is set, we try to apply these changes to the key view, if present.
		If this routine is called before there is a key view, it will still set the rects and move the statusbar. */
	UIWindow *key = [UIWindow keyWindow];
	if (key) 
	{
		
		[self setStatusBarMode:[self statusBarMode]
			       orientation: (degrees == 180) ? 0 : degrees
			          duration:reorientationDuration 
					   fenceID:0 
					 animation:3];
	
		UIView *content = [key contentView];
		if (content) 
		{
			struct CGSize oldSize = [content bounds].size;

			[UIView beginAnimations: nil];
				[UIView setAnimationDuration: reorientationDuration];
		
				[content setBounds: FullContentBounds];
				[_mainView setBounds: FullContentBounds];
				[content resizeSubviewsWithOldSize: oldSize];
				[key setBounds: FullKeyBounds];
				[content setRotationBy: degrees - orientationDegrees];
			[UIView endAnimations];
			
		} 
		else 
		{
			[key setBounds: FullKeyBounds];
		}
	} 
	else 
	{
		[self setStatusBarMode: [self statusBarMode] 
		           orientation: (degrees == 180) ? 0 : degrees 
				      duration:0.0f];
	}
	orientationDegrees = degrees;
	[super setUIOrientation: o_code];
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
