//
//  PSTextFieldCell.m
//  MyTime
//
//  Created by Brent Priddy on 12/29/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import "PSTextFieldCellController.h"

@interface PSTextFieldCellController ()
@property (nonatomic, retain, readwrite) UITextField *textField;
@end

@implementation PSTextFieldCellController
@synthesize textField;
@synthesize placeholder;
@synthesize returnKeyType;
@synthesize keyboardType;
@synthesize clearButtonMode;
@synthesize autocapitalizationType;
@synthesize obtainFocus;
@synthesize allTextFields;
@synthesize autocorrectionType;
@synthesize rightView;
@synthesize rightViewMode;
@synthesize allowSelectionWhenNotEditing;
@synthesize hideEmptyRowWhenNotEditing;
@synthesize scrollPosition;
- (id)init
{
	if( (self = [super init]) )
	{
		self.allowSelectionWhenNotEditing = YES;
	}
	return self;
}

- (void)dealloc
{
	if(self.textField)
	{
		self.textField.delegate = nil;
		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:UITextFieldTextDidChangeNotification
													  object:self.textField];
		
		[self.allTextFields removeObject:self.textField];
		self.textField = nil;
	}
	self.allTextFields = nil;
	self.placeholder = nil;
	self.rightView = nil;
	self.model = nil;
	self.modelPath = nil;
	
	[super dealloc];
}

- (BOOL)isViewableWhenNotEditing
{
	if(self.hideEmptyRowWhenNotEditing && [[self.model valueForKey:self.modelPath] length] == 0)
	{
		return NO;
	}
	return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(self.textField)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:UITextFieldTextDidChangeNotification
													  object:self.textField];
		
		[self.allTextFields removeObject:self.textField];
		if(self.rightView)
		{
			self.textField.rightView = nil;
		}
		self.textField = nil;
	}
	NSString *commonIdentifier = [[self class] description];
	UITableViewTextFieldCell *cell = (UITableViewTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	self.textField = cell.textField;
	
	if(self.rightView)
	{
		cell.textField.rightView = self.rightView;
		cell.textField.rightViewMode = self.rightViewMode;
	}
	cell.allowSelectionWhenEditing = self.allowSelectionWhenNotEditing;
	if(self.hideEmptyRowWhenNotEditing)
	{
		cell.observeEditing = YES;
	}
	
	cell.textField.placeholder = self.placeholder;
	cell.textField.returnKeyType = self.returnKeyType;
	cell.textField.clearButtonMode = self.clearButtonMode;
	cell.textField.autocapitalizationType = self.autocapitalizationType;
	cell.textField.autocorrectionType = self.autocorrectionType;
	cell.selectionStyle = self.selectionStyle;
	cell.nextKeyboardResponder = [self nextRowResponderForTableView:tableView indexPath:indexPath];

	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTextFieldChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self.textField];
	[self.allTextFields addObject:self.textField];
	cell.textField.text = [self.model valueForKeyPath:self.modelPath];
	if(self.title)
		cell.titleLabel.text = self.title;
	cell.delegate = self;
	if(self.obtainFocus)
	{
		[cell.textField performSelector:@selector(becomeFirstResponder)
							 withObject:nil
							 afterDelay:0.0000001];
		self.obtainFocus = NO;
	}
	
	return cell;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[[(UITableViewTextFieldCell *)[tableView cellForRowAtIndexPath:indexPath] textField] becomeFirstResponder];
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableViewTextFieldCell:(UITableViewTextFieldCell *)cell selected:(BOOL)selected
{
	// it is only house number and apartment cell that uses this one, so lets scroll to the middle so that we will scroll up if this cell is selected
	if(self.scrollPosition != UITableViewScrollPositionNone)
	{
		NSIndexPath *indexPath = [self.tableViewController.tableView indexPathForCell:cell];
		[self.tableViewController.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	}
}


- (void)handleTextFieldChanged:(NSNotification *)note 
{
	[self.model setValue:self.textField.text forKeyPath:self.modelPath];
	
	if(textChangedTarget_)
	{
		NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:[textChangedTarget_ methodSignatureForSelector:textChangedAction_]];
		[invocation setTarget:textChangedTarget_];
		[invocation setSelector:textChangedAction_];
		[invocation setArgument:&self atIndex:2];
		NSString *text = self.textField.text;
		[invocation setArgument:&text atIndex:3];
		[invocation invoke];
	}
}

- (void)setTextChangedTarget:(id)target action:(SEL)action
{
	textChangedTarget_ = target;
	textChangedAction_ = action;
}

@end
