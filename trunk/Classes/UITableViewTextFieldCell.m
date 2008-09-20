//
//  UITableViewTextFieldCell.m
//  MyTime
//
//  Created by Brent Priddy on 7/27/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import "UITableViewTextFieldCell.h"
#import "Settings.h"

#define TITLE_LEFT_OFFSET 10
#define TITLE_TOP_OFFSET 6
#define TITLE_HEIGHT 30

#define VALUE_TOP_OFFSET 6
#define VALUE_HEIGHT 30

@implementation UITableViewTextFieldCell

@synthesize textField;
@synthesize nextKeyboardResponder;
@synthesize indexPath;
@synthesize tableView;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier 
{
	if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) 
	{
		delegate = nil;
		self.nextKeyboardResponder = nil;
		self.selected = NO;
		
		self.tableView = nil;
		self.indexPath = nil;
		
		titleLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.textColor = [UIColor blackColor];
		[self.contentView addSubview:titleLabel];

		self.textField = [[[UITextField alloc] initWithFrame:CGRectZero] autorelease];
		textField.backgroundColor = [UIColor clearColor];
		textField.textColor = [UIColor darkGrayColor];
		textField.delegate = self;
		[self.contentView addSubview:self.textField];
	}
	return self;
}

- (void)dealloc
{
    DEBUG(NSLog(@"%s: dealloc", __FILE__);)
	
	self.nextKeyboardResponder = nil;
	self.textField = nil;
	self.tableView = nil;
	self.indexPath = nil;
	self.delegate = nil;
	[super dealloc];
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
	if(delegate)
	{
		[delegate tableViewTextFieldCell:self selected:NO];
	}
	if(nextKeyboardResponder)
	{
		[nextKeyboardResponder becomeFirstResponder];
	}
	return YES;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	if(selected)
	{
		[self.textField becomeFirstResponder];
	}
	else
	{
		[self.textField resignFirstResponder];
	}
		
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if(delegate)
	{
		[delegate tableViewTextFieldCell:self selected:YES];
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if(delegate)
	{
		[delegate tableViewTextFieldCell:self selected:NO];
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
	
	float boundsX = contentRect.origin.x;
	float width = contentRect.size.width;
	float height = contentRect.size.height;
	CGRect frame;

	if(titleLabel.text == nil ||
	   [titleLabel.text isEqualToString:@""])
	{
		CGSize size = [@"Ig" sizeWithFont:textField.font];
		frame = CGRectMake(boundsX, (height - size.height)/2, width, size.height);
		[textField setFrame:frame];
		textField.textColor = [UIColor colorWithRed:58.0/255.0 green:86.0/255.0 blue:138.0/255.0 alpha:1.0];
		textField.font = [UIFont systemFontOfSize:16];
		textField.selected = NO;
		titleLabel.hidden = YES;
	}
	else
	{
		CGSize size = [titleLabel.text sizeWithFont:titleLabel.font];
		frame = CGRectMake(boundsX , (height - size.height)/2, size.width, size.height);
		[titleLabel setFrame:frame];
		titleLabel.textAlignment = UITextAlignmentLeft;
		titleLabel.font = [UIFont boldSystemFontOfSize:16];
		titleLabel.hidden = NO;

		textField.font = [UIFont systemFontOfSize:16];
		textField.textColor = [UIColor colorWithRed:58.0/255.0 green:86.0/255.0 blue:138.0/255.0 alpha:1.0];
		CGSize textSize = [@"Ig" sizeWithFont:textField.font];
		frame = CGRectMake(boundsX + TITLE_LEFT_OFFSET + size.width, (height - textSize.height)/2, width - size.width - TITLE_LEFT_OFFSET, textSize.height);
		[textField setFrame:frame];
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

- (BOOL)respondsToSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"%s respondsToSelector: %s", __FILE__, selector);)
    return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"%s methodSignatureForSelector: %s", __FILE__, selector);)
    return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    VERY_VERBOSE(NSLog(@"%s forwardInvocation: %s", __FILE__, [invocation selector]);)
    [super forwardInvocation:invocation];
}



@end
