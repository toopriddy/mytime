//
//  UITableViewMultiTextFieldCell.m
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
#import "UITableViewMultiTextFieldCell.h"
#import "Settings.h"

#define TITLE_LEFT_OFFSET 10
#define TITLE_TOP_OFFSET 6
#define TITLE_HEIGHT 30

#define VALUE_TOP_OFFSET 6
#define VALUE_HEIGHT 30

@interface UITableViewMultiTextFieldCell ()
@property (nonatomic, retain) NSMutableArray *multiTextFields;
@end


@implementation UITableViewMultiTextFieldCell

@synthesize multiTextFields = _multiTextFields;
@synthesize nextKeyboardResponder = _nextKeyboardResponder;
@synthesize delegate;
@synthesize widths = _widths;
@synthesize allowSelectionWhenNotEditing;
@synthesize allowSelectionWhenEditing;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier textFieldCount:(int)textFieldCount
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) 
	{
		VERBOSE(NSLog(@"%s: %s %p", __FILE__, __FUNCTION__, self);)

		allowSelectionWhenEditing = YES;
		allowSelectionWhenNotEditing = YES;
		
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		self.multiTextFields = [NSMutableArray array];
//		NSLog(@"it is %p", self.multiTextFields);
		int i;
		for(i = 0; i < textFieldCount; i++)
		{
			UITextField *textField = [[[UITextField alloc] initWithFrame:CGRectZero] autorelease];
			textField.backgroundColor = [UIColor whiteColor];
			textField.font = [UIFont systemFontOfSize:16];
			textField.textColor = [UIColor colorWithRed:58.0/255.0 green:86.0/255.0 blue:138.0/255.0 alpha:1.0];
			textField.delegate = self;
			textField.returnKeyType = UIReturnKeyDone;
			textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
			[[self.multiTextFields lastObject] setReturnKeyType:UIReturnKeyNext];
			[self.multiTextFields addObject:textField];
			
			[self.contentView addSubview:textField];
		}
	}
	return self;
}

- (void)dealloc
{
    VERBOSE(NSLog(@"%s: %s %p", __FILE__, __FUNCTION__, self);)
	
	self.nextKeyboardResponder = nil;
	self.multiTextFields = nil;
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
	[[self.multiTextFields lastObject] setReturnKeyType:(next == NULL ? UIReturnKeyDone : UIReturnKeyNext)];
	[_nextKeyboardResponder release];
	_nextKeyboardResponder = next;
	[_nextKeyboardResponder retain];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
	[textField resignFirstResponder];
	if(delegate && [delegate respondsToSelector:@selector(tableViewTextFieldCell:selected:)])
	{
		[delegate tableViewMultiTextFieldCell:self textField:textField selected:NO];
	}
	if([self.multiTextFields indexOfObject:textField] + 1 == [self.multiTextFields count])
	{
		if(_nextKeyboardResponder)
		{
			[_nextKeyboardResponder becomeFirstResponder];
		}
	}
	else
	{
		[[self.multiTextFields objectAtIndex:[self.multiTextFields indexOfObject:textField] + 1] becomeFirstResponder];
	}
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	if(delegate && [delegate respondsToSelector:@selector(tableViewTextFieldCell:shouldChangeCharactersInRange:replacementString:)])
	{
		return [delegate tableViewMultiTextFieldCell:self textField:textField shouldChangeCharactersInRange:range replacementString:string];
	}
	
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if(delegate && [delegate respondsToSelector:@selector(tableViewTextFieldCell:selected:)])
	{
		[delegate tableViewMultiTextFieldCell:self textField:textField selected:YES];
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if(delegate && [delegate respondsToSelector:@selector(tableViewTextFieldCell:selected:)])
	{
		[delegate tableViewMultiTextFieldCell:self textField:textField selected:NO];
	}
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
	
	float xoffset = contentRect.origin.x;
	float width = contentRect.size.width;
	float height = contentRect.size.height;
	CGRect frame;

	int count = [self.multiTextFields count];
	float avaliableWidth = width - (count == 0 ? 0 : (TITLE_LEFT_OFFSET * (count - 1)));
	int i;
	for(i = 0; i < count; ++i)
	{
		UITextField *textField = [self.multiTextFields objectAtIndex:i];
		float thisWidth = avaliableWidth * [[_widths objectAtIndex:i] floatValue];
		CGSize textSize = [@"Ig" sizeWithFont:textField.font];
		textSize.height = 31;
		frame = CGRectMake(xoffset, (height - textSize.height)/2, thisWidth, textSize.height);
		[textField setFrame:frame];
		xoffset += TITLE_LEFT_OFFSET + thisWidth;
	}
}

- (UITextField *)textFieldAtIndex:(int)index
{
	return [self.multiTextFields objectAtIndex:index];
}

- (void)setText:(NSString *)theText atIndex:(int)index
{
	[[self.multiTextFields objectAtIndex:index] setText:theText];
}

- (NSString *)textAtIndex:(int)index
{
	return [[self.multiTextFields objectAtIndex:index] text];
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
