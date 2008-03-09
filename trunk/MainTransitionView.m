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
	}
	
	return(self);
}

- (void)setBounds:(CGRect)rect;
{
	NSLog(@"(%f, %f) height=%f width=%f", rect.origin.x, rect.origin.y, rect.size.height, rect.size.width);
	[super setBounds:rect];
//	[[[self subviews] objectAtIndex:0] setBounds:rect];
}


- (BOOL)respondsToSelector:(SEL)selector
{
	NSLog(@"MainTransitionView respondsToSelector: %s", selector);
	return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
	NSLog(@"MainTransitionView methodSignatureForSelector: %s", selector);
	return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
	NSLog(@"MainTransitionView forwardInvocation: %s", [invocation selector]);
	[super forwardInvocation:invocation];
}

@end
