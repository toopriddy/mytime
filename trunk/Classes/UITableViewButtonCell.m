//
//  UITableViewButtonCell.m
//  MyTime
//
//  Created by Brent Priddy on 7/6/09.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "UITableViewButtonCell.h"

@implementation UITableViewButtonCell

@synthesize button;


#define TITLE_LEFT_OFFSET 10
#define TITLE_TOP_OFFSET 6
#define TITLE_HEIGHT 30

#define VALUE_TOP_OFFSET 6
#define VALUE_HEIGHT 30
- (id)initWithTitle:(NSString *)title image:(UIImage *)image imagePressed:(UIImage *)imagePressed darkTextColor:(BOOL)darkTextColor reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) 
	{
		self.button = [UIButton buttonWithType:UIButtonTypeCustom];
		self.button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		self.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		self.button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		[self.button setTitle:title forState:UIControlStateNormal];	
		if (darkTextColor)
		{
			[self.button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		}
		else
		{
			[self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		}
		button.titleLabel.font = [UIFont boldSystemFontOfSize:20];
		
		UIImage *newImage = [image stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		[self.button setBackgroundImage:newImage forState:UIControlStateNormal];
		
		UIImage *newPressedImage = [imagePressed stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		[self.button setBackgroundImage:newPressedImage forState:UIControlStateHighlighted];
				
		// in case the parent view draws with a custom color or gradient, use a transparent color
		self.button.backgroundColor = [UIColor clearColor];

		[self.contentView addSubview:self.button];
	}
	return self;
}

- (void)dealloc
{
	self.button = nil;
    VERBOSE(NSLog(@"%s: %s %p", __FILE__, __FUNCTION__, self);)
	[super dealloc];
}

- (void)layoutSubviews 
{
    [super layoutSubviews];
	self.backgroundView = nil;
	self.button.frame = self.contentView.bounds;
}


- (BOOL)respondsToSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"%s respondsToSelector: %s self=%p", __FILE__, selector, self);)
    return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"%s methodSignatureForSelector: %s self=%p", __FILE__, selector, self);)
    return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    VERY_VERBOSE(NSLog(@"%s forwardInvocation: %s self=%p", __FILE__, [invocation selector], self);)
    [super forwardInvocation:invocation];
}



@end
