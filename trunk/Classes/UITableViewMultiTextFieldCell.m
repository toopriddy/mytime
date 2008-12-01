#import "UITableViewMultiTextFieldCell.h"
#import "Settings.h"

#define TITLE_LEFT_OFFSET 10
#define TITLE_TOP_OFFSET 6
#define TITLE_HEIGHT 30

#define VALUE_TOP_OFFSET 6
#define VALUE_HEIGHT 30

@interface UITableViewMultiTextFieldCell ()
//@property (nonatomic,retain) UITableView *theTableView;
@property (nonatomic, retain) NSMutableArray *textFields;
//@property (nonatomic, retain) NSIndexPath *indexPath;
//@property (nonatomic, retain) UITableView *tableView;
@end


@implementation UITableViewMultiTextFieldCell

@synthesize textFields = _textFields;
@synthesize nextKeyboardResponder = _nextKeyboardResponder;
//@synthesize indexPath;
//@synthesize tableView;
@synthesize delegate;
@synthesize widths = _widths;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier textFieldCount:(int)textFieldCount
{
	if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) 
	{
		VERBOSE(NSLog(@"%s: %s %p", __FILE__, __FUNCTION__, self);)
		self.selected = NO;
		
//		tableView = nil;
//		indexPath = nil;
		self.textFields = [NSMutableArray array];
		int i;
		for(i = 0; i < textFieldCount; i++)
		{
			UITextField *textField = [[[UITextField alloc] initWithFrame:CGRectZero] autorelease];
			textField.backgroundColor = [UIColor clearColor];
			textField.font = [UIFont systemFontOfSize:16];
			textField.textColor = [UIColor colorWithRed:58.0/255.0 green:86.0/255.0 blue:138.0/255.0 alpha:1.0];
			textField.delegate = self;
			textField.returnKeyType = UIReturnKeyDone;
			[[_textFields lastObject] setReturnKeyType:UIReturnKeyNext];
			[_textFields addObject:textField];
			
			[self.contentView addSubview:textField];
		}
	}
	return self;
}

- (void)dealloc
{
    VERBOSE(NSLog(@"%s: %s %p", __FILE__, __FUNCTION__, self);)
	
	self.nextKeyboardResponder = nil;
	self.textFields = nil;
//	self.tableView = nil;
//	self.indexPath = nil;
	self.delegate = nil;
	[super dealloc];
}

- (void)setNextKeyboardResponder:(UIResponder *)next
{
	[[_textFields lastObject] setReturnKeyType:(next == NULL ? UIReturnKeyDone : UIReturnKeyNext)];
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
	if([_textFields indexOfObject:textField] + 1 == [_textFields count])
	{
		if(_nextKeyboardResponder)
		{
			[_nextKeyboardResponder becomeFirstResponder];
		}
	}
	else
	{
		[[_textFields objectAtIndex:[_textFields indexOfObject:textField] + 1] becomeFirstResponder];
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	if(selected)
	{
		[[_textFields objectAtIndex:0] becomeFirstResponder];
	}
	else
	{
		[[_textFields objectAtIndex:0] resignFirstResponder];
	}
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

	int count = [_textFields count];
	float avaliableWidth = width - (TITLE_LEFT_OFFSET * count);
	int i;
	for(i = 0; i < count; ++i)
	{
		UITextField *textField = [_textFields objectAtIndex:i];
		float thisWidth = avaliableWidth * [[_widths objectAtIndex:i] floatValue];
		CGSize textSize = [@"Ig" sizeWithFont:textField.font];
		frame = CGRectMake(xoffset, (height - textSize.height)/2, thisWidth, textSize.height);
		[textField setFrame:frame];
		xoffset += TITLE_LEFT_OFFSET + thisWidth;
	}
}

- (UITextField *)textFieldAtIndex:(int)index
{
	return [_textFields objectAtIndex:index];
}

- (void)setText:(NSString *)theText atIndex:(int)index
{
	[[_textFields objectAtIndex:index] setText:theText];
}

- (NSString *)textAtIndex:(int)index
{
	return [[_textFields objectAtIndex:index] text];
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
