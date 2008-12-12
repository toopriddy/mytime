//
//  UITableViewMultilineTextCell.m
//  MyTime
//
//  Created by Brent Priddy on 9/20/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import "UITableViewMultilineTextCell.h"
#import "Settings.h"

@implementation UITableViewMultilineTextCell
@synthesize textView;


#define TITLE_LEFT_OFFSET 10
#define TITLE_TOP_OFFSET 6
#define TITLE_HEIGHT 30

#define VALUE_TOP_OFFSET 6
#define VALUE_HEIGHT 30

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier 
{
	if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) 
	{
		VERBOSE(NSLog(@"%s: %s %p", __FILE__, __FUNCTION__, self);)
		textView = nil;
		
		self.textView = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		textView.backgroundColor = [UIColor clearColor];
		textView.font = [UIFont systemFontOfSize:16];
#if 1
		textView.textColor = [UIColor colorWithRed:58.0/255.0 green:86.0/255.0 blue:138.0/255.0 alpha:1.0];
		textView.highlightedTextColor = [UIColor whiteColor];
#else
		textView.font = [UIFont boldSystemFontOfSize:16];
		textView.textColor = [UIColor blackColor];
#endif
		textView.text = @"";
		textView.textAlignment = UITextAlignmentLeft;
		textView.lineBreakMode = UILineBreakModeWordWrap;
		textView.numberOfLines = 0;

		[self.contentView addSubview: textView];
		[self setAutoresizesSubviews:YES];
	}
	return self;
}

- (void)dealloc
{
	self.textView = nil;
    VERBOSE(NSLog(@"%s: %s %p", __FILE__, __FUNCTION__, self);)
	[super dealloc];
}

- (void)setText:(NSString *)text
{
	textView.text = text;
	[self layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
	/*
	 Views are drawn most efficiently when they are opaque and do not have a clear background, so in newLabelForMainText: the labels are made opaque and given a white background.  To show selection properly, however, the views need to be transparent (so that the selection color shows through).  
    */
	[super setSelected:selected animated:animated];

	if(self.selectionStyle != UITableViewCellSelectionStyleNone)
	{
		if(selected)
		{
			textView.textColor = [UIColor whiteColor];
		}
		else
		{
#if 1
			textView.textColor = [UIColor colorWithRed:58.0/255.0 green:86.0/255.0 blue:138.0/255.0 alpha:1.0];
#else
			textView.textColor = [UIColor blackColor];
#endif
		}
	}
}

+ (CGFloat)heightForWidth:(CGFloat)width withText:(NSString *)text
{
	CGSize constraints;
	constraints.width = width;
	constraints.height = 10000000000.0;
	CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:constraints];
	return(size.height > 44 ? size.height + 10.0 : 44);
}

- (void)layoutSubviews 
{
    [super layoutSubviews];
    CGRect contentRect = [self.contentView bounds];
	CGRect originalContentRect = contentRect;
	
	float boundsX = contentRect.origin.x;
	float width = contentRect.size.width;
	if(contentRect.origin.x == 0.0) 
	{
		boundsX = 10.0;
		width -= 20;
	}
	
	CGRect frame;
	CGSize constraints;
	constraints.width = width;
	constraints.height = 10000000000.0;
	CGSize size = [textView.text sizeWithFont:textView.font constrainedToSize:constraints];
	if(size.height < contentRect.size.height)
	{
		size.height = contentRect.size.height; 
	}
	else
	{
		contentRect.size.height = size.height + 10.0;
	}
	frame = CGRectMake(boundsX, (contentRect.size.height - size.height)/2, width, size.height);
	[textView setFrame:frame];

	[self.contentView setBounds:contentRect];
	frame = self.frame;
	frame.size.height += contentRect.size.height - originalContentRect.size.height;
	self.frame = frame;
	[super layoutSubviews];
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
