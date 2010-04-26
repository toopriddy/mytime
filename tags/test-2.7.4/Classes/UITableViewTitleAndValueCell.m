//
//  UITableViewTitleAndValueCell.m
//  MyTime
//
//  Created by Brent Priddy on 7/26/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "UITableViewTitleAndValueCell.h"
#import "Settings.h"

@implementation UITableViewTitleAndValueCell

@synthesize titleLabel;
@synthesize valueLabel;
@synthesize allowSelectionWhenNotEditing;
@synthesize allowSelectionWhenEditing;


#define TITLE_LEFT_OFFSET 10
#define TITLE_TOP_OFFSET 6
#define TITLE_HEIGHT 30

#define VALUE_TOP_OFFSET 6
#define VALUE_HEIGHT 30

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) 
	{
		allowSelectionWhenEditing = YES;
		allowSelectionWhenNotEditing = YES;
		
		VERBOSE(NSLog(@"%s: %s %p %p %p", __FILE__, __FUNCTION__, self, titleLabel, valueLabel);)
		titleLabel = nil;
		valueLabel = nil;
		self.titleLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		titleLabel.backgroundColor = [UIColor whiteColor];
		titleLabel.font = [UIFont boldSystemFontOfSize:16];
		titleLabel.textColor = [UIColor blackColor];
		titleLabel.highlightedTextColor = [UIColor whiteColor];
		titleLabel.text = @"";
		[self.contentView addSubview: titleLabel];

		self.valueLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		valueLabel.backgroundColor = [UIColor whiteColor];
		valueLabel.font = [UIFont systemFontOfSize:16];
		valueLabel.textColor = [UIColor colorWithRed:58.0/255.0 green:86.0/255.0 blue:138.0/255.0 alpha:1.0];
		valueLabel.highlightedTextColor = [UIColor whiteColor];
		valueLabel.text = @"";
		[self.contentView addSubview: valueLabel];
	}
	return self;
}

- (void)dealloc
{
	self.titleLabel = nil;
	self.valueLabel = nil;
    VERBOSE(NSLog(@"%s: %s %p", __FILE__, __FUNCTION__, self);)
	[super dealloc];
}

- (void)setAllowSelectionWhenEditing:(BOOL)enable
{
	allowSelectionWhenEditing = enable;
	if(self.editing)
	{
		if(enable)
		{
			self.selectionStyle = UITableViewCellSelectionStyleBlue;
		}
		else 
		{
			self.selectionStyle = UITableViewCellSelectionStyleNone;
		}
	}
}

- (void)setAllowSelectionWhenNotEditing:(BOOL)enable
{
	allowSelectionWhenNotEditing = enable;
	if(!self.editing)
	{
		if(enable)
		{
			self.selectionStyle = UITableViewCellSelectionStyleBlue;
		}
		else 
		{
			self.selectionStyle = UITableViewCellSelectionStyleNone;
		}
	}
}

- (void)willTransitionToState:(UITableViewCellStateMask)state
{
	[super willTransitionToState:state];
	if(state & UITableViewCellStateEditingMask)
	{
		if(self.allowSelectionWhenEditing)
		{
			self.selectionStyle = UITableViewCellSelectionStyleBlue;
		}
		else 
		{
			self.selectionStyle = UITableViewCellSelectionStyleNone;
		}
	}
	else 
	{
		if(self.allowSelectionWhenNotEditing)
		{
			self.selectionStyle = UITableViewCellSelectionStyleBlue;
		}
		else 
		{
			self.selectionStyle = UITableViewCellSelectionStyleNone;
		}
	}
}

- (void)updateLayout
{
	if(titleLabel.text == nil ||
	   [titleLabel.text isEqualToString:@""])
	{
		valueLabel.textAlignment = UITextAlignmentLeft;

		titleLabel.hidden = YES;
		valueLabel.hidden = NO;
	}
	else if(valueLabel.text == nil || 
			[valueLabel.text isEqualToString:@""])
	{
		titleLabel.textAlignment = UITextAlignmentLeft;

		titleLabel.hidden = NO;
		valueLabel.hidden = YES;
	}
	else
	{
		titleLabel.textAlignment = UITextAlignmentLeft;
		valueLabel.textAlignment = UITextAlignmentRight;
		titleLabel.hidden = NO;
		valueLabel.hidden = NO;
	}
}

- (void)setTitle:(NSString *)title
{
	titleLabel.text = title;
	[self updateLayout];
}

- (void)setValue:(NSString *)value
{
	valueLabel.text = value;
	[self updateLayout];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
}

- (void)layoutSubviews 
{
    [super layoutSubviews];
    CGRect contentRect = [self.contentView bounds];
	
	if(contentRect.origin.x == 0.0) 
	{
		contentRect.origin.x = 10.0;
		contentRect.size.width -= 20;
	}
	
	float boundsX = contentRect.origin.x;
	float width = contentRect.size.width;
	float height = contentRect.size.height;
	CGRect frame;

	if(titleLabel.text == nil ||
	   [titleLabel.text isEqualToString:@""])
	{
		CGSize size = [valueLabel.text sizeWithFont:valueLabel.font];
		frame = CGRectMake(boundsX, (height - size.height)/2, width, size.height);
		[valueLabel setFrame:frame];
	}
	else if(valueLabel.text == nil || 
			[valueLabel.text isEqualToString:@""])
	{
		CGSize size = [titleLabel.text sizeWithFont:titleLabel.font];
		frame = CGRectMake(boundsX, (height - size.height)/2, width, size.height);
		[titleLabel setFrame:frame];
	}
	else
	{
		CGSize size = [titleLabel.text sizeWithFont:titleLabel.font];
		frame = CGRectMake(boundsX, (height - size.height)/2, size.width, size.height);
		[titleLabel setFrame:frame];
		
		CGSize valueSize = [valueLabel.text sizeWithFont:valueLabel.font];
		float startingX;
		float valueWidth;
		if(boundsX + size.width > (boundsX + width - valueSize.width))
		{
			startingX = boundsX + size.width;
			valueWidth = contentRect.size.width - size.width - boundsX;
		}
		else
		{
			startingX = boundsX + width - valueSize.width;
			valueWidth = valueSize.width;
		}

		frame = CGRectMake(startingX, (height - valueSize.height)/2, valueWidth, valueSize.height);
		[valueLabel setFrame:frame];
	}
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
