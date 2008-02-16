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

	[_window orderFront: self];
	[_window makeKey: self];
    [_window _setHidden: NO];

	_rect.origin.x = 0;
	_rect.origin.y = 0;

    _transitionView = [[UITransitionView alloc] initWithFrame: _rect];
    [_window setContentView: _transitionView];
    
    _mainView = [[MainView alloc] initWithFrame: _rect];
    [_transitionView transition:0 toView:_mainView]; 
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
