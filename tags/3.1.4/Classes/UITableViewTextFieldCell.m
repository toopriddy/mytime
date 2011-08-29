//
//  UITableViewTextFieldCell.m
//  MyTime
//
//  Created by Brent Priddy on 7/27/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "UITableViewTextFieldCell.h"

#define TITLE_LEFT_OFFSET 10
#define TITLE_TOP_OFFSET 6
#define TITLE_HEIGHT 30

#define VALUE_TOP_OFFSET 6
#define VALUE_HEIGHT 30

@implementation UITableViewTextFieldCell

@synthesize textField;
@synthesize nextKeyboardResponder;
@synthesize titleLabel;
@synthesize valueLabel;
@synthesize delegate;
@synthesize observeEditing;
@synthesize allowSelectionWhenNotEditing;
@synthesize allowSelectionWhenEditing;

- (id)initWithStyle:(UITableViewCellStyle)style textField:(UITextField *)field reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) 
	{
		allowSelectionWhenEditing = YES;
		allowSelectionWhenNotEditing = YES;
		
		VERBOSE(NSLog(@"%s: %s %p", __FILE__, __FUNCTION__, self);)
		self.selected = NO;
		observeEditing = NO;
		
		self.titleLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		titleLabel.backgroundColor = [UIColor whiteColor];
		titleLabel.textColor = [UIColor blackColor];
		titleLabel.textAlignment = UITextAlignmentLeft;
		titleLabel.font = [UIFont boldSystemFontOfSize:16];
		[self.contentView addSubview:titleLabel];
		
		self.textField = field;
		textField.backgroundColor = [UIColor whiteColor];
		textField.textColor = [UIColor darkGrayColor];
		textField.textColor = [UIColor colorWithRed:58.0/255.0 green:86.0/255.0 blue:138.0/255.0 alpha:1.0];
		textField.font = [UIFont systemFontOfSize:16];
		textField.delegate = self;
		textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		[self.contentView addSubview:self.textField];
		
		self.valueLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		valueLabel.backgroundColor = [UIColor whiteColor];
		valueLabel.font = [UIFont systemFontOfSize:16];
		valueLabel.textColor = [UIColor colorWithRed:58.0/255.0 green:86.0/255.0 blue:138.0/255.0 alpha:1.0];
		valueLabel.highlightedTextColor = [UIColor whiteColor];
		valueLabel.text = textField.text;
		[self.contentView addSubview: valueLabel];
	}
	return self;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	UITextField *field = [[[UITextField alloc] initWithFrame:CGRectZero] autorelease];
	[self initWithStyle:style textField:field reuseIdentifier:reuseIdentifier];
	return self;
}

- (void)dealloc
{
    VERBOSE(NSLog(@"%s: %s %p", __FILE__, __FUNCTION__, self);)

	self.textField.delegate = nil;
	
	self.nextKeyboardResponder = nil;
	self.textField = nil;
	self.titleLabel = nil;
	self.valueLabel = nil;
	self.delegate = nil;
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

- (void)setNextKeyboardResponder:(UIResponder *)next
{
	textField.returnKeyType = next == NULL ? UIReturnKeyDone : UIReturnKeyNext;
	[nextKeyboardResponder release];
	nextKeyboardResponder = next;
	[nextKeyboardResponder retain];
}

- (BOOL)textFieldShouldReturn:(UITextField *)thetextField 
{
	[thetextField resignFirstResponder];
	if(delegate && [delegate respondsToSelector:@selector(tableViewTextFieldCell:selected:)])
	{
		[delegate tableViewTextFieldCell:self selected:NO];
	}
	if(nextKeyboardResponder)
	{
		[nextKeyboardResponder becomeFirstResponder];
	}
	return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	if(delegate && [delegate respondsToSelector:@selector(tableViewTextFieldCell:shouldChangeCharactersInRange:replacementString:)])
	{
		return [delegate tableViewTextFieldCell:self shouldChangeCharactersInRange:range replacementString:string];
	}
	
	return YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	UIColor *backgroundColor = selected || animated ? [UIColor clearColor] : [UIColor whiteColor];

	textField.backgroundColor = backgroundColor;
	textField.highlighted = selected;
	textField.opaque = !selected;
	titleLabel.backgroundColor = backgroundColor;
	titleLabel.highlighted = selected;
	titleLabel.opaque = !selected;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if(delegate && [delegate respondsToSelector:@selector(tableViewTextFieldCell:selected:)])
	{
		[delegate tableViewTextFieldCell:self selected:YES];
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if(delegate && [delegate respondsToSelector:@selector(tableViewTextFieldCell:selected:)])
	{
		[delegate tableViewTextFieldCell:self selected:NO];
	}
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	valueLabel.text = textField.text;
	[super setEditing:editing animated:animated];
	if(!editing)
		[self.textField resignFirstResponder];
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
		CGSize size = [@"Ig" sizeWithFont:textField.font];
		size.height = 31;
		frame = CGRectMake(boundsX, (height - size.height)/2, width, size.height);
		textField.frame = frame;
		valueLabel.frame = frame;
		textField.selected = NO;
		titleLabel.hidden = YES;

		valueLabel.textColor = [UIColor blackColor];
		valueLabel.textAlignment = UITextAlignmentLeft;
		valueLabel.font = [UIFont boldSystemFontOfSize:16];
	}
	else
	{
		CGSize size = [titleLabel.text sizeWithFont:titleLabel.font];
		size.height = 31;
		frame = CGRectMake(boundsX , (height - size.height)/2, size.width, size.height);
		[titleLabel setFrame:frame];
		titleLabel.hidden = NO;

		CGSize textSize = [@"Ig" sizeWithFont:textField.font];
		textSize.height = 31;
		frame = CGRectMake(boundsX + TITLE_LEFT_OFFSET + size.width, (height - textSize.height)/2, width - size.width - TITLE_LEFT_OFFSET, textSize.height);
		textField.frame = frame;
		valueLabel.frame = frame;
	}

	if(self.editing || !observeEditing)
	{
		self.selectionStyle = self.allowSelectionWhenEditing ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
		textField.hidden = NO;
		textField.enabled = YES;
		valueLabel.hidden = YES;
	}
	else
	{
		self.selectionStyle = self.allowSelectionWhenNotEditing ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
		textField.hidden = YES;
		textField.enabled = NO;
		valueLabel.hidden = NO;
	}

}

- (void)setText:(NSString *)theText
{
	titleLabel.text = theText;
}

- (NSString *)text
{
	return(titleLabel.text);
}

- (void)setValue:(NSString *)theText
{
	textField.text = theText;
	valueLabel.text = theText;
}

- (NSString *)value
{
	return textField.text;
}
@end
