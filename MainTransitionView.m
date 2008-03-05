//
//  MainTransitionView.m
//  MyTime
//
//  Created by Brent Priddy on 3/4/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MainTransitionView.h"


@implementation MainTransitionView


- (void)setBounds:(CGRect)rect;
{
	NSLog(@"(%f, %f) height=%f width=%f", rect.origin.x, rect.origin.y, rect.size.height, rect.size.width);
	[super setBounds:rect];
	[[[self subviews] objectAtIndex:0] setBounds:rect];
}

@end
